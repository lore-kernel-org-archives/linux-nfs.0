Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:38872 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbeDCUin (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 16:38:43 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v2] SUNRPC: Initialize rpc_rqst outside of
 xprt->reserve_lock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fa0afd37-bd06-cfe6-4c5f-e471ede3703f@Netapp.com>
Date: Tue, 3 Apr 2018 16:38:37 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <09F0E9FA-19E9-4780-A677-57AEC58CEE95@oracle.com>
References: <20180311152620.16974.96109.stgit@manet.1015granger.net>
 <fa0afd37-bd06-cfe6-4c5f-e471ede3703f@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 3, 2018, at 4:12 PM, Anna Schumaker <Anna.Schumaker@netapp.com> =
wrote:
>=20
> Hi Chuck,
>=20
> On 03/11/2018 11:27 AM, Chuck Lever wrote:
>> alloc_slot is a transport-specific op, but initializing an rpc_rqst
>> is common to all transports. In addition, the only part of initial-
>> izing an rpc_rqst that needs serialization is getting a fresh XID.
>>=20
>> Move rpc_rqst initialization to common code in preparation for
>> adding a transport-specific alloc_slot to xprtrdma.
>=20
> I'm having trouble with this patch again.  This time I'm running =
xfstests generic/074 with NFS v4.0, and my client starts seeing "nfs: =
server 192.168.100.215 not responding, still trying" after about a =
minute.  Any thoughts about what's going on here?

Random thoughts:

"nfs: server not responding" is a very generic failure. One
minute is the TCP timeout setting. NFSv4.0 clients don't
typically retransmit unless the server drops the connection.

What is your client, server, and network configuration?

Can you reproduce with NFSv3 or NFSv4.1? I assume you are
using TCP for this test.

Any other relevant messages in the client's or server's /v/l/m?


> I keep trying to capture it with Wireshark, but there are enough =
packets on the wire to crash Wireshark.

Use tcpdump instead, and capture into a tmpfs.


> Thoughts?
> Anna
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xprt.h |    1 +
>> net/sunrpc/clnt.c           |    1 +
>> net/sunrpc/xprt.c           |   12 +++++++-----
>> 3 files changed, 9 insertions(+), 5 deletions(-)
>>=20
>> Changes since v1:
>> - Partial sends should not bump the XID
>>=20
>> diff --git a/include/linux/sunrpc/xprt.h =
b/include/linux/sunrpc/xprt.h
>> index 5fea0fb..9784e28 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -324,6 +324,7 @@ struct xprt_class {
>> struct rpc_xprt		*xprt_create_transport(struct =
xprt_create *args);
>> void			xprt_connect(struct rpc_task *task);
>> void			xprt_reserve(struct rpc_task *task);
>> +void			xprt_request_init(struct rpc_task =
*task);
>> void			xprt_retry_reserve(struct rpc_task *task);
>> int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct =
rpc_task *task);
>> int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, =
struct rpc_task *task);
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 6e432ec..226f558 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1546,6 +1546,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
>> 	task->tk_status =3D 0;
>> 	if (status >=3D 0) {
>> 		if (task->tk_rqstp) {
>> +			xprt_request_init(task);
>> 			task->tk_action =3D call_refresh;
>> 			return;
>> 		}
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 70f0050..2d95926 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -66,7 +66,7 @@
>>  * Local functions
>>  */
>> static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
>> -static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
>> +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
>> static void	xprt_connect_status(struct rpc_task *task);
>> static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task =
*);
>> static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst =
*);
>> @@ -987,6 +987,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
>> 		task->tk_status =3D -EAGAIN;
>> 		goto out_unlock;
>> 	}
>> +	if (!bc_prealloc(req) && !req->rq_xmit_bytes_sent)
>> +		req->rq_xid =3D xprt_alloc_xid(xprt);
>> 	ret =3D true;
>> out_unlock:
>> 	spin_unlock_bh(&xprt->transport_lock);
>> @@ -1163,10 +1165,10 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, =
struct rpc_task *task)
>> out_init_req:
>> 	xprt->stat.max_slots =3D max_t(unsigned int, =
xprt->stat.max_slots,
>> 				     xprt->num_reqs);
>> +	spin_unlock(&xprt->reserve_lock);
>> +
>> 	task->tk_status =3D 0;
>> 	task->tk_rqstp =3D req;
>> -	xprt_request_init(task, xprt);
>> -	spin_unlock(&xprt->reserve_lock);
>> }
>> EXPORT_SYMBOL_GPL(xprt_alloc_slot);
>>=20
>> @@ -1303,8 +1305,9 @@ static inline void xprt_init_xid(struct =
rpc_xprt *xprt)
>> 	xprt->xid =3D prandom_u32();
>> }
>>=20
>> -static void xprt_request_init(struct rpc_task *task, struct rpc_xprt =
*xprt)
>> +void xprt_request_init(struct rpc_task *task)
>> {
>> +	struct rpc_xprt *xprt =3D task->tk_xprt;
>> 	struct rpc_rqst	*req =3D task->tk_rqstp;
>>=20
>> 	INIT_LIST_HEAD(&req->rq_list);
>> @@ -1312,7 +1315,6 @@ static void xprt_request_init(struct rpc_task =
*task, struct rpc_xprt *xprt)
>> 	req->rq_task	=3D task;
>> 	req->rq_xprt    =3D xprt;
>> 	req->rq_buffer  =3D NULL;
>> -	req->rq_xid     =3D xprt_alloc_xid(xprt);
>> 	req->rq_connect_cookie =3D xprt->connect_cookie - 1;
>> 	req->rq_bytes_sent =3D 0;
>> 	req->rq_snd_buf.len =3D 0;
>>=20

--
Chuck Lever



