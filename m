Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56422 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1IWQVg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:21:36 -0400
Received: by wyg34 with SMTP id 34so4122111wyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:21:35 -0700 (PDT)
In-Reply-To: <1316792468.3346.144.camel@perseus.themaw.net>
References: <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316792468.3346.144.camel@perseus.themaw.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 09:21:15 -0700
Message-ID: <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 8:41 AM, Ian Kent <raven@themaw.net> wrote:
>
> My point is that, since we haven't had any non-trivial problems reported
> due to the semantic change, in what six months or more, why change it
> now?

We may indeed have to revert for sanity at this point, but I have to
say that I think the arguments have been very weak, and the logic for
when to auto-mount and when not to seems to not really be based on any
real logic.

For example, I think the whole "let's consider lstat different from
stat" model is broken. It works for symlinks, but that's because

 - applications *know* about the symlink difference

 - lstat actually *informs* about the symlink

neither of which is true for automounts. So quite frankly, I think
trying to conflate automount behavior with symlink behavior is a
completely bogus model to begin with, and has no actual redeeming
values except for an implementation issue (->follow_link) that no
longer even exists!

So I seriously think that the old autofs model is technically
superior. Which doesn't make it the only right one, of course. But I
really do think it's totally broken to think that lstat works
differently from stat.

So I would argue that using lstat as a differentiator for this is bad, because

 - it's not what we've done historically
 - it's a crazy hack introduced by implementation reasons, not logic
 - it's against all lstat documentation
 - it's inflexible and makes it hard to script

Now, introducing a new internal kernel flag is in many ways even
*worse*, because it's going to make it even more ad-hoc and
implementation issue, and even less visible and logical to actual
users who don't care.

So *that* is why I thought the LOOKUP_DIRECTORY flag was so nice. And
I still suspect that if paired with LOOKUP_OPEN, it would actually be
a complete solution that avoids the crazy issues with "random
implementation detail" and could give us something that is both
accessible from user space *and* something we can explain to a user
from a logical basis.

In other words, if we are going to accept changing semantics (and
apparently we have to), let's just make sure the ones we pick are the
*sensible* ones.

                Linus
