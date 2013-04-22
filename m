Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840Ab3DVRH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 13:07:29 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3MH7Tm6000320
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Apr 2013 13:07:29 -0400
Message-ID: <51756E4F.2010907@RedHat.com>
Date: Mon, 22 Apr 2013 13:07:27 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        =?ISO-8859-1?Q?G=FCnther_Deschner?= <gdeschner@redhat.com>
Subject: Re: [PATCH] Allow GSSAPI to try to acquire credentials first.
References: <1365605450-3009-1-git-send-email-simo@redhat.com>
In-Reply-To: <1365605450-3009-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/04/13 10:50, Simo Sorce wrote:
> GSSAPI can be given a uid number as a special name, and then
> gss_acquire_cred() can use the name to try to find credentials for
> the user.
> 
> Give GSSAPI a chance to do it on its own, then fallback to the classic
> method of trolling through the file system to find a credential cache.
> 
> This patch uses a little know feature of GSSAPI that permits to acquire
> crdentials specifying the user's UID. Normally GSSAPI will simply perform
> a getpwuid() call and use the user name to generate a principal name and
> then see if it can find a TGT for that principal in the local ccache.
> 
> This feature is vital to allow the GSS-Proxy to be able to initiate crdentials
> on behalf of rpc.gssd using client keytabs stored in the filsystem.
> 
> GSS-Proxy works through an interposer-type plugin (new feature in MIT 1.11)
> that allows to intercept all GSSAPI requestes and relay them to a system
> daemon via a socket. This daemon (GSS-Proxy) then can perform operations on
> behalf of other applications with additional logic.
> 
> In the rpc.gssd case the GSS-Proxy daemon allows applications running as
> system users to properly access krb5 protected shares by creating a credential
> cache on the fly when necessary.
> 
> This way all applications that need access to krb5 protected shares do not need
> to be taught how to initiate crdentials on their own, nor they need to be
> wrapped in additional init scripts like k5start or use wasteful cronjobs to
> keep credentials fresh. All is needed is to drop a keytab with the right keys
> in a special location on the system and gss-proxy will do the rest.
> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
Committed 

steved.
> ---
>  utils/gssd/gssd_proc.c | 22 ++++++++++-----
>  utils/gssd/krb5_util.c | 77 +++++++++++++++++++++++++++++++++++++-------------
>  utils/gssd/krb5_util.h |  2 ++
>  3 files changed, 75 insertions(+), 26 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b1239785500f8e1bc601e4033a5f212c5b5b6c76..afc2076cde74e3cea6764408ec839a6f99b86ea4 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -817,7 +817,8 @@ create_auth_rpc_client(struct clnt_info *clp,
>  		       CLIENT **clnt_return,
>  		       AUTH **auth_return,
>  		       uid_t uid,
> -		       int authtype)
> +		       int authtype,
> +		       gss_cred_id_t cred)
>  {
>  	CLIENT			*rpc_clnt = NULL;
>  	struct rpc_gss_sec	sec;
> @@ -843,7 +844,7 @@ create_auth_rpc_client(struct clnt_info *clp,
>  
>  	sec.qop = GSS_C_QOP_DEFAULT;
>  	sec.svc = RPCSEC_GSS_SVC_NONE;
> -	sec.cred = GSS_C_NO_CREDENTIAL;
> +	sec.cred = cred;
>  	sec.req_flags = 0;
>  	if (authtype == AUTHTYPE_KRB5) {
>  		sec.mech = (gss_OID)&krb5oid;
> @@ -968,6 +969,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	char			**dirname;
>  	int			create_resp = -1;
>  	int			err, downcall_err = -EACCES;
> +	gss_cred_id_t		gss_cred;
>  	OM_uint32		maj_stat, min_stat, lifetime_rec;
>  
>  	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
> @@ -1002,15 +1004,20 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
>  				service == NULL)) {
>  		/* Tell krb5 gss which credentials cache to use */
> -		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
> +		/* Try first to acquire credentials directly via GSSAPI */
> +		err = gssd_acquire_user_cred(uid, &gss_cred);
> +		if (!err)
> +			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> +							     AUTHTYPE_KRB5, gss_cred);
> +		/* if create_auth_rplc_client fails try the traditional method of
> +		 * trolling for credentials */
> +		for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
>  			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
>  			if (err == -EKEYEXPIRED)
>  				downcall_err = -EKEYEXPIRED;
>  			else if (!err)
>  				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> -							     AUTHTYPE_KRB5);
> -			if (create_resp == 0)
> -				break;
> +							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL);
>  		}
>  	}
>  	if (create_resp != 0) {
> @@ -1036,7 +1043,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  					gssd_setup_krb5_machine_gss_ccache(*ccname);
>  					if ((create_auth_rpc_client(clp, &rpc_clnt,
>  								    &auth, uid,
> -								    AUTHTYPE_KRB5)) == 0) {
> +								    AUTHTYPE_KRB5,
> +								    GSS_C_NO_CREDENTIAL)) == 0) {
>  						/* Success! */
>  						success++;
>  						break;
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 20b55b37c0f38405794be18f4bebd8ac089dccd2..6275dd8717c64c69939481444bc4b115a2a93a13 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1350,6 +1350,57 @@ gssd_k5_get_default_realm(char **def_realm)
>  	krb5_free_context(context);
>  }
>  
> +static int
> +gssd_acquire_krb5_cred(gss_name_t name, gss_cred_id_t *gss_cred)
> +{
> +	OM_uint32 maj_stat, min_stat;
> +	gss_OID_set_desc desired_mechs = { 1, &krb5oid };
> +
> +	maj_stat = gss_acquire_cred(&min_stat, name, GSS_C_INDEFINITE,
> +				    &desired_mechs, GSS_C_INITIATE,
> +				    gss_cred, NULL, NULL);
> +
> +	if (maj_stat != GSS_S_COMPLETE) {
> +		if (get_verbosity() > 0)
> +			pgsserr("gss_acquire_cred",
> +				maj_stat, min_stat, &krb5oid);
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +int
> +gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
> +{
> +	OM_uint32 maj_stat, min_stat;
> +	gss_buffer_desc name_buf;
> +	gss_name_t name;
> +	char buf[11];
> +	int ret;
> +
> +	ret = snprintf(buf, 11, "%u", uid);
> +	if (ret < 1 || ret > 10) {
> +		return -1;
> +	}
> +	name_buf.value = buf;
> +	name_buf.length = ret + 1;
> +
> +	maj_stat = gss_import_name(&min_stat, &name_buf,
> +				   GSS_C_NT_STRING_UID_NAME, &name);
> +	if (maj_stat != GSS_S_COMPLETE) {
> +		if (get_verbosity() > 0)
> +			pgsserr("gss_import_name",
> +				maj_stat, min_stat, &krb5oid);
> +		return -1;
> +	}
> +
> +	ret = gssd_acquire_krb5_cred(name, gss_cred);
> +
> +	maj_stat = gss_release_name(&min_stat, &name);
> +	return ret;
> +}
> +
>  #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
>  /*
>   * this routine obtains a credentials handle via gss_acquire_cred()
> @@ -1368,28 +1419,18 @@ int
>  limit_krb5_enctypes(struct rpc_gss_sec *sec)
>  {
>  	u_int maj_stat, min_stat;
> -	gss_cred_id_t credh;
> -	gss_OID_set_desc  desired_mechs;
>  	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
>  				    ENCTYPE_DES_CBC_MD5,
>  				    ENCTYPE_DES_CBC_MD4 };
>  	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
>  	extern int num_krb5_enctypes;
>  	extern krb5_enctype *krb5_enctypes;
> +	int err = -1;
>  
> -	/* We only care about getting a krb5 cred */
> -	desired_mechs.count = 1;
> -	desired_mechs.elements = &krb5oid;
> -
> -	maj_stat = gss_acquire_cred(&min_stat, NULL, 0,
> -				    &desired_mechs, GSS_C_INITIATE,
> -				    &credh, NULL, NULL);
> -
> -	if (maj_stat != GSS_S_COMPLETE) {
> -		if (get_verbosity() > 0)
> -			pgsserr("gss_acquire_cred",
> -				maj_stat, min_stat, &krb5oid);
> -		return -1;
> +	if (sec->cred == GSS_C_NO_CREDENTIAL) {
> +		err = gssd_acquire_krb5_cred(GSS_C_NO_NAME, &sec->cred);
> +		if (err)
> +			return -1;
>  	}
>  
>  	/*
> @@ -1397,19 +1438,17 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
>  	 * list of supported enctypes, use local default here.
>  	 */
>  	if (krb5_enctypes == NULL || limit_to_legacy_enctypes)
> -		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
> +		maj_stat = gss_set_allowable_enctypes(&min_stat, sec->cred,
>  					&krb5oid, num_enctypes, enctypes);
>  	else
> -		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
> +		maj_stat = gss_set_allowable_enctypes(&min_stat, sec->cred,
>  					&krb5oid, num_krb5_enctypes, krb5_enctypes);
>  
>  	if (maj_stat != GSS_S_COMPLETE) {
>  		pgsserr("gss_set_allowable_enctypes",
>  			maj_stat, min_stat, &krb5oid);
> -		gss_release_cred(&min_stat, &credh);
>  		return -1;
>  	}
> -	sec->cred = credh;
>  
>  	return 0;
>  }
> diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
> index 9f41625858fe136a63f08d757b4140508729423e..eed12944a73024c015d79f1c4aace2a9d31a1688 100644
> --- a/utils/gssd/krb5_util.h
> +++ b/utils/gssd/krb5_util.h
> @@ -36,6 +36,8 @@ int  gssd_refresh_krb5_machine_credential(char *hostname,
>  char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
>  void gssd_k5_get_default_realm(char **def_realm);
>  
> +int gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred);
> +
>  #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
>  extern int limit_to_legacy_enctypes;
>  int limit_krb5_enctypes(struct rpc_gss_sec *sec);
> 
