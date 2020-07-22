# echo "requesting token"
# curl -u d0ba7196d0bd44ff863d0350ca858d44:kcqoweQHiqZWpTdtniwWorMz0LlKD66k -d grant_type=client_credentials https://us.battle.net/oauth/token > test.txt
# echo -e "token is " 
# cat test.txt
# python3 read_token.py

cat battle_tags.txt | while read line || [[ -n $line ]];
do
    echo $line
    # saves in profiles.txt
    curl -G "https://www.sc2ladder.com/api/player?query={${line}s}&limit={1}" > profiles.txt
done

python3 read_profiles.py






# python3 read_leon.py

# curl -X GET "https://us.api.blizzard.com/sc2/legacy/profile/1/1/5070029/matches?access_token=USUqIquBzDjvN03NuBuoo2t1XUqtNwI8G9"


