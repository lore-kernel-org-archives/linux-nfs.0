Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab3JVI3a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 04:29:30 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9M8TTpg030676
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 04:29:30 -0400
Message-ID: <52663791.6020605@RedHat.com>
Date: Tue, 22 Oct 2013 04:30:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Tony Asleson <tasleson@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
In-Reply-To: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/10/13 19:29, Tony Asleson wrote:
> To improve error handling when scripting exportfs it's useful
> to have non-zero exit codes when the requested operation did not
> succeed.
> 
> This patch also returns a non-zero exit code if you request to
> unexport a non-existant share.
> 
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
Committed! 

steved.

> ---
>  support/export/hostname.c |  2 ++
>  utils/exportfs/exportfs.c | 37 +++++++++++++++++++++++++++----------
>  2 files changed, 29 insertions(+), 10 deletions(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 3e949a1..e53d692 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -175,10 +175,12 @@ host_addrinfo(const char *hostname)
>  	case 0:
>  		return ai;
>  	case EAI_SYSTEM:
> +		export_errno = errno;
>  		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
>  				__func__, hostname, errno);
>  		break;
>  	default:
> +		export_errno = EINVAL;
>  		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
>  				__func__, hostname, gai_strerror(error));
>  		break;
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 52fc03d..318deb3 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -35,8 +35,8 @@
>  #include "xlog.h"
>  
>  static void	export_all(int verbose);
> -static void	exportfs(char *arg, char *options, int verbose);
> -static void	unexportfs(char *arg, int verbose);
> +static int	exportfs(char *arg, char *options, int verbose);
> +static int	unexportfs(char *arg, int verbose);
>  static void	exports_update(int verbose);
>  static void	dump(int verbose, int export_format);
>  static void	error(nfs_export *exp, int err);
> @@ -187,8 +187,12 @@ main(int argc, char **argv)
>  		if (f_all)
>  			export_all(f_verbose);
>  		else
> -			for (i = optind; i < argc ; i++)
> -				exportfs(argv[i], options, f_verbose);
> +			for (i = optind; i < argc ; i++) {
> +				if(!exportfs(argv[i], options, f_verbose)) {
> +					/* Only flag a generic EINVAL if no errno is set */
> +					export_errno = (export_errno) ? export_errno : EINVAL;
> +				}
> +			}
>  	}
>  	/* If we are unexporting everything, then
>  	 * don't care about what should be exported, as that
> @@ -201,8 +205,12 @@ main(int argc, char **argv)
>  		if (!f_reexport)
>  			xtab_export_read();
>  		if (!f_export)
> -			for (i = optind ; i < argc ; i++)
> -				unexportfs(argv[i], f_verbose);
> +			for (i = optind ; i < argc ; i++) {
> +				if (!unexportfs(argv[i], f_verbose)) {
> +					/* Only flag a generic EINVAL if no errno is set */
> +					export_errno = (export_errno) ? export_errno : EINVAL;
> +				}
> +			}
>  		if (!new_cache)
>  			rmtab_read();
>  	}
> @@ -296,9 +304,10 @@ export_all(int verbose)
>  }
>  
>  
> -static void
> +static int
>  exportfs(char *arg, char *options, int verbose)
>  {
> +	int rc = 0;
>  	struct exportent *eep;
>  	nfs_export	*exp = NULL;
>  	struct addrinfo	*ai = NULL;
> @@ -311,7 +320,8 @@ exportfs(char *arg, char *options, int verbose)
>  
>  	if (!path || *path != '/') {
>  		xlog(L_ERROR, "Invalid exporting option: %s", arg);
> -		return;
> +		export_errno = EINVAL;
> +		return rc;
>  	}
>  
>  	if ((htype = client_gettype(hname)) == MCL_FQDN) {
> @@ -339,13 +349,16 @@ exportfs(char *arg, char *options, int verbose)
>  	exp->m_warned = 0;
>  	validate_export(exp);
>  
> +	rc = 1;
>  out:
>  	freeaddrinfo(ai);
> +	return rc;
>  }
>  
> -static void
> +static int
>  unexportfs(char *arg, int verbose)
>  {
> +	int rc = 0;
>  	nfs_export	*exp;
>  	struct addrinfo *ai = NULL;
>  	char		*path;
> @@ -357,7 +370,8 @@ unexportfs(char *arg, int verbose)
>  
>  	if (!path || *path != '/') {
>  		xlog(L_ERROR, "Invalid unexporting option: %s", arg);
> -		return;
> +		export_errno = EINVAL;
> +		return rc;
>  	}
>  
>  	if ((htype = client_gettype(hname)) == MCL_FQDN) {
> @@ -397,9 +411,11 @@ unexportfs(char *arg, int verbose)
>  #endif
>  		exp->m_xtabent = 0;
>  		exp->m_mayexport = 0;
> +		rc = 1;
>  	}
>  
>  	freeaddrinfo(ai);
> +	return rc;
>  }
>  
>  static int can_test(void)
> @@ -728,6 +744,7 @@ error(nfs_export *exp, int err)
>  {
>  	xlog(L_ERROR, "%s:%s: %s", exp->m_client->m_hostname,
>  		exp->m_export.e_path, strerror(err));
> +	export_errno = (export_errno) ? export_errno : err;
>  }
>  
>  static void
> 
