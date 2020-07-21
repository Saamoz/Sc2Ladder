echo "requesting token"
curl -u d0ba7196d0bd44ff863d0350ca858d44:kcqoweQHiqZWpTdtniwWorMz0LlKD66k -d grant_type=client_credentials https://us.battle.net/oauth/token > test.txt
echo -e "token is " 
cat test.txt
python3 read_token.py

curl -H "Authorization: Bearer USp7j10raM6lSLHQj8N8twPQBiNUmMg5S2" http://us.battle.net/api/data/sc2/token/?namespace=dynamic-us

curl -X GET 'https://us.battle.net/oauth/userinfo' -H 'Authorization: Bearer USp7j10raM6lSLHQj8N8twPQBiNUmMg5S2' > output.html