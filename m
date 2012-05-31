Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37672 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757879Ab2EaUBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 16:01:39 -0400
Date: Thu, 31 May 2012 16:01:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: nfsd changes for 3.5
Message-ID: <20120531200138.GD25955@fieldses.org>
References: <20120531182457.GB25955@fieldses.org>
 <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 11:58:34AM -0700, Linus Torvalds wrote:
> On Thu, May 31, 2012 at 11:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Sorry this is a bit late.  In fact I still have a review backlog (at a
> > minimum some bugfixes), so will send a second pull later.
> 
> Quite frankly, I'm not going to pull this without lots of explanations.
> 
> The VFS-level changes have no acks or sign-offs from anybody else,

Sorry, yes, at best I had a verbal OK from Al (and maybe I'm wrong about
that).  I got impatient.

> and quite frankly, if I understand them correctly they look f*cking
> disgusting. If I read them right, they break delegations of a file
> (which can involve long waits for clients - no?)

Right.  By default it's 90 seconds before we'll give up on the client.

> while holding on to
> the directory inode lock (both directories for cross-inode renames).
> Which seems to be a singularly idiotic thing to do and sounds to me
> like a fundamental design mistake.

I hate that too, and originally tried to avoid it with something like:

	retry:
		acquire locks
		lookup inode
		ret = try_to_break_deleg(inode);
		if (ret)
			drop locks
			really_break_deleg(inode);
			goto retry;
		... do the real work ...
		drop locks

I felt like I was making already complicated code logic like rename's
even harder to follow.

And those operations don't really know the inode till they acquire the
locks, so in pathological cases that could continue forever.

...
> So quite frankly, this *all* looks like 3.6 material to me, and that's
> assuming you can convince people that file-delegation breaking really
> should happen with all lookups on the directory the file is in blocked
> by the directory inode mutex in the first place. Or tell me I'm a
> moron and I misread the patches and don't know what I'm talking about.

No, I think you understand correctly.

The presence of a delegation requires blocking certain operations until
a client somewhere responds (or we time out).

So the question as I understand it is whether there's a way to lessen
the impact by blocking only what we really need to.

I don't know if there's a way to do that without reworking the vfs
directory locking to be much more fine-grained.

--b.
