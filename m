Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbaCWPHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Mar 2014 11:07:25 -0400
Date: Sun, 23 Mar 2014 11:07:22 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/50] nfsd4: use xdr_truncate_encode
Message-ID: <20140323150722.GC30644@fieldses.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-23-git-send-email-bfields@redhat.com>
 <20140323065005.GC24465@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323065005.GC24465@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 22, 2014 at 11:50:05PM -0700, Christoph Hellwig wrote:
> Ah, here we got the helper for most of the error handling I asked for
> earlier.  Might be worth mentioning in that patch that this gets further
> improvements soons.

OK, will do.

> >  	if (nfserr) {
> > -		xdr->p -= 2;
> > -		xdr->iov->iov_len -= 8;
> > +		xdr->buf->page_len = 0;
> > +		xdr_truncate_encode(xdr, starting_len);
> 
> Why do we still need to manually set the page_len?

In the splice case read increments page_len as it goes.  This leaves the
xdr_buf in somewhat of an inconsistent state and may confuse a later
xdr_truncate_encode.

It's a little ugly, I'm not sure what to do about it.  Currently I'm
thinking of just telling nfsd's splice callback to leave page_len alone.
That'd mean taking another look at the splice callback and at the v2/v3
read code.

--b.
