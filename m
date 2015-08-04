Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19920 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbbHDOad convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 10:30:33 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 3/6] nfsidmap: List cached ID mapping results
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1AECCCCC-893E-4DD4-9415-EACC056AF724@oracle.com>
Date: Tue, 4 Aug 2015 10:30:24 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Message-Id: <110B6500-374B-47A6-A4CA-27F019339C44@oracle.com>
References: <20150731220914.50685.32887.stgit@seurat.1015granger.net> <20150731221355.50685.82639.stgit@seurat.1015granger.net> <55C0BE4D.4060709@RedHat.com> <1AECCCCC-893E-4DD4-9415-EACC056AF724@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 4, 2015, at 10:15 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Aug 4, 2015, at 9:29 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Hello,
>> 
>> On 07/31/2015 06:13 PM, Chuck Lever wrote:
>>> User space can see the keys, but not their contents.
>>> 
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> utils/nfsidmap/nfsidmap.c   |   85 ++++++++++++++++++++++++++++++++++++++++++-
>>> utils/nfsidmap/nfsidmap.man |   15 ++++++++
>>> 2 files changed, 98 insertions(+), 2 deletions(-)
>>> 
>>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>>> index 44b8b4b..ed397c6 100644
>>> --- a/utils/nfsidmap/nfsidmap.c
>>> +++ b/utils/nfsidmap/nfsidmap.c
>>> @@ -108,6 +108,81 @@ static int display_default_domain(void)
>>> 	return EXIT_SUCCESS;
>>> }
>>> 
>>> +static void list_key(key_serial_t key)
>>> +{
>>> +	char *buffer, *c;
>>> +	int rc;
>>> +
>>> +	rc = keyctl_describe_alloc(key, &buffer);
>>> +	if (rc < 0) {
>>> +		switch (errno) {
>>> +		case EKEYEXPIRED:
>>> +			printf("Expired key not displayed\n");
>>> +			break;
>>> +		default:
>>> +			xlog_err("Failed to describe key: %m");
>>> +		}
>>> +		return;
>>> +	}
>>> +
>>> +	c = strrchr(buffer, ';');
>>> +	if (!c) {
>>> +		xlog_err("Unparsable key not displayed\n");
>>> +		goto out_free;
>>> +	}
>>> +	printf("  %s\n", ++c);
>>> +
>>> +out_free:
>>> +	free(buffer);
>>> +}
>>> +
>>> +static void list_keys(const char *ring_name, key_serial_t ring_id)
>>> +{
>>> +	key_serial_t *key;
>>> +	void *keylist;
>>> +	int count;
>>> +
>>> +	count = keyctl_read_alloc(ring_id, &keylist);
>>> +	if (count < 0) {
>>> +		xlog_err("Failed to read keyring %s: %m", ring_name);
>>> +		return;
>>> +	}
>>> +	count /= (int)sizeof(*key);
>>> +
>>> +	switch (count) {
>>> +	case 0:
>>> +		printf("No %s keys found.\n", ring_name);
>>> +		break;
>>> +	case 1:
>>> +		printf("1 %s key found:\n", ring_name);
>>> +		break;
>>> +	default:
>>> +		printf("%u %s keys found:\n", count, ring_name);
>>> +	}
>>> +
>>> +	for (key = keylist; count--; key++)
>>> +		list_key(*key);
>>> +
>>> +	free(keylist);
>>> +}
>>> +
>>> +/*
>>> + * List all keys on a keyring
>>> + */
>>> +static int list_keyring(const char *keyring)
>>> +{
>>> +	key_serial_t key;
>>> +
>>> +	key = find_key_by_type_and_desc("keyring", keyring, 0);
>>> +	if (key == -1) {
>>> +		xlog_err("'%s' keyring was not found.", keyring);
>>> +		return EXIT_FAILURE;
>>> +	}
>>> +
>>> +	list_keys(keyring, key);
>>> +	return EXIT_SUCCESS;
>>> +}
>>> +
>>> /*
>>> * Find either a user or group id based on the name@domain string
>>> */
>>> @@ -277,7 +352,7 @@ int main(int argc, char **argv)
>>> 	int timeout = 600;
>>> 	key_serial_t key;
>>> 	char *progname, *keystr = NULL;
>>> -	int clearing = 0, keymask = 0, display = 0;
>>> +	int clearing = 0, keymask = 0, display = 0, list = 0;
>>> 
>>> 	/* Set the basename */
>>> 	if ((progname = strrchr(argv[0], '/')) != NULL)
>>> @@ -287,11 +362,14 @@ int main(int argc, char **argv)
>>> 
>>> 	xlog_open(progname);
>>> 
>>> -	while ((opt = getopt(argc, argv, "du:g:r:ct:v")) != -1) {
>>> +	while ((opt = getopt(argc, argv, "du:g:r:ct:vl")) != -1) {
>>> 		switch (opt) {
>>> 		case 'd':
>>> 			display++;
>>> 			break;
>>> +		case 'l':
>>> +			list++;
>>> +			break;
>>> 		case 'u':
>>> 			keymask = UIDKEYS;
>>> 			keystr = strdup(optarg);
>>> @@ -328,6 +406,9 @@ int main(int argc, char **argv)
>>> 
>>> 	if (display)
>>> 		return display_default_domain();
>>> +	else if (list)
>>> +		return list_keyring(DEFAULT_KEYRING);
>>> +
>> Just curious as to why the else clause... Are you
>> thinking it does not make sense to display the 
>> domain and list out the key ring?
> 
> Well, display already has a hard "return display_default_domain()".
> If you specify "-l" you're not getting anything else. The "else"

Sorry, I meant "if you specify "-d" you're not getting anything else."

> can probably be removed.
> 
> The idea is that "nfsidmap -l" or "nfsidmap -d" can be used
> in scripts too. In that context, specifying both would make
> parsing the output more difficult. And I think you would use
> these in different situations. "-l" might be used a lot. "-d"
> might be used once to check the configuration.
> 
> And IMO these new options should be careful to avoid updating
> or revoking any key, so the logic exits right there, as a
> defensive precaution.
> 
> We're overloading a kernel API here, after all. Maybe this kind
> of debugging belongs in a separate command. But this seems safe
> enough.
> 
> 
>> steved.
>> 
>>> 	if (keystr) {
>>> 		rc = key_invalidate(keystr, keymask);
>>> 		return rc;		
>>> diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
>>> index 04ddff6..0275bdf 100644
>>> --- a/utils/nfsidmap/nfsidmap.man
>>> +++ b/utils/nfsidmap/nfsidmap.man
>>> @@ -13,6 +13,8 @@ nfsidmap \- The NFS idmapper upcall program
>>> .B "nfsidmap [-v] [-u|-g|-r user]"
>>> .br
>>> .B "nfsidmap -d"
>>> +.br
>>> +.B "nfsidmap -l"
>>> .SH DESCRIPTION
>>> The NFSv4 protocol represents the local system's UID and GID values
>>> on the wire as strings of the form
>>> @@ -50,6 +52,13 @@ can also clear cached ID map results in the kernel,
>>> or revoke one particular key.
>>> An incorrect cached key can result in file and directory ownership
>>> reverting to "nobody" on NFSv4 mount points.
>>> +.PP
>>> +In addition, the
>>> +.B -d
>>> +and
>>> +.B -l
>>> +options are available to help diagnose misconfigurations.
>>> +They have no effect on the keyring containing ID mapping results.
>>> .SH OPTIONS
>>> .TP
>>> .B -c 
>>> @@ -62,6 +71,12 @@ Display the system's effective NFSv4 domain name on
>>> .B -g user
>>> Revoke the gid key of the given user.
>>> .TP
>>> +.B -l
>>> +Display on
>>> +.I stdout
>>> +all keys currently in the keyring used to cache ID mapping results.
>>> +These keys are visible only to the superuser.
>>> +.TP
>>> .B -r user
>>> Revoke both the uid and gid key of the given user.
>>> .TP
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



