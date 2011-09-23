Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34420 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372Ab1IWPPs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 11:15:48 -0400
Received: by eya28 with SMTP id 28so2291610eya.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 08:15:47 -0700 (PDT)
In-Reply-To: <1316790109.14812.14.camel@lade.trondhjem.org>
References: <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316790109.14812.14.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 08:15:27 -0700
Message-ID: <CA+55aFxDPd+O9tVDC7d47msFKv7jE0r6+Ui-Yvs1jYFw44ynZw@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 8:01 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Wrong. Miklos's patch introduces new behaviour that was never present
> previously:

Look at the big picture. The real damage wasn't done my Miklos, and
that's something you don't seem to understand.

So stop with the crazy "just revert" crap. That's not how it works. If
you want to talk about reverts, then you need to go all the way back
to the follow_link behavior.

Afaik, the closest we can get to old behavior is just checking
LOOKUP_DIRECTORY. We might want to check LOOKUP_OPEN too and that
solves your "whaa, whaah, it might be a file" thing. But neither stat
nor lstat used to auto-mount with autofs (and quite frankly, some
NFS-side automounting should strive to look the same, imgo).

So please *understand* the problem I have already. My problem is that
you seem to think "revert miklos" just fixes all the issues and is
some "safe" approach. It just re-introduces the *original* regression.

                              Linus
