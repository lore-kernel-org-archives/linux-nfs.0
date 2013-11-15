Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:43363 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab3KOQAu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 11:00:50 -0500
Received: by mail-ie0-f179.google.com with SMTP id u16so5134065iet.10
        for <linux-nfs@vger.kernel.org>; Fri, 15 Nov 2013 08:00:50 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131115152549.GA25512@infradead.org>
Date: Fri, 15 Nov 2013 11:00:47 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A928994C-83C2-4EE0-B774-87FAD6A930B3@gmail.com>
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

OK, so afaics it is basically a wrapper around a 2 lock system: an rw_semaphore and the i_mutex. That means adding an rw_semaphore to the nfs_inode; we unfortunately cannot use the existing rw_sem since that is taken during lock recovery and so could deadlock if we take it during i/o.