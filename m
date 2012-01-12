Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:54480 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926Ab2ALTWQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 14:22:16 -0500
Message-ID: <1326396135.6198.9.camel@lade.trondhjem.org>
Subject: Re: [PATCH] nfsidmap: Purge the keyring when its full.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 12 Jan 2012 14:22:15 -0500
In-Reply-To: <1326383899-4358-1-git-send-email-steved@redhat.com>
References: <1326383899-4358-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-01-12 at 10:58 -0500, Steve Dickson wrote: 
> When a key can not be added to a keyring because
> the keyring is full, keyctl_instantiate() will fail
> with the errno being set to -EDQUOT. To recover,
> purge the keyring of all its keys and then try to
> add the new key.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/nfsidmap/nfsidmap.c |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index ce8cf3e..470f9d4 100644
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
> @@ -52,6 +54,14 @@ int id_lookup(char *name_at_domain, key_serial_t key, int type)
>  
>  	if (rc == 0) {
>  		rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
> +		if (rc < 0 && errno == -EDQUOT) {

Shouldn't the above be a test for -ENFILE (or perhaps for both)?

> +			/*
> +			 * The keyring is full. Clear the keyring and try again
> +			 */
> +			rc = keyring_clear(DEFAULT_KEYRING);
> +			if (rc == 0)
> +				rc = keyctl_instantiate(key, id, strlen(id) + 1, 0);
> +		}
>  		if (rc < 0)
>  			xlog_err("id_lookup: keyctl_instantiate failed: %m");
>  	}
> @@ -105,7 +115,6 @@ static int keyring_clear(char *keyring)
>  	char buf[BUFSIZ];
>  	key_serial_t key;
>  
> -	xlog_syslog(0);
>  	if (keyring == NULL)
>  		keyring = DEFAULT_KEYRING;
>  
> @@ -172,7 +181,7 @@ static int key_revoke(char *keystr, int keymask)
>  		if ((keymask & mask) == 0)
>  			continue;
>  
> -		if (strncmp(ptr+4, keystr, strlen(keystr)) != NULL)
> +		if (strncmp(ptr+4, keystr, strlen(keystr)) != 0)
>  			continue;
>  
>  		if (verbose) {
> @@ -255,6 +264,7 @@ int main(int argc, char **argv)
>  		return rc;		
>  	}
>  	if (clearing) {
> +		xlog_syslog(0);
>  		rc = keyring_clear(DEFAULT_KEYRING);
>  		return rc;		
>  	}

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

