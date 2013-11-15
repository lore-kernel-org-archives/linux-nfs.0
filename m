Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:50512 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3KOPez convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 10:34:55 -0500
Received: by mail-ie0-f182.google.com with SMTP id e14so4928985iej.27
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 07:34:54 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131115152549.GA25512@infradead.org>
Date: Fri, 15 Nov 2013 10:34:52 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <33A9F8E7-A6DE-435C-AC7A-39472E6A8E90@gmail.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.013211118@bombadil.infradead.org> <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com> <20131115143237.GC1107@infradead.org> <B39AEFF9-86F1-4427-B413-72B03548FAEE@gmail.com> <20131115152549.GA25512@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 10:25, Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Nov 15, 2013 at 10:23:01AM -0500, Trond Myklebust wrote:
>>> buffered read:			shared
>>> direct I/O			exclusive if pagecache is present, then
>>> 				demote to shared for actual I/O,
>>> 				shared only if no pages are present on
>>> 				the file
>> 
>> I think we should try to close the truncate race first. Then let?s look at whether or not people need better consistency with the page cache.
> 
> With the current locking model that will require the i_mutex in both
> read and write around the i_dio_count increment.  The XFS model avoids
> taking an exclusive lock for the direct I/O fast path.
> 

Is that the xfs_ilock vs xfs_rw_ilock code?

