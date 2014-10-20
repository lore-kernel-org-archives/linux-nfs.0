Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16440 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbaJTOEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2014 10:04:47 -0400
Message-ID: <5445167D.9050401@Netapp.com>
Date: Mon, 20 Oct 2014 10:04:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 03/16] SUNRPC: Pass callsize and recvsize to buf_alloc
 as separate arguments
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016193838.13414.12691.stgit@manet.1015granger.net>
In-Reply-To: <20141016193838.13414.12691.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/16/14 15:38, Chuck Lever wrote:
> I noticed that on RDMA, NFSv4 operations were using "hardway"
> allocations much more than not. A "hardway" allocation uses GFP_NOFS
> during each RPC to allocate the XDR buffer, instead of using a
> pre-allocated pre-registered buffer for each RPC.
>
> The pre-allocated buffers are 2200 bytes in length.  The requested
> XDR buffer sizes looked like this:
>
>     GETATTR: 3220 bytes
>     LOOKUP:  3612 bytes
>     WRITE:   3256 bytes
>     OPEN:    6344 bytes
>
> But an NFSv4 GETATTR RPC request should be small. It's the reply
> part of GETATTR that can grow large.
>
> call_allocate() passes a single value as the XDR buffer size: the
> sum of call and reply buffers. However, the xprtrdma transport
> allocates its XDR request and reply buffers separately.
>
> xprtrdma needs to know the maximum call size, as guidance for how
> large the outgoing request is going to be and how the NFS payload
> will be marshalled into chunks.
>
> But RDMA XDR reply buffers are pre-posted, fixed-size buffers, not
> allocated by xprt_rdma_allocate().
>
> Because of the sum passed through ->buf_alloc(), xprtrdma's
> ->buf_alloc() always allocates more XDR buffer than it will ever
> use. For NFSv4, it is unnecessarily triggering the slow "hardway"
> path for almost every RPC.
>
> Pass the call and reply buffer size values separately to the
> transport's ->buf_alloc method.  The RDMA transport ->buf_alloc can
> now ignore the reply size, and allocate just what it will use for
> the call buffer.  The socket transport ->buf_alloc can simply add
> them together, as call_allocate() did before.
>
> With this patch, an NFSv4 GETATTR request now allocates a 476 byte
> RDMA XDR buffer. I didn't see a single NFSv4 request that did not
> fit into the transport's pre-allocated XDR buffer.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/sched.h    |    2 +-
>  include/linux/sunrpc/xprt.h     |    3 ++-
>  net/sunrpc/clnt.c               |    4 ++--
>  net/sunrpc/sched.c              |    6 ++++--
>  net/sunrpc/xprtrdma/transport.c |    2 +-
>  net/sunrpc/xprtsock.c           |    3 ++-
>  6 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 1a89599..68fa71d 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -232,7 +232,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
>  					void *);
>  void		rpc_wake_up_status(struct rpc_wait_queue *, int);
>  void		rpc_delay(struct rpc_task *, unsigned long);
> -void *		rpc_malloc(struct rpc_task *, size_t);
> +void		*rpc_malloc(struct rpc_task *, size_t, size_t);
>  void		rpc_free(void *);
>  int		rpciod_up(void);
>  void		rpciod_down(void);
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index fcbfe87..632685c 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -124,7 +124,8 @@ struct rpc_xprt_ops {
>  	void		(*rpcbind)(struct rpc_task *task);
>  	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
>  	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
> -	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
> +	void *		(*buf_alloc)(struct rpc_task *task,
> +					size_t call, size_t reply);
>  	void		(*buf_free)(void *buffer);
>  	int		(*send_request)(struct rpc_task *task);
>  	void		(*set_retrans_timeout)(struct rpc_task *task);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 488ddee..5e817d6 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1599,8 +1599,8 @@ call_allocate(struct rpc_task *task)
>  	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
>  	req->rq_rcvsize <<= 2;
>  
> -	req->rq_buffer = xprt->ops->buf_alloc(task,
> -					req->rq_callsize + req->rq_rcvsize);
> +	req->rq_buffer = xprt->ops->buf_alloc(task, req->rq_callsize,
> +					      req->rq_rcvsize);
>  	if (req->rq_buffer != NULL)
>  		return;
>  
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 9358c79..fc4f939 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -829,7 +829,8 @@ static void rpc_async_schedule(struct work_struct *work)
>  /**
>   * rpc_malloc - allocate an RPC buffer
>   * @task: RPC task that will use this buffer
> - * @size: requested byte size
> + * @call: maximum size of on-the-wire RPC call, in bytes
> + * @reply: maximum size of on-the-wire RPC reply, in bytes
>   *
>   * To prevent rpciod from hanging, this allocator never sleeps,
>   * returning NULL and suppressing warning if the request cannot be serviced
> @@ -843,8 +844,9 @@ static void rpc_async_schedule(struct work_struct *work)
>   * In order to avoid memory starvation triggering more writebacks of
>   * NFS requests, we avoid using GFP_KERNEL.
>   */
> -void *rpc_malloc(struct rpc_task *task, size_t size)
> +void *rpc_malloc(struct rpc_task *task, size_t call, size_t reply)
>  {
> +	size_t size = call + reply;
>  	struct rpc_buffer *buf;
>  	gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
>  
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 2faac49..6e9d0a7 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -459,7 +459,7 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
>   * the receive buffer portion when using reply chunks.
>   */
>  static void *
> -xprt_rdma_allocate(struct rpc_task *task, size_t size)
> +xprt_rdma_allocate(struct rpc_task *task, size_t size, size_t replen)

The comment right before this function mentions that send and receive buffers are allocated in the same call.  Can you update this?

Anna

>  {
>  	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
>  	struct rpcrdma_req *req, *nreq;
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 43cd89e..b4aca48 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2423,8 +2423,9 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>   * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
>   * to use the server side send routines.
>   */
> -static void *bc_malloc(struct rpc_task *task, size_t size)
> +static void *bc_malloc(struct rpc_task *task, size_t call, size_t reply)
>  {
> +	size_t size = call + reply;
>  	struct page *page;
>  	struct rpc_buffer *buf;
>  
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

