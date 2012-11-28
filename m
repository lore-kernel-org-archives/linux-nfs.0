Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932294Ab2K1TyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 14:54:00 -0500
Message-ID: <50B66BD1.4080606@RedHat.com>
Date: Wed, 28 Nov 2012 14:53:53 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: Handle the target name correctly
References: <1354044186-38830-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1354044186-38830-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27/11/12 14:23, Trond Myklebust wrote:
> The target name contains a hostname in the realm that we are authenticating
> to. Since we may be authenticating to a different realm than the default
> realm for the server, we should not assume that the target name and host
> name point to the same string.
> In fact, the kernel NFS client will always use its own hostname as the
> target name, since it is always authenticating to its own default realm.
> On the other hand, the NFS server's callback channel will pass the hostname
> of the NFS client that it is authenticating too (Section 3.4, RFC3530).
> 
> This patch fixes the handling of the target name in process_krb5_upcall,
> and ensures that it gets passed to find_keytab_entry().
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Committed...

steved.
> ---
>  utils/gssd/gssd_proc.c |  9 ++-------
>  utils/gssd/krb5_util.c | 20 ++++++++++++++------
>  utils/gssd/krb5_util.h |  3 ++-
>  3 files changed, 18 insertions(+), 14 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index aa5bbb9..2fba7de 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -951,12 +951,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  
>  	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
>  
> -	if (tgtname) {
> -		if (clp->servicename) {
> -			free(clp->servicename);
> -			clp->servicename = strdup(tgtname);
> -		}
> -	}
>  	token.length = 0;
>  	token.value = NULL;
>  	memset(&pd, 0, sizeof(struct authgss_private_data));
> @@ -1005,7 +999,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  			int success = 0;
>  			do {
>  				gssd_refresh_krb5_machine_credential(clp->servername,
> -								     NULL, service);
> +								     NULL, service,
> +								     tgtname);
>  				/*
>  				 * Get a list of credential cache names and try each
>  				 * of them until one works or we've tried them all
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 60ba594..aeb8f70 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -774,12 +774,16 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>  }
>  
>  /*
> - * Find a keytab entry to use for a given target hostname.
> + * Find a keytab entry to use for a given target realm.
>   * Tries to find the most appropriate keytab to use given the
>   * name of the host we are trying to connect with.
> + *
> + * Note: the tgtname contains a hostname in the realm that we
> + * are authenticating to. It may, or may not be the same as
> + * the server hostname.
>   */
>  static int
> -find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
> +find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>  		  krb5_keytab_entry *kte, const char **svcnames)
>  {
>  	krb5_error_code code;
> @@ -795,7 +799,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
>  
>  
>  	/* Get full target hostname */
> -	retval = get_full_hostname(hostname, targethostname,
> +	retval = get_full_hostname(tgtname, targethostname,
>  				   sizeof(targethostname));
>  	if (retval)
>  		goto out;
> @@ -1128,7 +1132,7 @@ gssd_get_krb5_machine_cred_list(char ***list)
>  		if (ple->ccname) {
>  			/* Make sure cred is up-to-date before returning it */
>  			retval = gssd_refresh_krb5_machine_credential(NULL, ple,
> -				NULL);
> +				NULL, NULL);
>  			if (retval)
>  				continue;
>  			if (i + 1 > listsize) {
> @@ -1219,7 +1223,8 @@ gssd_destroy_krb5_machine_creds(void)
>  int
>  gssd_refresh_krb5_machine_credential(char *hostname,
>  				     struct gssd_k5_kt_princ *ple, 
> -					 char *service)
> +					 char *service,
> +					 char *tgtname)
>  {
>  	krb5_error_code code = 0;
>  	krb5_context context;
> @@ -1258,7 +1263,10 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  	if (ple == NULL) {
>  		krb5_keytab_entry kte;
>  
> -		code = find_keytab_entry(context, kt, hostname, &kte, svcnames);
> +		if (tgtname == NULL)
> +			tgtname = hostname;
> +
> +		code = find_keytab_entry(context, kt, tgtname, &kte, svcnames);
>  		if (code) {
>  			printerr(0, "ERROR: %s: no usable keytab entry found "
>  				 "in keytab %s for connection with host %s\n",
> diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
> index cd6e107..9f41625 100644
> --- a/utils/gssd/krb5_util.h
> +++ b/utils/gssd/krb5_util.h
> @@ -31,7 +31,8 @@ void gssd_setup_krb5_machine_gss_ccache(char *servername);
>  void gssd_destroy_krb5_machine_creds(void);
>  int  gssd_refresh_krb5_machine_credential(char *hostname,
>  					  struct gssd_k5_kt_princ *ple, 
> -					  char *service);
> +					  char *service,
> +					  char *tgtname);
>  char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
>  void gssd_k5_get_default_realm(char **def_realm);
>  
> 
