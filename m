Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbaATWBr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 17:01:47 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0KM1ljJ030536
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:01:47 -0500
Message-ID: <52DD9D3A.70300@RedHat.com>
Date: Mon, 20 Jan 2014 17:03:38 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>, jlayton@redhat.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] Remove unused arguments
References: <1389931919-4801-1-git-send-email-simo@redhat.com> <1389977800-10922-1-git-send-email-simo@redhat.com> <1389977800-10922-2-git-send-email-simo@redhat.com> <1389977800-10922-3-git-send-email-simo@redhat.com>
In-Reply-To: <1389977800-10922-3-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/01/14 11:56, Simo Sorce wrote:
> The name variable is always set to NULL now in all callers, so just
> sto passing it around needlessly.
> The uid_t variable is not used at all, so chuck it out too.
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_proc.c |    2 +-
>  utils/gssd/krb5_util.c |   10 +++++-----
>  utils/gssd/krb5_util.h |    2 +-
>  3 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 2a6ea97135848eaf601bbed17e5b62cb77bd66b9..33cfeb2afd2ed6c6810dc39548b1a9da8daa8c37 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -1095,7 +1095,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  
>  		/* Tell krb5 gss which credentials cache to use */
>  		/* Try first to acquire credentials directly via GSSAPI */
> -		err = gssd_acquire_user_cred(uid, &gss_cred);
> +		err = gssd_acquire_user_cred(&gss_cred);
>  		if (!err)
>  			create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
>  							     AUTHTYPE_KRB5, gss_cred);
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 230b909b14d244f832c0b5dd62e600cf8db4f80b..208c72bc072bceecc81f591887603e274dc35d9b 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1359,12 +1359,12 @@ gssd_k5_get_default_realm(char **def_realm)
>  }
>  
>  static int
> -gssd_acquire_krb5_cred(gss_name_t name, gss_cred_id_t *gss_cred)
> +gssd_acquire_krb5_cred(gss_cred_id_t *gss_cred)
>  {
>  	OM_uint32 maj_stat, min_stat;
>  	gss_OID_set_desc desired_mechs = { 1, &krb5oid };
>  
> -	maj_stat = gss_acquire_cred(&min_stat, name, GSS_C_INDEFINITE,
> +	maj_stat = gss_acquire_cred(&min_stat, GSS_C_NO_NAME, GSS_C_INDEFINITE,
>  				    &desired_mechs, GSS_C_INITIATE,
>  				    gss_cred, NULL, NULL);
>  
> @@ -1379,12 +1379,12 @@ gssd_acquire_krb5_cred(gss_name_t name, gss_cred_id_t *gss_cred)
>  }
>  
>  int
> -gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
> +gssd_acquire_user_cred(gss_cred_id_t *gss_cred)
>  {
>  	OM_uint32 min_stat;
>  	int ret;
>  
> -	ret = gssd_acquire_krb5_cred(GSS_C_NO_NAME, gss_cred);
> +	ret = gssd_acquire_krb5_cred(gss_cred);
>  
>  	/* force validation of cred to check for expiry */
>  	if (ret == 0) {
> @@ -1423,7 +1423,7 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
>  	int err = -1;
>  
>  	if (sec->cred == GSS_C_NO_CREDENTIAL) {
> -		err = gssd_acquire_krb5_cred(GSS_C_NO_NAME, &sec->cred);
> +		err = gssd_acquire_krb5_cred(&sec->cred);
>  		if (err)
>  			return -1;
>  	}
> diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
> index 3f0723e05cb3fd24b8063941e715010b21db0515..a319588a61253420da1ba7f62124df6b74795eea 100644
> --- a/utils/gssd/krb5_util.h
> +++ b/utils/gssd/krb5_util.h
> @@ -35,7 +35,7 @@ int  gssd_refresh_krb5_machine_credential(char *hostname,
>  char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
>  void gssd_k5_get_default_realm(char **def_realm);
>  
> -int gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred);
> +int gssd_acquire_user_cred(gss_cred_id_t *gss_cred);
>  
>  #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
>  extern int limit_to_legacy_enctypes;
> 
