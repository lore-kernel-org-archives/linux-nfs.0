Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:34244 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbeCFWa5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 17:30:57 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 5/9] SUNRPC: Initialize rpc_rqst outside of
 xprt->reserve_lock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <FA9A696D-3702-43DB-8FBA-E924B54E0F28@oracle.com>
Date: Tue, 6 Mar 2018 17:30:53 -0500
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <41538F44-115C-4F64-9BCA-0A6B8723A9F5@oracle.com>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
 <20180305201318.10904.57825.stgit@manet.1015granger.net>
 <4dd8259a-e447-122b-c267-75e2e6b4714e@Netapp.com>
 <FA9A696D-3702-43DB-8FBA-E924B54E0F28@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 6, 2018, at 5:07 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>=20
>=20
>> On Mar 6, 2018, at 5:02 PM, Anna Schumaker =
<Anna.Schumaker@netapp.com> wrote:
>>=20
>> Hi Chuck,
>>=20
>> I'm seeing a huge performance hit with this patch.  I'm just running =
cthon over TCP, and it goes from finishing in 22 seconds to taking well =
over 5 minutes.  I seem to only see this on the read and write tests, =
such as basic test5 taking a minute to finish:
>>=20
>>   ./test5: read and write                                             =
                                         =20
>>           wrote 1048576 byte file 10 times in 60.35 seconds (173737 =
bytes/sec)                                 =20
>>           read 1048576 byte file 10 times in 0.0  seconds =
(-2147483648 bytes/sec)                              =20
>>           ./test5 ok.=20
>=20
> OK. This looks like write is impacted, but this test doesn't
> actually perform any reads on the wire. Try iozone with -I,
> maybe? That would show results for both read and write.

Hum.

Stock v4.16-rc4:

./test5: read and write
	wrote 1048576 byte file 10 times in 0.2  seconds (350811642 =
bytes/sec)
	read 1048576 byte file 10 times in 0.0  seconds (-2147483648 =
bytes/sec)
	./test5 ok.


v4.16-rc4 with my full set of patches:

./test5: read and write
	wrote 1048576 byte file 10 times in 0.2  seconds (354236681 =
bytes/sec)
	read 1048576 byte file 10 times in 0.0  seconds (-2147483648 =
bytes/sec)
	./test5 ok.

I don't see a regression here. Let me know how it goes!


>> I haven't dug into this too deeply, but my best guess is that maybe =
it's due to adding a call to xprt_request_init() in =
net/sunrpc/clnt.c:call_reserveresult()
>=20
> It wasn't added there, it was moved from xprt_alloc_slot. So,
> it's not new work per-RPC.
>=20
> Any additional information would be appreciated!
>=20
>=20
>> Thoughts?
>> Anna
>>=20
>> On 03/05/2018 03:13 PM, Chuck Lever wrote:
>>> alloc_slot is a transport-specific op, but initializing an rpc_rqst
>>> is common to all transports. Move initialization to common code in
>>> preparation for adding a transport-specific alloc_slot to xprtrdma.
>>>=20
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> include/linux/sunrpc/xprt.h |    1 +
>>> net/sunrpc/clnt.c           |    1 +
>>> net/sunrpc/xprt.c           |   12 +++++++-----
>>> 3 files changed, 9 insertions(+), 5 deletions(-)
>>>=20
>>> diff --git a/include/linux/sunrpc/xprt.h =
b/include/linux/sunrpc/xprt.h
>>> index 5fea0fb..9784e28 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -324,6 +324,7 @@ struct xprt_class {
>>> struct rpc_xprt		*xprt_create_transport(struct =
xprt_create *args);
>>> void			xprt_connect(struct rpc_task *task);
>>> void			xprt_reserve(struct rpc_task *task);
>>> +void			xprt_request_init(struct rpc_task =
*task);
>>> void			xprt_retry_reserve(struct rpc_task =
*task);
>>> int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct =
rpc_task *task);
>>> int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, =
struct rpc_task *task);
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 6e432ec..226f558 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1546,6 +1546,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
>>> 	task->tk_status =3D 0;
>>> 	if (status >=3D 0) {
>>> 		if (task->tk_rqstp) {
>>> +			xprt_request_init(task);
>>> 			task->tk_action =3D call_refresh;
>>> 			return;
>>> 		}
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index 70f0050..a394b46 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -66,7 +66,7 @@
>>> * Local functions
>>> */
>>> static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
>>> -static void	xprt_request_init(struct rpc_task *, struct =
rpc_xprt *);
>>> +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
>>> static void	xprt_connect_status(struct rpc_task *task);
>>> static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task =
*);
>>> static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst =
*);
>>> @@ -987,6 +987,8 @@ bool xprt_prepare_transmit(struct rpc_task =
*task)
>>> 		task->tk_status =3D -EAGAIN;
>>> 		goto out_unlock;
>>> 	}
>>> +	if (likely(!bc_prealloc(req)))
>>> +		req->rq_xid =3D xprt_alloc_xid(xprt);
>>> 	ret =3D true;
>>> out_unlock:
>>> 	spin_unlock_bh(&xprt->transport_lock);
>>> @@ -1163,10 +1165,10 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, =
struct rpc_task *task)
>>> out_init_req:
>>> 	xprt->stat.max_slots =3D max_t(unsigned int, =
xprt->stat.max_slots,
>>> 				     xprt->num_reqs);
>>> +	spin_unlock(&xprt->reserve_lock);
>>> +
>>> 	task->tk_status =3D 0;
>>> 	task->tk_rqstp =3D req;
>>> -	xprt_request_init(task, xprt);
>>> -	spin_unlock(&xprt->reserve_lock);
>>> }
>>> EXPORT_SYMBOL_GPL(xprt_alloc_slot);
>>>=20
>>> @@ -1303,8 +1305,9 @@ static inline void xprt_init_xid(struct =
rpc_xprt *xprt)
>>> 	xprt->xid =3D prandom_u32();
>>> }
>>>=20
>>> -static void xprt_request_init(struct rpc_task *task, struct =
rpc_xprt *xprt)
>>> +void xprt_request_init(struct rpc_task *task)
>>> {
>>> +	struct rpc_xprt *xprt =3D task->tk_xprt;
>>> 	struct rpc_rqst	*req =3D task->tk_rqstp;
>>>=20
>>> 	INIT_LIST_HEAD(&req->rq_list);
>>> @@ -1312,7 +1315,6 @@ static void xprt_request_init(struct rpc_task =
*task, struct rpc_xprt *xprt)
>>> 	req->rq_task	=3D task;
>>> 	req->rq_xprt    =3D xprt;
>>> 	req->rq_buffer  =3D NULL;
>>> -	req->rq_xid     =3D xprt_alloc_xid(xprt);
>>> 	req->rq_connect_cookie =3D xprt->connect_cookie - 1;
>>> 	req->rq_bytes_sent =3D 0;
>>> 	req->rq_snd_buf.len =3D 0;
>>>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



