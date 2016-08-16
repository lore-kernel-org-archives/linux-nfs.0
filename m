Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34119 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbcHPBVF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 21:21:05 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 03/22] SUNRPC: Generalize the RPC buffer allocation API
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CD81109C-4EB7-4925-9D30-852D3440ACF3@primarydata.com>
Date: Mon, 15 Aug 2016 21:20:57 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0AC75666-AE72-4669-A47D-9CB3AFBD0B9C@oracle.com>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net> <20160815205038.11652.47749.stgit@manet.1015granger.net> <CD81109C-4EB7-4925-9D30-852D3440ACF3@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2016, at 5:59 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
>> 
>> On Aug 15, 2016, at 16:50, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> xprtrdma needs to allocate the Call and Reply buffers separately.
>> TBH, the reliance on using a single buffer for the pair of XDR
>> buffers is transport implementation-specific.
>> 
>> Transports that want to allocate separate Call and Reply buffers
>> will ignore the "size" argument anyway.  Don't bother passing it.
>> 
>> The buf_alloc method can't return two pointers. Instead, make the
>> method's return value an error code, and set the rq_buffer pointer
>> in the method itself.
>> 
>> This gives call_allocate an opportunity to terminate an RPC instead
>> of looping forever when a permanent problem occurs. If a request is
>> just bogus, or the transport is in a state where it can't allocate
>> resources for any request, there needs to be a way to kill the RPC
>> right there and not loop.
>> 
>> This immediately fixes a rare problem in the backchannel send path,
>> which loops if the server happens to send a CB request whose
>> call+reply size is larger than a page (which it shouldn't do yet).
>> 
>> One more issue: looks like xprt_inject_disconnect was incorrectly
>> placed in the failure path in call_allocate. It needs to be in the
>> success path, as it is for other call-sites.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/sched.h               |    2 +-
>> include/linux/sunrpc/xprt.h                |    2 +-
>> net/sunrpc/clnt.c                          |   12 ++++++++----
>> net/sunrpc/sched.c                         |   24 +++++++++++++++---------
>> net/sunrpc/sunrpc.h                        |    2 +-
>> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 +++++++++--------
>> net/sunrpc/xprtrdma/transport.c            |   26 ++++++++++++++++++--------
>> net/sunrpc/xprtsock.c                      |   17 +++++++++++------
>> 8 files changed, 64 insertions(+), 38 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
>> index 817af0b..38d4c1b 100644
>> --- a/include/linux/sunrpc/sched.h
>> +++ b/include/linux/sunrpc/sched.h
>> @@ -239,7 +239,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
>> 					void *);
>> void		rpc_wake_up_status(struct rpc_wait_queue *, int);
>> void		rpc_delay(struct rpc_task *, unsigned long);
>> -void *		rpc_malloc(struct rpc_task *, size_t);
>> +int		rpc_malloc(struct rpc_task *);
>> void		rpc_free(void *);
>> int		rpciod_up(void);
>> void		rpciod_down(void);
>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>> index 559dad3..6f0f796 100644
>> --- a/include/linux/sunrpc/xprt.h
>> +++ b/include/linux/sunrpc/xprt.h
>> @@ -127,7 +127,7 @@ struct rpc_xprt_ops {
>> 	void		(*rpcbind)(struct rpc_task *task);
>> 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
>> 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
>> -	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
>> +	int		(*buf_alloc)(struct rpc_task *task);
>> 	void		(*buf_free)(void *buffer);
>> 	int		(*send_request)(struct rpc_task *task);
>> 	void		(*set_retrans_timeout)(struct rpc_task *task);
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 0e75369..601b3ca 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1693,6 +1693,7 @@ call_allocate(struct rpc_task *task)
>> 	struct rpc_rqst *req = task->tk_rqstp;
>> 	struct rpc_xprt *xprt = req->rq_xprt;
>> 	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
>> +	int status;
>> 
>> 	dprint_status(task);
>> 
>> @@ -1718,11 +1719,14 @@ call_allocate(struct rpc_task *task)
>> 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
>> 	req->rq_rcvsize <<= 2;
>> 
>> -	req->rq_buffer = xprt->ops->buf_alloc(task,
>> -					req->rq_callsize + req->rq_rcvsize);
>> -	if (req->rq_buffer != NULL)
>> -		return;
>> +	status = xprt->ops->buf_alloc(task);
>> 	xprt_inject_disconnect(xprt);
>> +	if (status == 0)
>> +		return;
>> +	if (status == -EIO) {
>> +		rpc_exit(task, -EIO);
> 
> What does EIO mean in this context, and why should it be a fatal error? A buffer allocation is not normally considered to be I/O.

Here I'm using it to mean "some permanent error occurred" as
opposed to something like EAGAIN or ENOMEM, meaning "transient
error, it's OK to try again later."

So, at one point, this patch series changed xprt_rdma_allocate
to return EIO if DMA mapping could not be done on the returned
buffer. That kind of maybe qualifies as a local I/O error.

Or, in the backchannel, if the caller has specified a buffer
size that is too large, the RPC needs to be killed; otherwise
call_allocate will simply delay and call again, with the same
result over and over. In that case, EINVAL might be more
appropriate.

But -EIO is the usual status when an RPC is killed. It depends
on what you want to allow to be leaked upwards.


>> +		return;
>> +	}
>> 
>> 	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
>> 
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index 9ae5885..b964d40 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -849,14 +849,17 @@ static void rpc_async_schedule(struct work_struct *work)
>> }
>> 
>> /**
>> - * rpc_malloc - allocate an RPC buffer
>> - * @task: RPC task that will use this buffer
>> - * @size: requested byte size
>> + * rpc_malloc - allocate RPC buffer resources
>> + * @task: RPC task
>> + *
>> + * A single memory region is allocated, which is split between the
>> + * RPC call and RPC reply that this task is being used for. When
>> + * this RPC is retired, the memory is released by calling rpc_free.
>> *
>> * To prevent rpciod from hanging, this allocator never sleeps,
>> - * returning NULL and suppressing warning if the request cannot be serviced
>> - * immediately.
>> - * The caller can arrange to sleep in a way that is safe for rpciod.
>> + * returning -ENOMEM and suppressing warning if the request cannot
>> + * be serviced immediately. The caller can arrange to sleep in a
>> + * way that is safe for rpciod.
>> *
>> * Most requests are 'small' (under 2KiB) and can be serviced from a
>> * mempool, ensuring that NFS reads and writes can always proceed,
>> @@ -865,8 +868,10 @@ static void rpc_async_schedule(struct work_struct *work)
>> * In order to avoid memory starvation triggering more writebacks of
>> * NFS requests, we avoid using GFP_KERNEL.
>> */
>> -void *rpc_malloc(struct rpc_task *task, size_t size)
>> +int rpc_malloc(struct rpc_task *task)
>> {
>> +	struct rpc_rqst *rqst = task->tk_rqstp;
>> +	size_t size = rqst->rq_callsize + rqst->rq_rcvsize;
>> 	struct rpc_buffer *buf;
>> 	gfp_t gfp = GFP_NOIO | __GFP_NOWARN;
>> 
>> @@ -880,12 +885,13 @@ void *rpc_malloc(struct rpc_task *task, size_t size)
>> 		buf = kmalloc(size, gfp);
>> 
>> 	if (!buf)
>> -		return NULL;
>> +		return -ENOMEM;
>> 
>> 	buf->len = size;
>> 	dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
>> 			task->tk_pid, size, buf);
>> -	return &buf->data;
>> +	rqst->rq_buffer = buf->data;
>> +	return 0;
>> }
>> EXPORT_SYMBOL_GPL(rpc_malloc);
>> 
>> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
>> index f2b7cb5..a4f44ca 100644
>> --- a/net/sunrpc/sunrpc.h
>> +++ b/net/sunrpc/sunrpc.h
>> @@ -34,7 +34,7 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>> */
>> struct rpc_buffer {
>> 	size_t	len;
>> -	char	data[];
>> +	__be32	data[];
> 
> Again, why? Nothing should be touching the data contents directly from this pointer.

Technically, the contents of this buffer are network-byte-order,
and are accessed in four-octet pieces, so __be32 * is the correctly-
annotated type to use.

The type change in this patch and the previous aren't required for
proper function, though. I just wanted to cut down on the amount of
implicit and explicit pointer type casting that's going on. It can
be reworked if you prefer.

Thanks for the review!


>> };
>> 
>> static inline int rpc_reply_expected(struct rpc_task *task)
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> index a2a7519..b7c698f7f 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
>> @@ -159,29 +159,30 @@ out_unmap:
>> /* Server-side transport endpoint wants a whole page for its send
>> * buffer. The client RPC code constructs the RPC header in this
>> * buffer before it invokes ->send_request.
>> - *
>> - * Returns NULL if there was a temporary allocation failure.
>> */
>> -static void *
>> -xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
>> +static int
>> +xprt_rdma_bc_allocate(struct rpc_task *task)
>> {
>> 	struct rpc_rqst *rqst = task->tk_rqstp;
>> 	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
>> +	size_t size = rqst->rq_callsize;
>> 	struct svcxprt_rdma *rdma;
>> 	struct page *page;
>> 
>> 	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
>> 
>> -	/* Prevent an infinite loop: try to make this case work */
>> -	if (size > PAGE_SIZE)
>> +	if (size > PAGE_SIZE) {
>> 		WARN_ONCE(1, "svcrdma: large bc buffer request (size %zu)\n",
>> 			  size);
>> +		return -EIO;
>> +	}
>> 
>> 	page = alloc_page(RPCRDMA_DEF_GFP);
>> 	if (!page)
>> -		return NULL;
>> +		return -ENOMEM;
>> 
>> -	return page_address(page);
>> +	rqst->rq_buffer = page_address(page);
>> +	return 0;
>> }
>> 
>> static void
>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>> index be95ece..daa7d4d 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -477,7 +477,15 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
>> 	}
>> }
>> 
>> -/*
>> +/**
>> + * xprt_rdma_allocate - allocate transport resources for an RPC
>> + * @task: RPC task
>> + *
>> + * Return values:
>> + *        0:	Success; rq_buffer points to RPC buffer to use
>> + *   ENOMEM:	Out of memory, call again later
>> + *      EIO:	A permanent error occurred, do not retry
>> + *
>> * The RDMA allocate/free functions need the task structure as a place
>> * to hide the struct rpcrdma_req, which is necessary for the actual send/recv
>> * sequence.
>> @@ -486,11 +494,12 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
>> * (rq_send_buf and rq_rcv_buf are both part of a single contiguous buffer).
>> * We may register rq_rcv_buf when using reply chunks.
>> */
>> -static void *
>> -xprt_rdma_allocate(struct rpc_task *task, size_t size)
>> +static int
>> +xprt_rdma_allocate(struct rpc_task *task)
>> {
>> -	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
>> -	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>> +	struct rpc_rqst *rqst = task->tk_rqstp;
>> +	size_t size = rqst->rq_callsize + rqst->rq_rcvsize;
>> +	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
>> 	struct rpcrdma_regbuf *rb;
>> 	struct rpcrdma_req *req;
>> 	size_t min_size;
>> @@ -498,7 +507,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
>> 
>> 	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
>> 	if (req == NULL)
>> -		return NULL;
>> +		return -ENOMEM;
>> 
>> 	flags = RPCRDMA_DEF_GFP;
>> 	if (RPC_IS_SWAPPER(task))
>> @@ -515,7 +524,8 @@ out:
>> 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
>> 	req->rl_connect_cookie = 0;	/* our reserved value */
>> 	req->rl_task = task;
>> -	return req->rl_sendbuf->rg_base;
>> +	rqst->rq_buffer = req->rl_sendbuf->rg_base;
>> +	return 0;
>> 
>> out_rdmabuf:
>> 	min_size = r_xprt->rx_data.inline_wsize;
>> @@ -558,7 +568,7 @@ out_sendbuf:
>> 
>> out_fail:
>> 	rpcrdma_buffer_put(req);
>> -	return NULL;
>> +	return -ENOMEM;
>> }
>> 
>> /*
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 8ede3bc..d6db5cf 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2533,23 +2533,28 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>> * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
>> * to use the server side send routines.
>> */
>> -static void *bc_malloc(struct rpc_task *task, size_t size)
>> +static int bc_malloc(struct rpc_task *task)
>> {
>> +	struct rpc_rqst *rqst = task->tk_rqstp;
>> +	size_t size = rqst->rq_callsize;
>> 	struct page *page;
>> 	struct rpc_buffer *buf;
>> 
>> -	WARN_ON_ONCE(size > PAGE_SIZE - sizeof(struct rpc_buffer));
>> -	if (size > PAGE_SIZE - sizeof(struct rpc_buffer))
>> -		return NULL;
>> +	if (size > PAGE_SIZE - sizeof(struct rpc_buffer)) {
>> +		WARN_ONCE(1, "xprtsock: large bc buffer request (size %zu)\n",
>> +			  size);
>> +		return -EIO;
>> +	}
>> 
>> 	page = alloc_page(GFP_KERNEL);
>> 	if (!page)
>> -		return NULL;
>> +		return -ENOMEM;
>> 
>> 	buf = page_address(page);
>> 	buf->len = PAGE_SIZE;
>> 
>> -	return buf->data;
>> +	rqst->rq_buffer = buf->data;
>> +	return 0;
>> }
>> 
>> /*
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



