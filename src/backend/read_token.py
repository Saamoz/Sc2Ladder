import json

f = open('test.json', 'r')
text = f.read()

request = json.loads(text)

print()
print(request)
token = request['access_token']
print("token is " + request['access_token'])

g = open('token.txt', 'w')
g.write(token)
