From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Tue, 6 Jan 2009 18:05:51 -0500
Message-ID: <20090106230551.GC13785@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <20090106230244.GB13785@fieldses.org> <20090106230356.GA31520@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>, Eric Sesterhenn <snakebyte@gmx.de>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40758 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbZAFXFy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:05:54 -0500
In-Reply-To: <20090106230356.GA31520@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2009 at 12:03:56AM +0100, Christoph Hellwig wrote:
> On Tue, Jan 06, 2009 at 06:02:44PM -0500, J. Bruce Fields wrote:
> > On Tue, Jan 06, 2009 at 02:56:12PM -0800, Andrew Morton wrote:
> > > 
> > > I just built current mainline plus the just-sent 266 -mm patches.
> > > 
> > > The machine failed to power off when hit with `halt -pfn'.  dmesg output:
> > 
> > Christoph, can you live with this for now?
> 
> nfsd part is well, livable.  But the fs/sync.c is buggy as stackable
> filesystems can call vfs_fsync with a NULL pointer due to nfs calling it
> that way, so please drop that hunk.

Whoops, OK, I didn't understand that.  I'll drop that hunk, retest, then
submit--should take a few minutes.

--b.
