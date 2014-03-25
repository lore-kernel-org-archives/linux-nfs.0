Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55281 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbaCYPiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2014 11:38:23 -0400
Date: Tue, 25 Mar 2014 08:38:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 18/50] nfsd4: use xdr_stream throughout compound encoding
Message-ID: <20140325153821.GB5613@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-19-git-send-email-bfields@redhat.com>
 <20140323064336.GA24465@infradead.org>
 <20140323151142.GD30644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323151142.GD30644@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 23, 2014 at 11:11:42AM -0400, J. Bruce Fields wrote:
> > >  } while (0)
> > > -#define ADJUST_ARGS()		resp->xdr.p = p
> > > +#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\
> > 
> > I think the code would become more clear if you'd start expanding these
> > macros.  IF the RESERVE_SPACE BUG_ON is important enough it should move
> > into xdr_reserve_space or a variant thereof, or otherweise just removed.
> 
> Yeah, those will go later.
> 
> Ideas for how to sequence these changes better welcomed.

In this case I'd suggest just killing ADJUST_ARGS in this patch.

In general if there's something looking ugly that gets killed or cleaned
up later I simply mention it in the patch description.

> > > +	xdr->p = savep;
> > > +	xdr->iov->iov_len = ((char *)resp->xdr.p)
> > > +				- (char *)resp->xdr.buf->head[0].iov_base;
> > 
> > Where is this coming from?  Looks like deep magic to be and would
> > benefit from comments, symbolic names and/or a helper.
> 
> OK, may be worth a comment even if it's only a temporary thing.

I didn't know it was going away when I read the patch.  Keeping the code
as-is is fine with me, but maybe a little comment in the changelog might
help reviwers the look at the next iteration.

