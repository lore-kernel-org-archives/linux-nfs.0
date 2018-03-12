Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:58284 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbeCLOa1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2018 10:30:27 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v2] SUNRPC: Initialize rpc_rqst outside of
 xprt->reserve_lock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0141adad-602c-70d0-08d6-e33b954cc163@talpey.com>
Date: Mon, 12 Mar 2018 10:30:21 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BD616613-2AE5-479E-87B9-F567C6A1DEB0@oracle.com>
References: <20180311152620.16974.96109.stgit@manet.1015granger.net>
 <0141adad-602c-70d0-08d6-e33b954cc163@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom-

Thanks for taking a look!


> On Mar 11, 2018, at 8:41 PM, Tom Talpey <tom@talpey.com> wrote:
>=20
> > +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
>=20
> Why is the type a be32? The XID is opaque, tested only for equality, =
and
> no byte order is defined by the RPC protocol.
>=20
> Methinks it should be u32.

Others have already commented, but I'll throw in my 2 pfennigs worth.

Here, I'm adding a forward declaration for xprt_alloc_xid. The
existing function definition already returns __be32. So the patch
isn't actually altering the function's return type. The forward
declaration added here reflects the existing function definition.

The Linux client places this opaque on the wire without XDR-encoding
it, because, as you observed, this data item is indeed opaque to the
RPC server. No encoding is needed since the remote system does not
interpret these bits.

Therefore what comes out of this function can be considered already
XDR-encoded. XDR is essentially big-endian, and __be32 is how we
denote "already XDR-encoded" data in the Linux kernel, to assist our
static checkers (ie, sparse).

Compare, for example, the constant NFS status values that are handled
by the NFS server. Rather than handling native values and XDR-encoding
them every time, since they are constant they are pre-encoded constant
32-bit integers, already encoded, and therefore their type is __be32.


> Tom.
>=20
> On 3/11/2018 8:27 AM, Chuck Lever wrote:
>> alloc_slot is a transport-specific op, but initializing an rpc_rqst
>> is common to all transports. In addition, the only part of initial-
>> izing an rpc_rqst that needs serialization is getting a fresh XID.
>> Move rpc_rqst initialization to common code in preparation for
>> adding a transport-specific alloc_slot to xprtrdma.
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  include/linux/sunrpc/xprt.h |    1 +
>>  net/sunrpc/clnt.c           |    1 +
>>  net/sunrpc/xprt.c           |   12 +++++++-----
>>  3 files changed, 9 insertions(+), 5 deletions(-)
>> Changes since v1:
>> - Partial sends should not bump the XID
>> diff --git a/include/linux/sunrpc/xprt.h =
b/include/linux/sunrpc/xprt.h
>> index 5fea0fb..9784e28 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -324,6 +324,7 @@ struct xprt_class {
>>  struct rpc_xprt		*xprt_create_transport(struct =
xprt_create *args);
>>  void			xprt_connect(struct rpc_task *task);
>>  void			xprt_reserve(struct rpc_task *task);
>> +void			xprt_request_init(struct rpc_task =
*task);
>>  void			xprt_retry_reserve(struct rpc_task =
*task);
>>  int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct =
rpc_task *task);
>>  int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, =
struct rpc_task *task);
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 6e432ec..226f558 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1546,6 +1546,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
>>  	task->tk_status =3D 0;
>>  	if (status >=3D 0) {
>>  		if (task->tk_rqstp) {
>> +			xprt_request_init(task);
>>  			task->tk_action =3D call_refresh;
>>  			return;
>>  		}
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index 70f0050..2d95926 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -66,7 +66,7 @@
>>   * Local functions
>>   */
>>  static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
>> -static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
>> +static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
>>  static void	xprt_connect_status(struct rpc_task *task);
>>  static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task =
*);
>>  static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst =
*);
>> @@ -987,6 +987,8 @@ bool xprt_prepare_transmit(struct rpc_task *task)
>>  		task->tk_status =3D -EAGAIN;
>>  		goto out_unlock;
>>  	}
>> +	if (!bc_prealloc(req) && !req->rq_xmit_bytes_sent)
>> +		req->rq_xid =3D xprt_alloc_xid(xprt);
>>  	ret =3D true;
>>  out_unlock:
>>  	spin_unlock_bh(&xprt->transport_lock);
>> @@ -1163,10 +1165,10 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, =
struct rpc_task *task)
>>  out_init_req:
>>  	xprt->stat.max_slots =3D max_t(unsigned int, =
xprt->stat.max_slots,
>>  				     xprt->num_reqs);
>> +	spin_unlock(&xprt->reserve_lock);
>> +
>>  	task->tk_status =3D 0;
>>  	task->tk_rqstp =3D req;
>> -	xprt_request_init(task, xprt);
>> -	spin_unlock(&xprt->reserve_lock);
>>  }
>>  EXPORT_SYMBOL_GPL(xprt_alloc_slot);
>>  @@ -1303,8 +1305,9 @@ static inline void xprt_init_xid(struct =
rpc_xprt *xprt)
>>  	xprt->xid =3D prandom_u32();
>>  }
>>  -static void xprt_request_init(struct rpc_task *task, struct =
rpc_xprt *xprt)
>> +void xprt_request_init(struct rpc_task *task)
>>  {
>> +	struct rpc_xprt *xprt =3D task->tk_xprt;
>>  	struct rpc_rqst	*req =3D task->tk_rqstp;
>>    	INIT_LIST_HEAD(&req->rq_list);
>> @@ -1312,7 +1315,6 @@ static void xprt_request_init(struct rpc_task =
*task, struct rpc_xprt *xprt)
>>  	req->rq_task	=3D task;
>>  	req->rq_xprt    =3D xprt;
>>  	req->rq_buffer  =3D NULL;
>> -	req->rq_xid     =3D xprt_alloc_xid(xprt);
>>  	req->rq_connect_cookie =3D xprt->connect_cookie - 1;
>>  	req->rq_bytes_sent =3D 0;
>>  	req->rq_snd_buf.len =3D 0;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



