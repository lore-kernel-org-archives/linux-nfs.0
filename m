Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754549Ab3IXTR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 15:17:26 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r8OJHPjI013739
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Sep 2013 15:17:26 -0400
Message-ID: <5241E561.3030406@RedHat.com>
Date: Tue, 24 Sep 2013 15:17:53 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCHv2 3/3] gssd: let tgtname override clp->servicename
References: <1379624239-31199-2-git-send-email-bfields@redhat.com> <1379624632-31476-1-git-send-email-bfields@redhat.com> <1379624632-31476-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1379624632-31476-3-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/09/13 17:03, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> When the kernel provides an explicit "target=" name in the upcall, that
> should override the name in clp->servicename.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved.

> ---
>  utils/gssd/gssd_proc.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 7200a78..e58c341 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -822,6 +822,7 @@ set_port:
>   */
>  static int
>  create_auth_rpc_client(struct clnt_info *clp,
> +		       char *tgtname,
>  		       CLIENT **clnt_return,
>  		       AUTH **auth_return,
>  		       uid_t uid,
> @@ -926,14 +927,16 @@ create_auth_rpc_client(struct clnt_info *clp,
>  			 clnt_spcreateerror(rpc_errmsg));
>  		goto out_fail;
>  	}
> +	if (!tgtname)
> +		tgtname = clp->servicename;
>  
> -	printerr(2, "creating context with server %s\n", clp->servicename);
> -	auth = authgss_create_default(rpc_clnt, clp->servicename, &sec);
> +	printerr(2, "creating context with server %s\n", tgtname);
> +	auth = authgss_create_default(rpc_clnt, tgtname, &sec);
>  	if (!auth) {
>  		/* Our caller should print appropriate message */
>  		printerr(2, "WARNING: Failed to create krb5 context for "
>  			    "user with uid %d for server %s\n",
> -			 uid, clp->servername);
> +			 uid, tgtname);
>  		goto out_fail;
>  	}
>  
> @@ -1015,7 +1018,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  		/* Try first to acquire credentials directly via GSSAPI */
>  		err = gssd_acquire_user_cred(uid, &gss_cred);
>  		if (!err)
> -			create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> +			create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
>  							     AUTHTYPE_KRB5, gss_cred);
>  		/* if create_auth_rplc_client fails try the traditional method of
>  		 * trolling for credentials */
> @@ -1024,7 +1027,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  			if (err == -EKEYEXPIRED)
>  				downcall_err = -EKEYEXPIRED;
>  			else if (!err)
> -				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> +				create_resp = create_auth_rpc_client(clp, tgtname, &rpc_clnt, &auth, uid,
>  							     AUTHTYPE_KRB5, GSS_C_NO_CREDENTIAL);
>  		}
>  	}
> @@ -1048,7 +1051,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  				}
>  				for (ccname = credlist; ccname && *ccname; ccname++) {
>  					gssd_setup_krb5_machine_gss_ccache(*ccname);
> -					if ((create_auth_rpc_client(clp, &rpc_clnt,
> +					if ((create_auth_rpc_client(clp, tgtname, &rpc_clnt,
>  								    &auth, uid,
>  								    AUTHTYPE_KRB5,
>  								    GSS_C_NO_CREDENTIAL)) == 0) {
> 
