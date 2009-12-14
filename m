From: Jeff Layton <jlayton@redhat.com>
Subject: Re: mountpoint-crossing
Date: Mon, 14 Dec 2009 11:44:39 -0500
Message-ID: <20091214114439.471a22fe@tlielax.poochiereds.net>
References: <20091213213945.GB20421@fieldses.org>
	<1260743595.3076.12.camel@localhost>
	<20091214083843.5e6e73f5@tlielax.poochiereds.net>
	<20091214152418.GA12946@fieldses.org>
	<20091214105214.64714867@tlielax.poochiereds.net>
	<20091214160401.GC12946@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbZLNQpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2009 11:45:10 -0500
In-Reply-To: <20091214160401.GC12946@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Dec 2009 11:04:01 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Dec 14, 2009 at 10:52:14AM -0500, Jeff Layton wrote:
> > On Mon, 14 Dec 2009 10:24:18 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Dec 14, 2009 at 08:38:43AM -0500, Jeff Layton wrote:
> > > > I looked at this problem recently based on a request by some of our
> > > > coreutils folks. A bit of the discussion is here:
> > > > 
> > > >     https://bugzilla.redhat.com/show_bug.cgi?id=533569
> > > > 
> > > > ...and earlier:
> > > > 
> > > >     https://bugzilla.redhat.com/show_bug.cgi?id=501848
> > > > 
> > > > Jim Meyering also brought this up on LKML:
> > > > 
> > > >     http://lkml.org/lkml/2009/11/4/451
> > > > 
> > > > I'm a little leery of triggering a mount for any server-side mountpoint
> > > > that we just happen to have a peek at. That seems like it might get
> > > > expensive. Suppose you had 1000 filesystems mounted under the root
> > > > share here?
> > > 
> > > For what it's worth, I'll admit that I ran across this just in
> > > artificial testing--I'm not claiming it was causing me a real problem.
> > > 
> > 
> > Understood. It's a bit of a dilemma...
> > 
> > Clearly though, it's going to be a problem for some programs that need
> > to deal with mountpoints (stuff like backup programs in particular).
> > The problem though is that I don't think we want to trigger a bunch of
> > submounts just because someone does a "ls -l" in a directory that holds
> > a bunch of server-side mountpoints.
> > 
> > The real problem I think is that we allocate new dev minor numbers at
> > mount time.
> 
> So you're not saying that the minor number allocation is the expensive
> part, you're saying that it's cheap and something that we could do
> before we do the rest of the mount?
> 

Yeah, minor number allocation is fairly cheap (it's just IDA hash calls
I think). If we wanted to try and preallocate them then we have to
consider how long to cache them too. The hassle of doing that may outweigh the expense of triggering

I am making an assumption that mounts are somewhat expensive to do.
Maybe you can convince me otherwise. :)


> > The ideal thing might be to have the client somehow
> > pre-determine what the dev number of that mount would be without
> > actually doing the mount. Then we could just present that device number
> > in the stat call.
> 
> We also need the inode number, for example, which may require an rpc
> call.
> 

We already have that, right? We've done a GETATTR (or equivalent) and
noticed that the inode has a different fsid. We even send back the
"real" inode number in the statbuf (but obviously w/o the right
device info since the mount hasn't been triggered yet).

> So what is the most expensive part of a mount?
> 
> For a directory full of referral points, there's the problem that you
> don't want to have to wait on stat calls from a lot of different
> servers.  But maybe that should be handled as a special case.
> 

Good question. I suppose I was making an assumption here that
triggering a mount would mean at least some RPC's and that might make
that "ls -l" stall for a while if we have to talk to a bunch of
different servers.

Maybe I'm blowing the performance hit out of proportion though? That
said, I'm not crazy about altering the generic VFS to fix this. I
wonder if there's another way to do it?

-- 
Jeff Layton <jlayton@redhat.com>
