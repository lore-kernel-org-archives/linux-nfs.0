From: Jeff Layton <jlayton@redhat.com>
Subject: Re: mountpoint-crossing
Date: Mon, 14 Dec 2009 10:52:14 -0500
Message-ID: <20091214105214.64714867@tlielax.poochiereds.net>
References: <20091213213945.GB20421@fieldses.org>
	<1260743595.3076.12.camel@localhost>
	<20091214083843.5e6e73f5@tlielax.poochiereds.net>
	<20091214152418.GA12946@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178AbZLNPwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2009 10:52:20 -0500
In-Reply-To: <20091214152418.GA12946@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Dec 2009 10:24:18 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Dec 14, 2009 at 08:38:43AM -0500, Jeff Layton wrote:
> > On Sun, 13 Dec 2009 17:33:15 -0500
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Sun, 2009-12-13 at 16:39 -0500, J. Bruce Fields wrote: 
> > > > On a recent kernel:
> > > > 
> > > > 	# mount -tnfs4 pearlet1:/ /mnt/
> > > > 	# find /mnt/
> > > > 	/mnt/
> > > > 	find: File system loop detected; `/mnt/DIR' is part of the same
> > > > 	file system loop as `/mnt/'.
> > > > 
> > > > Here /mnt/DIR is a server-side mountpoint, hence has a different fsid
> > > > than /mnt/.  Wireshark confirms that the server is returning a different
> > > > fsid.  However, 'strace -v find /mnt/' shows stat returning
> > > > st_dev=makedev(0, 22) for both /mnt and /mnt/DIR.
> > > > 
> > > > If I then do a 'ls /mnt/DIR', followed by another find, the error goes
> > > > away, and this time an strace shows that stat is returning (0, 23) for
> > > > /mnt/DIR.
> > > > 
> > > > I don't see any obvious problem with the network trace, so it looks to
> > > > me like the client is failing to recognize the mountpoint when it
> > > > should?
> > > 
> > > This is a known consequence of the way we treat submounts (and
> > > referrals); we're basically treating them as a special kind of symlink.
> > > The problem then arises when syscalls such as stat() fail to set the
> > > LOOKUP_FOLLOW flag, and so the user is granted a temporary peek of the
> > > underlying inode.
> > > 
> > > I'm not sure how we should treat this. I suppose we could change the
> > > test in __link_path_walk() so that it always call follow_link() if the
> > > inode is not a symlink...
> > > 
> > 
> > I looked at this problem recently based on a request by some of our
> > coreutils folks. A bit of the discussion is here:
> > 
> >     https://bugzilla.redhat.com/show_bug.cgi?id=533569
> > 
> > ...and earlier:
> > 
> >     https://bugzilla.redhat.com/show_bug.cgi?id=501848
> > 
> > Jim Meyering also brought this up on LKML:
> > 
> >     http://lkml.org/lkml/2009/11/4/451
> > 
> > I'm a little leery of triggering a mount for any server-side mountpoint
> > that we just happen to have a peek at. That seems like it might get
> > expensive. Suppose you had 1000 filesystems mounted under the root
> > share here?
> 
> For what it's worth, I'll admit that I ran across this just in
> artificial testing--I'm not claiming it was causing me a real problem.
> 

Understood. It's a bit of a dilemma...

Clearly though, it's going to be a problem for some programs that need
to deal with mountpoints (stuff like backup programs in particular).
The problem though is that I don't think we want to trigger a bunch of
submounts just because someone does a "ls -l" in a directory that holds
a bunch of server-side mountpoints.

The real problem I think is that we allocate new dev minor numbers at
mount time. The ideal thing might be to have the client somehow
pre-determine what the dev number of that mount would be without
actually doing the mount. Then we could just present that device number
in the stat call.

-- 
Jeff Layton <jlayton@redhat.com>
