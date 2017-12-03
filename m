Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:38655 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdLCSya (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 13:54:30 -0500
Received: by mail-it0-f67.google.com with SMTP id r6so1634986itr.3
        for <linux-nfs@vger.kernel.org>; Sun, 03 Dec 2017 10:54:29 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20171203185012.24473-1-trond.myklebust@primarydata.com>
Date: Sun, 3 Dec 2017 13:54:28 -0500
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9F7B84A7-B241-49D3-8F9D-36338669C827@gmail.com>
References: <20171203185012.24473-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 3, 2017, at 1:50 PM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>=20
> We must ensure that the call to rpc_sleep_on() in xprt_transmit() =
cannot
> race with the call to xprt_complete_rqst().

:-( this will kill scalability, we might as well just go back
to the old locking scheme.

But I will give it a try.


> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D317
> Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
> Cc: stable@vger.kernel.org # 4.14+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> net/sunrpc/xprt.c | 2 ++
> 1 file changed, 2 insertions(+)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 333b9d697ae5..9d9092805696 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1035,6 +1035,7 @@ void xprt_transmit(struct rpc_task *task)
>=20
> 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
> 	task->tk_flags |=3D RPC_TASK_SENT;
> +	spin_lock(&xprt->recv_lock);
> 	spin_lock_bh(&xprt->transport_lock);
>=20
> 	xprt->ops->set_retrans_timeout(task);
> @@ -1061,6 +1062,7 @@ void xprt_transmit(struct rpc_task *task)
> 		req->rq_connect_cookie =3D xprt->connect_cookie;
> 	}
> 	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> }
>=20
> static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task =
*task)
> --=20
> 2.14.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



