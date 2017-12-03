Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:39691 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdLCXdo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 18:33:44 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1512332690.28811.3.camel@primarydata.com>
Date: Sun, 3 Dec 2017 18:33:39 -0500
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <16F08CAD-84C9-44ED-B0CC-5116C59A2FDD@oracle.com>
References: <20171203185012.24473-1-trond.myklebust@primarydata.com> <9F7B84A7-B241-49D3-8F9D-36338669C827@gmail.com> <1512331965.24703.5.camel@primarydata.com> <0CE894EE-2CB0-4716-BEFA-C946FBE3A27A@gmail.com> <1512332690.28811.3.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 3, 2017, at 3:24 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> On Sun, 2017-12-03 at 15:19 -0500, Chuck Lever wrote:
>>> On Dec 3, 2017, at 3:12 PM, Trond Myklebust <trondmy@primarydata.co
>>> m> wrote:
>>>=20
>>> On Sun, 2017-12-03 at 13:54 -0500, Chuck Lever wrote:
>>>>> On Dec 3, 2017, at 1:50 PM, Trond Myklebust <trond.myklebust@pr
>>>>> imar
>>>>> ydata.com> wrote:
>>>>>=20
>>>>> We must ensure that the call to rpc_sleep_on() in
>>>>> xprt_transmit()
>>>>> cannot
>>>>> race with the call to xprt_complete_rqst().
>>>>=20
>>>> :-( this will kill scalability, we might as well just go back
>>>> to the old locking scheme.
>>>=20
>>> It shouldn't make a huge difference, but I agree that we do want to
>>> get
>>> rid of that transport lock.
>>>=20
>>> How about the following, then?
>>=20
>> This looks better, I'll give it a try!

After testing for several hours, I was not able to reproduce the
lost RPC completion symptom.

I've been concerned about the performance impact. 8-thread dbench
throughput regresses 2-3% on my 56Gb/s network. There will probably
not be any noticeable degradation on a slower fabric.

Tested-by: Chuck Lever <chuck.lever@oracle.com>


>>=20
>> But touching the recv_lock in the transmit path is what I'd like
>> to avoid completely, if possible. I'm not clear on why the pending
>> waitqueue is unprotected. Doesn't it have a lock of its own?
>=20
> The recv_lock ensures that the check of req->rq_reply_bytes_recvd is
> atomic with the call to rpc_sleep_on().

Ah, makes sense. I agree it is an oversight in ce7c252a8c7 not to
have made this change at the same time.

> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 3 Dec 2017 13:37:27 -0500
> Subject: [PATCH v2] SUNRPC: Fix a race in the receive code path
>=20
> We must ensure that the call to rpc_sleep_on() in xprt_transmit() =
cannot
> race with the call to xprt_complete_rqst().

IMHO the patch description could mention rq_reply_bytes_recvd, which
is the data that is protected by the recv_lock. More bread crumbs
for our future selves...


> @@ -1048,19 +1049,22 @@ void xprt_transmit(struct rpc_task *task)
> 	xprt->stat.sending_u +=3D xprt->sending.qlen;
> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
>=20
> -	/* Don't race with disconnect */
> -	if (!xprt_connected(xprt))
> -		task->tk_status =3D -ENOTCONN;
> -	else {
> +	spin_unlock_bh(&xprt->transport_lock);
> +
> +	if (!READ_ONCE(req->rq_reply_bytes_recvd) && =
rpc_reply_expected(task)) {

I was wondering about this optimization. It seems to provide about a
1% benefit in dbench throughput results in my setup, though it is
certainly not a common case that the reply has arrived at this point.


> +		spin_lock(&xprt->recv_lock);
> 		/*
> 		 * Sleep on the pending queue since
> 		 * we're expecting a reply.
> 		 */
> -		if (!req->rq_reply_bytes_recvd && =
rpc_reply_expected(task))
> +		if (!req->rq_reply_bytes_recvd) {
> 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
> -		req->rq_connect_cookie =3D xprt->connect_cookie;
> +			/* Deal with disconnect races */
> +			if (!xprt_connected(xprt))
> +				xprt_wake_pending_tasks(xprt, =
-ENOTCONN);

Here, the !xprt_connected test is no longer done unconditionally,
but only when the task has to be put to sleep. Is that a 100% safe
change?

I'm also wondering if this check can be omitted. Won't disconnect
wait until xprt_release_xprt ?

Otherwise if this check is still needed, the new comment could be
a little more explanatory :-)


> +		}
> +		spin_unlock(&xprt->recv_lock);
> 	}
> -	spin_unlock_bh(&xprt->transport_lock);
> }


Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

And thanks for your quick response!


--
Chuck Lever



