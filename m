Return-Path: linux-kernel-owner@vger.kernel.org
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 13 Dec 2014 09:06:45 -0500
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH v2 00/16] nfsd/sunrpc: add support for a workqueue-based
 nfsd
Message-ID: <20141213090645.62fd5348@tlielax.poochiereds.net>
In-Reply-To: <20141212165952.GD22149@ZenIV.linux.org.uk>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
	<20141212021241.GA5944@ZenIV.linux.org.uk>
	<CA+55aFy_LRUzMO_ixgVtysr7OKs=GSk9dU1ORRUdrTn210VuyA@mail.gmail.com>
	<20141212030206.GA22149@ZenIV.linux.org.uk>
	<20141212065408.2f76c41e@tlielax.poochiereds.net>
	<20141212165952.GD22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Dec 2014 16:59:52 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Fri, Dec 12, 2014 at 06:54:08AM -0500, Jeff Layton wrote:
> 
> > > Umm...  I would be very surprised if it turned out to be a problem.
> > > nfsd really doesn't give a fuck about its cwd and root - not in the
> > > thread side of things.  And (un)exporting is (a) not on a hot path
> > > and (b) not done from a kernel thread anyway.  fh_to_dentry and friends
> > > doesn't care about root/cwd, etc.
> > > 
> > > I don't see anything that could cause that kind of issues.
> > 
> > I like the change overall -- it would certainly make my patch series
> > simpler, but what about pathwalking? We do take the fs->lock in
> > unlazy_walk. Is it possible we'd end up with more contention there?
> 
> That would take a pathname lookup in kernel thread side of nfsd that
> 	* isn't single-component
> 	* isn't LOOKUP_ROOT one (i.e. vfs_path_lookup() or file_open_root())
> and I would really hope we don't have such things.  Any such a beast would
> allow probing the tree layout outside of what we export, to start with...
> 
> AFAICS, we really don't have anything of that sort.  Note that e.g.
> lookup_one_len() doesn't go anywhere near ->fs->lock...

Ahh right. Ok, then I don't see any issue with this so far. Maybe worth
letting it stew in -next once -rc1 ships? Thanks! 

Acked-by: Jeff Layton <jlayton@primarydata.com>
