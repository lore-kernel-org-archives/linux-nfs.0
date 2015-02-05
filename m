Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:37487 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbbBEQrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 11:47:04 -0500
Date: Thu, 5 Feb 2015 11:47:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150205164701.GA4289@fieldses.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54D394EC.9030902@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2015 at 11:06:04AM -0500, Anna Schumaker wrote:
> On 02/05/2015 09:13 AM, Christoph Hellwig wrote:
> >> +	p = xdr_reserve_space(xdr, 4 + 8 + 4); /* content type, offset, maxcount */
> >> +	if (!p)
> >> +		return nfserr_resource;
> >> +	xdr_commit_encode(xdr);
> >> +
> >> +	maxcount = svc_max_payload(resp->rqstp);
> >> +	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
> >> +	maxcount = min_t(unsigned long, maxcount, read->rd_length);
> >> +
> >> +	err = nfsd4_encode_readv(resp, read, file, &maxcount);
> > 
> > If the READ_PLUS implementation can't use the splice read path it's
> > probably a loss for most workloads.
> > 
> 
> I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.

The advantage of splice is it can hand us references to page cache pages
that already hold the read data, which we can in turn hand off to the
network layer when we send the reply, minimizing copying.

But then we need a data structure than can keep track of all the pieces
of the resulting reply, which consists of that the read data plus any
protocol xdr that surrounds the read data.  The xdr_buf represents this
fine: head, (pages[], page_base, page_len), tail.

If you want to do zero-copy READ_PLUS then you need a data structure
that will represent a reply with multiple data segments.

I guess you could add more fields to the xdr_buf, or leave it alone and
keep a list of xdr_buf's instead.

The latter sounds better to me, and I imagine that would be doable but
tedious--but I haven't honestly thought it through.

There's also a tradeoff on the client side, isn't there?  Worst case if
the data to be read is a small hole followed by a bunch of data, then a
READ_PLUS would end up needing to copy all the data in return for only a
small savings in data transferred.

I feel like READ_PLUS needs more of an argument.

--b.
