Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:40283 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727465AbeICWLG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 18:11:06 -0400
Received: by mail-it0-f67.google.com with SMTP id h23-v6so1851776ita.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 10:49:52 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 20/27] SUNRPC: Treat the task and request as separate in
 the xprt_ops->send_request()
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <0b84ef010e4b3e4d156b6b7ac60c5fb0c2a48627.camel@gmail.com>
Date: Mon, 3 Sep 2018 13:49:50 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4CBB86A7-C070-468C-A36E-2B586BEBD952@gmail.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
 <20180903152936.24325-14-trond.myklebust@hammerspace.com>
 <20180903152936.24325-15-trond.myklebust@hammerspace.com>
 <20180903152936.24325-16-trond.myklebust@hammerspace.com>
 <20180903152936.24325-17-trond.myklebust@hammerspace.com>
 <20180903152936.24325-18-trond.myklebust@hammerspace.com>
 <20180903152936.24325-19-trond.myklebust@hammerspace.com>
 <20180903152936.24325-20-trond.myklebust@hammerspace.com>
 <20180903152936.24325-21-trond.myklebust@hammerspace.com>
 <C7D44AFD-1BFF-4FB9-A4AB-AF60F836DA34@gmail.com>
 <0b84ef010e4b3e4d156b6b7ac60c5fb0c2a48627.camel@gmail.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 3, 2018, at 1:47 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> On Mon, 2018-09-03 at 13:28 -0400, Chuck Lever wrote:
>>> On Sep 3, 2018, at 11:29 AM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>> 
>>> When we shift to using the transmit queue, then the task that holds
>>> the
>>> write lock will not necessarily be the same as the one being
>>> transmitted.
>> 
>> Can you pass in just the rpc_rqst? Then @task would be available as
>> xprt->snd_task.
> 
> No. The point is that when we add queueing, @req->rq_task will usually
> be asleep on xprt->sending. Only the task that holds the XPRT_LOCK is
> awake, and so it is the one that needs to be put asleep when we hit a
> socket nospace/EAGAIN error.

Right, that task is rqst->rq_xprt->snd_task, isn't it?


> We _could_ potentially avoid passing in the task at all, and just have
> xs_nospace() put xprt->snd_task to sleep, but that would skirt the edge
> of a transport layering violation.
> 
>> 
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>> include/linux/sunrpc/xprt.h                |  2 +-
>>> net/sunrpc/xprt.c                          |  2 +-
>>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  3 +--
>>> net/sunrpc/xprtrdma/transport.c            |  5 ++--
>>> net/sunrpc/xprtsock.c                      | 27 +++++++++++------
>>> -----
>>> 5 files changed, 18 insertions(+), 21 deletions(-)
>>> 
>>> diff --git a/include/linux/sunrpc/xprt.h
>>> b/include/linux/sunrpc/xprt.h
>>> index 81a6c2c8dfc7..6d91acfe0644 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -140,7 +140,7 @@ struct rpc_xprt_ops {
>>> 	void		(*connect)(struct rpc_xprt *xprt, struct
>>> rpc_task *task);
>>> 	int		(*buf_alloc)(struct rpc_task *task);
>>> 	void		(*buf_free)(struct rpc_task *task);
>>> -	int		(*send_request)(struct rpc_task *task);
>>> +	int		(*send_request)(struct rpc_rqst *req, struct
>>> rpc_task *task);
>>> 	void		(*set_retrans_timeout)(struct rpc_task
>>> *task);
>>> 	void		(*timer)(struct rpc_xprt *xprt, struct
>>> rpc_task *task);
>>> 	void		(*release_request)(struct rpc_task *task);
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index defc6167570a..3efcb69af526 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -1170,7 +1170,7 @@ void xprt_transmit(struct rpc_task *task)
>>> 	}
>>> 
>>> 	connect_cookie = xprt->connect_cookie;
>>> -	status = xprt->ops->send_request(task);
>>> +	status = xprt->ops->send_request(req, task);
>>> 	trace_xprt_transmit(xprt, req->rq_xid, status);
>>> 	if (status != 0) {
>>> 		task->tk_status = status;
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>>> b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>>> index 09b12b7568fe..d1618c70edb4 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>>> @@ -215,9 +215,8 @@ rpcrdma_bc_send_request(struct svcxprt_rdma
>>> *rdma, struct rpc_rqst *rqst)
>>> * connection.
>>> */
>>> static int
>>> -xprt_rdma_bc_send_request(struct rpc_task *task)
>>> +xprt_rdma_bc_send_request(struct rpc_rqst *rqst, struct rpc_task
>>> *task)
>>> {
>>> -	struct rpc_rqst *rqst = task->tk_rqstp;
>>> 	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
>>> 	struct svcxprt_rdma *rdma;
>>> 	int ret;
>>> diff --git a/net/sunrpc/xprtrdma/transport.c
>>> b/net/sunrpc/xprtrdma/transport.c
>>> index 143ce2579ba9..fa684bf4d090 100644
>>> --- a/net/sunrpc/xprtrdma/transport.c
>>> +++ b/net/sunrpc/xprtrdma/transport.c
>>> @@ -706,9 +706,8 @@ xprt_rdma_free(struct rpc_task *task)
>>> *		sent. Do not try to send this message again.
>>> */
>>> static int
>>> -xprt_rdma_send_request(struct rpc_task *task)
>>> +xprt_rdma_send_request(struct rpc_rqst *rqst, struct rpc_task
>>> *task)
>> 
>> Nit: The function's documenting comment will need to be updated.
>> 
>> 
>>> {
>>> -	struct rpc_rqst *rqst = task->tk_rqstp;
>>> 	struct rpc_xprt *xprt = rqst->rq_xprt;
>>> 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
>>> 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>>> @@ -741,7 +740,7 @@ xprt_rdma_send_request(struct rpc_task *task)
>>> 	/* An RPC with no reply will throw off credit accounting,
>>> 	 * so drop the connection to reset the credit grant.
>>> 	 */
>>> -	if (!rpc_reply_expected(task))
>>> +	if (!rpc_reply_expected(rqst->rq_task))
>>> 		goto drop_connection;
>>> 	return 0;
>>> 
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 8d6404259ff9..b8143eded4af 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -449,12 +449,12 @@ static void xs_nospace_callback(struct
>>> rpc_task *task)
>>> 
>>> /**
>>> * xs_nospace - place task on wait queue if transmit was incomplete
>>> + * @req: pointer to RPC request
>>> * @task: task to put to sleep
>>> *
>>> */
>>> -static int xs_nospace(struct rpc_task *task)
>>> +static int xs_nospace(struct rpc_rqst *req, struct rpc_task *task)
>>> {
>>> -	struct rpc_rqst *req = task->tk_rqstp;
>>> 	struct rpc_xprt *xprt = req->rq_xprt;
>>> 	struct sock_xprt *transport = container_of(xprt, struct
>>> sock_xprt, xprt);
>>> 	struct sock *sk = transport->inet;
>>> @@ -513,6 +513,7 @@ static inline void
>>> xs_encode_stream_record_marker(struct xdr_buf *buf)
>>> 
>>> /**
>>> * xs_local_send_request - write an RPC request to an AF_LOCAL
>>> socket
>>> + * @req: pointer to RPC request
>>> * @task: RPC task that manages the state of an RPC request
>>> *
>>> * Return values:
>>> @@ -522,9 +523,8 @@ static inline void
>>> xs_encode_stream_record_marker(struct xdr_buf *buf)
>>> * ENOTCONN:	Caller needs to invoke connect logic then call
>>> again
>>> *    other:	Some other error occured, the request was not
>>> sent
>>> */
>>> -static int xs_local_send_request(struct rpc_task *task)
>>> +static int xs_local_send_request(struct rpc_rqst *req, struct
>>> rpc_task *task)
>>> {
>>> -	struct rpc_rqst *req = task->tk_rqstp;
>>> 	struct rpc_xprt *xprt = req->rq_xprt;
>>> 	struct sock_xprt *transport =
>>> 				container_of(xprt, struct sock_xprt,
>>> xprt);
>>> @@ -569,7 +569,7 @@ static int xs_local_send_request(struct
>>> rpc_task *task)
>>> 	case -ENOBUFS:
>>> 		break;
>>> 	case -EAGAIN:
>>> -		status = xs_nospace(task);
>>> +		status = xs_nospace(req, task);
>>> 		break;
>>> 	default:
>>> 		dprintk("RPC:       sendmsg returned unrecognized error
>>> %d\n",
>>> @@ -585,6 +585,7 @@ static int xs_local_send_request(struct
>>> rpc_task *task)
>>> 
>>> /**
>>> * xs_udp_send_request - write an RPC request to a UDP socket
>>> + * @req: pointer to RPC request
>>> * @task: address of RPC task that manages the state of an RPC
>>> request
>>> *
>>> * Return values:
>>> @@ -594,9 +595,8 @@ static int xs_local_send_request(struct
>>> rpc_task *task)
>>> * ENOTCONN:	Caller needs to invoke connect logic then call
>>> again
>>> *    other:	Some other error occurred, the request was not
>>> sent
>>> */
>>> -static int xs_udp_send_request(struct rpc_task *task)
>>> +static int xs_udp_send_request(struct rpc_rqst *req, struct
>>> rpc_task *task)
>>> {
>>> -	struct rpc_rqst *req = task->tk_rqstp;
>>> 	struct rpc_xprt *xprt = req->rq_xprt;
>>> 	struct sock_xprt *transport = container_of(xprt, struct
>>> sock_xprt, xprt);
>>> 	struct xdr_buf *xdr = &req->rq_snd_buf;
>>> @@ -638,7 +638,7 @@ static int xs_udp_send_request(struct rpc_task
>>> *task)
>>> 		/* Should we call xs_close() here? */
>>> 		break;
>>> 	case -EAGAIN:
>>> -		status = xs_nospace(task);
>>> +		status = xs_nospace(req, task);
>>> 		break;
>>> 	case -ENETUNREACH:
>>> 	case -ENOBUFS:
>>> @@ -658,6 +658,7 @@ static int xs_udp_send_request(struct rpc_task
>>> *task)
>>> 
>>> /**
>>> * xs_tcp_send_request - write an RPC request to a TCP socket
>>> + * @req: pointer to RPC request
>>> * @task: address of RPC task that manages the state of an RPC
>>> request
>>> *
>>> * Return values:
>>> @@ -670,9 +671,8 @@ static int xs_udp_send_request(struct rpc_task
>>> *task)
>>> * XXX: In the case of soft timeouts, should we eventually give up
>>> *	if sendmsg is not able to make progress?
>>> */
>>> -static int xs_tcp_send_request(struct rpc_task *task)
>>> +static int xs_tcp_send_request(struct rpc_rqst *req, struct
>>> rpc_task *task)
>>> {
>>> -	struct rpc_rqst *req = task->tk_rqstp;
>>> 	struct rpc_xprt *xprt = req->rq_xprt;
>>> 	struct sock_xprt *transport = container_of(xprt, struct
>>> sock_xprt, xprt);
>>> 	struct xdr_buf *xdr = &req->rq_snd_buf;
>>> @@ -697,7 +697,7 @@ static int xs_tcp_send_request(struct rpc_task
>>> *task)
>>> 	 * completes while the socket holds a reference to the pages,
>>> 	 * then we may end up resending corrupted data.
>>> 	 */
>>> -	if (task->tk_flags & RPC_TASK_SENT)
>>> +	if (req->rq_task->tk_flags & RPC_TASK_SENT)
>>> 		zerocopy = false;
>>> 
>>> 	if (test_bit(XPRT_SOCK_UPD_TIMEOUT, &transport->sock_state))
>>> @@ -761,7 +761,7 @@ static int xs_tcp_send_request(struct rpc_task
>>> *task)
>>> 		/* Should we call xs_close() here? */
>>> 		break;
>>> 	case -EAGAIN:
>>> -		status = xs_nospace(task);
>>> +		status = xs_nospace(req, task);
>>> 		break;
>>> 	case -ECONNRESET:
>>> 	case -ECONNREFUSED:
>>> @@ -2706,9 +2706,8 @@ static int bc_sendto(struct rpc_rqst *req)
>>> /*
>>> * The send routine. Borrows from svc_send
>>> */
>>> -static int bc_send_request(struct rpc_task *task)
>>> +static int bc_send_request(struct rpc_rqst *req, struct rpc_task
>>> *task)
>>> {
>>> -	struct rpc_rqst *req = task->tk_rqstp;
>>> 	struct svc_xprt	*xprt;
>>> 	int len;
>>> 
>>> -- 
>>> 2.17.1
>>> 
>> 
>> --
>> Chuck Lever
>> chucklever@gmail.com
>> 
>> 
>> 
> 

--
Chuck Lever
chucklever@gmail.com
