From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/05] svcrdma: Refactor RDMA_WRITE dma mapping logic
Date: Tue, 20 May 2008 22:52:16 -0400
Message-ID: <20080521025216.GA19820@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com> <12111560022506-git-send-email-tom@opengridcomputing.com> <1211156002624-git-send-email-tom@opengridcomputing.com> <20080521004608.GL8177@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:32938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040AbYEUCwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 22:52:18 -0400
In-Reply-To: <20080521004608.GL8177@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 20, 2008 at 08:46:08PM -0400, J. Bruce Fields wrote:
> On Sun, May 18, 2008 at 07:13:18PM -0500, Tom Tucker wrote:
> > In order to make the dma mapping code easier to understand and redu=
ce the
> > number of I/O contexts required, move the DMA for RDMA_WRITE WR to =
the
> > code that prepares the WR SGE.
>=20
> This one makes my (32-bit) compiler whine:
>=20
> CC      net/sunrpc/xprtrdma/svc_rdma_sendto.o
> net/sunrpc/xprtrdma/svc_rdma_sendto.c: In function =E2=80=98send_writ=
e=E2=80=99:
> net/sunrpc/xprtrdma/svc_rdma_sendto.c:180: warning: passing argument =
2 of =E2=80=98ib_dma_map_single=E2=80=99 makes pointer from integer wit=
hout a cast
> net/sunrpc/xprtrdma/svc_rdma_sendto.c: In function =E2=80=98send_repl=
y=E2=80=99:
> net/sunrpc/xprtrdma/svc_rdma_sendto.c:416: warning: passing argument =
2 of =E2=80=98ib_dma_map_single=E2=80=99 makes pointer from integer wit=
hout a cast

Erm, sorry, that should have been:

unrpc/xprtrdma/svc_rdma_sendto.c: In function =E2=80=98send_write=E2=80=
=99:
net/sunrpc/xprtrdma/svc_rdma_sendto.c:180: warning: cast to pointer fro=
m integer of different size
net/sunrpc/xprtrdma/svc_rdma_sendto.c: In function =E2=80=98send_reply=E2=
=80=99:
net/sunrpc/xprtrdma/svc_rdma_sendto.c:417: warning: cast to pointer fro=
m integer of different size

--b.

> And the types do seem weird:
>=20
> >=20
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >=20
> > ---
> >  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   44 +++++++++++++++---=
------------
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +++-
> >  2 files changed, 26 insertions(+), 23 deletions(-)
> >=20
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xpr=
trdma/svc_rdma_sendto.c
> > index fb82b1b..85931c4 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> > @@ -84,10 +84,7 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_=
rdma *xprt,
> >  	sge_no =3D 1;
> > =20
> >  	/* Head SGE */
> > -	sge[sge_no].addr =3D ib_dma_map_single(xprt->sc_cm_id->device,
> > -					     xdr->head[0].iov_base,
> > -					     xdr->head[0].iov_len,
> > -					     DMA_TO_DEVICE);
> > +	sge[sge_no].addr =3D (unsigned long)xdr->head[0].iov_base;
>=20
> So before we called a function that took a void *, returned a u64; no=
w
> we're storing a void* directly into a u64.
>=20
> >  	sge_bytes =3D min_t(u32, byte_count, xdr->head[0].iov_len);
> >  	byte_count -=3D sge_bytes;
> >  	sge[sge_no].length =3D sge_bytes;
> > @@ -99,11 +96,9 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_=
rdma *xprt,
> >  	page_bytes =3D xdr->page_len;
> >  	page_off =3D xdr->page_base;
> >  	while (byte_count && page_bytes) {
> > +		sge[sge_no].addr =3D (unsigned long)
> > +			page_address(xdr->pages[page_no]) + page_off;
> >  		sge_bytes =3D min_t(u32, byte_count, (PAGE_SIZE-page_off));
> > -		sge[sge_no].addr =3D
> > -			ib_dma_map_page(xprt->sc_cm_id->device,
> > -					xdr->pages[page_no], page_off,
> > -					sge_bytes, DMA_TO_DEVICE);
> >  		sge_bytes =3D min(sge_bytes, page_bytes);
> >  		byte_count -=3D sge_bytes;
> >  		page_bytes -=3D sge_bytes;
> > @@ -117,11 +112,7 @@ static struct ib_sge *xdr_to_sge(struct svcxpr=
t_rdma *xprt,
> > =20
> >  	/* Tail SGE */
> >  	if (byte_count && xdr->tail[0].iov_len) {
> > -		sge[sge_no].addr =3D
> > -			ib_dma_map_single(xprt->sc_cm_id->device,
> > -					  xdr->tail[0].iov_base,
> > -					  xdr->tail[0].iov_len,
> > -					  DMA_TO_DEVICE);
> > +		sge[sge_no].addr =3D (unsigned long)xdr->tail[0].iov_base;
> >  		sge_bytes =3D min_t(u32, byte_count, xdr->tail[0].iov_len);
> >  		byte_count -=3D sge_bytes;
> >  		sge[sge_no].length =3D sge_bytes;
> > @@ -145,7 +136,6 @@ static int send_write(struct svcxprt_rdma *xprt=
, struct svc_rqst *rqstp,
> >  		      u32 xdr_off, int write_len,
> >  		      struct ib_sge *xdr_sge, int sge_count)
> >  {
> > -	struct svc_rdma_op_ctxt *tmp_sge_ctxt;
> >  	struct ib_send_wr write_wr;
> >  	struct ib_sge *sge;
> >  	int xdr_sge_no;
> > @@ -163,9 +153,8 @@ static int send_write(struct svcxprt_rdma *xprt=
, struct svc_rqst *rqstp,
> >  		write_len, xdr_sge, sge_count);
> > =20
> >  	ctxt =3D svc_rdma_get_context(xprt);
> > -	ctxt->count =3D 0;
> > -	tmp_sge_ctxt =3D svc_rdma_get_context(xprt);
> > -	sge =3D tmp_sge_ctxt->sge;
> > +	ctxt->direction =3D DMA_TO_DEVICE;
> > +	sge =3D ctxt->sge;
> > =20
> >  	/* Find the SGE associated with xdr_off */
> >  	for (bc =3D xdr_off, xdr_sge_no =3D 1; bc && xdr_sge_no < sge_cou=
nt;
> > @@ -181,14 +170,20 @@ static int send_write(struct svcxprt_rdma *xp=
rt, struct svc_rqst *rqstp,
> > =20
> >  	/* Copy the remaining SGE */
> >  	while (bc !=3D 0 && xdr_sge_no < sge_count) {
> > -		sge[sge_no].addr =3D xdr_sge[xdr_sge_no].addr + sge_off;
> >  		sge[sge_no].lkey =3D xdr_sge[xdr_sge_no].lkey;
> >  		sge_bytes =3D min((size_t)bc,
> >  				(size_t)(xdr_sge[xdr_sge_no].length-sge_off));
> >  		sge[sge_no].length =3D sge_bytes;
> > -
> > +		sge[sge_no].addr =3D
> > +			ib_dma_map_single(xprt->sc_cm_id->device,
> > +					  (void *)
> > +					  xdr_sge[xdr_sge_no].addr + sge_off,
> > +					  sge_bytes, DMA_TO_DEVICE);
> > +		if (dma_mapping_error(sge[sge_no].addr))
> > +			return -EINVAL;
>=20
> And then here we're casting the u64 back to a void *.  Also, we're
> adding sge_off to the input, instead of to the result.  Is it true th=
at
> that
>=20
> 	ib_dma_map_single(., x + sge_off, ., .)
>=20
> and
>=20
> 	ib_dma_map_single(., x, ., .) + sge_off
>=20
> always have the same result?
>=20
> --b.
>=20
> >  		sge_off =3D 0;
> >  		sge_no++;
> > +		ctxt->count++;
> >  		xdr_sge_no++;
> >  		bc -=3D sge_bytes;
> >  	}
> > @@ -210,11 +205,10 @@ static int send_write(struct svcxprt_rdma *xp=
rt, struct svc_rqst *rqstp,
> >  	/* Post It */
> >  	atomic_inc(&rdma_stat_write);
> >  	if (svc_rdma_send(xprt, &write_wr)) {
> > -		svc_rdma_put_context(ctxt, 1);
> > +		svc_rdma_put_context(ctxt, 0);
> >  		/* Fatal error, close transport */
> >  		ret =3D -EIO;
> >  	}
> > -	svc_rdma_put_context(tmp_sge_ctxt, 0);
> >  	return ret;
> >  }
> > =20
> > @@ -417,6 +411,11 @@ static int send_reply(struct svcxprt_rdma *rdm=
a,
> >  		sge_bytes =3D min((size_t)ctxt->sge[sge_no].length,
> >  				(size_t)byte_count);
> >  		byte_count -=3D sge_bytes;
> > +		ctxt->sge[sge_no].addr =3D
> > +			ib_dma_map_single(rdma->sc_cm_id->device,
> > +					  (void *)
> > +					  ctxt->sge[sge_no].addr,
> > +					  sge_bytes, DMA_TO_DEVICE);
> >  	}
> >  	BUG_ON(byte_count !=3D 0);
> > =20
> > @@ -428,8 +427,9 @@ static int send_reply(struct svcxprt_rdma *rdma=
,
> >  		ctxt->pages[page_no+1] =3D rqstp->rq_respages[page_no];
> >  		ctxt->count++;
> >  		rqstp->rq_respages[page_no] =3D NULL;
> > +		if (page_no+1 >=3D sge_no)
> > +			ctxt->sge[page_no+1].length =3D 0;
> >  	}
> > -
> >  	BUG_ON(sge_no > rdma->sc_max_sge);
> >  	memset(&send_wr, 0, sizeof send_wr);
> >  	ctxt->wr_op =3D IB_WR_SEND;
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/=
xprtrdma/svc_rdma_transport.c
> > index e132509..9e9e244 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > @@ -361,10 +361,13 @@ static void sq_cq_reap(struct svcxprt_rdma *x=
prt)
> > =20
> >  		switch (ctxt->wr_op) {
> >  		case IB_WR_SEND:
> > -		case IB_WR_RDMA_WRITE:
> >  			svc_rdma_put_context(ctxt, 1);
> >  			break;
> > =20
> > +		case IB_WR_RDMA_WRITE:
> > +			svc_rdma_put_context(ctxt, 0);
> > +			break;
> > +
> >  		case IB_WR_RDMA_READ:
> >  			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
> >  				struct svc_rdma_op_ctxt *read_hdr =3D ctxt->read_hdr;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
