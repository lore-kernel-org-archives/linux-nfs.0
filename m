Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:38477 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752966AbcHOVvT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 17:51:19 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Lever Chuck <chuck.lever@oracle.com>
CC: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 02/22] SUNRPC: Refactor rpc_xdr_buf_init()
Date: Mon, 15 Aug 2016 21:51:12 +0000
Message-ID: <0750E5E3-335B-4D49-8B17-45DC0A616225@primarydata.com>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
 <20160815205030.11652.6620.stgit@manet.1015granger.net>
In-Reply-To: <20160815205030.11652.6620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2016, at 16:50, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
> Clean up: there is some XDR initialization logic that is commoon
> to the forward channel and backchannel. Move it to an XDR header
> so it can be shared.
>=20
> rpc_rqst::rq_buffer points to a buffer containing big-endian data.
> Update its annotation as part of the clean up.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> include/linux/sunrpc/xdr.h        |   10 ++++++++++
> include/linux/sunrpc/xprt.h       |    2 +-
> net/sunrpc/backchannel_rqst.c     |    8 +-------
> net/sunrpc/clnt.c                 |   24 ++++++------------------
> net/sunrpc/xprtrdma/backchannel.c |   12 +-----------
> 5 files changed, 19 insertions(+), 37 deletions(-)
>=20
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 70c6b92..551569c 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -67,6 +67,16 @@ struct xdr_buf {
> =09=09=09len;=09=09/* Length of XDR encoded message */
> };
>=20
> +static inline void
> +xdr_buf_init(struct xdr_buf *buf, __be32 *start, size_t len)
> +{
> +=09memset(buf, 0, sizeof(*buf));

Can we please leave this as it was. There is no need to zero out unused fie=
lds such as the pages pointer, the tail iov_base, etc.

> +
> +=09buf->head[0].iov_base =3D start;
> +=09buf->head[0].iov_len =3D len;
> +=09buf->buflen =3D len;
> +}
> +
> /*
>  * pre-xdr'ed macros.
>  */
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index a16070d..559dad3 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -83,7 +83,7 @@ struct rpc_rqst {
> =09void (*rq_release_snd_buf)(struct rpc_rqst *); /* release rq_enc_pages=
 */
> =09struct list_head=09rq_list;
>=20
> -=09__u32 *=09=09=09rq_buffer;=09/* XDR encode buffer */
> +=09__be32=09=09=09*rq_buffer;=09/* Call XDR encode buffer */

If changing it, why not make it a void* ? Nothing should ever be touching t=
he contents of this buffer directly.

> =09size_t=09=09=09rq_callsize,
> =09=09=09=09rq_rcvsize;
> =09size_t=09=09=09rq_xmit_bytes_sent;=09/* total bytes sent */
> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.=
c
> index 229956b..ac701c2 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -76,13 +76,7 @@ static int xprt_alloc_xdr_buf(struct xdr_buf *buf, gfp=
_t gfp_flags)
> =09page =3D alloc_page(gfp_flags);
> =09if (page =3D=3D NULL)
> =09=09return -ENOMEM;
> -=09buf->head[0].iov_base =3D page_address(page);
> -=09buf->head[0].iov_len =3D PAGE_SIZE;
> -=09buf->tail[0].iov_base =3D NULL;
> -=09buf->tail[0].iov_len =3D 0;
> -=09buf->page_len =3D 0;
> -=09buf->len =3D 0;
> -=09buf->buflen =3D PAGE_SIZE;
> +=09xdr_buf_init(buf, page_address(page), PAGE_SIZE);
> =09return 0;
> }
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 7f79fb7..0e75369 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1748,18 +1748,6 @@ rpc_task_force_reencode(struct rpc_task *task)
> =09task->tk_rqstp->rq_bytes_sent =3D 0;
> }
>=20
> -static inline void
> -rpc_xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
> -{
> -=09buf->head[0].iov_base =3D start;
> -=09buf->head[0].iov_len =3D len;
> -=09buf->tail[0].iov_len =3D 0;
> -=09buf->page_len =3D 0;
> -=09buf->flags =3D 0;
> -=09buf->len =3D 0;
> -=09buf->buflen =3D len;
> -}
> -
> /*
>  * 3.=09Encode arguments of an RPC call
>  */
> @@ -1772,12 +1760,12 @@ rpc_xdr_encode(struct rpc_task *task)
>=20
> =09dprint_status(task);
>=20
> -=09rpc_xdr_buf_init(&req->rq_snd_buf,
> -=09=09=09 req->rq_buffer,
> -=09=09=09 req->rq_callsize);
> -=09rpc_xdr_buf_init(&req->rq_rcv_buf,
> -=09=09=09 (char *)req->rq_buffer + req->rq_callsize,
> -=09=09=09 req->rq_rcvsize);
> +=09xdr_buf_init(&req->rq_snd_buf,
> +=09=09     req->rq_buffer,
> +=09=09     req->rq_callsize);
> +=09xdr_buf_init(&req->rq_rcv_buf,
> +=09=09     (__be32 *)((char *)req->rq_buffer + req->rq_callsize),
> +=09=09     req->rq_rcvsize);
>=20
> =09p =3D rpc_encode_header(task);
> =09if (p =3D=3D NULL) {
> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/back=
channel.c
> index 5f60ab2..d3cfaf2 100644
> --- a/net/sunrpc/xprtrdma/backchannel.c
> +++ b/net/sunrpc/xprtrdma/backchannel.c
> @@ -38,7 +38,6 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r=
_xprt,
> =09struct rpcrdma_ia *ia =3D &r_xprt->rx_ia;
> =09struct rpcrdma_regbuf *rb;
> =09struct rpcrdma_req *req;
> -=09struct xdr_buf *buf;
> =09size_t size;
>=20
> =09req =3D rpcrdma_create_req(r_xprt);
> @@ -60,16 +59,7 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *=
r_xprt,
> =09req->rl_sendbuf =3D rb;
> =09/* so that rpcr_to_rdmar works when receiving a request */
> =09rqst->rq_buffer =3D (void *)req->rl_sendbuf->rg_base;
> -
> -=09buf =3D &rqst->rq_snd_buf;
> -=09buf->head[0].iov_base =3D rqst->rq_buffer;
> -=09buf->head[0].iov_len =3D 0;
> -=09buf->tail[0].iov_base =3D NULL;
> -=09buf->tail[0].iov_len =3D 0;
> -=09buf->page_len =3D 0;
> -=09buf->len =3D 0;
> -=09buf->buflen =3D size;
> -
> +=09xdr_buf_init(&rqst->rq_snd_buf, rqst->rq_buffer, size);
> =09return 0;
>=20
> out_fail:
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

