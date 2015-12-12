Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbbLLMLc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Dec 2015 07:11:32 -0500
Subject: Re: [PATCH] nfsidmap: keyring_clear() should succeed if id_resolver
 keyring not found
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151202212010.5614.82182.stgit@manet.1015granger.net>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <566C0EF3.2030606@RedHat.com>
Date: Sat, 12 Dec 2015 07:11:31 -0500
MIME-Version: 1.0
In-Reply-To: <20151202212010.5614.82182.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2015 04:20 PM, Chuck Lever wrote:
> root#nfsvmb10:~# nfsidmap -c
> nfsidmap: 'id_resolver' keyring was not found.
> root#nfsvmb10:~# echo $?
> 1
> 
> If the id_resolver keyring doesn't exist, the kernel has no cached
> idmap information to expunge. AFAIK it's not an error.
> 
> If nfsidmap is run by a non-privileged user, the id_resolver keyring
> is never visible. IMO that should be reported, but the error message
> should report the privilege problem, not the missing keyring.
> 
> Reported-by: Amy Shi <amy.shi@oracle.com>
> Fixes: 69aa69e7de80 ('nfsidmap: Allow keys to be cleared from the ')
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  utils/nfsidmap/nfsidmap.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index 507193b..15b4a51 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -80,8 +80,9 @@ static int keyring_clear(const char *keyring)
>  
>  	key = find_key_by_type_and_desc("keyring", keyring, 0);
>  	if (key == -1) {
> -		xlog_err("'%s' keyring was not found.", keyring);
> -		return EXIT_FAILURE;
> +		if (verbose)
> +			xlog_warn("'%s' keyring was not found.", keyring);
> +		return EXIT_SUCCESS;
>  	}
>  
>  	if (keyctl_clear(key) < 0) {
> @@ -89,10 +90,9 @@ static int keyring_clear(const char *keyring)
>  				(unsigned int)key);
>  		return EXIT_FAILURE;
>  	}
> -	
> +
>  	if (verbose)
>  		xlog_warn("'%s' cleared", keyring);
> -
>  	return EXIT_SUCCESS;
>  }
>  
> @@ -404,6 +404,11 @@ int main(int argc, char **argv)
>  		}
>  	}
>  
> +	if (geteuid() != 0) {
> +		xlog_err("Must be run as root.");
> +		return EXIT_FAILURE;
> +	}
> +
>  	if ((rc = nfs4_init_name_mapping(PATH_IDMAPDCONF)))  {
>  		xlog_errno(rc, "Unable to create name to user id mappings.");
>  		return EXIT_FAILURE;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
