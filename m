From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsd: Replace nfsd_sync() with vfs_fsync() and
 vfs_fsync_range()
Date: Fri, 29 Jan 2010 15:57:03 -0500
Message-ID: <1264798623.3644.18.camel@localhost>
References: <1264796353.3644.4.camel@localhost>
	 <20100129205022.GA14449@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52554 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab0A2U5P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 15:57:15 -0500
In-Reply-To: <20100129205022.GA14449@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-29 at 15:50 -0500, Christoph Hellwig wrote: 
> On Fri, Jan 29, 2010 at 03:19:13PM -0500, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Currently, the nfs server holds the inode->i_mutex across both the
> > filemap_write_and_wait() call and the fsync() call itself. However we know
> > that filemap_write_and_wait() is already safe against livelocks, so we only
> > need to hold the mutex across the fsync() call.
> > 
> > Fix this by reusing vfs_fsync(), which already does the right thing.
> > Also make sure that we use vfs_fsync_range() in the COMMIT operation, to
> > improve the efficiency for clients that do specify a range.
> 
> I already sent a patch to replace nfsd_sync with it that should be
> queued up.  We can't use vfs_fsync for nfsd_sync_dir as we're already
> holding i_mutex when calling it.  The vfs_fsync_range optimizations
> seems like something that should be applied ontop, though.
> 

OK. I missed your patch as it flew by on the list, but I assume it is
this one:

http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=6a68f89ee1f2d177af4a5410fa7a45734c975fd6;hp=de3cab793c6a5c8505d66bee111edcc7098380ba


I'll separate out the vfs_sync_range() changes and cobble up a patch on
top of the above changeset...

Cheers
  Trond
