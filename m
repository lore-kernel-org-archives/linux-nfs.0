From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mountpoint-crossing
Date: Mon, 14 Dec 2009 11:04:01 -0500
Message-ID: <20091214160401.GC12946@fieldses.org>
References: <20091213213945.GB20421@fieldses.org> <1260743595.3076.12.camel@localhost> <20091214083843.5e6e73f5@tlielax.poochiereds.net> <20091214152418.GA12946@fieldses.org> <20091214105214.64714867@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757587AbZLNQEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Dec 2009 11:04:14 -0500
In-Reply-To: <20091214105214.64714867-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 14, 2009 at 10:52:14AM -0500, Jeff Layton wrote:
> On Mon, 14 Dec 2009 10:24:18 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Dec 14, 2009 at 08:38:43AM -0500, Jeff Layton wrote:
> > > I looked at this problem recently based on a request by some of our
> > > coreutils folks. A bit of the discussion is here:
> > > 
> > >     https://bugzilla.redhat.com/show_bug.cgi?id=533569
> > > 
> > > ...and earlier:
> > > 
> > >     https://bugzilla.redhat.com/show_bug.cgi?id=501848
> > > 
> > > Jim Meyering also brought this up on LKML:
> > > 
> > >     http://lkml.org/lkml/2009/11/4/451
> > > 
> > > I'm a little leery of triggering a mount for any server-side mountpoint
> > > that we just happen to have a peek at. That seems like it might get
> > > expensive. Suppose you had 1000 filesystems mounted under the root
> > > share here?
> > 
> > For what it's worth, I'll admit that I ran across this just in
> > artificial testing--I'm not claiming it was causing me a real problem.
> > 
> 
> Understood. It's a bit of a dilemma...
> 
> Clearly though, it's going to be a problem for some programs that need
> to deal with mountpoints (stuff like backup programs in particular).
> The problem though is that I don't think we want to trigger a bunch of
> submounts just because someone does a "ls -l" in a directory that holds
> a bunch of server-side mountpoints.
> 
> The real problem I think is that we allocate new dev minor numbers at
> mount time.

So you're not saying that the minor number allocation is the expensive
part, you're saying that it's cheap and something that we could do
before we do the rest of the mount?

> The ideal thing might be to have the client somehow
> pre-determine what the dev number of that mount would be without
> actually doing the mount. Then we could just present that device number
> in the stat call.

We also need the inode number, for example, which may require an rpc
call.

So what is the most expensive part of a mount?

For a directory full of referral points, there's the problem that you
don't want to have to wait on stat calls from a lot of different
servers.  But maybe that should be handled as a special case.

--b.
