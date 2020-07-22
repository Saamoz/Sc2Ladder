<<<<<<< HEAD:read_token.py
import json
f = open('test.txt', 'r')
text = f.read()

request = json.loads(text)

print()
print(request)
token = request['access_token']
print("token is " + request['access_token'])

g = open('token.txt', 'w')
g.write(token)
=======
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
>>>>>>> 8b9137ceb5c2661ad08ef37d2b94faec5f2ee768:src/backend/read_token.py
