Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:50473 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab1I0EYK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 00:24:10 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <CA+55aFyGxUu8-kzSrY5SZrF3VpqtemLDK4ES6q+kTcEzFVYd5A@mail.gmail.com>
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
	 <1317085155.21770.17.camel@lade.trondhjem.org>
	 <CA+55aFyGxUu8-kzSrY5SZrF3VpqtemLDK4ES6q+kTcEzFVYd5A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Sep 2011 12:24:03 +0800
Message-ID: <1317097443.3176.23.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-26 at 18:18 -0700, Linus Torvalds wrote:
> On Mon, Sep 26, 2011 at 5:59 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > OK. Then how about something along the lines of the following patch
> > (compile tested only)?
> 
> I would seriously suggest aiming for *minimal*.
> 
> So if it already has any of LOOKUP_DIRECTORY, LOOKUP_OPEN,
> LOOKUP_CREATE or LOOKUP_PARENT, don't add LOOKUP_AUTOMOUNT - because
> it's not adding anything.
> 
> We *have* to automount on those flags anyway. They are not like
> LOOKUP_FOLLOW was, where the automount decision was just a random
> (bad) choice.
> 
> From a quick look, pretty much all of the cases you added
> LOOKUP_AUTOMOUNT to were already implicit automount events. So I think
> the two remaining ones are quotactl Q_QUOTAON case, bind mount in
> do_looopback(), and the nfs_follow_remote_path() case.
> 
> Sure, we could add it to the others as some kind of "documentation"
> thing, but I think that should be separate and is debatable to begin
> with.

That was the only question I had when I suggested using LOOKUP_AUTOMOUNT
to restore the previous automounting behavior. The trade off being to
add the flag and simplify the check in follow_automount() or to not add
it to implicit automount cases and retain the check but minimize the
changes to path walk call sites.

Talk about an automount file type was purely a suggestion of something
that would be good to do later along with what would be a lengthy user
space co-ordination and education process, not something I thought was
good to do now.

Making allowances for the change back to the old behavior for those
kernel users that had different semantics at the outset was a second and
separate question and still is.

Ian


