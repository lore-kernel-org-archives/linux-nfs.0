Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:56161 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729503AbeICVgQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 17:36:16 -0400
Received: by mail-it0-f68.google.com with SMTP id d10-v6so1858932itj.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 10:15:12 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 04/27] SUNRPC: Simplify identification of when the message
 send/receive is complete
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20180903152936.24325-5-trond.myklebust@hammerspace.com>
Date: Mon, 3 Sep 2018 13:15:10 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B9E479F0-4B14-4B2F-A9F3-264581820619@gmail.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 3, 2018, at 11:29 AM, Trond Myklebust <trondmy@gmail.com> =
wrote:
>=20
> Add states to indicate that the message send and receive are not yet
> complete.

In general, the context provided by the cover letter is lost
since it does not appear in the git commit log. Some of the
patch descriptions in this series, like this one, fail to
explain "why", so there's no guidance at all to folks looking
through these patches after they're merged.

So I'm not sure if this is a clean up patch or a pre-requisite
and why it might be necessary.


> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> include/linux/sunrpc/sched.h |  6 ++++--
> net/sunrpc/clnt.c            | 19 +++++++------------
> net/sunrpc/xprt.c            | 17 ++++++++++++++---
> 3 files changed, 25 insertions(+), 17 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/sched.h =
b/include/linux/sunrpc/sched.h
> index 592653becd91..9e655df70131 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -140,8 +140,10 @@ struct rpc_task_setup {
> #define RPC_TASK_RUNNING	0
> #define RPC_TASK_QUEUED		1
> #define RPC_TASK_ACTIVE		2
> -#define RPC_TASK_MSG_RECV	3
> -#define RPC_TASK_MSG_RECV_WAIT	4
> +#define RPC_TASK_NEED_XMIT	3
> +#define RPC_TASK_NEED_RECV	4
> +#define RPC_TASK_MSG_RECV	5
> +#define RPC_TASK_MSG_RECV_WAIT	6
>=20
> #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, =
&(t)->tk_runstate)
> #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, =
&(t)->tk_runstate)
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index d41b5ac1d4e8..e5ac35e803ad 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1156,6 +1156,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst =
*req)
> 	 */
> 	xbufp->len =3D xbufp->head[0].iov_len + xbufp->page_len +
> 			xbufp->tail[0].iov_len;
> +	set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
>=20
> 	task->tk_action =3D call_bc_transmit;
> 	atomic_inc(&task->tk_count);
> @@ -1720,17 +1721,10 @@ call_allocate(struct rpc_task *task)
> 	rpc_exit(task, -ERESTARTSYS);
> }
>=20
> -static inline int
> +static int

Nit: perhaps this function should return a bool type.


> rpc_task_need_encode(struct rpc_task *task)
> {
> -	return task->tk_rqstp->rq_snd_buf.len =3D=3D 0;
> -}
> -
> -static inline void
> -rpc_task_force_reencode(struct rpc_task *task)
> -{
> -	task->tk_rqstp->rq_snd_buf.len =3D 0;
> -	task->tk_rqstp->rq_bytes_sent =3D 0;
> +	return test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate) =3D=3D =
0;
> }
>=20
> /*
> @@ -1765,6 +1759,8 @@ rpc_xdr_encode(struct rpc_task *task)
>=20
> 	task->tk_status =3D rpcauth_wrap_req(task, encode, req, p,
> 			task->tk_msg.rpc_argp);
> +	if (task->tk_status =3D=3D 0)
> +		set_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
> }
>=20
> /*
> @@ -1999,7 +1995,6 @@ call_transmit_status(struct rpc_task *task)
> 	 */
> 	if (task->tk_status =3D=3D 0) {
> 		xprt_end_transmit(task);
> -		rpc_task_force_reencode(task);
> 		return;
> 	}
>=20
> @@ -2010,7 +2005,6 @@ call_transmit_status(struct rpc_task *task)
> 	default:
> 		dprint_status(task);
> 		xprt_end_transmit(task);
> -		rpc_task_force_reencode(task);
> 		break;
> 		/*
> 		 * Special cases: if we've been waiting on the
> @@ -2038,7 +2032,7 @@ call_transmit_status(struct rpc_task *task)
> 	case -EADDRINUSE:
> 	case -ENOTCONN:
> 	case -EPIPE:
> -		rpc_task_force_reencode(task);
> +		break;
> 	}
> }
>=20
> @@ -2185,6 +2179,7 @@ call_status(struct rpc_task *task)
> 		rpc_exit(task, status);
> 		break;
> 	case -EBADMSG:
> +		clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
> 		task->tk_action =3D call_transmit;
> 		break;
> 	default:
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3973e10ea2bd..45d580cd93ac 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -936,10 +936,18 @@ void xprt_complete_rqst(struct rpc_task *task, =
int copied)
> 	/* req->rq_reply_bytes_recvd */
> 	smp_wmb();
> 	req->rq_reply_bytes_recvd =3D copied;
> +	clear_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
> 	rpc_wake_up_queued_task(&xprt->pending, task);
> }
> EXPORT_SYMBOL_GPL(xprt_complete_rqst);
>=20
> +static bool
> +xprt_request_data_received(struct rpc_task *task)
> +{
> +	return !test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
> +		task->tk_rqstp->rq_reply_bytes_recvd !=3D 0;
> +}
> +
> static void xprt_timer(struct rpc_task *task)
> {
> 	struct rpc_rqst *req =3D task->tk_rqstp;
> @@ -1031,12 +1039,13 @@ void xprt_transmit(struct rpc_task *task)
> 			/* Add request to the receive list */
> 			spin_lock(&xprt->recv_lock);
> 			list_add_tail(&req->rq_list, &xprt->recv);
> +			set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
> 			spin_unlock(&xprt->recv_lock);
> 			xprt_reset_majortimeo(req);
> 			/* Turn off autodisconnect */
> 			del_singleshot_timer_sync(&xprt->timer);
> 		}
> -	} else if (!req->rq_bytes_sent)
> +	} else if (xprt_request_data_received(task) && =
!req->rq_bytes_sent)
> 		return;
>=20
> 	connect_cookie =3D xprt->connect_cookie;
> @@ -1046,9 +1055,11 @@ void xprt_transmit(struct rpc_task *task)
> 		task->tk_status =3D status;
> 		return;
> 	}
> +
> 	xprt_inject_disconnect(xprt);
>=20
> 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
> +	clear_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
> 	task->tk_flags |=3D RPC_TASK_SENT;
> 	spin_lock_bh(&xprt->transport_lock);
>=20
> @@ -1062,14 +1073,14 @@ void xprt_transmit(struct rpc_task *task)
> 	spin_unlock_bh(&xprt->transport_lock);
>=20
> 	req->rq_connect_cookie =3D connect_cookie;
> -	if (rpc_reply_expected(task) && =
!READ_ONCE(req->rq_reply_bytes_recvd)) {
> +	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
> 		/*
> 		 * Sleep on the pending queue if we're expecting a =
reply.
> 		 * The spinlock ensures atomicity between the test of
> 		 * req->rq_reply_bytes_recvd, and the call to =
rpc_sleep_on().
> 		 */
> 		spin_lock(&xprt->recv_lock);
> -		if (!req->rq_reply_bytes_recvd) {
> +		if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
> 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
> 			/*
> 			 * Send an extra queue wakeup call if the
> --=20
> 2.17.1
>=20

--
Chuck Lever
chucklever@gmail.com
