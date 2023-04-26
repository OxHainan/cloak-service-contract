import json

challengeTEE = dict()
acknowledge = dict()
failNegotiation = dict()
challengeParties = dict()
partyResponse = dict()
punishParties = dict()
punishTEE = dict()
f = open('./data/data.txt', 'r')
line = f.readline()
while line:
    j = json.loads(line)
    if (j['name'] == 'challengeTEE'):
        challengeTEE[j['n']] = j['gasUsed']
    elif (j['name'] == 'acknowledge'):
        acknowledge[j['n']] = j['gasUsed']
    elif (j['name'] == 'failNegotiation'):
        failNegotiation[j['n']] = j['gasUsed']
    elif (j['name'] == 'challengeParties'):
        challengeParties[j['n']] = j['gasUsed']
    elif (j['name'] == 'partyResponse'):
        partyResponse[j['n']] = j['gasUsed']
    elif (j['name'] == 'punishParties'):
        punishParties[j['n']] = j['gasUsed']
    elif (j['name'] == 'punishTEE'):
        punishTEE[j['n']] = j['gasUsed']
    line = f.readline()
f.close()

for keys in challengeTEE:
    print("mpt: %s" %keys)
    print("challengeTEE gas used: %d" %challengeTEE[keys])
    print("response merge gas used: %d" %acknowledge[keys])
    print("failNegotiation gas used: %d" %failNegotiation[keys])
    print("challengeParties gas used: %d" %challengeParties[keys])
    print("partyResponse gas used: %d" %partyResponse[keys])
    print("punishParties gas used: %d" %punishParties[keys])
    print("punishTEE gas used: %d" %punishTEE[keys])