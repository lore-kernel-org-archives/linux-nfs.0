Return-Path: linux-kernel-owner@vger.kernel.org
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 12 Dec 2014 06:54:08 -0500
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH v2 00/16] nfsd/sunrpc: add support for a workqueue-based
 nfsd
Message-ID: <20141212065408.2f76c41e@tlielax.poochiereds.net>
In-Reply-To: <20141212030206.GA22149@ZenIV.linux.org.uk>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
	<20141212021241.GA5944@ZenIV.linux.org.uk>
	<CA+55aFy_LRUzMO_ixgVtysr7OKs=GSk9dU1ORRUdrTn210VuyA@mail.gmail.com>
	<20141212030206.GA22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Dec 2014 03:02:06 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Thu, Dec 11, 2014 at 06:29:37PM -0800, Linus Torvalds wrote:
> > On Thu, Dec 11, 2014 at 6:12 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > >
> > > Linus, do you see any problems with the following patch (against the mainline)?
> > 
> > Not concpetually, but create_kthread() uses CLONE_FS, and I don't
> > think it's just umask that things like nfsd want to avoid sharing.
> > What about all the *other* fields?
> > 
> > Just as an example: even if all the threads actually end up all having
> > the same global root, what about contention on 'fs->lock'?
> > 
> > I have *not* looked at the details, and maybe there's some reason I'm
> > completely off, but it worries me.
> 
> Umm...  I would be very surprised if it turned out to be a problem.
> nfsd really doesn't give a fuck about its cwd and root - not in the
> thread side of things.  And (un)exporting is (a) not on a hot path
> and (b) not done from a kernel thread anyway.  fh_to_dentry and friends
> doesn't care about root/cwd, etc.
> 
> I don't see anything that could cause that kind of issues.

I like the change overall -- it would certainly make my patch series
simpler, but what about pathwalking? We do take the fs->lock in
unlazy_walk. Is it possible we'd end up with more contention there?

-- 
Jeff Layton <jlayton@primarydata.com>
