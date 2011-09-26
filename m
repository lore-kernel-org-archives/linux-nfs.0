Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884Ab1IZXJk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 19:09:40 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Mon, 26 Sep 2011 19:09:23 -0400
In-Reply-To: <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
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
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317078563.21770.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-26 at 15:56 -0700, Linus Torvalds wrote: 
> On Mon, Sep 26, 2011 at 3:33 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > Lookup permission checks would be replaced with open permission checks
> > on the server.
> >
> > IOW: the operation could potentially fail due to a completely unrelated
> > issue.
> 
> Quite frankly, that still sounds like a "I'm trying to make a problem
> out of something that isn't actually a problem". And you still seem to
> be unwilling to admit that LOOKUP_FOLLOW is a problem that has
> actually been reported in real life, so you just cut out that part of
> my question about how this would be a bigger issue.

I never questioned your argument that we need to address the problem of
regressions. That's why I cut out the LOOKUP_FOLLOW part.

I just questioned your proposed solution because it seemed to introduce
new problems. We're in the 3rd iteration of a bugfix (the first being
the introduction of ->d_automount() and the second being Miklos's
patch), and I'm assuming nobody is interested in seeing a 4th iteration.

> But whatever. I can't really care, since it's a two-liner to add a new
> flag, and then it falls down to "if you want to follow automounts, you
> can set that flag instead".
> 
> Almost nobody is ever going to bother setting the flag anyway, since
> LOOKUP_OPEN and LOOKUP_DIRECTORY are going to take care of all the
> common cases.
> 
> So here. You can set LOOKUP_AUTOMOUNT to force an automount traversal. Ok?

I assume that means that we can get rid of LOOKUP_NO_AUTOMOUNT, and just
replace the convoluted logic in follow_automount() with a test for
LOOKUP_AUTOMOUNT? If we have agreed on a default behaviour, then that
would seem cleaner than enumerating all these exceptions.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

