Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754549Ab3IXTRH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 15:17:07 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r8OJH7X0020131
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Sep 2013 15:17:07 -0400
Message-ID: <5241E54F.2020507@RedHat.com>
Date: Tue, 24 Sep 2013 15:17:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCHv2 2/3] gssd: don't use tgtname to find our keytab
References: <1379624239-31199-2-git-send-email-bfields@redhat.com> <1379624632-31476-1-git-send-email-bfields@redhat.com> <1379624632-31476-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1379624632-31476-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/09/13 17:03, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The tgtname is of the form service@hostname.  It's not a hostname, and
> attempting to look it up here just causes failure of any upcall with a
> "target=" field (currently, any upcall on behalf of an nfsv4.0
> callback).
> 
> I think the theory was that knowning that target= name might help pick
> the right keytab, but I don't really know if that's helpful.  For now,
> just stop trying to do this.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed....

steved.

> ---
>  utils/gssd/gssd_proc.c |  3 +--
>  utils/gssd/krb5_util.c | 10 +++-------
>  utils/gssd/krb5_util.h |  3 +--
>  3 files changed, 5 insertions(+), 11 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 0383883..7200a78 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -1035,8 +1035,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  			int success = 0;
>  			do {
>  				gssd_refresh_krb5_machine_credential(clp->servername,
> -								     NULL, service,
> -								     tgtname);
> +								     NULL, service);
>  				/*
>  				 * Get a list of credential cache names and try each
>  				 * of them until one works or we've tried them all
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 83b9651..c6e52fd 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1149,7 +1149,7 @@ gssd_get_krb5_machine_cred_list(char ***list)
>  		if (ple->ccname) {
>  			/* Make sure cred is up-to-date before returning it */
>  			retval = gssd_refresh_krb5_machine_credential(NULL, ple,
> -				NULL, NULL);
> +				NULL);
>  			if (retval)
>  				continue;
>  			if (i + 1 > listsize) {
> @@ -1240,8 +1240,7 @@ gssd_destroy_krb5_machine_creds(void)
>  int
>  gssd_refresh_krb5_machine_credential(char *hostname,
>  				     struct gssd_k5_kt_princ *ple, 
> -					 char *service,
> -					 char *tgtname)
> +					 char *service)
>  {
>  	krb5_error_code code = 0;
>  	krb5_context context;
> @@ -1280,10 +1279,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  	if (ple == NULL) {
>  		krb5_keytab_entry kte;
>  
> -		if (tgtname == NULL)
> -			tgtname = hostname;
> -
> -		code = find_keytab_entry(context, kt, tgtname, &kte, svcnames);
> +		code = find_keytab_entry(context, kt, hostname, &kte, svcnames);
>  		if (code) {
>  			printerr(0, "ERROR: %s: no usable keytab entry found "
>  				 "in keytab %s for connection with host %s\n",
> diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
> index eed1294..3f0723e 100644
> --- a/utils/gssd/krb5_util.h
> +++ b/utils/gssd/krb5_util.h
> @@ -31,8 +31,7 @@ void gssd_setup_krb5_machine_gss_ccache(char *servername);
>  void gssd_destroy_krb5_machine_creds(void);
>  int  gssd_refresh_krb5_machine_credential(char *hostname,
>  					  struct gssd_k5_kt_princ *ple, 
> -					  char *service,
> -					  char *tgtname);
> +					  char *service);
>  char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
>  void gssd_k5_get_default_realm(char **def_realm);
>  
> 
