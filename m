Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:62252 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbAVUUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 15:20:47 -0500
Received: by mail-qg0-f46.google.com with SMTP id i50so3065203qgf.5
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 12:20:47 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 22 Jan 2015 15:20:42 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server V2
Message-ID: <20150122152042.08d95397@tlielax.poochiereds.net>
In-Reply-To: <20150122200618.GI898@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
	<20150122200618.GI898@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Jan 2015 15:06:18 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jan 22, 2015 at 12:09:46PM +0100, Christoph Hellwig wrote:
> > This series adds support for the pNFS operations in NFS v4.1, as well
> > as a block layout driver that can export block based filesystems that
> > implement a few additional export operations.  Support for XFS is
> > provided in this series, but other filesystems could be added easily.
> > 
> > The core pNFS code of course owns its heritage to the existing Linux
> > pNFS server prototype, but except for a few bits and pieces in the
> > XDR path nothing is left from it.
> > 
> > The design of this new pNFS server is fairly different from the old
> > one - while the old one implemented very little semantics in nfsd
> > and left almost everything to filesystems my implementation implements
> > as much as possible in common nfsd code, then dispatches to a layout
> > driver that still is part of nfsd and only then calls into the
> > filesystem, thus keeping it free from intimate pNFS knowledge.
> > 
> > This version of the code has been rebased to the locks-for-3.20
> > tree which adds a new lock context structure to the inode.
> 
> By the way, Jeff, do you consider the lock changes are ready?  Would you
> mind if I pulled or cherry-picked them into the nfsd tree just to
> simplify merging this stuff for 3.20?  (Assuming it's going to be
> ready.)
> 
> --b.
> 

Sure, that'd be fine.

The latest version of that set seems to be OK (tip commit ==
8116bf4cb62d33) and has been sitting in linux-next for a while now.
I'll let you know if I get any reports of problems in that area between
now and the merge window though.

Thanks,
Jeff

> > For now
> > we still (ab)use the lease list like in the last version.  Adding
> > a pNFS-specific list would duplicate a lot of code without much
> > benefit.  But during this research I came up with way to associate
> > a nfs4_file with a struct file at open time which should allow
> > to greatly simplify the pNFS and delegation code.  So stay tuned
> > for some patches in this area!
> > 
> > For now this also doesn't take errata 3901 for rfc 5661 into account
> > yet and sticks to the verified errata.  The changes in 3901 seem
> > useful in the longer run one verified and will be implemented
> > eventually. Note that the only existing pNFS block client (Linux)
> > would not benefit from the longer layout lifetimes anyway.
> > 
> > More details are document in the individual patch descriptions and
> > code comments.
> > 
> > This code is also available from:
> > 
> > 	git://git.infradead.org/users/hch/pnfs.git pnfsd-for-3.20-2
> > 
> > Changes since V1:
> > 	- rebased to the locks-for-3.20 tree
> > 	- fixed a memory leak in the nfsd4_encode_getdeviceinfo error path
> > 	- removed the always one lg_roc field
> > 	- added a nopnfs export option
> > 	- use a synchronous transaction in layoutget to simplify recovery
> > 	- various XFS fixes pointed out by Dave
> > 	- various documentation typo fixes


-- 
Jeff Layton <jlayton@primarydata.com>
