Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52308 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab1IZWZV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 18:25:21 -0400
Received: by wyg34 with SMTP id 34so6398933wyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 15:25:20 -0700 (PDT)
In-Reply-To: <1317072718.19951.13.camel@lade.trondhjem.org>
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
 <20110924073610.4b045189@tlielax.poochiereds.net> <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
 <1317013864.3187.81.camel@perseus.themaw.net> <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
 <1317071626.19951.8.camel@lade.trondhjem.org> <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com>
 <1317072718.19951.13.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2011 15:24:59 -0700
Message-ID: <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 26, 2011 at 2:31 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> A bind mount doesn't actually want us to set up OPEN state on the NFSv4
> server and return a fully initialised 'struct file' in the struct
> nameidata. If it did, we would already have set the LOOKUP_OPEN flag
> together with the accompanying open intent structure in the struct
> nameidata.
>
> Ditto for the quotactl().

Umm. As far as I can see, adding LOOKUP_OPEN doesn't actually even
*do* what you claim.

The whole "allocate struct file in struct nameidata" happens in
path_openat(), it doesn't happen in the normal path creation
(do_path_lookup() and friends). The only thing NFS does with
LOOKUP_OPEN is to check whether it needs to do a revalidate
regardless.

But even more importantly than your apparent confusion about filling
in the 'nameidata.intent' fields, even *if* we were to do unnecessary
filp allocations etc (which we don't do, as mentioned), from a user
standpoint, what would be the actual downside?

It would be extra work for a (very rare) operation, but compared to
the known downside that is LOOKUP_FOLLOW and auto-mounting when we
shouldn't, even that hypothetical downside seems pretty benign,
doesn't it?

In other words, what I don't understand is how you seem to be totally
happy ignoring the known problems with LOOKUP_FOLLOW, but LOOKUP_OPEN
is some monster thing that you don't want to deal with.

WHY?

                        Linus

PS. That said, looking at the *cifs* code, it seems to do some nasty
things on LOOKUP_OPEN, and assumes that it always has a 'file'
pointer. Sad. That might actually argue for another flag, or
alternatively for just fixing CIFS.
