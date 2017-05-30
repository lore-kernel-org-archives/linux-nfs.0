Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbdE3QpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:45:01 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 51F2115554
        for <linux-nfs@vger.kernel.org>; Tue, 30 May 2017 16:45:01 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1EEB15C47D
        for <linux-nfs@vger.kernel.org>; Tue, 30 May 2017 16:45:01 +0000 (UTC)
Subject: Re: [PATCH 1/2] rpcbproc_callit_com: Stop freeing a static pointer.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170525203531.4471-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e80532a8-3fda-5054-f9d4-73057041f0a4@RedHat.com>
Date: Tue, 30 May 2017 12:45:00 -0400
MIME-Version: 1.0
In-Reply-To: <20170525203531.4471-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/25/2017 04:35 PM, Steve Dickson wrote:
> commit 7ea36ee introduced a svc_freeargs() call
> that ended up freeing static pointer.
> 
> It turns out the allocations for the rmt_args
> is not necessary . The xdr routines (xdr_bytes) will
> handle the memory management and the largest
> possible message size is UDPMSGSIZE (due to UDP only)
> which is smaller than RPC_BUF_MAX
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.... 

steved.
> ---
>  src/rpcb_svc_com.c | 39 ++++++---------------------------------
>  1 file changed, 6 insertions(+), 33 deletions(-)
> 
> diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
> index cb63afd..1fc2229 100644
> --- a/src/rpcb_svc_com.c
> +++ b/src/rpcb_svc_com.c
> @@ -612,9 +612,9 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
>  	struct netconfig *nconf;
>  	struct netbuf *caller;
>  	struct r_rmtcall_args a;
> -	char *buf_alloc = NULL, *outbufp;
> +	char *outbufp;
>  	char *outbuf_alloc = NULL;
> -	char buf[RPC_BUF_MAX], outbuf[RPC_BUF_MAX];
> +	char  outbuf[RPC_BUF_MAX];
>  	struct netbuf *na = (struct netbuf *) NULL;
>  	struct rpc_msg call_msg;
>  	int outlen;
> @@ -635,36 +635,10 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
>  	}
>  	if (si.si_socktype != SOCK_DGRAM)
>  		return;	/* Only datagram type accepted */
> -	sendsz = __rpc_get_t_size(si.si_af, si.si_proto, UDPMSGSIZE);
> -	if (sendsz == 0) {	/* data transfer not supported */
> -		if (reply_type == RPCBPROC_INDIRECT)
> -			svcerr_systemerr(transp);
> -		return;
> -	}
> -	/*
> -	 * Should be multiple of 4 for XDR.
> -	 */
> -	sendsz = ((sendsz + 3) / 4) * 4;
> -	if (sendsz > RPC_BUF_MAX) {
> -#ifdef	notyet
> -		buf_alloc = alloca(sendsz);		/* not in IDR2? */
> -#else
> -		buf_alloc = malloc(sendsz);
> -#endif	/* notyet */
> -		if (buf_alloc == NULL) {
> -			if (debugging)
> -				xlog(LOG_DEBUG,
> -					"rpcbproc_callit_com:  No Memory!\n");
> -			if (reply_type == RPCBPROC_INDIRECT)
> -				svcerr_systemerr(transp);
> -			return;
> -		}
> -		a.rmt_args.args = buf_alloc;
> -	} else {
> -		a.rmt_args.args = buf;
> -	}
> +	sendsz = UDPMSGSIZE;
>  
>  	call_msg.rm_xid = 0;	/* For error checking purposes */
> +	memset(&a, 0, sizeof(a)); /* Zero out the input buffer */
>  	if (!svc_getargs(transp, (xdrproc_t) xdr_rmtcall_args, (char *) &a)) {
>  		if (reply_type == RPCBPROC_INDIRECT)
>  			svcerr_decode(transp);
> @@ -704,7 +678,8 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
>  	if (rbl == (rpcblist_ptr)NULL) {
>  #ifdef RPCBIND_DEBUG
>  		if (debugging)
> -			xlog(LOG_DEBUG, "not found\n");
> +			xlog(LOG_DEBUG, "prog %lu vers %lu: not found\n", 
> +				a.rmt_prog, a.rmt_vers);
>  #endif
>  		if (reply_type == RPCBPROC_INDIRECT)
>  			svcerr_noprog(transp);
> @@ -937,8 +912,6 @@ out:
>  	}
>  	if (local_uaddr)
>  		free(local_uaddr);
> -	if (buf_alloc)
> -		free(buf_alloc);
>  	if (outbuf_alloc)
>  		free(outbuf_alloc);
>  	if (na) {
> 
