Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755897Ab2APTwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jan 2012 14:52:19 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0GJqJW2002105
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jan 2012 14:52:19 -0500
Message-ID: <4F147FF2.2060108@RedHat.com>
Date: Mon, 16 Jan 2012 14:52:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsidmap: Purge the keyring when its full.
References: <1326399314-31920-1-git-send-email-steved@redhat.com>
In-Reply-To: <1326399314-31920-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/12/2012 03:15 PM, Steve Dickson wrote:
> When a key can not be added to a keyring because
> the keyring is full or there is no memory for
> the playload, keyctl_instantiate() will fail
> and set the errno to -EDQUOT, -ENFILE or
> -ENOMEM
> 
> When this happens, purge the keyring to
> free things up and then try to re-add
> the key.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/nfsidmap/nfsidmap.c |   24 +++++++++++++++++++++---
>  1 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index ce8cf3e..cf11551 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -3,6 +3,7 @@
>  #include <stdio.h>
>  #include <stdlib.h>
>  #include <string.h>
> +#include <errno.h>
>  
>  #include <pwd.h>
>  #include <grp.h>
> @@ -25,6 +26,7 @@ char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
>  #define DEFAULT_KEYRING "id_resolver"
>  #endif
>  
> +static int keyring_clear(char *keyring);
>  
>  #define UIDKEYS 0x1
>  #define GIDKEYS 0x2
> @@ -52,6 +54,22 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
>  
>  	if (rc == 0) {
>  		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
> +		if (rc < 0) {
> +			switch(rc) {
> +			case -EDQUOT:
> +			case -ENFILE:
> +			case -ENOMEM:
> +				/*
> +			 	 * The keyring is full. Clear the keyring and try again
> +			 	 */
> +				rc = keyring_clear(DEFAULT_KEYRING);
> +				if (rc == 0)
> +					rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
> +				break;
> +			default:
> +				break;
> +			}
> +		}
>  		if (rc < 0)
>  			xlog_err("id_lookup: keyctl_instantiate failed: %m");
>  	}
> @@ -105,7 +123,6 @@ static int keyring_clear(char *keyring)
>  	char buf[BUFSIZ];
>  	key_serial_t key;
>  
> -	xlog_syslog(0);
>  	if (keyring == NULL)
>  		keyring = DEFAULT_KEYRING;
>  
> @@ -172,7 +189,7 @@ static int key_revoke(char *keystr, int keymask)
>  		if ((keymask & mask) == 0)
>  			continue;
>  
> -		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
> +		if (strncmp(ptr+4, keystr, strlen(keystr)) != 0)
>  			continue;
>  
>  		if (verbose) {
> @@ -255,6 +272,7 @@ int main(int argc, char **argv)
>  		return rc;		
>  	}
>  	if (clearing) {
> +		xlog_syslog(0);
>  		rc = keyring_clear(DEFAULT_KEYRING);
>  		return rc;		
>  	}
> @@ -280,7 +298,7 @@ int main(int argc, char **argv)
>  	value = strtok(NULL, ":");
>  
>  	if (verbose) {
> -		xlog_warn("key: %ld type: %s value: %s timeout %ld",
> +		xlog_warn("key: 0x%lx type: %s value: %s timeout %ld",
>  			key, type, value, timeout);
>  	}
>  
