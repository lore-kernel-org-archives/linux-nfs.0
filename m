Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34465 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdHAO0O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 10:26:14 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH Version 4 1/2] Use RPCSEC_GSS version 3
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1501275000-24236-2-git-send-email-andros@netapp.com>
Date: Tue, 1 Aug 2017 10:26:06 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        olga.kornievskaia@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <ABDF2826-C777-4A5F-A724-8EB7A92B8BF2@oracle.com>
References: <1501275000-24236-1-git-send-email-andros@netapp.com> <1501275000-24236-2-git-send-email-andros@netapp.com>
To: "William A. (Andy) Adamson" <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 28, 2017, at 4:49 PM, andros@netapp.com wrote:
> 
> From: Andy Adamson <andros@netapp.com>
> 
> Pass gss version to authgss_create
> If version 3 fails, fall back to version 1
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> autogen.sh           |  0
> src/auth_gss.c       | 19 +++++++++++++++----
> tirpc/rpc/auth_gss.h |  8 +++++++-
> 3 files changed, 22 insertions(+), 5 deletions(-)
> mode change 100644 => 100755 autogen.sh
> 
> diff --git a/autogen.sh b/autogen.sh
> old mode 100644
> new mode 100755
> diff --git a/src/auth_gss.c b/src/auth_gss.c
> index cf96ada..8f3da2c 100644
> --- a/src/auth_gss.c
> +++ b/src/auth_gss.c
> @@ -132,6 +132,7 @@ char *p;
> 	fprintf(stderr, "     qop: %d\n", ptr->qop);
> 	fprintf(stderr, "     service: %d\n", ptr->svc);
> 	fprintf(stderr, "     cred: %p\n", ptr->cred);
> +	fprintf(stderr, "     gss version: %d\n", ptr->gss_vers);
> }
> 
> struct rpc_gss_data {
> @@ -156,9 +157,14 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
> 	AUTH			*auth, *save_auth;
> 	struct rpc_gss_data	*gd;
> 	OM_uint32		min_stat = 0;
> +	int                     vers;
> 
> 	gss_log_debug("in authgss_create()");
> 
> +	/* Old gssd versions do not set gss_vers */
> +	vers = sec->gss_vers == 0 ? RPCSEC_GSS_VERSION : sec->gss_vers;
> +
> +retry_gssv1:
> 	memset(&rpc_createerr, 0, sizeof(rpc_createerr));
> 
> 	if ((auth = calloc(sizeof(*auth), 1)) == NULL) {
> @@ -190,7 +196,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
> 	gd->ctx = GSS_C_NO_CONTEXT;
> 	gd->sec = *sec;
> 
> -	gd->gc.gc_v = RPCSEC_GSS_VERSION;
> +	gd->gc.gc_v = vers;
> 	gd->gc.gc_proc = RPCSEC_GSS_INIT;
> 	gd->gc.gc_svc = gd->sec.svc;
> 
> @@ -200,9 +206,13 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
> 	save_auth = clnt->cl_auth;
> 	clnt->cl_auth = auth;
> 
> -	if (!authgss_refresh(auth, NULL))
> -		auth = NULL;
> -	else
> +	if (!authgss_refresh(auth, NULL)) {
> +		if (vers == RPCSEC_GSS3_VERSION) {
> +			vers = RPCSEC_GSS_VERSION;
> +			goto retry_gssv1;

How often does authgss_refresh fail for a reason other
than "GSS3_VERSION is not supported" ? Any such failure
will trigger a damp squib retry with GSSv1, which will
also fail.

Perhaps _rpc_gss_refresh should be changed to return an
error value instead of a boolean, and you should call that
here, directly, instead of authgss_refresh?

I suggest that because ah_refresh is part of a structure
of ops that is visible to library consumers; I'm not sure
it is feasible to change the synopsis of ah_refresh.


> +		} else
> +			auth = NULL;
> +	} else
> 		auth_get(auth); /* Reference for caller */
> 
> 	clnt->cl_auth = save_auth;
> @@ -263,6 +273,7 @@ authgss_get_private_data(AUTH *auth, struct authgss_private_data *pd)
> 	pd->pd_ctx = gd->ctx;
> 	pd->pd_ctx_hndl = gd->gc.gc_ctx;
> 	pd->pd_seq_win = gd->win;
> +	pd->pd_gss_vers = gd->gc.gc_v;
> 	/*
> 	 * We've given this away -- don't try to use it ourself any more
> 	 * Caller should call authgss_free_private_data to free data.
> diff --git a/tirpc/rpc/auth_gss.h b/tirpc/rpc/auth_gss.h
> index a17b34b..a311e08 100644
> --- a/tirpc/rpc/auth_gss.h
> +++ b/tirpc/rpc/auth_gss.h
> @@ -45,7 +45,10 @@ typedef enum {
> 	RPCSEC_GSS_DATA = 0,
> 	RPCSEC_GSS_INIT = 1,
> 	RPCSEC_GSS_CONTINUE_INIT = 2,
> -	RPCSEC_GSS_DESTROY = 3
> +	RPCSEC_GSS_DESTROY = 3,
> +	RPCSEC_GSS_BIND_CHANNEL = 4,	/* GSSv2, not used */
> +	RPCSEC_GSS_CREATE = 5,		/* GSSv3 */
> +	RPCSEC_GSS_LIST = 6		/* GSSv3 */
> } rpc_gss_proc_t;
> 
> /* RPCSEC_GSS services. */
> @@ -56,6 +59,7 @@ typedef enum {
> } rpc_gss_svc_t;
> 
> #define RPCSEC_GSS_VERSION	1
> +#define RPCSEC_GSS3_VERSION	3
> 
> /* RPCSEC_GSS security triple. */
> struct rpc_gss_sec {
> @@ -64,6 +68,7 @@ struct rpc_gss_sec {
> 	rpc_gss_svc_t	svc;		/* service */
> 	gss_cred_id_t	cred;		/* cred handle */
> 	u_int		req_flags;	/* req flags for init_sec_context */
> +	int		gss_vers;	/* highest supported gss version */
> };
> 
> /* Private data required for kernel implementation */
> @@ -71,6 +76,7 @@ struct authgss_private_data {
> 	gss_ctx_id_t	pd_ctx;		/* Session context handle */
> 	gss_buffer_desc	pd_ctx_hndl;	/* Credentials context handle */
> 	u_int		pd_seq_win;	/* Sequence window */
> +	u_int		pd_gss_vers;	/* RPCSEC_GSS version */
> };
> 
> #define g_OID_equal(o1, o2) \
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



