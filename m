Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:53766 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753011AbdLNPt2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 10:49:28 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1513253779.6553.7.camel@primarydata.com>
Date: Thu, 14 Dec 2017 10:49:21 -0500
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <42B23A9B-3566-4E0F-9E3D-53BB2C39C0E9@oracle.com>
References: <20171204001726.5747-1-trond.myklebust@primarydata.com> <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com> <C5351D4D-2E01-4B6D-AF19-EE6BABD46CCF@oracle.com> <BF7A22EC-55D9-4545-9F48-93A143A658DB@oracle.com> <1513253779.6553.7.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 14, 2017, at 7:16 AM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> On Wed, 2017-12-13 at 20:13 -0500, Chuck Lever wrote:
>>> On Dec 13, 2017, at 6:42 PM, Chuck Lever <chuck.lever@oracle.com>
>>> wrote:
>>>=20
>>>>=20
>>>> On Dec 13, 2017, at 11:14 AM, Chuck Lever <chuck.lever@oracle.com
>>>>> wrote:
>>>>=20
>>>> Hi Trond-
>>>>=20
>>>>> On Dec 3, 2017, at 7:17 PM, Trond Myklebust <trond.myklebust@pr
>>>>> imarydata.com> wrote:
>>>>>=20
>>>>> We must ensure that the call to rpc_sleep_on() in
>>>>> xprt_transmit() cannot
>>>>> race with the call to xprt_complete_rqst().
>>>>>=20
>>>>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D317
>>>>> Fixes: ce7c252a8c74 ("SUNRPC: Add a separate spinlock to
>>>>> protect..")
>>>>> Cc: stable@vger.kernel.org # 4.14+
>>>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com
>>>>>>=20
>>>>> ---
>>>>> net/sunrpc/xprt.c | 26 +++++++++++++++++---------
>>>>> 1 file changed, 17 insertions(+), 9 deletions(-)
>>>>>=20
>>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>>> index 333b9d697ae5..5e4278e9ce37 100644
>>>>> --- a/net/sunrpc/xprt.c
>>>>> +++ b/net/sunrpc/xprt.c
>>>>> @@ -1024,6 +1024,7 @@ void xprt_transmit(struct rpc_task *task)
>>>>> 	} else if (!req->rq_bytes_sent)
>>>>> 		return;
>>>>>=20
>>>>> +	req->rq_connect_cookie =3D xprt->connect_cookie;
>>>>> 	req->rq_xtime =3D ktime_get();
>>>>> 	status =3D xprt->ops->send_request(task);
>>>>> 	trace_xprt_transmit(xprt, req->rq_xid, status);
>>>>> @@ -1047,20 +1048,27 @@ void xprt_transmit(struct rpc_task
>>>>> *task)
>>>>> 	xprt->stat.bklog_u +=3D xprt->backlog.qlen;
>>>>> 	xprt->stat.sending_u +=3D xprt->sending.qlen;
>>>>> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
>>>>> +	spin_unlock_bh(&xprt->transport_lock);
>>>>>=20
>>>>> -	/* Don't race with disconnect */
>>>>> -	if (!xprt_connected(xprt))
>>>>> -		task->tk_status =3D -ENOTCONN;
>>>>> -	else {
>>>>> +	if (rpc_reply_expected(task) && !READ_ONCE(req-
>>>>>> rq_reply_bytes_recvd)) {
>>>>> 		/*
>>>>> -		 * Sleep on the pending queue since
>>>>> -		 * we're expecting a reply.
>>>>> +		 * Sleep on the pending queue if we're
>>>>> expecting a reply.
>>>>> +		 * The spinlock ensures atomicity between the
>>>>> test of
>>>>> +		 * req->rq_reply_bytes_recvd, and the call to
>>>>> rpc_sleep_on().
>>>>> 		 */
>>>>> -		if (!req->rq_reply_bytes_recvd &&
>>>>> rpc_reply_expected(task))
>>>>> +		spin_lock(&xprt->recv_lock);
>>>>> +		if (!req->rq_reply_bytes_recvd) {
>>>>> 			rpc_sleep_on(&xprt->pending, task,
>>>>> xprt_timer);
>>>>> -		req->rq_connect_cookie =3D xprt->connect_cookie;
>>>>> +			/*
>>>>> +			 * Send an extra queue wakeup call if
>>>>> the
>>>>> +			 * connection was dropped in case the
>>>>> call to
>>>>> +			 * rpc_sleep_on() raced.
>>>>> +			 */
>>>>> +			if (!xprt_connected(xprt))
>>>>> +				xprt_wake_pending_tasks(xprt,
>>>>> -ENOTCONN);
>>>>> +		}
>>>>> +		spin_unlock(&xprt->recv_lock);
>>>>> 	}
>>>>> -	spin_unlock_bh(&xprt->transport_lock);
>>>>> }
>>>>>=20
>>>>> static void xprt_add_backlog(struct rpc_xprt *xprt, struct
>>>>> rpc_task *task)
>>>>> --=20
>>>>> 2.14.3
>>>>=20
>>>> I've run into a problem with this version of the patch (on v4.15-
>>>> rc3).
>>>>=20
>>>> With dbench on NFSv4.0 (on RDMA) I no longer see constant
>>>> throughput
>>>> and a temporarily climbing latency followed by a recovery, but
>>>> this
>>>> can happen on occasion:
>>>>=20
>>>> releasing clients
>>>> 16       584   322.55 MB/sec  warmup   1 sec  latency 807.121 ms
>>>> 16       584   161.28 MB/sec  warmup   2 sec  latency 1807.175 ms
>>>> 16       584   107.52 MB/sec  warmup   3 sec  latency 2807.198 ms
>>>> 16       584    80.64 MB/sec  warmup   4 sec  latency 3807.217 ms
>>>> 16       584    64.51 MB/sec  warmup   5 sec  latency 4807.235 ms
>>>> 16       584    53.76 MB/sec  warmup   6 sec  latency 5807.251 ms
>>>> 16       584    46.08 MB/sec  warmup   7 sec  latency 6807.269 ms
>>>> 16       584    40.32 MB/sec  warmup   8 sec  latency 7807.285 ms
>>>> 16       584    35.84 MB/sec  warmup   9 sec  latency 8807.303 ms
>>>> 16       584    32.26 MB/sec  warmup  10 sec  latency 9807.318 ms
>>>> 16       584    29.32 MB/sec  warmup  11 sec  latency 10807.334
>>>> ms
>>>> 16       584    26.88 MB/sec  warmup  12 sec  latency 11807.355
>>>> ms
>>>> 16       584    24.81 MB/sec  warmup  13 sec  latency 12807.372
>>>> ms
>>>> 16       584    23.04 MB/sec  warmup  14 sec  latency 13807.387
>>>> ms
>>>> 16       584    21.50 MB/sec  warmup  15 sec  latency 14807.406
>>>> ms
>>>> 16       584    20.16 MB/sec  warmup  16 sec  latency 15807.423
>>>> ms
>>>>=20
>>>> No recovery. The latency number keeps climbing, and throughput
>>>> drops.
>>>>=20
>>>> "kernel: nfs: server klimt-ib not responding, still trying"
>>>> appears in the client's /var/log/messages.
>>>>=20
>>>> Without this patch applied, the NFSv4.0 behavior is the same as I
>>>> reported with NFSv3: every once in a while, one RPC completion is
>>>> lost, but when the timer fires, the client notices the reply
>>>> actually did arrive and the RPC completes normally.
>>>>=20
>>>> I'm looking into it.
>>>=20
>>> Root cause:
>>>=20
>>> The transport is temporarily out of resources and returns -ENOBUFS
>>> from ->send_request.
>>>=20
>>> The FSM schedules a delay then calls call_transmit again, which
>>> invokes xprt_prepare_transmit.
>>>=20
>>> On NFSv3 mounts, xprt_prepare_transmit tries to acquire the
>>> transport write lock.
>>>=20
>>> On NFSv4 mounts, RPC_TASK_NO_RETRANS_TIMEOUT is set. This causes
>>> xprt_prepare_transmit to see that the transport is connected and
>>> rq_connect_cookie is the same as xprt->connect_cookie, so it
>>> queues the task on ->pending and returns false.
>>>=20
>>> The transport never sends the Call, but still waits for a Reply,
>>> forever. This is not a bug in your patch, it is a pre-existing
>>> issue.
>>=20
>> Sorry for one more reply...
>>=20
>> I think this last statement is incorrect. It is a bug in your
>> patch after all.
>>=20
>> I forgot that your patch moves the line that sets
>>=20
>>    req->rq_connect_cookie =3D xprt->connect_cookie;
>>=20
>> to before the call to ->send_request. But rq_connect_cookie
>> must be set iff ->send_request is successful. Moving this
>> line seems to fix the issue:
>>=20
>> 1027         req->rq_xtime =3D ktime_get();
>> 1028         status =3D xprt->ops->send_request(task);
>> 1029         trace_xprt_transmit(xprt, req->rq_xid, status);
>> 1030         if (status !=3D 0) {
>> 1031                 task->tk_status =3D status;
>> 1032                 return;
>> 1033         }
>> 1034         req->rq_connect_cookie =3D xprt->connect_cookie; <<<<
>> 1035         xprt_inject_disconnect(xprt);
>>=20
>=20
> Let's rather apply the attached fix (incremental to the original patch
> and intended to be applied using 'git rebase --autosquash'). The =
reason
> for wanting to set the connect cookie before we call send_request() is
> to avoid races with disconnects that happen immediately after we sent
> the data (but before we get round to setting the cookie).
>=20
> 8<--------------------------------------------------------
> =46rom 326c12727b179d5c2fd42f374a4c0e2d56ee90c5 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 14 Dec 2017 07:05:27 -0500
> Subject: [PATCH] fixup! SUNRPC: Fix a race in the receive code path
>=20
> ---
> net/sunrpc/xprt.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 5e4278e9ce37..2cf4cf21a878 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1021,10 +1021,11 @@ void xprt_transmit(struct rpc_task *task)
> 			/* Turn off autodisconnect */
> 			del_singleshot_timer_sync(&xprt->timer);
> 		}
> +		if (!req->rq_bytes_sent)
> +			req->rq_connect_cookie =3D xprt->connect_cookie;
> 	} else if (!req->rq_bytes_sent)
> 		return;
>=20
> -	req->rq_connect_cookie =3D xprt->connect_cookie;
> 	req->rq_xtime =3D ktime_get();
> 	status =3D xprt->ops->send_request(task);
> 	trace_xprt_transmit(xprt, req->rq_xid, status);
> --=20
> 2.14.3

Tested with a client that returns -ENOBUFS from ->send_request
with a little extra frequency.

This doesn't appear to address the problem. The transport
deadlocks as before when send_request() fails to send the RPC.

I imagine this issue could also impact write buffer exhaustion
on TCP.


--
Chuck Lever



