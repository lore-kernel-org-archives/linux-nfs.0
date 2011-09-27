Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29655 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab1I0PLT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 11:11:19 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Tue, 27 Sep 2011 08:11:14 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B54E566@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <CA+55aFw408L6kHwx6tFGCbvmfqfL6r0zkqtUqSe0ngCjammUhA@mail.gmail.com>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org> <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu> <1316827854.3346.154.camel@perseus.themaw.net> <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com> <20110924073610.4b045189@tl!
 ielax.poo
	chiereds.net
	> <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com> <1317013864.3187.81.camel@perseus.themaw.net> <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com> <1317071626.19951.8.camel@lade.trondhjem.org> <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com> <1317072718.19951.13.camel@lade.trondhjem.org> <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com> <1317076424.19951.32.camel@lade.trondhjem.org> <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com> <1317078563.21770.8.camel@lade.trondhjem.org> <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com> <1317085155.21770.17.camel@lade.trondhjem.org> <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com> <1317097001.3176.20.camel@perseus.themaw.net> <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com> <1317099091.3176.31.camel@perseus.themaw.net> <CA+55aFw408L6kHwx6tFGCbvmfqfL6r0zkqtUqSe0ngCjammUhA@mail.
	gmail.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>,
        "Ian Kent" <raven@themaw.net>
Cc: "Jeff Layton" <jlayton@redhat.com>, "Miklos Szeredi" <miklos@szeredi.hu>,
        "David Howells" <dhowells@redhat.com>, <viro@zeniv.linux.org.uk>,
        <gregkh@suse.de>, <linux-nfs@vger.kernel.org>,
        <leonardo.lists@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Linus Torvalds [mailto:torvalds@linux-foundation.org]
> Sent: Tuesday, September 27, 2011 10:32 AM
> To: Ian Kent
> Cc: Myklebust, Trond; Jeff Layton; Miklos Szeredi; David Howells;
> viro@zeniv.linux.org.uk; gregkh@suse.de; linux-nfs@vger.kernel.org;
> leonardo.lists@gmail.com
> Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr,
etc.
> 
> On Mon, Sep 26, 2011 at 9:51 PM, Ian Kent <raven@themaw.net> wrote:
> >
> > Is there a source tree somewhere, I'm not sure now exactly what has
> > been changed. I can run tests if I can get accurate source.
> 
> It's all at git://github.com/torvalds/linux.
> 
> I've only applied two patches so far, though: the "Add
> LOOKUP_AUTOMOUNT flag" (that didn't actually set it anywhere), and
then
> the minimal version of Trond's patch.
> 
> And I see that I have a few patches from Trond in my mailbox, but I
haven't
> looked at them yet.

I should have checked the github repository before posting.
The stuff you've already committed appears to obsolete the 1/2 patch,
but it might still be worth your while looking at 2/2: that documents
which lookups we expect might result in an automount of the last
component (but contains no actual functional changes).

Cheers
  Trond
