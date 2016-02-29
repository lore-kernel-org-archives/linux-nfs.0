Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38629 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbcB2Nek (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Feb 2016 08:34:40 -0500
Date: Mon, 29 Feb 2016 05:34:39 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs/blocklayout: make sure making a aligned read request
Message-ID: <20160229133439.GA4416@infradead.org>
References: <56BF34E3.1020003@gmail.com>
 <20160229095756.GA19397@infradead.org>
 <56D432D5.7000905@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56D432D5.7000905@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 29, 2016 at 08:00:21PM +0800, Kinglong Mee wrote:
> On 2/29/2016 17:57, Christoph Hellwig wrote:
> > On Sat, Feb 13, 2016 at 09:51:31PM +0800, Kinglong Mee wrote:
> >> Only treat write goes up to the inode size as aligned request,
> >> because it always write PAGE_CACHE_SIZE, but read a dynamic size.
> > 
> > Can you explain what the point is? 
> 
> I run ltp tests with read02 hang.
> There seams a loop in block codes.
> It is caused by passing an unaligned read to bio.
> So this patch is out as making a aligned read request.

Do you have any additional details?

> > We'll never use data pas the block size
> > in the page cache, but per the block size requirement in the spec we must
> > be able to read it.  This patch means we can't direct storage reads where
> > we previously could, without any obvious upside.
> 
> bl_pg_init_read/bl_pg_test_read checks aligned base on SECTOR_SIZE.
> bl_pg_init_write/bl_pg_test_write checks aligned base on PAGE_SIZE.
> 
> If according the codes, reads data per block size is okay.
> 
> But, there is a comment in bl_read_pagelist() as,
> 
> 250         isect = (sector_t) (f_offset >> SECTOR_SHIFT);
> 251         /* Code assumes extents are page-aligned */
> 252         for (i = pg_index; i < header->page_array.npages; i++) {
> 253                 if (extent_length <= 0) {
> 
> I don't known the meaning of "extents are page-aligned", 
> extent's start offset is aligned to page size?
> or extent's start offset is aligned to page size and length
> is equal to PAGE_SIZE too ?

All of them should start aligned to PAGE_SIZE, and also have a length
that is a multiple of PAGE_SIZE.
