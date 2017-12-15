Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:33544 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754594AbdLOCQ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 21:16:58 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3] SUNRPC: Fix a race in the receive code path
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1513287230.15001.15.camel@primarydata.com>
Date: Thu, 14 Dec 2017 21:16:52 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FEF00E0C-42F8-4388-9F57-458D30BF7608@oracle.com>
References: <20171204001726.5747-1-trond.myklebust@primarydata.com> <17932F80-EF03-48BA-AD6C-90A441B286EF@oracle.com> <C5351D4D-2E01-4B6D-AF19-EE6BABD46CCF@oracle.com> <BF7A22EC-55D9-4545-9F48-93A143A658DB@oracle.com> <1513253779.6553.7.camel@primarydata.com> <42B23A9B-3566-4E0F-9E3D-53BB2C39C0E9@oracle.com> <1513278198.5198.3.camel@primarydata.com> <2E949D1D-AD89-448B-B263-B53FB66C9766@oracle.com> <1513283844.11150.11.camel@primarydata.com> <4D12D608-0108-4CBA-AEF4-CD8CEC86B55F@oracle.com> <1513287230.15001.15.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 14, 2017, at 4:33 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> On Thu, 2017-12-14 at 15:59 -0500, Chuck Lever wrote:
>>> On Dec 14, 2017, at 3:37 PM, Trond Myklebust <trondmy@primarydata.c
>>> om> wrote:
>>>=20
>>> On Thu, 2017-12-14 at 14:22 -0500, Chuck Lever wrote:
>>>>> On Dec 14, 2017, at 2:03 PM, Trond Myklebust <trondmy@primaryda
>>>>> ta.c
>>>>> om> wrote:
>>>>>=20
>>>>> Does the RDMA code update the connect cookie when the
>>>>> connection
>>>>> breaks? It looks to me as if it only does that when the
>>>>> connection
>>>>> is
>>>>> re-established. We really want both.
>>>>>=20
>>>>>> I imagine this issue could also impact write buffer
>>>>>> exhaustion
>>>>>> on TCP.
>>>>>=20
>>>>> See net/sunrpc/xprtsock.c:xs_tcp_state_change()
>>>>=20
>>>> xprtrdma manipulates the connect_cookie in its connect worker,
>>>> see rpcrdma_connect_worker. This was added by:
>>>>=20
>>>> commit 575448bd36208f99fe0dd554a43518d798966740
>>>> Author:     Tom Talpey <talpey@netapp.com>
>>>> AuthorDate: Thu Oct 9 15:00:40 2008 -0400
>>>> Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
>>>> CommitDate: Fri Oct 10 15:10:36 2008 -0400
>>>>=20
>>>>   RPC/RDMA: suppress retransmit on RPC/RDMA clients.
>>>>=20
>>>> Would it be more correct to bump the cookie in
>>>> rpcrdma_conn_upcall,
>>>> which is the equivalent to xs_tcp_state_change? (if so, why, so
>>>> I can compose a reasonable patch description)
>>>>=20
>>>> It could be bumped in the RDMA_CM_EVENT_ESTABLISHED and the
>>>> RDMA_CM_EVENT_DISCONNECTED cases, for example. I'm not sure
>>>> RDMA provides a distinction between "server disconnected"
>>>> and "client disconnected" although that probably does not
>>>> matter for this purpose.
>>>>=20
>>>> But, why would the additional cookie update help? The transport
>>>> is not disconnecting before the deadlock.
>>>>=20
>>>=20
>>> The connection cookie's purpose is twofold:
>>>=20
>>> 1) It tracks whether or not a request has been transmitted on the
>>> current connection or not.
>>=20
>> That's broken by setting the cookie unconditionally outside
>> the transport_lock, isn't it?
>>=20
>>=20
>>> 2) It ensures that when several requests with the same connection
>>> cookie all call xprt_conditional_disconnect(), then that results in
>>> a
>>> single disconnection event. To do so, it assumes that
>>> xprt_autoclose()
>>> will change the cookie if the disconnection attempt is successful.
>>>=20
>>> In TCP we do so in the xs_tcp_state_change(). If the RDMA transport
>>> can
>>> guarantee that the call to xprt->ops->close(xprt) is always
>>> successful,
>>> then you could do so there.
>>=20
>> I don't mind moving the cookie bump to rpcrdma_conn_upcall,
>> but I'm not sure I understand the locking requirements.
>>=20
>> Currently, xprt_transmit sets the connect_cookie while holding
>> the transport_lock.
>>=20
>> xprt_conditional_disconnect compares the cookie while holding
>> the transport_lock.
>>=20
>> For TCP, the transport_lock is held when bumping the cookie
>> in the ESTABLISHED case, but _not_ in the two CLOSE cases?
>=20
> That should be OK. The networking layer should provide sufficient
> serialisation that we don't have to worry about collisions.
>=20
>>=20
>> xprtrdma holds the transport_lock when bumping the cookie,
>> which it does in its connect worker. It has to hold the lock
>> because it skips the value 0. xprtrdma needs to guarantee
>> that an RPC is never transmitted on the same connection
>> twice (and maybe it could use rq_connect_cookie instead of
>> its own cookie).
>>=20
>> xprt_reserve_init is holding the reserve_lock but not the
>> transport_lock when it grabs the cookie. Maybe it should
>> not be initializing the rqst's cookie there?
>>=20
>> Seems to me that xprt_transmit needs to update the rqst's
>> cookie while holding the transport_lock, especially if
>> xprtrdma needs to skip a cookie value? I'm sure I'm missing
>> something.
>>=20
>=20
> It should be OK, given that the connection is a state machine.
> However, I missed something that you said earlier about
> xprt_prepare_transmit().
>=20
> OK. How about the following fixup patch instead of the earlier one?
>=20
> 8<---------------------------------------------------
> =46rom 21cdb2802d9d8b71553998e6be5aafeff0742142 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 14 Dec 2017 07:05:27 -0500
> Subject: [PATCH] fixup! SUNRPC: Fix a race in the receive code path
>=20
> ---
> net/sunrpc/xprt.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 5e4278e9ce37..33b74fd84051 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1001,6 +1001,7 @@ void xprt_transmit(struct rpc_task *task)
> {
> 	struct rpc_rqst	*req =3D task->tk_rqstp;
> 	struct rpc_xprt	*xprt =3D req->rq_xprt;
> +	unsigned int connect_cookie;
> 	int status, numreqs;
>=20
> 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, =
req->rq_slen);
> @@ -1024,7 +1025,7 @@ void xprt_transmit(struct rpc_task *task)
> 	} else if (!req->rq_bytes_sent)
> 		return;
>=20
> -	req->rq_connect_cookie =3D xprt->connect_cookie;
> +	connect_cookie =3D xprt->connect_cookie;
> 	req->rq_xtime =3D ktime_get();
> 	status =3D xprt->ops->send_request(task);
> 	trace_xprt_transmit(xprt, req->rq_xid, status);
> @@ -1050,6 +1051,7 @@ void xprt_transmit(struct rpc_task *task)
> 	xprt->stat.pending_u +=3D xprt->pending.qlen;
> 	spin_unlock_bh(&xprt->transport_lock);
>=20
> +	req->rq_connect_cookie =3D connect_cookie;
> 	if (rpc_reply_expected(task) && =
!READ_ONCE(req->rq_reply_bytes_recvd)) {
> 		/*
> 		 * Sleep on the pending queue if we're expecting a =
reply.
> --=20
> 2.14.3

No problems here, passed basic testing with NFSv4.0 on a
client with extra send_request fault injection.

I hope we can get the recv race fix (as updated here) and
the queue-work-on patch [1] into v4.15-rc.


--
Chuck Lever

[1] https://marc.info/?l=3Dlinux-nfs&m=3D151241427912572&w=3D2=
