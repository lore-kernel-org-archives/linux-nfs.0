Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbbKTQUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 11:20:23 -0500
Date: Fri, 20 Nov 2015 11:20:20 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4: limit callback decoding to received bytes
In-Reply-To: <99FC53A8-5A33-4F03-AFEF-A18C5880B493@oracle.com>
Message-ID: <alpine.OSX.2.19.9992.1511201107060.34561@planck.local>
References: <80ed0167773dfee0807c79233555c7d0c1fae11a.1448031054.git.bcodding@redhat.com> <99FC53A8-5A33-4F03-AFEF-A18C5880B493@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 20 Nov 2015, Chuck Lever wrote:

>
> > On Nov 20, 2015, at 9:55 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > A truncated cb_compound request will cause the client to decode null or
> > data from a previous callback for nfs4.1 backchannel case, or uninitialized
> > data for the nfs4.0 case. This is because the path through
> > svc_process_common() advances the request's iov_base and decrements iov_len
> > without adjusting the overall xdr_buf's len field.  That causes
> > xdr_init_decode() to set up the xdr_stream with an incorrect length in
> > nfs4_callback_compound().
> >
> > Fixing this for the nfs4.1 backchannel case first requires setting the
> > correct iov_len and page_len based on the length of received data in the
> > same manner as the nfs4.0 case.
> >
> > Then the request's xdr_buf length can be adjusted for both cases based upon
> > the remaining iov_len and page_len.
> >
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> > fs/nfs/callback_xdr.c         |    7 +++++--
> > net/sunrpc/backchannel_rqst.c |    8 ++++++++
> > net/sunrpc/svc.c              |    1 +
> > 3 files changed, 14 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> > index 6b1697a..1c8213e 100644
> > --- a/fs/nfs/callback_xdr.c
> > +++ b/fs/nfs/callback_xdr.c
> > @@ -76,7 +76,8 @@ static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
> >
> > 	p = xdr_inline_decode(xdr, nbytes);
> > 	if (unlikely(p == NULL))
> > -		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed!\n");
> > +		printk(KERN_WARNING "NFS: NFSv4 callback reply buffer overflowed "
> > +							"or truncated request.\n");
> > 	return p;
> > }
> >
> > @@ -892,6 +893,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> > 	struct cb_compound_hdr_arg hdr_arg = { 0 };
> > 	struct cb_compound_hdr_res hdr_res = { NULL };
> > 	struct xdr_stream xdr_in, xdr_out;
> > +	struct xdr_buf *rq_arg = &rqstp->rq_arg;
> > 	__be32 *p, status;
> > 	struct cb_process_state cps = {
> > 		.drc_status = 0,
> > @@ -903,7 +905,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
> >
> > 	dprintk("%s: start\n", __func__);
> >
> > -	xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
> > +	rq_arg->len = rq_arg->head[0].iov_len + rq_arg->page_len;
> > +	xdr_init_decode(&xdr_in, rq_arg, rq_arg->head[0].iov_base);
> >
> > 	p = (__be32*)((char *)rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len);
> > 	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
> > diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> > index 6255d14..d92cee1 100644
> > --- a/net/sunrpc/backchannel_rqst.c
> > +++ b/net/sunrpc/backchannel_rqst.c
> > @@ -333,12 +333,20 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
> > {
> > 	struct rpc_xprt *xprt = req->rq_xprt;
> > 	struct svc_serv *bc_serv = xprt->bc_serv;
> > +	struct xdr_buf *rq_rcv_buf = &req->rq_rcv_buf;
> >
> > 	spin_lock(&xprt->bc_pa_lock);
> > 	list_del(&req->rq_bc_pa_list);
> > 	xprt_dec_alloc_count(xprt, 1);
> > 	spin_unlock(&xprt->bc_pa_lock);
> >
> > +	if (copied <= rq_rcv_buf->head[0].iov_len) {
> > +		rq_rcv_buf->head[0].iov_len = copied;
> > +		rq_rcv_buf->page_len = 0;
> > +	} else {
> > +		rq_rcv_buf->page_len = copied - rq_rcv_buf->head[0].iov_len;
> > +	}
> > +
>
> Are similar changes needed in rpcrdma_bc_receive_call ?

Good question..  I was working on 4.3+ which was missing the rdma stuff, so
I overlooked this.

net/sunrpc/xprtrdma/backchannel.c:
324     size = rep->rr_len - RPCRDMA_HDRLEN_MIN;
...
347     memset(buf, 0, sizeof(*buf));
348     buf->head[0].iov_base = p;
349     buf->head[0].iov_len = size;

^^ that looks like it is going to set the iov_len to the size of the XDR
portion of the data, sans transport headers.. which means that it shouldn't
need the fixup just above.

In the case requiring the fixup iov_len was always set to 4096, and
decremented from there no matter the size of the request.

Ben

> > 	req->rq_private_buf.len = copied;
> > 	set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
> >
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index a8f579d..af9f987 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1363,6 +1363,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> > 	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
> > 	memcpy(&rqstp->rq_arg, &req->rq_rcv_buf, sizeof(rqstp->rq_arg));
> > 	memcpy(&rqstp->rq_res, &req->rq_snd_buf, sizeof(rqstp->rq_res));
> > +	rqstp->rq_arg.len = req->rq_private_buf.len;
> >
> > 	/* reset result send buffer "put" position */
> > 	resv->iov_len = 0;
> > --
> > 1.7.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
>
>
