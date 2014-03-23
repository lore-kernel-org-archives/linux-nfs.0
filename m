Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47324 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaCWOwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 10:52:08 -0400
Date: Sun, 23 Mar 2014 07:52:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 23/50] nfsd4: "backfill" using write_bytes_to_xdr_buf
Message-ID: <20140323145205.GA29730@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-24-git-send-email-bfields@redhat.com>
 <20140323065154.GD24465@infradead.org>
 <20140323144344.GA30644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323144344.GA30644@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 23, 2014 at 10:43:44AM -0400, J. Bruce Fields wrote:
> By the end of the series, most xdr encoding looks like
> 
> 	p = xdr_reserve_space(xdr, <nbytes>);
> 
> 	*p++ = cpu_to_be32(<some value>);
> 	p = xdr_encode_something_more_complicated(p, <some struct>);
> 	...
> 
> It doesn't require the encoders to know much about xdr_buf's.
> 
> The main exception is read, especially the splice case.  We could
> probably do better there, I just haven't thought much about it yet.
> 
> Hm, but maybe what you're asking for here is just a
> write_bytes_to_xdr_buf wrapper that takes the xdr_stream instead of an
> xdr_buf, and a corresponding function to read xdr->buf->len when we want
> an offset?  OK, maybe so.

I was thinking of something like that, but looking over the rest of the
series I don't think it fits in here.  I like the way where your series
is moving the XDR code, and that seems enough for now.

