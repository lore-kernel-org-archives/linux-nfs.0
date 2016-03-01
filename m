Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34115 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcCAMg0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2016 07:36:26 -0500
Received: by mail-pa0-f45.google.com with SMTP id fy10so111409498pac.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Mar 2016 04:36:25 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH] nfs/blocklayout: make sure making a aligned read request
To: Christoph Hellwig <hch@infradead.org>
References: <56BF34E3.1020003@gmail.com>
 <20160229095756.GA19397@infradead.org> <56D432D5.7000905@gmail.com>
 <20160229133439.GA4416@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@primarydata.com>, kinglongmee@gmail.com
Message-ID: <56D58CAC.7010603@gmail.com>
Date: Tue, 1 Mar 2016 20:35:56 +0800
MIME-Version: 1.0
In-Reply-To: <20160229133439.GA4416@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc Peng Tao,

On 2/29/2016 21:34, Christoph Hellwig wrote:
> On Mon, Feb 29, 2016 at 08:00:21PM +0800, Kinglong Mee wrote:
>> On 2/29/2016 17:57, Christoph Hellwig wrote:
>>> On Sat, Feb 13, 2016 at 09:51:31PM +0800, Kinglong Mee wrote:
>>>> Only treat write goes up to the inode size as aligned request,
>>>> because it always write PAGE_CACHE_SIZE, but read a dynamic size.
>>>
>>> Can you explain what the point is? 
>>
>> I run ltp tests with read02 hang.
>> There seams a loop in block codes.
>> It is caused by passing an unaligned read to bio.
>> So this patch is out as making a aligned read request.
> 
> Do you have any additional details?

See the following comments.

> 
>>> We'll never use data pas the block size
>>> in the page cache, but per the block size requirement in the spec we must
>>> be able to read it.  This patch means we can't direct storage reads where
>>> we previously could, without any obvious upside.
>>
>> bl_pg_init_read/bl_pg_test_read checks aligned base on SECTOR_SIZE.
>> bl_pg_init_write/bl_pg_test_write checks aligned base on PAGE_SIZE.
>>
>> If according the codes, reads data per block size is okay.
>>
>> But, there is a comment in bl_read_pagelist() as,
>>
>> 250         isect = (sector_t) (f_offset >> SECTOR_SHIFT);
>> 251         /* Code assumes extents are page-aligned */
>> 252         for (i = pg_index; i < header->page_array.npages; i++) {
>> 253                 if (extent_length <= 0) {
>>
>> I don't known the meaning of "extents are page-aligned", 
>> extent's start offset is aligned to page size?
>> or extent's start offset is aligned to page size and length
>> is equal to PAGE_SIZE too ?
> 
> All of them should start aligned to PAGE_SIZE, and also have a length
> that is a multiple of PAGE_SIZE.

Commit f742dc4a3258 ("pnfsblock: fix non-aligned DIO read") has
change the aligned size to SECTOR_SIZE but the request is aligned.

+static bool
+is_aligned_req(struct nfs_page *req, unsigned int alignment)
+{
+	return IS_ALIGNED(req->wb_offset, alignment) &&
+	       IS_ALIGNED(req->wb_bytes, alignment);
+}

Commit 3a6fd1f004fc ("pnfs/blocklayout: remove read-modify-write
 handling in bl_write_pagelist") adds reading up to the inode size.

+       if (req_offset(req) + req->wb_bytes == i_size_read(pgio->pg_inode)) {
+               /*
+                * If the write goes up to the inode size, just write
+                * the full page.  Data past the inode size is
+                * guaranteed to be zeroed by the higher level client
+                * code, and this behaviour is mandated by RFC 5663
+                * section 2.3.2.
+                */
+               return true;
+       }

But the comments are about write request, without any read.
After that patch, the read request can be unaligned.

thanks,
Kinglong Mee
