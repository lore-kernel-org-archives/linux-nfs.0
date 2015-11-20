Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH] nfs4: limit callback decoding to received bytes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <80ed0167773dfee0807c79233555c7d0c1fae11a.1448031054.git.bcodding@redhat.com>
Date: Fri, 20 Nov 2015 10:18:19 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <99FC53A8-5A33-4F03-AFEF-A18C5880B493@oracle.com>
References: <80ed0167773dfee0807c79233555c7d0c1fae11a.1448031054.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 20, 2015, at 9:55 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> A truncated cb_compound request will cause the client to decode null =
or
> data from a previous callback for nfs4.1 backchannel case, or =
uninitialized
> data for the nfs4.0 case. This is because the path through
> svc_process_common() advances the request's iov_base and decrements =
iov_len
> without adjusting the overall xdr_buf's len field.  That causes
> xdr_init_decode() to set up the xdr_stream with an incorrect length in
> nfs4_callback_compound().
>=20
> Fixing this for the nfs4.1 backchannel case first requires setting the
> correct iov_len and page_len based on the length of received data in =
the
> same manner as the nfs4.0 case.
>=20
> Then the request's xdr_buf length can be adjusted for both cases based =
upon
> the remaining iov_len and page_len.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> fs/nfs/callback_xdr.c         |    7 +++++--
> net/sunrpc/backchannel_rqst.c |    8 ++++++++
> net/sunrpc/svc.c              |    1 +
> 3 files changed, 14 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 6b1697a..1c8213e 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -76,7 +76,8 @@ static __be32 *read_buf(struct xdr_stream *xdr, int =
nbytes)
>=20
> 	p =3D xdr_inline_decode(xdr, nbytes);
> 	if (unlikely(p =3D=3D NULL))
> -		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer =
overflowed!\n");
> +		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer =
overflowed "
> +							"or truncated =
request.\n");
> 	return p;
> }
>=20
> @@ -892,6 +893,7 @@ static __be32 nfs4_callback_compound(struct =
svc_rqst *rqstp, void *argp, void *r
> 	struct cb_compound_hdr_arg hdr_arg =3D { 0 };
> 	struct cb_compound_hdr_res hdr_res =3D { NULL };
> 	struct xdr_stream xdr_in, xdr_out;
> +	struct xdr_buf *rq_arg =3D &rqstp->rq_arg;
> 	__be32 *p, status;
> 	struct cb_process_state cps =3D {
> 		.drc_status =3D 0,
> @@ -903,7 +905,8 @@ static __be32 nfs4_callback_compound(struct =
svc_rqst *rqstp, void *argp, void *r
>=20
> 	dprintk("%s: start\n", __func__);
>=20
> -	xdr_init_decode(&xdr_in, &rqstp->rq_arg, =
rqstp->rq_arg.head[0].iov_base);
> +	rq_arg->len =3D rq_arg->head[0].iov_len + rq_arg->page_len;
> +	xdr_init_decode(&xdr_in, rq_arg, rq_arg->head[0].iov_base);
>=20
> 	p =3D (__be32*)((char *)rqstp->rq_res.head[0].iov_base + =
rqstp->rq_res.head[0].iov_len);
> 	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
> diff --git a/net/sunrpc/backchannel_rqst.c =
b/net/sunrpc/backchannel_rqst.c
> index 6255d14..d92cee1 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -333,12 +333,20 @@ void xprt_complete_bc_request(struct rpc_rqst =
*req, uint32_t copied)
> {
> 	struct rpc_xprt *xprt =3D req->rq_xprt;
> 	struct svc_serv *bc_serv =3D xprt->bc_serv;
> +	struct xdr_buf *rq_rcv_buf =3D &req->rq_rcv_buf;
>=20
> 	spin_lock(&xprt->bc_pa_lock);
> 	list_del(&req->rq_bc_pa_list);
> 	xprt_dec_alloc_count(xprt, 1);
> 	spin_unlock(&xprt->bc_pa_lock);
>=20
> +	if (copied <=3D rq_rcv_buf->head[0].iov_len) {
> +		rq_rcv_buf->head[0].iov_len =3D copied;
> +		rq_rcv_buf->page_len =3D 0;
> +	} else {
> +		rq_rcv_buf->page_len =3D copied - =
rq_rcv_buf->head[0].iov_len;
> +	}
> +

Are similar changes needed in rpcrdma_bc_receive_call ?


> 	req->rq_private_buf.len =3D copied;
> 	set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index a8f579d..af9f987 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1363,6 +1363,7 @@ bc_svc_process(struct svc_serv *serv, struct =
rpc_rqst *req,
> 	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
> 	memcpy(&rqstp->rq_arg, &req->rq_rcv_buf, sizeof(rqstp->rq_arg));
> 	memcpy(&rqstp->rq_res, &req->rq_snd_buf, sizeof(rqstp->rq_res));
> +	rqstp->rq_arg.len =3D req->rq_private_buf.len;
>=20
> 	/* reset result send buffer "put" position */
> 	resv->iov_len =3D 0;
> --=20
> 1.7.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
