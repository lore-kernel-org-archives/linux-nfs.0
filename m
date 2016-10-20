Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47074 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbcJTKWC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2016 06:22:02 -0400
Date: Thu, 20 Oct 2016 03:22:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-nfs@vger.kernel.org
Subject: Re: sg_set_buf
Message-ID: <20161020102200.GA6628@infradead.org>
References: <20161018213755.GA10777@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161018213755.GA10777@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 18, 2016 at 05:37:55PM -0400, J. Bruce Fields wrote:
> The NFS code is using sg_set_buf to turn a bit of stack menory into a
> scatterlist it can pass to the crypto code.  That started BUG()ing as of
> ac4e97abce9b "scatterlist: sg_set_buf() argument must be in linear
> mapping".
> 
> Is that BUG() being overly strict, or is this something we should never
> have been doing in the first place?

In general we use scatterlists to pass dma addresses to hardware, so
yes, they should not point to the stack. 
