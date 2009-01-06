From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix double-lock of i_mutex on nfsv4 recovery
	directory
Date: Tue, 6 Jan 2009 15:07:51 -0500
Message-ID: <20090106200751.GC5901@fieldses.org>
References: <20090106100246.GA13742@alice> <20090106172914.GG2386@fieldses.org> <20090106175828.GH2386@fieldses.org> <20090106192301.GA5901@fieldses.org> <20090106193256.GA13367@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Sesterhenn <snakebyte@gmx.de>, linux-nfs@vger.kernel.org,
	hch@lst.de, neilb@suse.de
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbZAFUHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 15:07:54 -0500
In-Reply-To: <20090106193256.GA13367@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 02:32:56PM -0500, Christoph Hellwig wrote:
> On Tue, Jan 06, 2009 at 02:23:01PM -0500, J. Bruce Fields wrote:
> > On Tue, Jan 06, 2009 at 12:58:29PM -0500, bfields wrote:
> > > No, then we just run into a deadlocks in unlink, create, or any of the
> > > other nfsd operations that want the parent lock to cover more than just
> > > the sync.  So 4c728ef583b3d just doesn't work for nfsd.
> > 
> > We could add another nfsd exception to vfs_sync() by taking the i_mutex
> > only in the "file != NULL" case.  Perhaps there'd be some advantage to
> > having nfsd's peculiarity noted in the common code; I don't have
> > terifically strong feelings either way.
> > 
> > However I'm inclined to think that at that point the special cases get
> > out of hand and that it would be better to keep this back in the nfsd
> > code itself.  The following (tested this time) seems to work.
> 
> Sorry, this is not going to do it.  i_mutex is going to move into
> ->fsync soon unless we kill it entirely pretty soon.  And for the
> cases of stckable filesystems what you do (aswell as the <= 2.6.28 case)
> is broken, as the NFS locking scheme can't apply to the lower stacked
> filesystem.

We need an immediate fix for the regression--nfsd (all versions) just
doesn't work at all in mainline right now.  My apologies for not having
seen that earlier.

A more complete solution is going to take more than a day or two.

--b.
