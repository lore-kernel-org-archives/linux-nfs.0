Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57311 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab3KOOch (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 09:32:37 -0500
Date: Fri, 15 Nov 2013 06:32:37 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
Message-ID: <20131115143237.GC1107@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.013211118@bombadil.infradead.org>
 <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 14, 2013 at 03:43:21PM -0500, Trond Myklebust wrote:
> 
> Hi Christoph,
> 
> Why do we need to protect the page cache here? Using O_DIRECT and the page cache without some kind of application-specific synchronization method is technically not supported, since that violates close-to-open cache consistency.

As far as I understand close to open matter for synchronizations with
access from different clients.  Linux applications do expect tight
synchronization locally.

> What we _do_ want to support, though, is parallel reads and writes to the server by applications that know what they are doing. If we were to only protect the i_dio_count, then we could fix the truncate race, while continuing to allow parallelism. Is there any reason why we cannot do this?

To just fix that race we could do it.  Note that even with the patch we
only do the setup and I/O submission under the lock, and wait for it
outside, similar to what the local filesystems do for aio, but not for
synchronous direct I/O.

Another good way to speed this up is to use locking scheme XFS uses with
a shared exclusive lock:

buffered write:			exclusive
buffered read:			shared
direct I/O			exclusive if pagecache is present, then
				demote to shared for actual I/O,
				shared only if no pages are present on
				the file

