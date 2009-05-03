From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC 03/10] nfsd41: sunrpc: Added rpc server-side backchannel
	handling
Date: Sun, 3 May 2009 16:36:45 -0400
Message-ID: <20090503203645.GA22306@fieldses.org>
References: <49FA2D86.8060402@panasas.com> <1241132750-32462-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Rahul Iyer <iyer@netapp.com>,
	Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44911 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbZECUg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 16:36:56 -0400
In-Reply-To: <1241132750-32462-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2009 at 02:05:50AM +0300, Benny Halevy wrote:
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 4e6d406..619764e 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -49,6 +49,7 @@
>  #include <linux/sunrpc/msg_prot.h>
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
> +#include <linux/sunrpc/xprt.h>
>  
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
> @@ -825,6 +826,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	int		len;
>  	struct kvec *vec;
>  	int pnum, vlen;
> +	struct rpc_rqst *req = NULL;
>  
>  	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
>  		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
> @@ -891,12 +893,65 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  	len = svsk->sk_reclen;
>  	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  
> +	/*
> +	 * We have enough data for the whole tcp record. Let's try and read the
> +	 * first 8 bytes to get the xid and the call direction. We can use this
> +	 * to figure out if this is a call or a reply to a callback. If
> +	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
> +	 * In that case, don't bother with the calldir and just read the data.
> +	 * It will be rejected in svc_process.
> +	 */
> +
>  	vec = rqstp->rq_vec;
>  	vec[0] = rqstp->rq_arg.head[0];
>  	vlen = PAGE_SIZE;
> +
> +	if (len >= 8) {
> +		u32 *p;
> +		u32 xid;
> +		u32 calldir;

Style complaint: "Functions should be short and sweet, and do just one
thing."  The code in this "if" clause looks like something that could
easily be encapsulated in a helper function.

> +
> +		len = svc_recvfrom(rqstp, vec, 1, 8);
> +		if (len < 0)
> +			goto error;
> +
> +		p = (u32 *)rqstp->rq_arg.head[0].iov_base;
> +		xid = *p++;
> +		calldir = *p;
> +
> +		if (calldir) {
> +			/* REPLY */
> +			if (svsk->sk_bc_xprt)
> +				req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
> +			if (req) {
> +				memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
> +					sizeof(struct xdr_buf));

This worries me.  Has anyone tested this with krb5p?  If not, please do.

> +				/* copy the xid and call direction */
> +				memcpy(req->rq_private_buf.head[0].iov_base,
> +					rqstp->rq_arg.head[0].iov_base, 8);
> +				vec[0] = req->rq_private_buf.head[0];
> +			} else
> +				printk(KERN_NOTICE
> +					"%s: Got unrecognized reply: "
> +					"calldir 0x%x sk_bc_xprt %p xid %08x\n",
> +					__func__, ntohl(calldir),
> +					svsk->sk_bc_xprt, xid);
> +		}

And another style nit:  other things being equal, I'd generally prefer

	if (exceptional case)
		handle it, goto/return
	if (another exceptional case)
		handle it, goto/return
	...
	normal case
	...

to

	if (normal case) {
		...
		normal case
		...
	} else
		handle exceptional case

--b.
