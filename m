From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/04]  NFS/RDMA client stall patches
Date: Tue, 10 Jun 2008 15:19:20 -0400
Message-ID: <1213125560.20459.28.camel@localhost>
References: <4830F929.7000307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: talpey@netapp.com, linux-nfs@vger.kernel.org
To: Peter Leckie <pleckie@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33178 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755572AbYFJTT0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 15:19:26 -0400
In-Reply-To: <4830F929.7000307@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-05-19 at 13:51 +1000, Peter Leckie wrote:
> Drain both the sending and resend queues on disconnect.
> This prevents the client from getting it's self into a
> dead state when the server disconnects us.
> 
> Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> X-Sgi-Pv: 971446
>  <http://bugworks/query.cgi/971446>---
> Index: linux-2.6.25.3/net/sunrpc/xprt.c
> ===================================================================
> --- linux-2.6.25.3.orig/net/sunrpc/xprt.c
> +++ linux-2.6.25.3/net/sunrpc/xprt.c
> @@ -586,6 +586,8 @@ void xprt_disconnect_done(struct rpc_xpr
>         spin_lock_bh(&xprt->transport_lock);
>         xprt_clear_connected(xprt);
>         xprt_wake_pending_tasks(xprt, -ENOTCONN);
> +       rpc_wake_up_status(&xprt->resend, -ENOTCONN);
> +       rpc_wake_up_status(&xprt->sending, -ENOTCONN);
>         spin_unlock_bh(&xprt->transport_lock);
>  }
>  EXPORT_SYMBOL_GPL(xprt_disconnect_done);

What kind of a deadlock? The tasks on these queues should be waiting for
the XPRT_LOCKED bit. Why would the change in connection status change
anything to that?

Trond

