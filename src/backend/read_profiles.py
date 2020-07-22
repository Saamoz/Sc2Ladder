import json
f = open('profiles.txt', 'r')
text = f.read()

request = json.loads(text)

for player in request:
    print(player['profile_id'])

