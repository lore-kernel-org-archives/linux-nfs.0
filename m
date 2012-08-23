Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079Ab2HWQe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Aug 2012 12:34:29 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7NGYTq9027300
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 12:34:29 -0400
Message-ID: <50365BC0.1090604@RedHat.com>
Date: Thu, 23 Aug 2012 12:35:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Nalin Dahyabhai <nalin@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] Use /run/user/${UID} instead of /run/user/${USER}
References: <20120821205232.GE9511@redhat.com>
In-Reply-To: <20120821205232.GE9511@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/21/2012 04:52 PM, Nalin Dahyabhai wrote:
> Newer versions of systemd create a /run/user/${UID} directory
> instead of the /run/user/${USER} directory, so switch to
> scanning for that.  To make the per-user directory bit a little
> less magical, change the default to incorporate a "%U", which
> gets dynamically expanded to the user's UID when needed.
> 
> Signed-off-by: Nalin Dahyabhai <nalin@redhat.com>
Committed...

steved.
> ---
>  utils/gssd/gssd.h      |  2 +-
>  utils/gssd/gssd.man    |  9 ++++++---
>  utils/gssd/gssd_proc.c | 36 ++----------------------------------
>  utils/gssd/krb5_util.c | 30 ++++++++++++++++++++++++++----
>  4 files changed, 35 insertions(+), 42 deletions(-)
> 
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 1d923d7..86472a1 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -45,7 +45,7 @@
>  #define DNOTIFY_SIGNAL		(SIGRTMIN + 3)
>  
>  #define GSSD_DEFAULT_CRED_DIR			"/tmp"
> -#define GSSD_USER_CRED_DIR			"/run/user"
> +#define GSSD_USER_CRED_DIR			"/run/user/%U"
>  #define GSSD_DEFAULT_CRED_PREFIX		"krb5cc"
>  #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
>  #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index d8138fa..c74b7e8 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -103,9 +103,12 @@ where to look for the rpc_pipefs filesystem.  The default value is
>  .B -d directory
>  Tells
>  .B rpc.gssd
> -where to look for Kerberos credential files.  The default value is "/tmp".
> -This can also be a colon separated list of directories to be searched
> -for Kerberos credential files.  Note that if machine credentials are being
> +where to look for Kerberos credential files.  The default value is
> +"/tmp:/run/user/%U".
> +This can also be a colon separated list of directories to be searched for
> +Kerberos credential files.  The sequence "%U", if used, is replaced with
> +the UID of the user for whom credentials are being searched.
> +Note that if machine credentials are being
>  stored in files, then the first directory on this list is where the
>  machine credentials are stored.
>  .TP
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index e393d59..336f3e9 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -937,23 +937,6 @@ int create_auth_rpc_client(struct clnt_info *clp,
>  	goto out;
>  }
>  
> -static char *
> -user_cachedir(char *dirname, uid_t uid)
> -{
> -	struct passwd *pw;
> -	char *ptr;
> -
> -	if ((pw = getpwuid(uid)) == NULL) {
> -		printerr(0, "user_cachedir: Failed to find '%d' uid"
> -			    " for cache directory\n");
> -		return NULL;
> -	}
> -	ptr = malloc(strlen(dirname)+strlen(pw->pw_name)+2);
> -	if (ptr)
> -		sprintf(ptr, "%s/%s", dirname, pw->pw_name);
> -
> -	return ptr;
> -}
>  /*
>   * this code uses the userland rpcsec gss library to create a krb5
>   * context on behalf of the kernel
> @@ -968,7 +951,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	gss_buffer_desc		token;
>  	char			**credlist = NULL;
>  	char			**ccname;
> -	char			**dirname, *dir, *userdir;
> +	char			**dirname;
>  	int			create_resp = -1;
>  	int			err, downcall_err = -EACCES;
>  
> @@ -1011,22 +994,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  				service == NULL)) {
>  		/* Tell krb5 gss which credentials cache to use */
>  		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
> -			/* See if the user name is needed */
> -			if (strncmp(*dirname, GSSD_USER_CRED_DIR, 
> -					strlen(GSSD_USER_CRED_DIR)) == 0) {
> -				userdir = user_cachedir(*dirname, uid);
> -				if (userdir == NULL) 
> -					continue;
> -				dir = userdir;
> -			} else
> -				dir = *dirname;
> -
> -			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, dir);
> -
> -			if (userdir) {
> -				free(userdir);
> -				userdir = NULL;
> -			}
> +			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
>  			if (err == -EKEYEXPIRED)
>  				downcall_err = -EKEYEXPIRED;
>  			else if (!err)
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 2389276..60ba594 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1036,16 +1036,38 @@ err_cache:
>   * Returns 0 if a ccache was found, and a non-zero error code otherwise.
>   */
>  int
> -gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirname)
> +gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
>  {
> -	char			buf[MAX_NETOBJ_SZ];
> +	char			buf[MAX_NETOBJ_SZ], dirname[PATH_MAX];
>  	const char		*cctype;
>  	struct dirent		*d;
> -	int			err;
> +	int			err, i, j;
>  
>  	printerr(2, "getting credentials for client with uid %u for "
>  		    "server %s\n", uid, servername);
> -	memset(buf, 0, sizeof(buf));
> +
> +	for (i = 0, j = 0; dirpattern[i] != '\0'; i++) {
> +		switch (dirpattern[i]) {
> +		case '%':
> +			switch (dirpattern[i + 1]) {
> +			case '%':
> +				dirname[j++] = dirpattern[i];
> +				i++;
> +				break;
> +			case 'U':
> +				j += sprintf(dirname + j, "%lu",
> +					     (unsigned long) uid);
> +				i++;
> +				break;
> +			}
> +			break;
> +		default:
> +			dirname[j++] = dirpattern[i];
> +			break;
> +		}
> +	}
> +	dirname[j] = '\0';
> +
>  	err = gssd_find_existing_krb5_ccache(uid, dirname, &cctype, &d);
>  	if (err)
>  		return err;
