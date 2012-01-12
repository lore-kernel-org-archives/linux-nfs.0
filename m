Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634Ab2ALTyt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 14:54:49 -0500
Message-ID: <4F0F3A87.6010107@RedHat.com>
Date: Thu, 12 Jan 2012 14:54:47 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap: Purge the keyring when its full.
References: <1326383899-4358-1-git-send-email-steved@redhat.com> <1326396135.6198.9.camel@lade.trondhjem.org>
In-Reply-To: <1326396135.6198.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/12/2012 02:22 PM, Trond Myklebust wrote:
> On Thu, 2012-01-12 at 10:58 -0500, Steve Dickson wrote: 
>> When a key can not be added to a keyring because
>> the keyring is full, keyctl_instantiate() will fail
>> with the errno being set to -EDQUOT. To recover,
>> purge the keyring of all its keys and then try to
>> add the new key.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  utils/nfsidmap/nfsidmap.c |   14 ++++++++++++--
>>  1 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> index ce8cf3e..470f9d4 100644
>> --- a/utils/nfsidmap/nfsidmap.c
>> +++ b/utils/nfsidmap/nfsidmap.c
>> @@ -3,6 +3,7 @@
>>  #include <stdio.h>
>>  #include <stdlib.h>
>>  #include <string.h>
>> +#include <errno.h>
>>  
>>  #include <pwd.h>
>>  #include <grp.h>
>> @@ -25,6 +26,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
>>  #define DEFAULT_KEYRING "id_resolver"
>>  #endif
>>  
>> +static int keyring_clear(char *keyring);
>>  
>>  #define UIDKEYS 0x1
>>  #define GIDKEYS 0x2
>> @@ -52,6 +54,14 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
>>  
>>  	if (rc == 0) {
>>  		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
>> +		if (rc < 0 && errno == -EDQUOT) {
> 
> Shouldn't the above be a test for -ENFILE (or perhaps for both)?
Taking a look at the code, again, it appears -ENFILE is returned
when there is no room for the new key. -EDQUOT and -ENOMEM are 
returned when there is no memory for the payload data.

We might as well purge the keyring when we get any of those
error just to free up memory....

steved.

> 
>> +			/*
>> +			 * The keyring is full. Clear the keyring and try again
>> +			 */
>> +			rc = keyring_clear(DEFAULT_KEYRING);
>> +			if (rc == 0)
>> +				rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
>> +		}
>>  		if (rc < 0)
>>  			xlog_err("id_lookup: keyctl_instantiate failed: %m");
>>  	}
>> @@ -105,7 +115,6 @@ static int keyring_clear(char *keyring)
>>  	char buf[BUFSIZ];
>>  	key_serial_t key;
>>  
>> -	xlog_syslog(0);
>>  	if (keyring == NULL)
>>  		keyring = DEFAULT_KEYRING;
>>  
>> @@ -172,7 +181,7 @@ static int key_revoke(char *keystr, int keymask)
>>  		if ((keymask & mask) == 0)
>>  			continue;
>>  
>> -		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
>> +		if (strncmp(ptr+4, keystr, strlen(keystr)) != 0)
>>  			continue;
>>  
>>  		if (verbose) {
>> @@ -255,6 +264,7 @@ int main(int argc, char **argv)
>>  		return rc;		
>>  	}
>>  	if (clearing) {
>> +		xlog_syslog(0);
>>  		rc = keyring_clear(DEFAULT_KEYRING);
>>  		return rc;		
>>  	}
> 
