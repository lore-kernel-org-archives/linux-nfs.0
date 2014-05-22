Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbaEVPN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 11:13:26 -0400
Date: Thu, 22 May 2014 11:13:20 -0400
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/43] nfsd4: embed xdr_stream in nfsd4_compoundres
Message-ID: <20140522151320.GA20943@fieldses.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-2-git-send-email-bfields@redhat.com>
 <5375E13D.8060508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5375E13D.8060508@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 16, 2014 at 05:58:21PM +0800, Kinglong Mee wrote:
> On 5/12/2014 04:52, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > This is a mechanical transformation with no change in behavior.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4proc.c  |   12 +++++-----
> >  fs/nfsd/nfs4state.c |    8 +++----
> >  fs/nfsd/nfs4xdr.c   |   65 ++++++++++++++++++++++++++-------------------------
> >  fs/nfsd/xdr4.h      |    4 +---
> >  4 files changed, 44 insertions(+), 45 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 2c1ee70..46370f5 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1268,13 +1268,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> >  	u32		plen = 0;
> >  	__be32		status;
> >  
> > -	resp->xbuf = &rqstp->rq_res;
> > -	resp->p = rqstp->rq_res.head[0].iov_base +
> > +	resp->xdr.buf = &rqstp->rq_res;
> > +	resp->xdr.p = rqstp->rq_res.head[0].iov_base +
> >  						rqstp->rq_res.head[0].iov_len;
> 
> I'd like using a temp pointer as (struct xdr_stream *resp_xdr = &resp->xdr;).

Agreed.  I move this code into a helper function a couple patches later
and define the temp pointer then.

--b.

> 
> thanks,
> Kinglong Mee
> 
> > -	resp->tagp = resp->p;
> > +	resp->tagp = resp->xdr.p;
> >  	/* reserve space for: taglen, tag, and opcnt */
> > -	resp->p += 2 + XDR_QUADLEN(args->taglen);
> > -	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
> > +	resp->xdr.p += 2 + XDR_QUADLEN(args->taglen);
> > +	resp->xdr.end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
> >  	resp->taglen = args->taglen;
> >  	resp->tag = args->tag;
> >  	resp->opcnt = 0;
> > @@ -1326,7 +1326,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> >  		 * failed response to the next operation.  If we don't
> >  		 * have enough room, fail with ERR_RESOURCE.
> >  		 */
> > -		slack_bytes = (char *)resp->end - (char *)resp->p;
> > +		slack_bytes = (char *)resp->xdr.end - (char *)resp->xdr.p;
> >  		if (slack_bytes < COMPOUND_SLACK_SPACE
> >  				+ COMPOUND_ERR_SLACK_SPACE) {
> >  			BUG_ON(slack_bytes < COMPOUND_ERR_SLACK_SPACE);
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index fac2683..05cc3eb 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1569,10 +1569,10 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
> >  		slot->sl_datalen = 0;
> >  		return;
> >  	}
> > -	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
> > +	slot->sl_datalen = (char *)resp->xdr.p - (char *)resp->cstate.datap;
> >  	base = (char *)resp->cstate.datap -
> > -					(char *)resp->xbuf->head[0].iov_base;
> > -	if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_data,
> > +					(char *)resp->xdr.buf->head[0].iov_base;
> > +	if (read_bytes_from_xdr_buf(resp->xdr.buf, base, slot->sl_data,
> >  				    slot->sl_datalen))
> >  		WARN("%s: sessions DRC could not cache compound\n", __func__);
> >  	return;
> > @@ -1626,7 +1626,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> >  	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
> >  
> >  	resp->opcnt = slot->sl_opcnt;
> > -	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
> > +	resp->xdr.p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
> >  	status = slot->sl_status;
> >  
> >  	return status;
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 18881f3..ef65ffc 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -1747,10 +1747,10 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
> >  }
> >  
> >  #define RESERVE_SPACE(nbytes)	do {				\
> > -	p = resp->p;						\
> > -	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->end);		\
> > +	p = resp->xdr.p;						\
> > +	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->xdr.end);		\
> >  } while (0)
> > -#define ADJUST_ARGS()		resp->p = p
> > +#define ADJUST_ARGS()		resp->xdr.p = p
> >  
> >  /* Encode as an array of strings the string given with components
> >   * separated @sep, escaped with esc_enter and esc_exit.
> > @@ -2751,9 +2751,9 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >  	if (nfserr)
> >  		return nfserr;
> >  
> > -	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
> > +	buflen = resp->xdr.end - resp->xdr.p - (COMPOUND_ERR_SLACK_SPACE >> 2);
> >  	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
> > -				    &resp->p, buflen, getattr->ga_bmval,
> > +				    &resp->xdr.p, buflen, getattr->ga_bmval,
> >  				    resp->rqstp, 0);
> >  	return nfserr;
> >  }
> > @@ -2953,7 +2953,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
> >  
> >  	if (nfserr)
> >  		return nfserr;
> > -	if (resp->xbuf->page_len)
> > +	if (resp->xdr.buf->page_len)
> >  		return nfserr_resource;
> >  
> >  	RESERVE_SPACE(8); /* eof flag and byte count */
> > @@ -2991,18 +2991,18 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
> >  	WRITE32(eof);
> >  	WRITE32(maxcount);
> >  	ADJUST_ARGS();
> > -	resp->xbuf->head[0].iov_len = (char*)p
> > -					- (char*)resp->xbuf->head[0].iov_base;
> > -	resp->xbuf->page_len = maxcount;
> > +	resp->xdr.buf->head[0].iov_len = (char*)p
> > +				- (char*)resp->xdr.buf->head[0].iov_base;
> > +	resp->xdr.buf->page_len = maxcount;
> >  
> >  	/* Use rest of head for padding and remaining ops: */
> > -	resp->xbuf->tail[0].iov_base = p;
> > -	resp->xbuf->tail[0].iov_len = 0;
> > +	resp->xdr.buf->tail[0].iov_base = p;
> > +	resp->xdr.buf->tail[0].iov_len = 0;
> >  	if (maxcount&3) {
> >  		RESERVE_SPACE(4);
> >  		WRITE32(0);
> > -		resp->xbuf->tail[0].iov_base += maxcount&3;
> > -		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
> > +		resp->xdr.buf->tail[0].iov_base += maxcount&3;
> > +		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
> >  		ADJUST_ARGS();
> >  	}
> >  	return 0;
> > @@ -3017,7 +3017,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
> >  
> >  	if (nfserr)
> >  		return nfserr;
> > -	if (resp->xbuf->page_len)
> > +	if (resp->xdr.buf->page_len)
> >  		return nfserr_resource;
> >  	if (!*resp->rqstp->rq_next_page)
> >  		return nfserr_resource;
> > @@ -3041,18 +3041,18 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
> >  
> >  	WRITE32(maxcount);
> >  	ADJUST_ARGS();
> > -	resp->xbuf->head[0].iov_len = (char*)p
> > -				- (char*)resp->xbuf->head[0].iov_base;
> > -	resp->xbuf->page_len = maxcount;
> > +	resp->xdr.buf->head[0].iov_len = (char*)p
> > +				- (char*)resp->xdr.buf->head[0].iov_base;
> > +	resp->xdr.buf->page_len = maxcount;
> >  
> >  	/* Use rest of head for padding and remaining ops: */
> > -	resp->xbuf->tail[0].iov_base = p;
> > -	resp->xbuf->tail[0].iov_len = 0;
> > +	resp->xdr.buf->tail[0].iov_base = p;
> > +	resp->xdr.buf->tail[0].iov_len = 0;
> >  	if (maxcount&3) {
> >  		RESERVE_SPACE(4);
> >  		WRITE32(0);
> > -		resp->xbuf->tail[0].iov_base += maxcount&3;
> > -		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
> > +		resp->xdr.buf->tail[0].iov_base += maxcount&3;
> > +		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
> >  		ADJUST_ARGS();
> >  	}
> >  	return 0;
> > @@ -3068,7 +3068,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >  
> >  	if (nfserr)
> >  		return nfserr;
> > -	if (resp->xbuf->page_len)
> > +	if (resp->xdr.buf->page_len)
> >  		return nfserr_resource;
> >  	if (!*resp->rqstp->rq_next_page)
> >  		return nfserr_resource;
> > @@ -3080,7 +3080,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >  	WRITE32(0);
> >  	WRITE32(0);
> >  	ADJUST_ARGS();
> > -	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
> > +	resp->xdr.buf->head[0].iov_len = ((char*)resp->xdr.p)
> > +				- (char*)resp->xdr.buf->head[0].iov_base;
> >  	tailbase = p;
> >  
> >  	maxcount = PAGE_SIZE;
> > @@ -3121,14 +3122,14 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >  	p = readdir->buffer;
> >  	*p++ = 0;	/* no more entries */
> >  	*p++ = htonl(readdir->common.err == nfserr_eof);
> > -	resp->xbuf->page_len = ((char*)p) -
> > +	resp->xdr.buf->page_len = ((char*)p) -
> >  		(char*)page_address(*(resp->rqstp->rq_next_page-1));
> >  
> >  	/* Use rest of head for padding and remaining ops: */
> > -	resp->xbuf->tail[0].iov_base = tailbase;
> > -	resp->xbuf->tail[0].iov_len = 0;
> > -	resp->p = resp->xbuf->tail[0].iov_base;
> > -	resp->end = resp->p + (PAGE_SIZE - resp->xbuf->head[0].iov_len)/4;
> > +	resp->xdr.buf->tail[0].iov_base = tailbase;
> > +	resp->xdr.buf->tail[0].iov_len = 0;
> > +	resp->xdr.p = resp->xdr.buf->tail[0].iov_base;
> > +	resp->xdr.end = resp->xdr.p + (PAGE_SIZE - resp->xdr.buf->head[0].iov_len)/4;
> >  
> >  	return 0;
> >  err_no_verf:
> > @@ -3587,10 +3588,10 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
> >  	session = resp->cstate.session;
> >  
> >  	if (xb->page_len == 0) {
> > -		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
> > +		length = (char *)resp->xdr.p - (char *)xb->head[0].iov_base + pad;
> >  	} else {
> >  		if (xb->tail[0].iov_base && xb->tail[0].iov_len > 0)
> > -			tlen = (char *)resp->p - (char *)xb->tail[0].iov_base;
> > +			tlen = (char *)resp->xdr.p - (char *)xb->tail[0].iov_base;
> >  
> >  		length = xb->head[0].iov_len + xb->page_len + tlen + pad;
> >  	}
> > @@ -3629,7 +3630,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
> >  		op->status = nfsd4_check_resp_size(resp, 0);
> >  	if (so) {
> >  		so->so_replay.rp_status = op->status;
> > -		so->so_replay.rp_buflen = (char *)resp->p - (char *)(statp+1);
> > +		so->so_replay.rp_buflen = (char *)resp->xdr.p - (char *)(statp+1);
> >  		memcpy(so->so_replay.rp_buf, statp+1, so->so_replay.rp_buflen);
> >  	}
> >  status:
> > @@ -3731,7 +3732,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
> >  		iov = &rqstp->rq_res.tail[0];
> >  	else
> >  		iov = &rqstp->rq_res.head[0];
> > -	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
> > +	iov->iov_len = ((char*)resp->xdr.p) - (char*)iov->iov_base;
> >  	BUG_ON(iov->iov_len > PAGE_SIZE);
> >  	if (nfsd4_has_session(cs)) {
> >  		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index 5ea7df3..6884d70 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -506,9 +506,7 @@ struct nfsd4_compoundargs {
> >  
> >  struct nfsd4_compoundres {
> >  	/* scratch variables for XDR encode */
> > -	__be32 *			p;
> > -	__be32 *			end;
> > -	struct xdr_buf *		xbuf;
> > +	struct xdr_stream		xdr;
> >  	struct svc_rqst *		rqstp;
> >  
> >  	u32				taglen;
> > 
