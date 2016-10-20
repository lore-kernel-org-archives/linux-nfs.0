Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41764 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753072AbcJTNUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 09:20:31 -0400
Date: Thu, 20 Oct 2016 09:20:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-nfs@vger.kernel.org
Subject: Re: sg_set_buf
Message-ID: <20161020132030.GA2868@fieldses.org>
References: <20161018213755.GA10777@fieldses.org>
 <20161020102200.GA6628@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161020102200.GA6628@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 03:22:00AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 18, 2016 at 05:37:55PM -0400, J. Bruce Fields wrote:
> > The NFS code is using sg_set_buf to turn a bit of stack menory into a
> > scatterlist it can pass to the crypto code.  That started BUG()ing as of
> > ac4e97abce9b "scatterlist: sg_set_buf() argument must be in linear
> > mapping".
> > 
> > Is that BUG() being overly strict, or is this something we should never
> > have been doing in the first place?
> 
> In general we use scatterlists to pass dma addresses to hardware, so
> yes, they should not point to the stack. 

The crypto code isn't actually doing that though, is it?

(Or is there a chance it could be passing the data to separate crypto
hardware?  Do people do that these days?)

--b.
