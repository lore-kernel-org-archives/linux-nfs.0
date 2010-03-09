Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bld-mail14.adl6.internode.on.net ([150.101.137.99]:38919 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753632Ab0CIIwR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 03:52:17 -0500
Date: Tue, 9 Mar 2010 19:52:09 +1100
From: Dave Chinner <david@fromorbit.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [git pull] vfs part 3 (write_inode mess)
Message-ID: <20100309085209.GK28189@discord.disaster>
References: <1267802800.5174.6.camel@localhost.localdomain> <20100305154823.GV30031@ZenIV.linux.org.uk> <20100305174017.GX30031@ZenIV.linux.org.uk> <4B955C8D.6030907@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B955C8D.6030907@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 08, 2010 at 03:22:37PM -0500, Steve Dickson wrote:
> On 03/05/2010 12:40 PM, Al Viro wrote:
> > On Fri, Mar 05, 2010 at 03:48:23PM +0000, Al Viro wrote:
> >> I'm going to push the next VFS pile in about half an hour and get to the
> >> write_inode situation.  I'm not sure what's the best course here.  Note
> >> that since you've pulled it, you also have conflicts with what's in the
> >> mainline.  I can do *another* backmerge (already had one due to gfs2 trivial
> >> conflicts) and push the result.  Which will suck, since XFS conflicts
> >> are not entirely trivial and we'll get a really ugly merge node, with
> >> conflict resolution both hidden and not quite obvious.
> > 
> > OK, a backmerge it is.  Linus, could you please pull
> > git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ write_inode
> > or suggest a saner way to do that?
> > 
> > I've done backmerges of two points in mainline (trees that got merged
> > into mainline, actually) that created conflicts.  So at that point it's
> > (a) descendent of what's been pulled into NFS tree and (b) merges clean
> > with mainline.  All for two patches (at commit 716c28c..) ;-/
> > 
> > It's independent from the previous VFS pull; there's more stuff, hopefully
> > for later today, but the worst of the mess should be gone with that one.
> Has there been any kind of testing that show this approach does indeed
> improve performance? Any hardcore number? 

http://oss.sgi.com/archives/xfs/2010-01/msg00556.html

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
