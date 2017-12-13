Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:42600 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdLMXnN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Dec 2017 18:43:13 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com>
Date: Wed, 13 Dec 2017 18:42:30 -0500
Cc: Chuck Lever <chuck.lever@oracl.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C5351D4D-2E01-4B6D-AF19-EE6BABD46CCF@oracle.com>
References: <20171204001726.5747-1-trond.myklebust@primarydata.com> <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 13, 2017, at 11:14 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> Hi Trond-
>=20
>> On Dec 3, 2017, at 7:17 PM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:
>>=20
>> We must ensure that the call to rpc_sleep_on() in xprt_transmit() =
cannot
>> race with the call to xprt_complete_rqst().
>>=20
>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>> Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D317
>> Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to protect..")
>> Cc: stable@vger.kernel.org # 4.14+
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> net/sunrpc/xprt.c | 26 +++++++++++++++++---------
>> 1 file changed, 17 insertions(+), 9 deletions(-)
>>=20
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 333b9d697ae5..5e4278e9ce37 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -1024,6 +1024,7 @@ void xprt_transmit(struct rpc_task *task)
>> 	} else if (!req->rq_bytes_sent)
>> 		return;
>>=20
>> +	req->rq_connect_cookie =3D xprt->connect_cookie;
>> 	req->rq_xtime =3D ktime_get();
>> 	status =3D xprt->ops->send_request(task);
>> 	trace_xprt_transmit(xprt, req->rq_xid, status);
>> @@ -1047,20 +1048,27 @@ void xprt_transmit(struct rpc_task *task)
>> 	xprt->stat.bklog_u +=3D xprt->backlog.qlen;
>> 	xprt->stat.sending_u +=3D xprt->sending.qlen;
>> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
>> +	spin_unlock_bh(&xprt->transport_lock);
>>=20
>> -	/* Don't race with disconnect */
>> -	if (!xprt_connected(xprt))
>> -		task->tk_status =3D -ENOTCONN;
>> -	else {
>> +	if (rpc_reply_expected(task) && =
!READ_ONCE(req->rq_reply_bytes_recvd)) {
>> 		/*
>> -		 * Sleep on the pending queue since
>> -		 * we're expecting a reply.
>> +		 * Sleep on the pending queue if we're expecting a =
reply.
>> +		 * The spinlock ensures atomicity between the test of
>> +		 * req->rq_reply_bytes_recvd, and the call to =
rpc_sleep_on().
>> 		 */
>> -		if (!req->rq_reply_bytes_recvd && =
rpc_reply_expected(task))
>> +		spin_lock(&xprt->recv_lock);
>> +		if (!req->rq_reply_bytes_recvd) {
>> 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
>> -		req->rq_connect_cookie =3D xprt->connect_cookie;
>> +			/*
>> +			 * Send an extra queue wakeup call if the
>> +			 * connection was dropped in case the call to
>> +			 * rpc_sleep_on() raced.
>> +			 */
>> +			if (!xprt_connected(xprt))
>> +				xprt_wake_pending_tasks(xprt, =
-ENOTCONN);
>> +		}
>> +		spin_unlock(&xprt->recv_lock);
>> 	}
>> -	spin_unlock_bh(&xprt->transport_lock);
>> }
>>=20
>> static void xprt_add_backlog(struct rpc_xprt *xprt, struct rpc_task =
*task)
>> --=20
>> 2.14.3
>=20
> I've run into a problem with this version of the patch (on v4.15-rc3).
>=20
> With dbench on NFSv4.0 (on RDMA) I no longer see constant throughput
> and a temporarily climbing latency followed by a recovery, but this
> can happen on occasion:
>=20
> releasing clients
>  16       584   322.55 MB/sec  warmup   1 sec  latency 807.121 ms
>  16       584   161.28 MB/sec  warmup   2 sec  latency 1807.175 ms
>  16       584   107.52 MB/sec  warmup   3 sec  latency 2807.198 ms
>  16       584    80.64 MB/sec  warmup   4 sec  latency 3807.217 ms
>  16       584    64.51 MB/sec  warmup   5 sec  latency 4807.235 ms
>  16       584    53.76 MB/sec  warmup   6 sec  latency 5807.251 ms
>  16       584    46.08 MB/sec  warmup   7 sec  latency 6807.269 ms
>  16       584    40.32 MB/sec  warmup   8 sec  latency 7807.285 ms
>  16       584    35.84 MB/sec  warmup   9 sec  latency 8807.303 ms
>  16       584    32.26 MB/sec  warmup  10 sec  latency 9807.318 ms
>  16       584    29.32 MB/sec  warmup  11 sec  latency 10807.334 ms
>  16       584    26.88 MB/sec  warmup  12 sec  latency 11807.355 ms
>  16       584    24.81 MB/sec  warmup  13 sec  latency 12807.372 ms
>  16       584    23.04 MB/sec  warmup  14 sec  latency 13807.387 ms
>  16       584    21.50 MB/sec  warmup  15 sec  latency 14807.406 ms
>  16       584    20.16 MB/sec  warmup  16 sec  latency 15807.423 ms
>=20
> No recovery. The latency number keeps climbing, and throughput
> drops.
>=20
> "kernel: nfs: server klimt-ib not responding, still trying"
> appears in the client's /var/log/messages.
>=20
> Without this patch applied, the NFSv4.0 behavior is the same as I
> reported with NFSv3: every once in a while, one RPC completion is
> lost, but when the timer fires, the client notices the reply
> actually did arrive and the RPC completes normally.
>=20
> I'm looking into it.

Root cause:

The transport is temporarily out of resources and returns -ENOBUFS
from ->send_request.

The FSM schedules a delay then calls call_transmit again, which
invokes xprt_prepare_transmit.

On NFSv3 mounts, xprt_prepare_transmit tries to acquire the
transport write lock.

On NFSv4 mounts, RPC_TASK_NO_RETRANS_TIMEOUT is set. This causes
xprt_prepare_transmit to see that the transport is connected and
rq_connect_cookie is the same as xprt->connect_cookie, so it
queues the task on ->pending and returns false.

The transport never sends the Call, but still waits for a Reply,
forever. This is not a bug in your patch, it is a pre-existing
issue.

There's a simple fix, which is to set

   rq_connect_cookie =3D xprt->connect_cookie - 1;

if RPC-over-RDMA header marshaling fails. This is a one-line fix,
appropriate for -rc and backport to stable (to at least v4.8).

A more robust fix might be to have ->send_request return -EAGAIN
instead, and let xprtrdma call xprt_write_space when the resource
exhaustion is relieved. That might be more involved, and thus is
future-facing.

I'm investigating both fixes.


--
Chuck Lever



