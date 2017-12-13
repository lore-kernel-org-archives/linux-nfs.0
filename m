Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:39763 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753253AbdLMQPm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Dec 2017 11:15:42 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171204001726.5747-1-trond.myklebust@primarydata.com>
Date: Wed, 13 Dec 2017 11:14:59 -0500
Cc: Chuck Lever <chuck.lever@oracl.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com>
References: <20171204001726.5747-1-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

> On Dec 3, 2017, at 7:17 PM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>=20
> We must ensure that the call to rpc_sleep_on() in xprt_transmit() =
cannot
> race with the call to xprt_complete_rqst().
>=20
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D317
> Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
> Cc: stable@vger.kernel.org # 4.14+
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> net/sunrpc/xprt.c | 26 +++++++++++++++++---------
> 1 file changed, 17 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 333b9d697ae5..5e4278e9ce37 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1024,6 +1024,7 @@ void xprt_transmit(struct rpc_task *task)
> 	} else if (!req->rq_bytes_sent)
> 		return;
>=20
> +	req->rq_connect_cookie =3D xprt->connect_cookie;
> 	req->rq_xtime =3D ktime_get();
> 	status =3D xprt->ops->send_request(task);
> 	trace_xprt_transmit(xprt, req->rq_xid, status);
> @@ -1047,20 +1048,27 @@ void xprt_transmit(struct rpc_task *task)
> 	xprt->stat.bklog_u +=3D xprt->backlog.qlen;
> 	xprt->stat.sending_u +=3D xprt->sending.qlen;
> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
> +	spin_unlock_bh(&xprt->transport_lock);
>=20
> -	/* Don't race with disconnect */
> -	if (!xprt_connected(xprt))
> -		task->tk_status =3D -ENOTCONN;
> -	else {
> +	if (rpc_reply_expected(task) && =
!READ_ONCE(req->rq_reply_bytes_recvd)) {
> 		/*
> -		 * Sleep on the pending queue since
> -		 * we're expecting a reply.
> +		 * Sleep on the pending queue if we're expecting a =
reply.
> +		 * The spinlock ensures atomicity between the test of
> +		 * req->rq_reply_bytes_recvd, and the call to =
rpc_sleep_on().
> 		 */
> -		if (!req->rq_reply_bytes_recvd && =
rpc_reply_expected(task))
> +		spin_lock(&xprt->recv_lock);
> +		if (!req->rq_reply_bytes_recvd) {
> 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
> -		req->rq_connect_cookie =3D xprt->connect_cookie;
> +			/*
> +			 * Send an extra queue wakeup call if the
> +			 * connection was dropped in case the call to
> +			 * rpc_sleep_on() raced.
> +			 */
> +			if (!xprt_connected(xprt))
> +				xprt_wake_pending_tasks(xprt, =
-ENOTCONN);
> +		}
> +		spin_unlock(&xprt->recv_lock);
> 	}
> -	spin_unlock_bh(&xprt->transport_lock);
> }
>=20
> static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task =
*task)
> --=20
> 2.14.3

I've run into a problem with this version of the patch (on v4.15-rc3).

With dbench on NFSv4.0 (on RDMA) I no longer see constant throughput
and a temporarily climbing latency followed by a recovery, but this
can happen on occasion:

releasing clients
  16       584   322.55 MB/sec  warmup   1 sec  latency 807.121 ms
  16       584   161.28 MB/sec  warmup   2 sec  latency 1807.175 ms
  16       584   107.52 MB/sec  warmup   3 sec  latency 2807.198 ms
  16       584    80.64 MB/sec  warmup   4 sec  latency 3807.217 ms
  16       584    64.51 MB/sec  warmup   5 sec  latency 4807.235 ms
  16       584    53.76 MB/sec  warmup   6 sec  latency 5807.251 ms
  16       584    46.08 MB/sec  warmup   7 sec  latency 6807.269 ms
  16       584    40.32 MB/sec  warmup   8 sec  latency 7807.285 ms
  16       584    35.84 MB/sec  warmup   9 sec  latency 8807.303 ms
  16       584    32.26 MB/sec  warmup  10 sec  latency 9807.318 ms
  16       584    29.32 MB/sec  warmup  11 sec  latency 10807.334 ms
  16       584    26.88 MB/sec  warmup  12 sec  latency 11807.355 ms
  16       584    24.81 MB/sec  warmup  13 sec  latency 12807.372 ms
  16       584    23.04 MB/sec  warmup  14 sec  latency 13807.387 ms
  16       584    21.50 MB/sec  warmup  15 sec  latency 14807.406 ms
  16       584    20.16 MB/sec  warmup  16 sec  latency 15807.423 ms

No recovery. The latency number keeps climbing, and throughput
drops.

"kernel: nfs: server klimt-ib not responding, still trying"
appears in the client's /var/log/messages.

Without this patch applied, the NFSv4.0 behavior is the same as I
reported with NFSv3: every once in a while, one RPC completion is
lost, but when the timer fires, the client notices the reply
actually did arrive and the RPC completes normally.

I'm looking into it.


--
Chuck Lever



