Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:24855 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbcHOV7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 17:59:48 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Lever Chuck <chuck.lever@oracle.com>
CC: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 03/22] SUNRPC: Generalize the RPC buffer allocation API
Date: Mon, 15 Aug 2016 21:59:41 +0000
Message-ID: <CD81109C-4EB7-4925-9D30-852D3440ACF3@primarydata.com>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
 <20160815205038.11652.47749.stgit@manet.1015granger.net>
In-Reply-To: <20160815205038.11652.47749.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2016, at 16:50, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
> xprtrdma needs to allocate the Call and Reply buffers separately.
> TBH, the reliance on using a single buffer for the pair of XDR
> buffers is transport implementation-specific.
>=20
> Transports that want to allocate separate Call and Reply buffers
> will ignore the "size" argument anyway.  Don't bother passing it.
>=20
> The buf_alloc method can't return two pointers. Instead, make the
> method's return value an error code, and set the rq_buffer pointer
> in the method itself.
>=20
> This gives call_allocate an opportunity to terminate an RPC instead
> of looping forever when a permanent problem occurs. If a request is
> just bogus, or the transport is in a state where it can't allocate
> resources for any request, there needs to be a way to kill the RPC
> right there and not loop.
>=20
> This immediately fixes a rare problem in the backchannel send path,
> which loops if the server happens to send a CB request whose
> call+reply size is larger than a page (which it shouldn't do yet).
>=20
> One more issue: looks like xprt_inject_disconnect was incorrectly
> placed in the failure path in call_allocate. It needs to be in the
> success path, as it is for other call-sites.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> include/linux/sunrpc/sched.h               |    2 +-
> include/linux/sunrpc/xprt.h                |    2 +-
> net/sunrpc/clnt.c                          |   12 ++++++++----
> net/sunrpc/sched.c                         |   24 +++++++++++++++--------=
-
> net/sunrpc/sunrpc.h                        |    2 +-
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 +++++++++--------
> net/sunrpc/xprtrdma/transport.c            |   26 ++++++++++++++++++-----=
---
> net/sunrpc/xprtsock.c                      |   17 +++++++++++------
> 8 files changed, 64 insertions(+), 38 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 817af0b..38d4c1b 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -239,7 +239,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_qu=
eue *,
> =09=09=09=09=09void *);
> void=09=09rpc_wake_up_status(struct rpc_wait_queue *, int);
> void=09=09rpc_delay(struct rpc_task *, unsigned long);
> -void *=09=09rpc_malloc(struct rpc_task *, size_t);
> +int=09=09rpc_malloc(struct rpc_task *);
> void=09=09rpc_free(void *);
> int=09=09rpciod_up(void);
> void=09=09rpciod_down(void);
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 559dad3..6f0f796 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -127,7 +127,7 @@ struct rpc_xprt_ops {
> =09void=09=09(*rpcbind)(struct rpc_task *task);
> =09void=09=09(*set_port)(struct rpc_xprt *xprt, unsigned short port);
> =09void=09=09(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
> -=09void *=09=09(*buf_alloc)(struct rpc_task *task, size_t size);
> +=09int=09=09(*buf_alloc)(struct rpc_task *task);
> =09void=09=09(*buf_free)(void *buffer);
> =09int=09=09(*send_request)(struct rpc_task *task);
> =09void=09=09(*set_retrans_timeout)(struct rpc_task *task);
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 0e75369..601b3ca 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1693,6 +1693,7 @@ call_allocate(struct rpc_task *task)
> =09struct rpc_rqst *req =3D task->tk_rqstp;
> =09struct rpc_xprt *xprt =3D req->rq_xprt;
> =09struct rpc_procinfo *proc =3D task->tk_msg.rpc_proc;
> +=09int status;
>=20
> =09dprint_status(task);
>=20
> @@ -1718,11 +1719,14 @@ call_allocate(struct rpc_task *task)
> =09req->rq_rcvsize =3D RPC_REPHDRSIZE + slack + proc->p_replen;
> =09req->rq_rcvsize <<=3D 2;
>=20
> -=09req->rq_buffer =3D xprt->ops->buf_alloc(task,
> -=09=09=09=09=09req->rq_callsize + req->rq_rcvsize);
> -=09if (req->rq_buffer !=3D NULL)
> -=09=09return;
> +=09status =3D xprt->ops->buf_alloc(task);
> =09xprt_inject_disconnect(xprt);
> +=09if (status =3D=3D 0)
> +=09=09return;
> +=09if (status =3D=3D -EIO) {
> +=09=09rpc_exit(task, -EIO);

What does EIO mean in this context, and why should it be a fatal error? A b=
uffer allocation is not normally considered to be I/O.

> +=09=09return;
> +=09}
>=20
> =09dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
>=20
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 9ae5885..b964d40 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -849,14 +849,17 @@ static void rpc_async_schedule(struct work_struct *=
work)
> }
>=20
> /**
> - * rpc_malloc - allocate an RPC buffer
> - * @task: RPC task that will use this buffer
> - * @size: requested byte size
> + * rpc_malloc - allocate RPC buffer resources
> + * @task: RPC task
> + *
> + * A single memory region is allocated, which is split between the
> + * RPC call and RPC reply that this task is being used for. When
> + * this RPC is retired, the memory is released by calling rpc_free.
>  *
>  * To prevent rpciod from hanging, this allocator never sleeps,
> - * returning NULL and suppressing warning if the request cannot be servi=
ced
> - * immediately.
> - * The caller can arrange to sleep in a way that is safe for rpciod.
> + * returning -ENOMEM and suppressing warning if the request cannot
> + * be serviced immediately. The caller can arrange to sleep in a
> + * way that is safe for rpciod.
>  *
>  * Most requests are 'small' (under 2KiB) and can be serviced from a
>  * mempool, ensuring that NFS reads and writes can always proceed,
> @@ -865,8 +868,10 @@ static void rpc_async_schedule(struct work_struct *w=
ork)
>  * In order to avoid memory starvation triggering more writebacks of
>  * NFS requests, we avoid using GFP_KERNEL.
>  */
> -void *rpc_malloc(struct rpc_task *task, size_t size)
> +int rpc_malloc(struct rpc_task *task)
> {
> +=09struct rpc_rqst *rqst =3D task->tk_rqstp;
> +=09size_t size =3D rqst->rq_callsize + rqst->rq_rcvsize;
> =09struct rpc_buffer *buf;
> =09gfp_t gfp =3D GFP_NOIO | __GFP_NOWARN;
>=20
> @@ -880,12 +885,13 @@ void *rpc_malloc(struct rpc_task *task, size_t size=
)
> =09=09buf =3D kmalloc(size, gfp);
>=20
> =09if (!buf)
> -=09=09return NULL;
> +=09=09return -ENOMEM;
>=20
> =09buf->len =3D size;
> =09dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
> =09=09=09task->tk_pid, size, buf);
> -=09return &buf->data;
> +=09rqst->rq_buffer =3D buf->data;
> +=09return 0;
> }
> EXPORT_SYMBOL_GPL(rpc_malloc);
>=20
> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
> index f2b7cb5..a4f44ca 100644
> --- a/net/sunrpc/sunrpc.h
> +++ b/net/sunrpc/sunrpc.h
> @@ -34,7 +34,7 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DA=
MAGE.
>  */
> struct rpc_buffer {
> =09size_t=09len;
> -=09char=09data[];
> +=09__be32=09data[];

Again, why? Nothing should be touching the data contents directly from this=
 pointer.

> };
>=20
> static inline int rpc_reply_expected(struct rpc_task *task)
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprt=
rdma/svc_rdma_backchannel.c
> index a2a7519..b7c698f7f 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -159,29 +159,30 @@ out_unmap:
> /* Server-side transport endpoint wants a whole page for its send
>  * buffer. The client RPC code constructs the RPC header in this
>  * buffer before it invokes ->send_request.
> - *
> - * Returns NULL if there was a temporary allocation failure.
>  */
> -static void *
> -xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
> +static int
> +xprt_rdma_bc_allocate(struct rpc_task *task)
> {
> =09struct rpc_rqst *rqst =3D task->tk_rqstp;
> =09struct svc_xprt *sxprt =3D rqst->rq_xprt->bc_xprt;
> +=09size_t size =3D rqst->rq_callsize;
> =09struct svcxprt_rdma *rdma;
> =09struct page *page;
>=20
> =09rdma =3D container_of(sxprt, struct svcxprt_rdma, sc_xprt);
>=20
> -=09/* Prevent an infinite loop: try to make this case work */
> -=09if (size > PAGE_SIZE)
> +=09if (size > PAGE_SIZE) {
> =09=09WARN_ONCE(1, "svcrdma: large bc buffer request (size %zu)\n",
> =09=09=09  size);
> +=09=09return -EIO;
> +=09}
>=20
> =09page =3D alloc_page(RPCRDMA_DEF_GFP);
> =09if (!page)
> -=09=09return NULL;
> +=09=09return -ENOMEM;
>=20
> -=09return page_address(page);
> +=09rqst->rq_buffer =3D page_address(page);
> +=09return 0;
> }
>=20
> static void
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transp=
ort.c
> index be95ece..daa7d4d 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -477,7 +477,15 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_=
task *task)
> =09}
> }
>=20
> -/*
> +/**
> + * xprt_rdma_allocate - allocate transport resources for an RPC
> + * @task: RPC task
> + *
> + * Return values:
> + *        0:=09Success; rq_buffer points to RPC buffer to use
> + *   ENOMEM:=09Out of memory, call again later
> + *      EIO:=09A permanent error occurred, do not retry
> + *
>  * The RDMA allocate/free functions need the task structure as a place
>  * to hide the struct rpcrdma_req, which is necessary for the actual send=
/recv
>  * sequence.
> @@ -486,11 +494,12 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc=
_task *task)
>  * (rq_send_buf and rq_rcv_buf are both part of a single contiguous buffe=
r).
>  * We may register rq_rcv_buf when using reply chunks.
>  */
> -static void *
> -xprt_rdma_allocate(struct rpc_task *task, size_t size)
> +static int
> +xprt_rdma_allocate(struct rpc_task *task)
> {
> -=09struct rpc_xprt *xprt =3D task->tk_rqstp->rq_xprt;
> -=09struct rpcrdma_xprt *r_xprt =3D rpcx_to_rdmax(xprt);
> +=09struct rpc_rqst *rqst =3D task->tk_rqstp;
> +=09size_t size =3D rqst->rq_callsize + rqst->rq_rcvsize;
> +=09struct rpcrdma_xprt *r_xprt =3D rpcx_to_rdmax(rqst->rq_xprt);
> =09struct rpcrdma_regbuf *rb;
> =09struct rpcrdma_req *req;
> =09size_t min_size;
> @@ -498,7 +507,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size=
)
>=20
> =09req =3D rpcrdma_buffer_get(&r_xprt->rx_buf);
> =09if (req =3D=3D NULL)
> -=09=09return NULL;
> +=09=09return -ENOMEM;
>=20
> =09flags =3D RPCRDMA_DEF_GFP;
> =09if (RPC_IS_SWAPPER(task))
> @@ -515,7 +524,8 @@ out:
> =09dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req=
);
> =09req->rl_connect_cookie =3D 0;=09/* our reserved value */
> =09req->rl_task =3D task;
> -=09return req->rl_sendbuf->rg_base;
> +=09rqst->rq_buffer =3D req->rl_sendbuf->rg_base;
> +=09return 0;
>=20
> out_rdmabuf:
> =09min_size =3D r_xprt->rx_data.inline_wsize;
> @@ -558,7 +568,7 @@ out_sendbuf:
>=20
> out_fail:
> =09rpcrdma_buffer_put(req);
> -=09return NULL;
> +=09return -ENOMEM;
> }
>=20
> /*
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8ede3bc..d6db5cf 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2533,23 +2533,28 @@ static void xs_tcp_print_stats(struct rpc_xprt *x=
prt, struct seq_file *seq)
>  * we allocate pages instead doing a kmalloc like rpc_malloc is because w=
e want
>  * to use the server side send routines.
>  */
> -static void *bc_malloc(struct rpc_task *task, size_t size)
> +static int bc_malloc(struct rpc_task *task)
> {
> +=09struct rpc_rqst *rqst =3D task->tk_rqstp;
> +=09size_t size =3D rqst->rq_callsize;
> =09struct page *page;
> =09struct rpc_buffer *buf;
>=20
> -=09WARN_ON_ONCE(size > PAGE_SIZE - sizeof(struct rpc_buffer));
> -=09if (size > PAGE_SIZE - sizeof(struct rpc_buffer))
> -=09=09return NULL;
> +=09if (size > PAGE_SIZE - sizeof(struct rpc_buffer)) {
> +=09=09WARN_ONCE(1, "xprtsock: large bc buffer request (size %zu)\n",
> +=09=09=09  size);
> +=09=09return -EIO;
> +=09}
>=20
> =09page =3D alloc_page(GFP_KERNEL);
> =09if (!page)
> -=09=09return NULL;
> +=09=09return -ENOMEM;
>=20
> =09buf =3D page_address(page);
> =09buf->len =3D PAGE_SIZE;
>=20
> -=09return buf->data;
> +=09rqst->rq_buffer =3D buf->data;
> +=09return 0;
> }
>=20
> /*
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

