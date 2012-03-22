Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030385Ab2CVPJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 11:09:26 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2MF9QLX027055
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 11:09:26 -0400
Message-ID: <4F6B40A0.2040605@RedHat.com>
Date: Thu, 22 Mar 2012 11:09:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] gssd: Look for user creds in user defined directory
References: <1332363613-9930-1-git-send-email-steved@redhat.com>
In-Reply-To: <1332363613-9930-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2012 05:00 PM, Steve Dickson wrote:
> The user credential cache currently is kept in /tmp.
> In upcoming Kerberos release that will be moved to
> /run/user/<username>/. This patch enables gssd to
> look in both the old and new caches
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed....

steved.

> ---
>  utils/gssd/gssd.c      |    2 +-
>  utils/gssd/gssd.h      |    1 +
>  utils/gssd/gssd_proc.c |   36 ++++++++++++++++++++++++++++++++++--
>  3 files changed, 36 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index ccadb07..d53795e 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -57,7 +57,7 @@
>  
>  char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
>  char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
> -char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
> +char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
>  char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
>  int  use_memcache = 0;
>  int  root_uses_machine_creds = 1;
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 40f824c..28a8206 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -45,6 +45,7 @@
>  #define DNOTIFY_SIGNAL		(SIGRTMIN + 3)
>  
>  #define GSSD_DEFAULT_CRED_DIR			"/tmp"
> +#define GSSD_USER_CRED_DIR			"/run/user"
>  #define GSSD_DEFAULT_CRED_PREFIX		"krb5cc_"
>  #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
>  #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index a51dbae..aa39435 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -918,6 +918,23 @@ int create_auth_rpc_client(struct clnt_info *clp,
>  	goto out;
>  }
>  
> +static char *
> +user_cachedir(char *dirname, uid_t uid)
> +{
> +	struct passwd *pw;
> +	char *ptr;
> +
> +	if ((pw = getpwuid(uid)) == NULL) {
> +		printerr(0, "user_cachedir: Failed to find '%d' uid"
> +			    " for cache directory\n");
> +		return NULL;
> +	}
> +	ptr = malloc(strlen(dirname)+strlen(pw->pw_name)+2);
> +	if (ptr)
> +		sprintf(ptr, "%s/%s", dirname, pw->pw_name);
> +
> +	return ptr;
> +}
>  /*
>   * this code uses the userland rpcsec gss library to create a krb5
>   * context on behalf of the kernel
> @@ -932,7 +949,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	gss_buffer_desc		token;
>  	char			**credlist = NULL;
>  	char			**ccname;
> -	char			**dirname;
> +	char			**dirname, *dir, *userdir;
>  	int			create_resp = -1;
>  	int			err, downcall_err = -EACCES;
>  
> @@ -975,7 +992,22 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  				service == NULL)) {
>  		/* Tell krb5 gss which credentials cache to use */
>  		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
> -			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
> +			/* See if the user name is needed */
> +			if (strncmp(*dirname, GSSD_USER_CRED_DIR, 
> +					strlen(GSSD_USER_CRED_DIR)) == 0) {
> +				userdir = user_cachedir(*dirname, uid);
> +				if (userdir == NULL) 
> +					continue;
> +				dir = userdir;
> +			} else
> +				dir = *dirname;
> +
> +			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, dir);
> +
> +			if (userdir) {
> +				free(userdir);
> +				userdir = NULL;
> +			}
>  			if (err == -EKEYEXPIRED)
>  				downcall_err = -EKEYEXPIRED;
>  			else if (!err)
