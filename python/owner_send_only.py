import os
import argparse
from mailmanclient import Client

parser = argparse.ArgumentParser(
    prog='owner_send_only',
    description='Set the specified listserv so only owners may send.'
)

parser.add_argument('listserv')
args = parser.parse_args()

api_url = 'http://localhost:8001/3.1'
listserv_name = args.listserv

print('Connecting to local REST API...')
client = Client(api_url, 'restadmin', os.environ['REST_PASS'])

print('Getting ListServ settings...')
listserv = client.get_list(listserv_name)

print('Getting owners...')
for owner in listserv.owners:
    member = listserv.get_member(owner.email)
    member.moderation_action = 'accept'
    member.save()
    print(f'Setting owner {owner.email} member moderation to {member.moderation_action}.')

print('Setting Listserv moderation defaults to discard...')
listserv.settings['default_member_action'] = 'discard'
listserv.settings['default_nonmember_action'] = 'discard'
listserv.settings.save()

print('Complete :)')