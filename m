Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40757 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab1IXP4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Sep 2011 11:56:46 -0400
Received: by wyg34 with SMTP id 34so4777461wyg.19
        for <linux-nfs@vger.kernel.org>; Sat, 24 Sep 2011 08:56:45 -0700 (PDT)
In-Reply-To: <20110924073610.4b045189@tlielax.poochiereds.net>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
 <1316827854.3346.154.camel@perseus.themaw.net> <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
 <20110924073610.4b045189@tlielax.poochiereds.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 24 Sep 2011 08:56:25 -0700
Message-ID: <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Jeff Layton <jlayton@redhat.com>
Cc: Ian Kent <raven@themaw.net>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Sep 24, 2011 at 4:36 AM, Jeff Layton <jlayton@redhat.com> wrote:
>
> The problem really boils down to this:
>
> The d_automount patches changed autofs' automount trigger behavior to
> be like that of NFS and CIFS. Miklos' patch reverts the behavior of
> autofs to pre-2.6.38 behavior, but it also changes NFS and CIFS in the
> same way, which is also a regression.

Sure.

> If you want to go back to pre-2.6.38 behavior, then you really have no
> choice but to do re-introduce filesystem-specific behavior for
> automounting. The behavior of autofs was different from that of
> NFS and CIFS in earlier kernels.

I have absolutely no problem with changing semantics in sane ways that
don't cause actual real users to complain.

We tried it the NFS way, and users complained. Let's now try it the autofs way.

And quite frankly, I think the autofs semantics are the clearly
superior semantics, so I have at least some hope that maybe they would
work.

The old NFS semantics were bad. And they existed not for a good
reason, but for a silly technical implementation reason. And that
technical reason has gone away, since now they don't use that "fake
symlink" approach any more.

So the reason I think the autofs semantics are clearly superior are:

 - they don't make the insane distinction between 'lstat' and 'stat'.

   Seriously, no sane program should expect lstat to give different
behavior from stat, unless the lstat information actually *tells* you
that there's something special about the file.

   Now, if the auto-mounting actually have a whole different kind of
file type for an unmounted entry (not necessarily S_IFLNK - I could
well imagine a new implementation just saying "we'll return the new
S_IFAUTO marker"), then using lstat/stat the same way as for symlinks
would make sense. And maybe that would have been a good thing: then
"ls" could show those things nicely as "unmounted automount points".

   But that's not how things work today, and while I think it would be
a valid approach, I suspect everybody here agrees that that would
probably be a lot of work, for very little gain, and quite a lot of
pain.

   Anyway, as long as lstat() returns a S_IFDIR, then there is
absolutely no way for an application to say "oh, but maybe I need to
do 'stat()' or something else like readlink() to actually get some
further information".

   So I seriously claim that the lstat/stat difference is just crazy.
It made sense as a "hey, we hook into this other thing we had, it's a
hack, don't look too closely - it works well enough in practice", but
it doesn't really make sense at any other level in my opinion.

 - They *do* get a difference between "[l]stat()" and "fd = open() ; fstat(fd)".

   Why do I then claim that open+fstat inconsistency is "less bad"
than lstat inconsistency? Am I not being intellectually dishonest?

   And yes, I agree, either approach is inconsistent *somewhere*. You
have to be, since the alternative is to automount every time somebody
does a "ls -l", and we know that doesn't work. But why is "[l]stat ->
open+fstat" inconsistency better than "lstat => stat" inconsistency?

   My argument is that there are two reasons open+fstat is the better
place to be inconsistent:

   1) It's later in the game. Delaying the automount as far as
possible is good. We know it's bad to automount too early: it's
expensive, and we don't want oblivious programs to automount something
unless they really have to. Doing a "stat" on things is pretty common,
and it's why people complained about making autofs match NFS. And we
*can* try to avoid automounting at stat. But if you actually do an
"open", we *have* to automount.

   So there's a very fundamental reason why open+fstat is different
from plain stat: the open really has forced our hand.

   2) People are actually somewhat *used* to [l]stat giving different
information from open+fstat. For *any* file type, not just for
symlinks. It's quite common to do a first "careless" check (using
[l]stat or even just the directory entry type), and then doing a
"careful" check with "open+fstat". Why? Because of all the races with
rename.

   So I actually think people are more likely to react reasonably to
open+fstat inconsistency than to lstat/stat inconsistency. Now, the
proof is in the pudding, but I think there are two independent
conceptual reasons to prefer automounting to happen at that stage.

 - finally: the autofs semantics have been around for a long long time
in Linux. So the autofs semantic choice is the really traditional one.

   I don't think that's a very strong argument, but it's at least an
argument for trying.

Anyway, what this all boils down to is that I'd *really* like to avoid
having semantic differences for different filesystems that really do
the same thing. So I think the autofs semantics are the better
semantics, and we do know that people started complaining when those
semantics were changed to the NFS/cifs semantics.

So my argument (by now much too long and verbose) is that we should
*try* to change the semantics the other way.

Yes, maybe that hits somebody else who has a big nfs automount site,
and really depended on the old semantics. And maybe we do need to then
add a mount option (because quite frankly, I don't think it should
depend on filesystem type: if somebody really prefers one over the
other, it should be possible to do it either way on *either*
filesystem type, no?). But before that, I'd really like to see if we
can get the "consistent semantics at least between filesystems" model
to work.

So that's me trying to outline what my standpoint is. This got much
longer than maybe necessary, but I wanted to avoid ambiguity.

Short summary: yes, maybe we need to do per-mount-point options. But
let's try to avoid them unless we have hard data that says that we
really do need it.

                          Linus
