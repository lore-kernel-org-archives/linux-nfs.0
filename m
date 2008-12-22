From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] backwards compatibility: fix order of fields in
	TI-RPC's svc_req
Date: Mon, 22 Dec 2008 12:18:10 -0500
Message-ID: <20081222171810.GN4191@fieldses.org>
References: <20081219152226.32332.5510.stgit@ingres.1015granger.net> <20081219153133.32332.48865.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, =okir@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:47370 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYLVRSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Dec 2008 12:18:34 -0500
In-Reply-To: <20081219153133.32332.48865.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2008 at 10:31:33AM -0500, Chuck Lever wrote:
> Preserve ABI compatibility between glibc's RPC implementation and
> the legacy RPC implementation in libtirpc by moving the rq_xprt
> field in the TI-RPC version of the svc_req struct so it is
> backwards compatible with the legacy version of this structure.
> 
> Linux's legacy svc_req struct, from /usr/include/rpc/svc.h, looks
> like this:
> 
> struct svc_req {
>   rpcprog_t rq_prog;		/* service program number */
>   rpcvers_t rq_vers;		/* service protocol version */
>   rpcproc_t rq_proc;		/* the desired procedure */
>   struct opaque_auth rq_cred;	/* raw creds from the wire */
>   caddr_t rq_clntcred;		/* read only cooked cred */
>   SVCXPRT *rq_xprt;		/* associated transport */
> };
> 
> The new TI-RPC svc_req struct, from /usr/include/tirpc/rpc/svc.h,
> looks like this:
> 
> struct svc_req {
>   u_int32_t rq_prog;		/* service program number */
>   u_int32_t rq_vers;		/* service protocol version */
>   u_int32_t rq_proc;		/* the desired procedure */
>   struct opaque_auth rq_cred;	/* raw creds from the wire */
>   void *rq_clntcred;		/* read only cooked cred */
>   caddr_t rq_clntname;		/* read only client name */
>   caddr_t rq_svcname;		/* read only cooked service cred */
>   SVCXPRT *rq_xprt;		/* associated transport */
> };
> 
> Note the extra fields rq_clntname and rq_svcname.  These are used for
> TI-RPC's RPCSEC GSS flavor support.
> 
> This issue came to light because rpc.statd still uses only legacy RPC
> calls, and thus includes /usr/include/rpc/svc.h.  However, other parts
> of nfs-utils now link with TI-RPC, so the legacy RPC functions in
> libtirpc are used in favor of glibc's RPC functions.  The libtirpc svc
> functions use the new svc_req struct, but rpc.statd uses the old
> svc_req struct.
> 
> Since the svc_req fields were different, rpc.statd broke after recent
> IPv6-related changes, even though I hadn't made any changes to it.
> Note that rpc.mountd also references the rq_xprt field, so it has the
> same issue.
> 
> In most operating systems, there is only one rpc/svc.h and one version
> of svc_req so this is not a problem.  We should audit all of the
> structures and functions under /usr/include/rpc and
> /usr/include/tirpc/rpc to ensure we have a reasonable level of
> backwards compatibility until such a time it is decided to merge these
> implementations or get rid of RPC support in glibc.

I think the glibc people don't want to update their RPC support--so it
should stay there as a legacy thing for backwards compatibility, but
eventually applications should be using something else.

As long as that "something else" supports both ipv6 and rpcsec_gss, I'm
happy....

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  tirpc/rpc/svc.h |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/tirpc/rpc/svc.h b/tirpc/rpc/svc.h
> index ec5914f..ea2985d 100644
> --- a/tirpc/rpc/svc.h
> +++ b/tirpc/rpc/svc.h
> @@ -131,14 +131,17 @@ typedef struct __rpc_svcxprt {
>   * Service request
>   */
>  struct svc_req {
> +	/* ORDER: compatibility with legacy RPC */
>  	u_int32_t	rq_prog;	/* service program number */
>  	u_int32_t	rq_vers;	/* service protocol version */
>  	u_int32_t	rq_proc;	/* the desired procedure */
>  	struct opaque_auth rq_cred;	/* raw creds from the wire */
>  	void		*rq_clntcred;	/* read only cooked cred */
> +	SVCXPRT		*rq_xprt;	/* associated transport */
> +
> +	/* New with TI-RPC */
>  	caddr_t		rq_clntname;	/* read only client name */
>  	caddr_t		rq_svcname;	/* read only cooked service cred */
> -	SVCXPRT		*rq_xprt;	/* associated transport */
>  };
>  
>  /*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
