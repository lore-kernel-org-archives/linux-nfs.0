Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57562 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660Ab3KOPhU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 10:37:20 -0500
Date: Fri, 15 Nov 2013 07:37:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
Message-ID: <20131115153719.GA5443@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.013211118@bombadil.infradead.org>
 <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com>
 <20131115143237.GC1107@infradead.org>
 <B39AEFF9-86F1-4427-B413-72B03548FAEE@gmail.com>
 <20131115152549.GA25512@infradead.org>
 <33A9F8E7-A6DE-435C-AC7A-39472E6A8E90@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <33A9F8E7-A6DE-435C-AC7A-39472E6A8E90@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 15, 2013 at 10:34:52AM -0500, Trond Myklebust wrote:
> > With the current locking model that will require the i_mutex in both
> > read and write around the i_dio_count increment.  The XFS model avoids
> > taking an exclusive lock for the direct I/O fast path.
> > 
> 
> Is that the xfs_ilock vs xfs_rw_ilock code?

xfs_rw_ilock is where you should lock, that are the helpers around
the xfs iolock which is the shared/exclusive lock and the i_mutex
which we still have to take in the exclusive case as the VFS expects it.

