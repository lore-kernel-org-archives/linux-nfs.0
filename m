Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab1I0A7n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 20:59:43 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Mon, 26 Sep 2011 20:59:15 -0400
In-Reply-To: <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
	 <1316747758.3346.89.camel@perseus.themaw.net>
	 <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	 <1316707443.3346.44.camel@perseus.themaw.net>
	 <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	 <1316709935.3346.48.camel@perseus.themaw.net>
	 <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
	 <20110922144453.6cf53a25@barsoom.rdu.redhat.com>
	 <1316719228.3968.14.camel@lade.trondhjem.org>
	 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
	 <21772.1316774025@redhat.com>
	 <1316788444.14812.10.camel@lade.trondhjem.org>
	 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
	 <1316827854.3346.154.camel@perseus.themaw.net>
	 <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
	 <20110924073610.4b045189@tlielax.poochiereds.net>
	 <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
	 <1317013864.3187.81.camel@perseus.themaw.net>
	 <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
	 <1317071626.19951.8.camel@lade.trondhjem.org>
	 <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com>
	 <1317072718.19951.13.camel@lade.trondhjem.org>
	 <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com>
	 <1317076424.19951.32.camel@lade.trondhjem.org>
	 <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
	 <1317078563.21770.8.camel@lade.trondhjem.org>
	 <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317085155.21770.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-26 at 16:26 -0700, Linus Torvalds wrote: 
> On Mon, Sep 26, 2011 at 4:09 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > I assume that means that we can get rid of LOOKUP_NO_AUTOMOUNT, and just
> > replace the convoluted logic in follow_automount() with a test for
> > LOOKUP_AUTOMOUNT? If we have agreed on a default behaviour, then that
> > would seem cleaner than enumerating all these exceptions.
> 
> I do think that LOOKUP_NO_AUTOMOUNT is bogus.  It's not a
> kernel-internal flag, it's for that silly "vfs_fstatat()" interface,
> that was designed when LOOKUP_FOLLOW would cause an automount.
> 
> Now that LOOKUP_FOLLOW doesn't do that, the whole reason for
> LOOKUP_NO_AUTOMOUNT really goes away, but then we have that crazy user
> interface that was encoded for it (only for the very special vfs
> 
> The question then becomes: should we just ignore (and deprecate) that
> crazy AT_NO_AUTOMOUNT flag? I say "yup".
> 
> Or should we do something *really* crazy, and say "if you *don't* have
> AT_SYMLINK_NOFOLLOW *and* you don't have AT_NO_AUTOMOUNT, then we make
> fstatat64() follow automounts, even though no sane version of *stat()
> does so any more"?
> 
> Quite frankly, that just sounds insane. But we could do it, and it
> would approximate the old semantics for that system call. Even if
> those old semantics were clearly not very good, and the whole point of
> AT_NO_AUTOMOUNT was to work around problems people must have had..
> 
> So my gut feel is that we should just ignore it for now.
> AT_NO_AUTOMOUNT becomes a no-op, and the LOOKUP_NO_AUTOMOUNT flag is
> already effectively one (since nothing but vfs_fstatat sets it, and
> vfs_fstatat now doesn't follow automounts *anyway*)
> 
> The "let's just see if anybody complains when we clean stuff up"
> approach, in other words.  Because I bet any user who doesn't have
> AT_NO_AUTOMOUNT isn't because they didn't really want an automount,
> it's because they weren't even aware of the issue.

OK. Then how about something along the lines of the following patch
(compile tested only)?

Cheers
  Trond

8<----------------------------------------------------------------------------------
