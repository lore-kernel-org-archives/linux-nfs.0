Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:48689 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750711AbeEaU43 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 16:56:29 -0400
Subject: Re: [PATCH v1 10/19] xprtrdma: Move Receive posting to Receive
 handler
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
 <20180504193520.31688.15642.stgit@manet.1015granger.net>
 <5945c510-7996-ea03-cad7-011abaa172c1@Netapp.com>
 <7FBF9DAA-CFF6-465A-889D-AD0C76095DEC@oracle.com>
 <27ddafba-f31d-40b3-0064-f87e3fcd8019@Netapp.com>
 <EA79F37B-EE36-4B97-9E87-6B0AA0F071A0@oracle.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <4c5e3a4b-52a5-ea51-bdea-cb05fae6741a@Netapp.com>
Date: Thu, 31 May 2018 16:55:41 -0400
MIME-Version: 1.0
In-Reply-To: <EA79F37B-EE36-4B97-9E87-6B0AA0F071A0@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/29/2018 02:23 PM, Chuck Lever wrote:
> 
> 
>> On May 8, 2018, at 3:52 PM, Anna Schumaker <anna.schumaker@netapp.com> wrote:
>>
>>
>>
>> On 05/08/2018 03:47 PM, Chuck Lever wrote:
>>>
>>>
>>>> On May 8, 2018, at 3:40 PM, Anna Schumaker <anna.schumaker@netapp.com> wrote:
>>>>
>>>> Hi Chuck,
>>>>
>>>> On 05/04/2018 03:35 PM, Chuck Lever wrote:
>>>>> Receive completion and Reply handling are done by a BOUND
>>>>> workqueue, meaning they run on only one CPU.
>>>>>
>>>>> Posting receives is currently done in the send_request path, which
>>>>> on large systems is typically done on a different CPU than the one
>>>>> handling Receive completions. This results in movement of
>>>>> Receive-related cachelines between the sending and receiving CPUs.
>>>>>
>>>>> More importantly, it means that currently Receives are posted while
>>>>> the transport's write lock is held, which is unnecessary and costly.
>>>>>
>>>>> Finally, allocation of Receive buffers is performed on-demand in
>>>>> the Receive completion handler. This helps guarantee that they are
>>>>> allocated on the same NUMA node as the CPU that handles Receive
>>>>> completions.
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>
>>>> Running this against a 4.17-rc4 server seems to work okay, but running against a 4.16 server fails the cthon special tests with:                                                                                                                                       
>>>>
>>>> write/read 30 MB file                                                                                                                                                                                                       
>>>> verify failed, offset 11272192; expected 79, got                                                                                                                                                                            
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>> 79 79 79 79 79 79 79 79 79 79                                                                                                                                                                                               
>>>>
>>>> and it goes on for several hundred more lines after this.  How worried do we need to be about somebody running a new client against and old server?
>>>
>>> I'm not sure what that result means, I've never seen it
>>> before. But I can't think of a reason there would be an
>>> incompatibility with a v4.16 server. That behavior needs
>>> to be chased down and explained.
>>>
>>> Can you bisect this to a particular commit?
>>
>> Do you mean on the server side?  I don't see the problem on the client until I apply this patch
> 
> Hi Anna-
> 
> Have you made any progress on this? What is the status of my NFS/RDMA
> patch series for v4.18 ?

I haven't been able to reproduce the issue against 4.16 in the last few days, so I'm assuming that whatever fixes it has already been backported.  I'm planning to send your patches to Trond tomorrow.

Anna

> 
> 
>>>> Some of the performance issues I've had in the past seem to have gone away with the 4.17-rc4 code as well.  I'm not sure if that's related to your code or something changing in soft roce, but either way I'm much happier :)
>>>>
>>>> Anna
>>>>
>>>>> ---
>>>>> include/trace/events/rpcrdma.h    |   40 +++++++-
>>>>> net/sunrpc/xprtrdma/backchannel.c |   32 +------
>>>>> net/sunrpc/xprtrdma/rpc_rdma.c    |   22 +----
>>>>> net/sunrpc/xprtrdma/transport.c   |    3 -
>>>>> net/sunrpc/xprtrdma/verbs.c       |  176 +++++++++++++++++++++----------------
>>>>> net/sunrpc/xprtrdma/xprt_rdma.h   |    6 +
>>>>> 6 files changed, 150 insertions(+), 129 deletions(-)
>>>>>
>>>>> diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
>>>>> index 99c0049..ad27e19 100644
>>>>> --- a/include/trace/events/rpcrdma.h
>>>>> +++ b/include/trace/events/rpcrdma.h
>>>>> @@ -546,6 +546,39 @@
>>>>> 	)
>>>>> );
>>>>>
>>>>> +TRACE_EVENT(xprtrdma_post_recvs,
>>>>> +	TP_PROTO(
>>>>> +		const struct rpcrdma_xprt *r_xprt,
>>>>> +		unsigned int count,
>>>>> +		int status
>>>>> +	),
>>>>> +
>>>>> +	TP_ARGS(r_xprt, count, status),
>>>>> +
>>>>> +	TP_STRUCT__entry(
>>>>> +		__field(const void *, r_xprt)
>>>>> +		__field(unsigned int, count)
>>>>> +		__field(int, status)
>>>>> +		__field(int, posted)
>>>>> +		__string(addr, rpcrdma_addrstr(r_xprt))
>>>>> +		__string(port, rpcrdma_portstr(r_xprt))
>>>>> +	),
>>>>> +
>>>>> +	TP_fast_assign(
>>>>> +		__entry->r_xprt = r_xprt;
>>>>> +		__entry->count = count;
>>>>> +		__entry->status = status;
>>>>> +		__entry->posted = r_xprt->rx_buf.rb_posted_receives;
>>>>> +		__assign_str(addr, rpcrdma_addrstr(r_xprt));
>>>>> +		__assign_str(port, rpcrdma_portstr(r_xprt));
>>>>> +	),
>>>>> +
>>>>> +	TP_printk("peer=[%s]:%s r_xprt=%p: %u new recvs, %d active (rc %d)",
>>>>> +		__get_str(addr), __get_str(port), __entry->r_xprt,
>>>>> +		__entry->count, __entry->posted, __entry->status
>>>>> +	)
>>>>> +);
>>>>> +
>>>>> /**
>>>>> ** Completion events
>>>>> **/
>>>>> @@ -800,7 +833,6 @@
>>>>> 		__field(unsigned int, task_id)
>>>>> 		__field(unsigned int, client_id)
>>>>> 		__field(const void *, req)
>>>>> -		__field(const void *, rep)
>>>>> 		__field(size_t, callsize)
>>>>> 		__field(size_t, rcvsize)
>>>>> 	),
>>>>> @@ -809,15 +841,13 @@
>>>>> 		__entry->task_id = task->tk_pid;
>>>>> 		__entry->client_id = task->tk_client->cl_clid;
>>>>> 		__entry->req = req;
>>>>> -		__entry->rep = req ? req->rl_reply : NULL;
>>>>> 		__entry->callsize = task->tk_rqstp->rq_callsize;
>>>>> 		__entry->rcvsize = task->tk_rqstp->rq_rcvsize;
>>>>> 	),
>>>>>
>>>>> -	TP_printk("task:%u@%u req=%p rep=%p (%zu, %zu)",
>>>>> +	TP_printk("task:%u@%u req=%p (%zu, %zu)",
>>>>> 		__entry->task_id, __entry->client_id,
>>>>> -		__entry->req, __entry->rep,
>>>>> -		__entry->callsize, __entry->rcvsize
>>>>> +		__entry->req, __entry->callsize, __entry->rcvsize
>>>>> 	)
>>>>> );
>>>>>
>>>>> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
>>>>> index 4034788..c8f1c2b 100644
>>>>> --- a/net/sunrpc/xprtrdma/backchannel.c
>>>>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>>>>> @@ -71,23 +71,6 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
>>>>> 	return -ENOMEM;
>>>>> }
>>>>>
>>>>> -/* Allocate and add receive buffers to the rpcrdma_buffer's
>>>>> - * existing list of rep's. These are released when the
>>>>> - * transport is destroyed.
>>>>> - */
>>>>> -static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
>>>>> -				 unsigned int count)
>>>>> -{
>>>>> -	int rc = 0;
>>>>> -
>>>>> -	while (count--) {
>>>>> -		rc = rpcrdma_create_rep(r_xprt);
>>>>> -		if (rc)
>>>>> -			break;
>>>>> -	}
>>>>> -	return rc;
>>>>> -}
>>>>> -
>>>>> /**
>>>>> * xprt_rdma_bc_setup - Pre-allocate resources for handling backchannel requests
>>>>> * @xprt: transport associated with these backchannel resources
>>>>> @@ -116,14 +99,6 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
>>>>> 	if (rc)
>>>>> 		goto out_free;
>>>>>
>>>>> -	rc = rpcrdma_bc_setup_reps(r_xprt, reqs);
>>>>> -	if (rc)
>>>>> -		goto out_free;
>>>>> -
>>>>> -	rc = rpcrdma_ep_post_extra_recv(r_xprt, reqs);
>>>>> -	if (rc)
>>>>> -		goto out_free;
>>>>> -
>>>>> 	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
>>>>> 	request_module("svcrdma");
>>>>> 	trace_xprtrdma_cb_setup(r_xprt, reqs);
>>>>> @@ -228,6 +203,7 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
>>>>> 	if (rc < 0)
>>>>> 		goto failed_marshal;
>>>>>
>>>>> +	rpcrdma_post_recvs(r_xprt, true);
>>>>> 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
>>>>> 		goto drop_connection;
>>>>> 	return 0;
>>>>> @@ -268,10 +244,14 @@ void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
>>>>> */
>>>>> void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
>>>>> {
>>>>> +	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
>>>>> 	struct rpc_xprt *xprt = rqst->rq_xprt;
>>>>>
>>>>> 	dprintk("RPC:       %s: freeing rqst %p (req %p)\n",
>>>>> -		__func__, rqst, rpcr_to_rdmar(rqst));
>>>>> +		__func__, rqst, req);
>>>>> +
>>>>> +	rpcrdma_recv_buffer_put(req->rl_reply);
>>>>> +	req->rl_reply = NULL;
>>>>>
>>>>> 	spin_lock_bh(&xprt->bc_pa_lock);
>>>>> 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
>>>>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>>>>> index 8f89e3f..d676106 100644
>>>>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>>>>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>>>>> @@ -1027,8 +1027,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
>>>>>
>>>>> out_short:
>>>>> 	pr_warn("RPC/RDMA short backward direction call\n");
>>>>> -	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
>>>>> -		xprt_disconnect_done(&r_xprt->rx_xprt);
>>>>> 	return true;
>>>>> }
>>>>> #else	/* CONFIG_SUNRPC_BACKCHANNEL */
>>>>> @@ -1334,13 +1332,14 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>>>> 	u32 credits;
>>>>> 	__be32 *p;
>>>>>
>>>>> +	--buf->rb_posted_receives;
>>>>> +
>>>>> 	if (rep->rr_hdrbuf.head[0].iov_len == 0)
>>>>> 		goto out_badstatus;
>>>>>
>>>>> +	/* Fixed transport header fields */
>>>>> 	xdr_init_decode(&rep->rr_stream, &rep->rr_hdrbuf,
>>>>> 			rep->rr_hdrbuf.head[0].iov_base);
>>>>> -
>>>>> -	/* Fixed transport header fields */
>>>>> 	p = xdr_inline_decode(&rep->rr_stream, 4 * sizeof(*p));
>>>>> 	if (unlikely(!p))
>>>>> 		goto out_shortreply;
>>>>> @@ -1379,17 +1378,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>>>>
>>>>> 	trace_xprtrdma_reply(rqst->rq_task, rep, req, credits);
>>>>>
>>>>> +	rpcrdma_post_recvs(r_xprt, false);
>>>>> 	queue_work(rpcrdma_receive_wq, &rep->rr_work);
>>>>> 	return;
>>>>>
>>>>> -out_badstatus:
>>>>> -	rpcrdma_recv_buffer_put(rep);
>>>>> -	if (r_xprt->rx_ep.rep_connected == 1) {
>>>>> -		r_xprt->rx_ep.rep_connected = -EIO;
>>>>> -		rpcrdma_conn_func(&r_xprt->rx_ep);
>>>>> -	}
>>>>> -	return;
>>>>> -
>>>>> out_badversion:
>>>>> 	trace_xprtrdma_reply_vers(rep);
>>>>> 	goto repost;
>>>>> @@ -1409,7 +1401,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>>>> * receive buffer before returning.
>>>>> */
>>>>> repost:
>>>>> -	r_xprt->rx_stats.bad_reply_count++;
>>>>> -	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
>>>>> -		rpcrdma_recv_buffer_put(rep);
>>>>> +	rpcrdma_post_recvs(r_xprt, false);
>>>>> +out_badstatus:
>>>>> +	rpcrdma_recv_buffer_put(rep);
>>>>> }
>>>>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>>>>> index 79885aa..0c775f0 100644
>>>>> --- a/net/sunrpc/xprtrdma/transport.c
>>>>> +++ b/net/sunrpc/xprtrdma/transport.c
>>>>> @@ -722,9 +722,6 @@
>>>>> 	if (rc < 0)
>>>>> 		goto failed_marshal;
>>>>>
>>>>> -	if (req->rl_reply == NULL) 		/* e.g. reconnection */
>>>>> -		rpcrdma_recv_buffer_get(req);
>>>>> -
>>>>> 	/* Must suppress retransmit to maintain credits */
>>>>> 	if (rqst->rq_connect_cookie == xprt->connect_cookie)
>>>>> 		goto drop_connection;
>>>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>>>> index f4ce7af..2a38301 100644
>>>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>>>> @@ -74,6 +74,7 @@
>>>>> */
>>>>> static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
>>>>> static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
>>>>> +static int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
>>>>> static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
>>>>>
>>>>> struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
>>>>> @@ -726,7 +727,6 @@
>>>>> {
>>>>> 	struct rpcrdma_xprt *r_xprt = container_of(ia, struct rpcrdma_xprt,
>>>>> 						   rx_ia);
>>>>> -	unsigned int extras;
>>>>> 	int rc;
>>>>>
>>>>> retry:
>>>>> @@ -770,9 +770,8 @@
>>>>> 	}
>>>>>
>>>>> 	dprintk("RPC:       %s: connected\n", __func__);
>>>>> -	extras = r_xprt->rx_buf.rb_bc_srv_max_requests;
>>>>> -	if (extras)
>>>>> -		rpcrdma_ep_post_extra_recv(r_xprt, extras);
>>>>> +
>>>>> +	rpcrdma_post_recvs(r_xprt, true);
>>>>>
>>>>> out:
>>>>> 	if (rc)
>>>>> @@ -1082,14 +1081,8 @@ struct rpcrdma_req *
>>>>> 	return req;
>>>>> }
>>>>>
>>>>> -/**
>>>>> - * rpcrdma_create_rep - Allocate an rpcrdma_rep object
>>>>> - * @r_xprt: controlling transport
>>>>> - *
>>>>> - * Returns 0 on success or a negative errno on failure.
>>>>> - */
>>>>> -int
>>>>> -rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
>>>>> +static int
>>>>> +rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp)
>>>>> {
>>>>> 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
>>>>> 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>>>>> @@ -1117,6 +1110,7 @@ struct rpcrdma_req *
>>>>> 	rep->rr_recv_wr.wr_cqe = &rep->rr_cqe;
>>>>> 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
>>>>> 	rep->rr_recv_wr.num_sge = 1;
>>>>> +	rep->rr_temp = temp;
>>>>>
>>>>> 	spin_lock(&buf->rb_lock);
>>>>> 	list_add(&rep->rr_list, &buf->rb_recv_bufs);
>>>>> @@ -1168,12 +1162,8 @@ struct rpcrdma_req *
>>>>> 		list_add(&req->rl_list, &buf->rb_send_bufs);
>>>>> 	}
>>>>>
>>>>> +	buf->rb_posted_receives = 0;
>>>>> 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
>>>>> -	for (i = 0; i <= buf->rb_max_requests; i++) {
>>>>> -		rc = rpcrdma_create_rep(r_xprt);
>>>>> -		if (rc)
>>>>> -			goto out;
>>>>> -	}
>>>>>
>>>>> 	rc = rpcrdma_sendctxs_create(r_xprt);
>>>>> 	if (rc)
>>>>> @@ -1268,7 +1258,6 @@ struct rpcrdma_req *
>>>>> 		rep = rpcrdma_buffer_get_rep_locked(buf);
>>>>> 		rpcrdma_destroy_rep(rep);
>>>>> 	}
>>>>> -	buf->rb_send_count = 0;
>>>>>
>>>>> 	spin_lock(&buf->rb_reqslock);
>>>>> 	while (!list_empty(&buf->rb_allreqs)) {
>>>>> @@ -1283,7 +1272,6 @@ struct rpcrdma_req *
>>>>> 		spin_lock(&buf->rb_reqslock);
>>>>> 	}
>>>>> 	spin_unlock(&buf->rb_reqslock);
>>>>> -	buf->rb_recv_count = 0;
>>>>>
>>>>> 	rpcrdma_mrs_destroy(buf);
>>>>> }
>>>>> @@ -1356,27 +1344,11 @@ struct rpcrdma_mr *
>>>>> 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);
>>>>> }
>>>>>
>>>>> -static struct rpcrdma_rep *
>>>>> -rpcrdma_buffer_get_rep(struct rpcrdma_buffer *buffers)
>>>>> -{
>>>>> -	/* If an RPC previously completed without a reply (say, a
>>>>> -	 * credential problem or a soft timeout occurs) then hold off
>>>>> -	 * on supplying more Receive buffers until the number of new
>>>>> -	 * pending RPCs catches up to the number of posted Receives.
>>>>> -	 */
>>>>> -	if (unlikely(buffers->rb_send_count < buffers->rb_recv_count))
>>>>> -		return NULL;
>>>>> -
>>>>> -	if (unlikely(list_empty(&buffers->rb_recv_bufs)))
>>>>> -		return NULL;
>>>>> -	buffers->rb_recv_count++;
>>>>> -	return rpcrdma_buffer_get_rep_locked(buffers);
>>>>> -}
>>>>> -
>>>>> -/*
>>>>> - * Get a set of request/reply buffers.
>>>>> +/**
>>>>> + * rpcrdma_buffer_get - Get a request buffer
>>>>> + * @buffers: Buffer pool from which to obtain a buffer
>>>>> *
>>>>> - * Reply buffer (if available) is attached to send buffer upon return.
>>>>> + * Returns a fresh rpcrdma_req, or NULL if none are available.
>>>>> */
>>>>> struct rpcrdma_req *
>>>>> rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
>>>>> @@ -1384,23 +1356,21 @@ struct rpcrdma_req *
>>>>> 	struct rpcrdma_req *req;
>>>>>
>>>>> 	spin_lock(&buffers->rb_lock);
>>>>> -	if (list_empty(&buffers->rb_send_bufs))
>>>>> -		goto out_reqbuf;
>>>>> -	buffers->rb_send_count++;
>>>>> +	if (unlikely(list_empty(&buffers->rb_send_bufs)))
>>>>> +		goto out_noreqs;
>>>>> 	req = rpcrdma_buffer_get_req_locked(buffers);
>>>>> -	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
>>>>> 	spin_unlock(&buffers->rb_lock);
>>>>> -
>>>>> 	return req;
>>>>>
>>>>> -out_reqbuf:
>>>>> +out_noreqs:
>>>>> 	spin_unlock(&buffers->rb_lock);
>>>>> 	return NULL;
>>>>> }
>>>>>
>>>>> -/*
>>>>> - * Put request/reply buffers back into pool.
>>>>> - * Pre-decrement counter/array index.
>>>>> +/**
>>>>> + * rpcrdma_buffer_put - Put request/reply buffers back into pool
>>>>> + * @req: object to return
>>>>> + *
>>>>> */
>>>>> void
>>>>> rpcrdma_buffer_put(struct rpcrdma_req *req)
>>>>> @@ -1411,27 +1381,16 @@ struct rpcrdma_req *
>>>>> 	req->rl_reply = NULL;
>>>>>
>>>>> 	spin_lock(&buffers->rb_lock);
>>>>> -	buffers->rb_send_count--;
>>>>> -	list_add_tail(&req->rl_list, &buffers->rb_send_bufs);
>>>>> +	list_add(&req->rl_list, &buffers->rb_send_bufs);
>>>>> 	if (rep) {
>>>>> -		buffers->rb_recv_count--;
>>>>> -		list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
>>>>> +		if (!rep->rr_temp) {
>>>>> +			list_add(&rep->rr_list, &buffers->rb_recv_bufs);
>>>>> +			rep = NULL;
>>>>> +		}
>>>>> 	}
>>>>> 	spin_unlock(&buffers->rb_lock);
>>>>> -}
>>>>> -
>>>>> -/*
>>>>> - * Recover reply buffers from pool.
>>>>> - * This happens when recovering from disconnect.
>>>>> - */
>>>>> -void
>>>>> -rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
>>>>> -{
>>>>> -	struct rpcrdma_buffer *buffers = req->rl_buffer;
>>>>> -
>>>>> -	spin_lock(&buffers->rb_lock);
>>>>> -	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
>>>>> -	spin_unlock(&buffers->rb_lock);
>>>>> +	if (rep)
>>>>> +		rpcrdma_destroy_rep(rep);
>>>>> }
>>>>>
>>>>> /*
>>>>> @@ -1443,10 +1402,13 @@ struct rpcrdma_req *
>>>>> {
>>>>> 	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
>>>>>
>>>>> -	spin_lock(&buffers->rb_lock);
>>>>> -	buffers->rb_recv_count--;
>>>>> -	list_add_tail(&rep->rr_list, &buffers->rb_recv_bufs);
>>>>> -	spin_unlock(&buffers->rb_lock);
>>>>> +	if (!rep->rr_temp) {
>>>>> +		spin_lock(&buffers->rb_lock);
>>>>> +		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
>>>>> +		spin_unlock(&buffers->rb_lock);
>>>>> +	} else {
>>>>> +		rpcrdma_destroy_rep(rep);
>>>>> +	}
>>>>> }
>>>>>
>>>>> /**
>>>>> @@ -1542,13 +1504,6 @@ struct rpcrdma_regbuf *
>>>>> 	struct ib_send_wr *send_wr = &req->rl_sendctx->sc_wr;
>>>>> 	int rc;
>>>>>
>>>>> -	if (req->rl_reply) {
>>>>> -		rc = rpcrdma_ep_post_recv(ia, req->rl_reply);
>>>>> -		if (rc)
>>>>> -			return rc;
>>>>> -		req->rl_reply = NULL;
>>>>> -	}
>>>>> -
>>>>> 	if (!ep->rep_send_count ||
>>>>> 	    test_bit(RPCRDMA_REQ_F_TX_RESOURCES, &req->rl_flags)) {
>>>>> 		send_wr->send_flags |= IB_SEND_SIGNALED;
>>>>> @@ -1623,3 +1578,70 @@ struct rpcrdma_regbuf *
>>>>> 	rpcrdma_recv_buffer_put(rep);
>>>>> 	return rc;
>>>>> }
>>>>> +
>>>>> +/**
>>>>> + * rpcrdma_post_recvs - Maybe post some Receive buffers
>>>>> + * @r_xprt: controlling transport
>>>>> + * @temp: when true, allocate temp rpcrdma_rep objects
>>>>> + *
>>>>> + */
>>>>> +void
>>>>> +rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp)
>>>>> +{
>>>>> +	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>>>>> +	struct ib_recv_wr *wr, *bad_wr;
>>>>> +	int needed, count, rc;
>>>>> +
>>>>> +	needed = buf->rb_credits + (buf->rb_bc_srv_max_requests << 1);
>>>>> +	if (buf->rb_posted_receives > needed)
>>>>> +		return;
>>>>> +	needed -= buf->rb_posted_receives;
>>>>> +
>>>>> +	count = 0;
>>>>> +	wr = NULL;
>>>>> +	while (needed) {
>>>>> +		struct rpcrdma_regbuf *rb;
>>>>> +		struct rpcrdma_rep *rep;
>>>>> +
>>>>> +		spin_lock(&buf->rb_lock);
>>>>> +		rep = list_first_entry_or_null(&buf->rb_recv_bufs,
>>>>> +					       struct rpcrdma_rep, rr_list);
>>>>> +		if (likely(rep))
>>>>> +			list_del(&rep->rr_list);
>>>>> +		spin_unlock(&buf->rb_lock);
>>>>> +		if (!rep) {
>>>>> +			if (rpcrdma_create_rep(r_xprt, temp))
>>>>> +				break;
>>>>> +			continue;
>>>>> +		}
>>>>> +
>>>>> +		rb = rep->rr_rdmabuf;
>>>>> +		if (!rpcrdma_regbuf_is_mapped(rb)) {
>>>>> +			if (!__rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, rb)) {
>>>>> +				rpcrdma_recv_buffer_put(rep);
>>>>> +				break;
>>>>> +			}
>>>>> +		}
>>>>> +
>>>>> +		trace_xprtrdma_post_recv(rep->rr_recv_wr.wr_cqe);
>>>>> +		rep->rr_recv_wr.next = wr;
>>>>> +		wr = &rep->rr_recv_wr;
>>>>> +		++count;
>>>>> +		--needed;
>>>>> +	}
>>>>> +	if (!count)
>>>>> +		return;
>>>>> +
>>>>> +	rc = ib_post_recv(r_xprt->rx_ia.ri_id->qp, wr, &bad_wr);
>>>>> +	if (rc) {
>>>>> +		for (wr = bad_wr; wr; wr = wr->next) {
>>>>> +			struct rpcrdma_rep *rep;
>>>>> +
>>>>> +			rep = container_of(wr, struct rpcrdma_rep, rr_recv_wr);
>>>>> +			rpcrdma_recv_buffer_put(rep);
>>>>> +			--count;
>>>>> +		}
>>>>> +	}
>>>>> +	buf->rb_posted_receives += count;
>>>>> +	trace_xprtrdma_post_recvs(r_xprt, count, rc);
>>>>> +}
>>>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>>> index 765e4df..a6d0d6e 100644
>>>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>>> @@ -197,6 +197,7 @@ struct rpcrdma_rep {
>>>>> 	__be32			rr_proc;
>>>>> 	int			rr_wc_flags;
>>>>> 	u32			rr_inv_rkey;
>>>>> +	bool			rr_temp;
>>>>> 	struct rpcrdma_regbuf	*rr_rdmabuf;
>>>>> 	struct rpcrdma_xprt	*rr_rxprt;
>>>>> 	struct work_struct	rr_work;
>>>>> @@ -397,11 +398,11 @@ struct rpcrdma_buffer {
>>>>> 	struct rpcrdma_sendctx	**rb_sc_ctxs;
>>>>>
>>>>> 	spinlock_t		rb_lock;	/* protect buf lists */
>>>>> -	int			rb_send_count, rb_recv_count;
>>>>> 	struct list_head	rb_send_bufs;
>>>>> 	struct list_head	rb_recv_bufs;
>>>>> 	u32			rb_max_requests;
>>>>> 	u32			rb_credits;	/* most recent credit grant */
>>>>> +	int			rb_posted_receives;
>>>>>
>>>>> 	u32			rb_bc_srv_max_requests;
>>>>> 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
>>>>> @@ -558,13 +559,13 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
>>>>> int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
>>>>> 				struct rpcrdma_req *);
>>>>> int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_rep *);
>>>>> +void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
>>>>>
>>>>> /*
>>>>> * Buffer calls - xprtrdma/verbs.c
>>>>> */
>>>>> struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
>>>>> void rpcrdma_destroy_req(struct rpcrdma_req *);
>>>>> -int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt);
>>>>> int rpcrdma_buffer_create(struct rpcrdma_xprt *);
>>>>> void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
>>>>> struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);
>>>>> @@ -577,7 +578,6 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
>>>>>
>>>>> struct rpcrdma_req *rpcrdma_buffer_get(struct rpcrdma_buffer *);
>>>>> void rpcrdma_buffer_put(struct rpcrdma_req *);
>>>>> -void rpcrdma_recv_buffer_get(struct rpcrdma_req *);
>>>>> void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
>>>>>
>>>>> struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
