Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51524 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919AbbIUXFG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 19:05:06 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 05/18] xprtrdma: Replace send and receive arrays
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55FE8FEE.1010006@dev.mellanox.co.il>
Date: Mon, 21 Sep 2015 16:04:28 -0700
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B217F6DC-F6B6-4544-91DB-B4CF2370617C@oracle.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204452.19671.66113.stgit@manet.1015granger.net> <55FE8FEE.1010006@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 20, 2015, at 3:52 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> On 9/17/2015 11:44 PM, Chuck Lever wrote:
>> The rb_send_bufs and rb_recv_bufs arrays are used to implement a
>> pair of stacks for keeping track of free rpcrdma_req and rpcrdma_rep
>> structs. Replace those arrays with free lists.
>> 
>> To allow more than 512 RPCs in-flight at once, each of these arrays
>> would be larger than a page (assuming 8-byte addresses and 4KB
>> pages). Allowing up to 64K in-flight RPCs (as TCP now does), each
>> buffer array would have to be 128 pages. That's an order-6
>> allocation. (Not that we're going there.)
>> 
>> A list is easier to expand dynamically. Instead of allocating a
>> larger array of pointers and copying the existing pointers to the
>> new array, simply append more buffers to each list.
>> 
>> This also makes it simpler to manage receive buffers that might
>> catch backwards-direction calls, or to post receive buffers in
>> bulk to amortize the overhead of ib_post_recv.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Hi Chuck,
> 
> I get the idea of this patch, but it is a bit confusing (to a
> non-educated reader).

OK, let’s see if there’s room for additional improvement.


> Can you explain why sometimes you call put/get_locked routines
> and sometimes you open-code them?

Are you talking about the later patch that adds support for
receiving backwards calls? That probably should use the
existing helpers, shouldn’t it.


> And is it mandatory to have
> the callers lock before calling get/put? Perhaps the code would
> be simpler if the get/put routines would take care of locking
> since rb_lock looks dedicated to them.

Not sure I understand this comment, I thought that the helpers
were already doing the locking.


> 
>> ---
>>  net/sunrpc/xprtrdma/verbs.c     |  141 +++++++++++++++++----------------------
>>  net/sunrpc/xprtrdma/xprt_rdma.h |    9 +-
>>  2 files changed, 66 insertions(+), 84 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index ac1345b..8d99214 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -962,44 +962,18 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
>>  {
>>  	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>>  	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>> -	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
>> -	char *p;
>> -	size_t len;
>>  	int i, rc;
>> 
>> -	buf->rb_max_requests = cdata->max_requests;
>> +	buf->rb_max_requests = r_xprt->rx_data.max_requests;
>>  	spin_lock_init(&buf->rb_lock);
>> 
>> -	/* Need to allocate:
>> -	 *   1.  arrays for send and recv pointers
>> -	 *   2.  arrays of struct rpcrdma_req to fill in pointers
>> -	 *   3.  array of struct rpcrdma_rep for replies
>> -	 * Send/recv buffers in req/rep need to be registered
>> -	 */
>> -	len = buf->rb_max_requests *
>> -		(sizeof(struct rpcrdma_req *) + sizeof(struct rpcrdma_rep *));
>> -
>> -	p = kzalloc(len, GFP_KERNEL);
>> -	if (p == NULL) {
>> -		dprintk("RPC:       %s: req_t/rep_t/pad kzalloc(%zd) failed\n",
>> -			__func__, len);
>> -		rc = -ENOMEM;
>> -		goto out;
>> -	}
>> -	buf->rb_pool = p;	/* for freeing it later */
>> -
>> -	buf->rb_send_bufs = (struct rpcrdma_req **) p;
>> -	p = (char *) &buf->rb_send_bufs[buf->rb_max_requests];
>> -	buf->rb_recv_bufs = (struct rpcrdma_rep **) p;
>> -	p = (char *) &buf->rb_recv_bufs[buf->rb_max_requests];
>> -
>>  	rc = ia->ri_ops->ro_init(r_xprt);
>>  	if (rc)
>>  		goto out;
>> 
>> +	INIT_LIST_HEAD(&buf->rb_send_bufs);
>>  	for (i = 0; i < buf->rb_max_requests; i++) {
>>  		struct rpcrdma_req *req;
>> -		struct rpcrdma_rep *rep;
>> 
>>  		req = rpcrdma_create_req(r_xprt);
>>  		if (IS_ERR(req)) {
>> @@ -1008,7 +982,12 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
>>  			rc = PTR_ERR(req);
>>  			goto out;
>>  		}
>> -		buf->rb_send_bufs[i] = req;
>> +		list_add(&req->rl_free, &buf->rb_send_bufs);
>> +	}
>> +
>> +	INIT_LIST_HEAD(&buf->rb_recv_bufs);
>> +	for (i = 0; i < buf->rb_max_requests + 2; i++) {
>> +		struct rpcrdma_rep *rep;
>> 
>>  		rep = rpcrdma_create_rep(r_xprt);
>>  		if (IS_ERR(rep)) {
>> @@ -1017,7 +996,7 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
>>  			rc = PTR_ERR(rep);
>>  			goto out;
>>  		}
>> -		buf->rb_recv_bufs[i] = rep;
>> +		list_add(&rep->rr_list, &buf->rb_recv_bufs);
>>  	}
>> 
>>  	return 0;
>> @@ -1051,25 +1030,26 @@ void
>>  rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
>>  {
>>  	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
>> -	int i;
>> 
>> -	/* clean up in reverse order from create
>> -	 *   1.  recv mr memory (mr free, then kfree)
>> -	 *   2.  send mr memory (mr free, then kfree)
>> -	 *   3.  MWs
>> -	 */
>> -	dprintk("RPC:       %s: entering\n", __func__);
>> +	while (!list_empty(&buf->rb_recv_bufs)) {
>> +		struct rpcrdma_rep *rep = list_entry(buf->rb_recv_bufs.next,
>> +						     struct rpcrdma_rep,
>> +						     rr_list);
>> 
>> -	for (i = 0; i < buf->rb_max_requests; i++) {
>> -		if (buf->rb_recv_bufs)
>> -			rpcrdma_destroy_rep(ia, buf->rb_recv_bufs[i]);
>> -		if (buf->rb_send_bufs)
>> -			rpcrdma_destroy_req(ia, buf->rb_send_bufs[i]);
>> +		list_del(&rep->rr_list);
>> +		rpcrdma_destroy_rep(ia, rep);
>>  	}
>> 
>> -	ia->ri_ops->ro_destroy(buf);
>> +	while (!list_empty(&buf->rb_send_bufs)) {
>> +		struct rpcrdma_req *req = list_entry(buf->rb_send_bufs.next,
>> +						     struct rpcrdma_req,
>> +						     rl_free);
>> 
>> -	kfree(buf->rb_pool);
>> +		list_del(&req->rl_free);
>> +		rpcrdma_destroy_req(ia, req);
>> +	}
>> +
>> +	ia->ri_ops->ro_destroy(buf);
>>  }
>> 
>>  struct rpcrdma_mw *
>> @@ -1102,24 +1082,27 @@ rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
>>  }
>> 
>>  static void
>> -rpcrdma_buffer_put_sendbuf(struct rpcrdma_req *req, struct rpcrdma_buffer *buf)
>> +rpcrdma_buffer_put_locked(struct rpcrdma_rep *rep, struct rpcrdma_buffer *buf)
>>  {
>> -	buf->rb_send_bufs[--buf->rb_send_index] = req;
>> -	req->rl_niovs = 0;
>> -	if (req->rl_reply) {
>> -		buf->rb_recv_bufs[--buf->rb_recv_index] = req->rl_reply;
>> -		req->rl_reply = NULL;
>> -	}
>> +	list_add_tail(&rep->rr_list, &buf->rb_recv_bufs);
>> +}
>> +
>> +static struct rpcrdma_rep *
>> +rpcrdma_buffer_get_locked(struct rpcrdma_buffer *buf)
>> +{
>> +	struct rpcrdma_rep *rep;
>> +
>> +	rep = list_first_entry(&buf->rb_recv_bufs,
>> +			       struct rpcrdma_rep, rr_list);
>> +	list_del(&rep->rr_list);
>> +
>> +	return rep;
>>  }
> 
> There seems to be a distinction between send/recv buffers. Would it
> make sense to have a symmetric handling for both send/recv buffers?

Or maybe the same helpers could handle both. I’ll have a look
when I get back from SNIA SDC.


>>  /*
>>   * Get a set of request/reply buffers.
>>   *
>> - * Reply buffer (if needed) is attached to send buffer upon return.
>> - * Rule:
>> - *    rb_send_index and rb_recv_index MUST always be pointing to the
>> - *    *next* available buffer (non-NULL). They are incremented after
>> - *    removing buffers, and decremented *before* returning them.
>> + * Reply buffer (if available) is attached to send buffer upon return.
>>   */
>>  struct rpcrdma_req *
>>  rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
>> @@ -1129,25 +1112,22 @@ rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
>> 
>>  	spin_lock_irqsave(&buffers->rb_lock, flags);
>> 
>> -	if (buffers->rb_send_index == buffers->rb_max_requests) {
>> +	if (list_empty(&buffers->rb_send_bufs)) {
>>  		spin_unlock_irqrestore(&buffers->rb_lock, flags);
>> -		dprintk("RPC:       %s: out of request buffers\n", __func__);
>> -		return ((struct rpcrdma_req *)NULL);
>> -	}
>> -
>> -	req = buffers->rb_send_bufs[buffers->rb_send_index];
>> -	if (buffers->rb_send_index < buffers->rb_recv_index) {
>> -		dprintk("RPC:       %s: %d extra receives outstanding (ok)\n",
>> -			__func__,
>> -			buffers->rb_recv_index - buffers->rb_send_index);
>> -		req->rl_reply = NULL;
>> -	} else {
>> -		req->rl_reply = buffers->rb_recv_bufs[buffers->rb_recv_index];
>> -		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
>> +		pr_warn("RPC:       %s: out of request buffers\n", __func__);
>> +		return NULL;
>>  	}
>> -	buffers->rb_send_bufs[buffers->rb_send_index++] = NULL;
>> +	req = list_first_entry(&buffers->rb_send_bufs,
>> +			       struct rpcrdma_req, rl_free);
>> +	list_del(&req->rl_free);
>> 
>> +	req->rl_reply = NULL;
>> +	if (!list_empty(&buffers->rb_recv_bufs))
>> +		req->rl_reply = rpcrdma_buffer_get_locked(buffers);
> 
> Would it make sense to check !list_empty() inside _get_locked and handle
> a possible NULL return?
> 
>>  	spin_unlock_irqrestore(&buffers->rb_lock, flags);
>> +
>> +	if (!req->rl_reply)
>> +		pr_warn("RPC:       %s: out of reply buffers\n", __func__);
>>  	return req;
>>  }
>> 
>> @@ -1159,17 +1139,22 @@ void
>>  rpcrdma_buffer_put(struct rpcrdma_req *req)
>>  {
>>  	struct rpcrdma_buffer *buffers = req->rl_buffer;
>> +	struct rpcrdma_rep *rep = req->rl_reply;
>>  	unsigned long flags;
>> 
>> +	req->rl_niovs = 0;
>> +	req->rl_reply = NULL;
>> +
>>  	spin_lock_irqsave(&buffers->rb_lock, flags);
>> -	rpcrdma_buffer_put_sendbuf(req, buffers);
>> +	list_add_tail(&req->rl_free, &buffers->rb_send_bufs);
>> +	if (rep)
>> +		rpcrdma_buffer_put_locked(rep, buffers);
>>  	spin_unlock_irqrestore(&buffers->rb_lock, flags);
>>  }
>> 
>>  /*
>>   * Recover reply buffers from pool.
>> - * This happens when recovering from error conditions.
>> - * Post-increment counter/array index.
>> + * This happens when recovering from disconnect.
>>   */
>>  void
>>  rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
>> @@ -1178,10 +1163,8 @@ rpcrdma_recv_buffer_get(struct rpcrdma_req *req)
>>  	unsigned long flags;
>> 
>>  	spin_lock_irqsave(&buffers->rb_lock, flags);
>> -	if (buffers->rb_recv_index < buffers->rb_max_requests) {
>> -		req->rl_reply = buffers->rb_recv_bufs[buffers->rb_recv_index];
>> -		buffers->rb_recv_bufs[buffers->rb_recv_index++] = NULL;
>> -	}
>> +	if (!list_empty(&buffers->rb_recv_bufs))
>> +		req->rl_reply = rpcrdma_buffer_get_locked(buffers);
>>  	spin_unlock_irqrestore(&buffers->rb_lock, flags);
>>  }
>> 
>> @@ -1196,7 +1179,7 @@ rpcrdma_recv_buffer_put(struct rpcrdma_rep *rep)
>>  	unsigned long flags;
>> 
>>  	spin_lock_irqsave(&buffers->rb_lock, flags);
>> -	buffers->rb_recv_bufs[--buffers->rb_recv_index] = rep;
>> +	rpcrdma_buffer_put_locked(rep, buffers);
>>  	spin_unlock_irqrestore(&buffers->rb_lock, flags);
>>  }
>> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index a13508b..e6a358f 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -252,6 +252,7 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
>>  #define RPCRDMA_MAX_IOVS	(2)
>> 
>>  struct rpcrdma_req {
>> +	struct list_head	rl_free;
>>  	unsigned int		rl_niovs;
>>  	unsigned int		rl_nchunks;
>>  	unsigned int		rl_connect_cookie;
>> @@ -285,12 +286,10 @@ struct rpcrdma_buffer {
>>  	struct list_head	rb_all;
>>  	char			*rb_pool;
>> 
>> -	spinlock_t		rb_lock;	/* protect buf arrays */
>> +	spinlock_t		rb_lock;	/* protect buf lists */
>> +	struct list_head	rb_send_bufs;
>> +	struct list_head	rb_recv_bufs;
>>  	u32			rb_max_requests;
>> -	int			rb_send_index;
>> -	int			rb_recv_index;
>> -	struct rpcrdma_req	**rb_send_bufs;
>> -	struct rpcrdma_rep	**rb_recv_bufs;
>>  };
>>  #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



