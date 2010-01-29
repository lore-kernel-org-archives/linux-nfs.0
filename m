From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nfsd: Replace nfsd_sync() with vfs_fsync() and
	vfs_fsync_range()
Date: Fri, 29 Jan 2010 15:50:22 -0500
Message-ID: <20100129205022.GA14449@infradead.org>
References: <1264796353.3644.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54500 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab0A2UuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 15:50:25 -0500
In-Reply-To: <1264796353.3644.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 29, 2010 at 03:19:13PM -0500, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Currently, the nfs server holds the inode->i_mutex across both the
> filemap_write_and_wait() call and the fsync() call itself. However we know
> that filemap_write_and_wait() is already safe against livelocks, so we only
> need to hold the mutex across the fsync() call.
> 
> Fix this by reusing vfs_fsync(), which already does the right thing.
> Also make sure that we use vfs_fsync_range() in the COMMIT operation, to
> improve the efficiency for clients that do specify a range.

I already sent a patch to replace nfsd_sync with it that should be
queued up.  We can't use vfs_fsync for nfsd_sync_dir as we're already
holding i_mutex when calling it.  The vfs_fsync_range optimizations
seems like something that should be applied ontop, though.

