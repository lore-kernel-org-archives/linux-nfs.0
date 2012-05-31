Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58743 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932487Ab2EaUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 16:53:00 -0400
Date: Thu, 31 May 2012 16:53:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: nfsd changes for 3.5
Message-ID: <20120531205300.GG25955@fieldses.org>
References: <20120531182457.GB25955@fieldses.org>
 <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
 <20120531200138.GD25955@fieldses.org>
 <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+55aFyuHz5Vn8G_kpKgnSStX0s125gwwQij2KXmnhfwaajhkg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 01:17:26PM -0700, Linus Torvalds wrote:
> On Thu, May 31, 2012 at 1:01 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Right.  By default it's 90 seconds before we'll give up on the client.
> 
> So a slightly buggy client can basically DoS the server by getting a
> delegation and then crashing or something. Everybody else that tries
> to read that directory (not that file) will be dead in the water.
> Definitely not good.
> 
> > I hate that too, and originally tried to avoid it with something like:
> >
> >        retry:
> >                acquire locks
> >                lookup inode
> >                ret = try_to_break_deleg(inode);
> >                if (ret)
> >                        drop locks
> >                        really_break_deleg(inode);
> >                        goto retry;
> >                ... do the real work ...
> >                drop locks
> >
> > I felt like I was making already complicated code logic like rename's
> > even harder to follow.
> 
> I do think it's the only thing we can reasonably do.

OK, I can give that another try.  Al, does that sound like the more
sensible choice to you?


Uh, that means ditching some work in my public git tree.  Which I
haven't rebased in years.  So, a stupid process question; would you
rather I:

	- continue to be strict about rebasing and apply a bunch of
	  reverts?
	- ditch it and start over?

#1 looks like a mess to me, so I guess #2's my default.  Probably nobody
will notice but me.

> I'd love to have
> some kind of per-dentry lock for unlink/rename, but we don't.
> Long-term, we really do need to do something about the directory
> locking, though, because it's also a huge problem for readdir()
> concurrency. Or at least it used to be (samba in particular). Making
> it an rwsem might help readdir a tiny amount, but I suspect people
> actually depend on the mutex in readdir right now.

Al called this all "highly non-trivial":

	http://marc.info/?l=linux-fsdevel&m=132726495726326&w=2

I don't know who'd have the cycles.

--b.

> 
> > And those operations don't really know the inode till they acquire the
> > locks, so in pathological cases that could continue forever.
> 
> I suspect at some point you just have to say "screw it".
