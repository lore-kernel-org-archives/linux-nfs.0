From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Wed, 7 Jan 2009 11:56:39 -0500
Message-ID: <20090107165639.GA28489@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <20090106230244.GB13785@fieldses.org> <20090106230356.GA31520@lst.de> <20090106230551.GC13785@fieldses.org> <20090107001501.GH13785@fieldses.org> <20090106162328.1b4511a6.akpm@linux-foundation.org> <20090107002816.GL13785@fieldses.org> <20090107074256.GA5102@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, hch@lst.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	neilb@suse.de, snakebyte@gmx.de
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:36991 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbZAGQ4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2009 11:56:47 -0500
In-Reply-To: <20090107074256.GA5102@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2009 at 02:42:56AM -0500, Christoph Hellwig wrote:
> On Tue, Jan 06, 2009 at 07:28:16PM -0500, J. Bruce Fields wrote:
> > On Tue, Jan 06, 2009 at 04:23:28PM -0800, Andrew Morton wrote:
> > > On Tue, 6 Jan 2009 19:15:01 -0500
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > >     nfsd: fix double-locks of directory mutex
> > > 
> > > grumble.
> > 
> > This is literally just a revert of part of 4c728ef583b3d822; if you'd
> > like me to clean up this stuff while I'm there, I'm happy to.
> 
> Please leave it as the revert.  NFSD really needs to use vfs_fsync
> eventually so we can sort out our ->fsync usage.

OK.  Mind if we just revert the whole commit for now?  With the
double-lock regression is still there for ecryptfs exports, then I'd
rather do a simple revert of the whole patch and not try to pick out
just the fs/nfsd/vfs.c part.

--b.

> I suspect the best way to get there is to to the i_mutex removal for
> fsync earlier than planned, but I'll need to audit the filesystems
> first.
