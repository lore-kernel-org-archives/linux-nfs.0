Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57518 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KOPZt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 10:25:49 -0500
Date: Fri, 15 Nov 2013 07:25:49 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
Message-ID: <20131115152549.GA25512@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.013211118@bombadil.infradead.org>
 <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com>
 <20131115143237.GC1107@infradead.org>
 <B39AEFF9-86F1-4427-B413-72B03548FAEE@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B39AEFF9-86F1-4427-B413-72B03548FAEE@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 15, 2013 at 10:23:01AM -0500, Trond Myklebust wrote:
> > buffered read:			shared
> > direct I/O			exclusive if pagecache is present, then
> > 				demote to shared for actual I/O,
> > 				shared only if no pages are present on
> > 				the file
> 
> I think we should try to close the truncate race first. Then let?s look at whether or not people need better consistency with the page cache.

With the current locking model that will require the i_mutex in both
read and write around the i_dio_count increment.  The XFS model avoids
taking an exclusive lock for the direct I/O fast path.

