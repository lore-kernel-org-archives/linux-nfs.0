Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbaCWOn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Mar 2014 10:43:56 -0400
Date: Sun, 23 Mar 2014 10:43:44 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 23/50] nfsd4: "backfill" using write_bytes_to_xdr_buf
Message-ID: <20140323144344.GA30644@fieldses.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-24-git-send-email-bfields@redhat.com>
 <20140323065154.GD24465@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323065154.GD24465@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 22, 2014 at 11:51:54PM -0700, Christoph Hellwig wrote:
> Looks good, but shouldn't there be an abstract function to skip writing
> into an XDR buf instead of the pointer increment as well?

So you're talking about the earlier spot in the code where we've got a

	p++; /* to be filled in later? */

I'm not convinced it'd be worth it, but maybe.

> I wonder if the XDR buf internal should even be entirely hidden to the
> consummers and it should only be accessed through procedural interfaces?

By the end of the series, most xdr encoding looks like

	p = xdr_reserve_space(xdr, <nbytes>);

	*p++ = cpu_to_be32(<some value>);
	p = xdr_encode_something_more_complicated(p, <some struct>);
	...

It doesn't require the encoders to know much about xdr_buf's.

The main exception is read, especially the splice case.  We could
probably do better there, I just haven't thought much about it yet.

Hm, but maybe what you're asking for here is just a
write_bytes_to_xdr_buf wrapper that takes the xdr_stream instead of an
xdr_buf, and a corresponding function to read xdr->buf->len when we want
an offset?  OK, maybe so.

--b.
