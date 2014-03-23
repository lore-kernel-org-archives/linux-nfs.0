Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbaCWPLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Mar 2014 11:11:44 -0400
Date: Sun, 23 Mar 2014 11:11:42 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 18/50] nfsd4: use xdr_stream throughout compound encoding
Message-ID: <20140323151142.GD30644@fieldses.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-19-git-send-email-bfields@redhat.com>
 <20140323064336.GA24465@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323064336.GA24465@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 22, 2014 at 11:43:36PM -0700, Christoph Hellwig wrote:
> >  #define RESERVE_SPACE(nbytes)	do {				\
> > -	p = resp->xdr.p;						\
> > -	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->xdr.end);		\
> > +	p = xdr_reserve_space(&resp->xdr, nbytes);		\
> > +	BUG_ON(!p);						\
> >  } while (0)
> > -#define ADJUST_ARGS()		resp->xdr.p = p
> > +#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\
> 
> I think the code would become more clear if you'd start expanding these
> macros.  IF the RESERVE_SPACE BUG_ON is important enough it should move
> into xdr_reserve_space or a variant thereof, or otherweise just removed.

Yeah, those will go later.

Ideas for how to sequence these changes better welcomed.

> > +	if (nfserr) {
> > +		xdr->p -= 2;
> > +		xdr->iov->iov_len -= 8;
> 
> 
> > +	if (nfserr) {
> > +		xdr->p--;
> > +		xdr->iov->iov_len -= 4;
> >  		return nfserr;
> > +	}
> 
> 
> > +	xdr->p = savep;
> > +	xdr->iov->iov_len = ((char *)resp->xdr.p)
> > +				- (char *)resp->xdr.buf->head[0].iov_base;
> 
> Where is this coming from?  Looks like deep magic to be and would
> benefit from comments, symbolic names and/or a helper.

OK, may be worth a comment even if it's only a temporary thing.

--b.
