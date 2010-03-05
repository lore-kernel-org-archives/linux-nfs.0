Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59763 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab0CEPs1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Mar 2010 10:48:27 -0500
Date: Fri, 5 Mar 2010 15:48:23 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: Merge of the 'write_inode' branch from the VFS tree
Message-ID: <20100305154823.GV30031@ZenIV.linux.org.uk>
References: <1267802800.5174.6.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1267802800.5174.6.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 05, 2010 at 10:26:40AM -0500, Trond Myklebust wrote:
> Hi Al,
> 
> When you submitted the VFS changes for this merge window, I was hoping
> you would include the 'write_inode' branch. I've been waiting for them
> in order to push the NFS writeback improvements to Linus.
> 
> Would you be willing to either push the write_inode branch to Linus or
> to Ack my doing so as part of the NFS push?

Said branch has managed to grow conflicts with XFS commits already in
the mainline ;-/  With commits postdating the write_inode ones by a week
or so and having the same author.

I'm going to push the next VFS pile in about half an hour and get to the
write_inode situation.  I'm not sure what's the best course here.  Note
that since you've pulled it, you also have conflicts with what's in the
mainline.  I can do *another* backmerge (already had one due to gfs2 trivial
conflicts) and push the result.  Which will suck, since XFS conflicts
are not entirely trivial and we'll get a really ugly merge node, with
conflict resolution both hidden and not quite obvious.

Or I can do a new branch, put updated pair of patches there (hch has sent
the updated variants my way) and ask you to rebuild NFS tree.  Which will
also suck, since it adds PITA for you and you are completely innocent in
that clusterfuck.

Suggestions?  I'd love to get out of that mess with minimal PITA for
everyone involved and minimally messed tree...

One thing for sure - I'm not going to do that kind of "guaranteed to be
unchanged" shared branches again, TYVM.
