using Revise # lets you change A2funcs without restarting julia!
includet("A2_src.jl")
using Plots
using Statistics: mean
using Zygote
using Test
using Logging
using LinearAlgebra
using Distributions
using .A2funcs: log1pexp # log(1 + exp(x)) stable
using .A2funcs: factorized_gaussian_log_density
using .A2funcs: skillcontour!
using .A2funcs: plot_line_equal_skill!

function log_prior(zs)
  return factorized_gaussian_log_density(0, 0, zs)
end

function logp_a_beats_b(za,zb)
  return -log1pexp(zb - za)
end

function all_games_log_likelihood(zs,games)
  zs_a = zs[games[:,1],:]
  zs_b = zs[games[:,2],:]
  likelihoods = logp_a_beats_b.(zs_a, zs_b)
  return  sum(likelihoods, dims=1)
end

function joint_log_density(zs,games)
  return all_games_log_likelihood(zs,games) + log_prior(zs)
end

@testset "Test shapes of batches for likelihoods" begin
  B = 15 # number of elements in batch
  N = 4 # Total Number of Players
  test_zs = randn(4,15)
  test_games = [1 2; 3 1; 4 2] # 1 beat 2, 3 beat 1, 4 beat 2
  @test size(test_zs) == (N,B)
  #batch of priors
  @test size(log_prior(test_zs)) == (1,B)
  # loglikelihood of p1 beat p2 for first sample in batch
  @test size(logp_a_beats_b(test_zs[1,1],test_zs[2,1])) == ()
  # loglikelihood of p1 beat p2 broadcasted over whole batch
  @test size(logp_a_beats_b.(test_zs[1,:],test_zs[2,:])) == (B,)
  # batch loglikelihood for evidence
  @test size(all_games_log_likelihood(test_zs,test_games)) == (1,B)
  # batch loglikelihood under joint of evidence and prior
  @test size(joint_log_density(test_zs,test_games)) == (1,B)
end

# Convenience function for producing toy games between two players.
two_player_toy_games(p1_wins, p2_wins) = vcat([repeat([1,2]',p1_wins), repeat([2,1]',p2_wins)]...)

# Example for how to use contour plotting code
plot(title="Example Gaussian Contour Plot",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
example_gaussian(zs) = exp(factorized_gaussian_log_density([-1.,2.],[0.,0.5],zs))
skillcontour!(example_gaussian)
plot_line_equal_skill!()
savefig(joinpath("plots","example_gaussian.pdf"))

plot(title="Prior Gaussian Contour Plot",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
prior_gaussian(zs) = exp(log_prior(zs))
skillcontour!(prior_gaussian)
plot_line_equal_skill!()

plot(title="Likelihood Gaussian Contour Plot",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
likelihood_gaussian(zs) = exp(all_games_log_likelihood(zs, two_player_toy_games(1, 1)))
skillcontour!(likelihood_gaussian)
plot_line_equal_skill!()

plot(title="Joint Gaussian Contour Plot - A wins 1",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
joint_gaussian_A1(zs) = exp(joint_log_density(zs, two_player_toy_games(1, 0)))
skillcontour!(joint_gaussian_A1)
plot_line_equal_skill!()

plot(title="Joint Gaussian Contour Plot - A wins 10",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
joint_gaussian_A10(zs) = exp(joint_log_density(zs, two_player_toy_games(10, 0)))
skillcontour!(joint_gaussian_A10)
plot_line_equal_skill!()

plot(title="Joint Gaussian Contour Plot - Both win 10",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   )
joint_gaussian_A10B10(zs) = exp(joint_log_density(zs, two_player_toy_games(10, 10)))
skillcontour!(joint_gaussian_A10B10)
plot_line_equal_skill!()

function elbo(params,logp,num_samples)
  N = length(params[1])
  samples = (randn(N, num_samples) .* exp.(params[2])) .+ params[1]
  logp_estimate = logp(samples)
  logq_estimate = factorized_gaussian_log_density(params[1], params[2], samples)
  return mean(logp_estimate - logq_estimate)
end

# Conveinence function for taking gradients
function neg_toy_elbo(params; games = two_player_toy_games(1,0), num_samples = 100)
  logp(zs) = joint_log_density(zs,games)
  return -elbo(params,logp, num_samples)
end


# Toy game
num_players_toy = 2
toy_mu = [-2.,3.] # Initial mu, can initialize randomly!
toy_ls = [0.5,0.] # Initual log_sigma, can initialize randomly!
toy_params_init = (toy_mu, toy_ls)

function fit_toy_variational_dist(init_params, toy_evidence; num_itrs=200, lr= 1e-2, num_q_samples = 10)
  params_cur = init_params
  for i in 1:num_itrs
    grad_params = gradient((params)->neg_toy_elbo(params,
              games=toy_evidence, num_samples=num_q_samples), params_cur)[1]

    params_cur =  params_cur .- (lr .* grad_params)
    @info neg_toy_elbo(params_cur, games=toy_evidence, num_samples=num_q_samples)
    plot();
    p(zs) = exp(joint_log_density(zs,toy_evidence))
    skillcontour!(p,colour=:red) # plot likelihood contours for target posterior
    plot_line_equal_skill!()
    q(zs) = exp(factorized_gaussian_log_density(params_cur[1], params_cur[2], zs))
    # display(skillcontour!(q, colour=:blue)) # plot likelihood contours for variational posterior
  end
  return params_cur
end

games = two_player_toy_games(1, 0)
fitted_A1_params = fit_toy_variational_dist(toy_params_init, games)
plot(title="Variational Gaussian Contour Plot - A wins 1",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   );
p(zs) = exp(joint_log_density(zs,games))
skillcontour!(p,colour=:red) # plot likelihood contours for target posterior
plot_line_equal_skill!()
q(zs) = exp(factorized_gaussian_log_density(fitted_A1_params[1], fitted_A1_params[2], zs))
skillcontour!(q, colour=:blue)

games = two_player_toy_games(10, 0)
fitted_A10_params = fit_toy_variational_dist(toy_params_init, games)
plot(title="Variational Gaussian Contour Plot - A wins 10",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   );
p(zs) = exp(joint_log_density(zs,games))
skillcontour!(p,colour=:red) # plot likelihood contours for target posterior
plot_line_equal_skill!()
q(zs) = exp(factorized_gaussian_log_density(fitted_A10_params[1], fitted_A10_params[2], zs))
skillcontour!(q, colour=:blue)

games = two_player_toy_games(10, 10)
fitted_A10B10_params = fit_toy_variational_dist(toy_params_init, games)
plot(title="Variational Gaussian Contour Plot - Both win 10",
    xlabel = "Player 1 Skill",
    ylabel = "Player 2 Skill"
   );
p(zs) = exp(joint_log_density(zs,games))
skillcontour!(p,colour=:red) # plot likelihood contours for target posterior
plot_line_equal_skill!()
q(zs) = exp(factorized_gaussian_log_density(fitted_A10B10_params[1], fitted_A10B10_params[2], zs))
skillcontour!(q, colour=:blue)

## Question 4
# Load the Data
using MAT
vars = matread("tennis_data.mat")
player_names = vars["W"]
tennis_games = Int.(vars["G"])
num_players = length(player_names)
print("Loaded data for $num_players players")


function fit_variational_dist(init_params, tennis_games; num_itrs=200, lr= 1e-2, num_q_samples = 10)
  params_cur = init_params
  for i in 1:num_itrs
    grad_params = gradient((params)->neg_toy_elbo(params,
              games=tennis_games, num_samples=num_q_samples), params_cur)[1]

    params_cur =  params_cur .- (lr .* grad_params)
    @info neg_toy_elbo(params_cur, games=tennis_games, num_samples=num_q_samples)
  end
  return params_cur
end

init_mu = randn(length(player_names))
init_log_sigma = randn(length(player_names))
init_params = (init_mu, init_log_sigma)

# Train variational distribution
trained_params = fit_variational_dist(init_params, tennis_games)

perm = sortperm(trained_params[1])
plot(trained_params[1][perm], yerror=exp.(trained_params[2][perm]))

#TODO: 10 players with highest mean skill under variational model
print(player_names[perm][end-9:end])

#TODO: joint posterior over "Roger-Federer" and ""Rafael-Nadal""
rog_index = findall(x->x=="Roger-Federer", player_names)
raf_index = findall(x->x=="Rafael-Nadal", player_names)

plot(legend=:topleft,
    title="Approximate Posterior of Skills of Federer and Nadal",
    xlabel = "Roger Federer Skill",
    ylabel = "Rafael Nadal Skill"
   );
means = [trained_params[1][rog_index]; trained_params[1][raf_index]]
logsigs = [trained_params[2][rog_index]; trained_params[2][raf_index]]

dist(zs) = exp.(factorized_gaussian_log_density(means, logsigs, zs))
skillcontour!(dist)
plot_line_equal_skill!()

function transform_skills(mu, logsig)
  A = [1 -1; 0 1]
  ya = mu[1] - mu[2]
  sig = Diagonal(exp.(logsig))
  cov = A * sig * A'
  var = sqrt(cov[1])
  threshold = -ya/var
  return 1 - cdf(Normal(0, 1), threshold)
end

function monte_carlo(mu, logsigs)
  num_samples = 10000
  samples = (randn(2, num_samples) .* exp.(logsigs)) .+ mu
  diff = samples[1,:] - samples[2,:]
  return count(x -> x > 0, diff)/num_samples
end
