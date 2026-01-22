import sys
import os
import argparse
from mailmanclient import Client

# Creates a List in mailman3 with some default settings.
# This is meant to be ran on the mailman3 server.

api_url = 'http://localhost:8001/3.1'
default_domain = 'example.com'

parser = argparse.ArgumentParser(
    prog='create_listserv',
    description='Create a list with default settings.'
)

parser.add_argument('listserv_name')
parser.add_argument('owners', nargs='+')
args = parser.parse_args()

listserv_name = args.listserv_name
owners = args.owners

print('Connecting to the local REST API...')
client = Client(api_url, 'restadmin', os.environ['REST_PASS'])

print(f"Creating ListServ '{listserv_name}@{default_domain}'...")
domain = client.get_domain(default_domain)
new_listserv = domain.create_list(listserv_name)

print(f"Setting owners for '{new_listserv.email}")
for owner in owners:
    new_listserv.add_owner(owner)
    new_listserv.subscribe(owner, pre_confirmed=True, pre_verified=True)
    member = new_listserv.get_member(owner)
    member.moderation_action = 'accept'
    member.save()

#new_listserv.settings['default_member_action'] = 'discard'
#new_listserv.settings['default_nonmember_action'] = 'discard'
new_listserv.settings['dmarc_mitigate_action'] = 'munge_from'
new_listserv.settings['dmarc_mitigate_unconditionally'] = True
new_listserv.settings['first_strip_reply_to'] = True
new_listserv.settings['max_message_size'] = 25000
new_listserv.settings['max_num_recipients'] = 0
new_listserv.settings['reply_goes_to_list'] = 'point_to_list'
new_listserv.settings.save()

print('Complete :)')