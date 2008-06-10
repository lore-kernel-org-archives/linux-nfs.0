From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 01/04]  NFS/RDMA client stall patches
Date: Tue, 10 Jun 2008 15:24:59 -0400
Message-ID: <1213125899.20459.34.camel@localhost>
References: <4830F91C.7070206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: talpey@netapp.com, linux-nfs@vger.kernel.org
To: Peter Leckie <pleckie@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:38238 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368AbYFJTZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 15:25:06 -0400
In-Reply-To: <4830F91C.7070206@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-05-19 at 13:50 +1000, Peter Leckie wrote:
> Don't call __xprt_get_cong() if this is a retransmit.
> This prevents __xprt_get_cong() from recursively
> incrementing the congestion avoidance window for
> retransmitted data.
> 
> Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> X-Sgi-Pv: 971446
>  <http://bugworks/query.cgi/971446>---
> Index: linux-2.6.25.3/net/sunrpc/xprt.c
> ===================================================================
> --- linux-2.6.25.3.orig/net/sunrpc/xprt.c
> +++ linux-2.6.25.3/net/sunrpc/xprt.c
> @@ -224,7 +224,8 @@ int xprt_reserve_xprt_cong(struct rpc_ta
>                         return 1;
>                 goto out_sleep;
>         }
> -       if (__xprt_get_cong(xprt, task)) {
> +     /*If this is a retransmit don't increment cong*/
> +       if ((req && req->rq_ntrans) ||__xprt_get_cong(xprt, task)) {
>                 xprt->snd_task = task;
>                 if (req) {
>                         req->rq_bytes_sent = 0;
> 

Why would we not want to increment the congestion avoidance window on
retransmitted data? On timeout, xprt_adjust_cwnd will call
__xprt_put_cong() prior to the retransmission, so I can't see how this
is a 'recursive increment'.

Trond

