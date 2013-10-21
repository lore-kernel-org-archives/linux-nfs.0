Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751718Ab3JUR35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:29:57 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9LHTuJL029675
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 13:29:57 -0400
Message-ID: <526564BC.9010303@RedHat.com>
Date: Mon, 21 Oct 2013 13:30:36 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: ssorce@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] gssd: do a more thorough change of identity after
 forking
References: <1381350116-10464-1-git-send-email-jlayton@redhat.com> <1381350116-10464-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1381350116-10464-3-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/10/13 16:21, Jeff Layton wrote:
> The part of process_krb5_upcall that handles non-machine user creds
> first tries to query GSSAPI for credentials. If that fails, it then
> falls back to trawling through likely credcache locations to find them
> and then points $KRB5CCNAME at it before proceeding. There are a number
> of bugs in this code that this patch attempts to address.
> 
> The code that queries GSSAPI for credentials does it as root which
> almost universally fails to do anything useful unless we happen to be
> looking for non-machine root creds. Because of this, gssd almost always
> falls back to having to search for credcaches "manually". The code that
> handles credential switching is in create_auth_rpc_client, so it's too
> late to be of any use here.
> 
> Worse yet, for historical reasons the MIT krb5 authors used %{uid} in
> the default credcache locations which translates to the real uid. Thus
> switching the fsuid or even euid is insufficient. You must switch the
> real uid in order to be able to find the proper credcache in most cases.
> 
> This patch moves the credential switching to occur much earlier in the
> process and has it do a much more thorough job of it. It first drops all
> supplimentary groups, then determines a gid to use and switches the gids
> and uids to the correct ones. If it can't determine the correct gid to
> use, it then tries to look up the one for "nobody" and uses that.
> 
> Once the credentials are switched, the forked child now no longer tries
> to change them back. It does the downcall with the new credentials and
> just exits when it's done.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_proc.c | 82 ++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 66 insertions(+), 16 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 99537d9..b48d163 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -834,7 +834,6 @@ create_auth_rpc_client(struct clnt_info *clp,
>  	CLIENT			*rpc_clnt = NULL;
>  	struct rpc_gss_sec	sec;
>  	AUTH			*auth = NULL;
> -	uid_t			save_uid = -1;
>  	int			retval = -1;
>  	OM_uint32		min_stat;
>  	char			rpc_errmsg[1024];
> @@ -843,16 +842,6 @@ create_auth_rpc_client(struct clnt_info *clp,
>  	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
>  	socklen_t		salen;
>  
> -	/* Create the context as the user (not as root) */
> -	save_uid = geteuid();
> -	if (setfsuid(uid) != 0) {
> -		printerr(0, "WARNING: Failed to setfsuid for "
> -			    "user with uid %d\n", uid);
> -		goto out_fail;
> -	}
> -	printerr(2, "creating context using fsuid %d (save_uid %d)\n",
> -			uid, save_uid);
> -
>  	sec.qop = GSS_C_QOP_DEFAULT;
>  	sec.svc = RPCSEC_GSS_SVC_NONE;
>  	sec.cred = cred;
> @@ -951,11 +940,6 @@ create_auth_rpc_client(struct clnt_info *clp,
>    out:
>  	if (sec.cred != GSS_C_NO_CREDENTIAL)
>  		gss_release_cred(&min_stat, &sec.cred);
> -	/* Restore euid to original value */
> -	if (((int)save_uid != -1) && (setfsuid(save_uid) != (int)uid)) {
> -		printerr(0, "WARNING: Failed to restore fsuid"
> -			    " to uid %d from %d\n", save_uid, uid);
> -	}
>  	return retval;
>  
>    out_fail:
> @@ -966,6 +950,64 @@ create_auth_rpc_client(struct clnt_info *clp,
>  }
>  
>  /*
> + * Create the context as the user (not as root).
> + *
> + * Note that we change the *real* uid here, as changing the effective uid is
> + * not sufficient. This is due to an unfortunate historical error in the MIT
> + * krb5 libs, where they used %{uid} in the default_ccache_name. Changing that
> + * now might break some applications so we're sort of stuck with it.
> + *
> + * Unfortunately, doing this leaves the forked child vulnerable to signals and
> + * renicing, but this is the best we can do. In the event that a child is
> + * signalled before downcalling, the kernel will just eventually time out the
> + * upcall attempt.
> + */
> +static int
> +change_identity(uid_t uid)
> +{
> +	struct passwd	*pw;
> +
> +	/* drop list of supplimentary groups first */
> +	if (setgroups(0, NULL) != 0) {
> +		printerr(0, "WARNING: unable to drop supplimentary groups!");
> +		return errno;
> +	}
> +
> +	/* try to get pwent for user */
> +	pw = getpwuid(uid);
> +	if (!pw) {
> +		/* if that doesn't work, try to get one for "nobody" */
> +		errno = 0;
> +		pw = getpwnam("nobody");
> +		if (!pw) {
> +			printerr(0, "WARNING: unable to determine gid for uid %u\n", uid);
> +			return errno ? errno : ENOENT;
> +		}
> +	}
> +
> +	/*
> +	 * Switch the GIDs. Note that we leave the saved-set-gid alone in an
> +	 * attempt to prevent attacks via ptrace()
> +	 */
> +	if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> +		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
> +		return errno;
> +	}
> +
> +	/*
> +	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
> +	 * other processes running with this uid.
> +	 */
> +	if (setresuid(uid, uid, -1) != 0) {
> +		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
> +				uid);
> +		return errno;
> +	}
> +
> +	return 0;
> +}
> +
> +/*
>   * this code uses the userland rpcsec gss library to create a krb5
>   * context on behalf of the kernel
>   */
> @@ -1036,6 +1078,14 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  		 service ? service : "<null>");
>  	if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0 &&
>  				service == NULL)) {
> +
> +		err = change_identity(uid);
> +		if (err) {
> +			printerr(0, "WARNING: failed to change identity: %s",
> +				 strerror(err));
> +			goto out_return_error;
> +		}
> +
>  		/* Tell krb5 gss which credentials cache to use */
>  		/* Try first to acquire credentials directly via GSSAPI */
>  		err = gssd_acquire_user_cred(uid, &gss_cred);
> 
