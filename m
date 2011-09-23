Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab1IWQlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:41:20 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com>
References: <CA+55aFx03u51bbAPe_o=4PeyE0dFnuL1KyqRdTJCFUD-vM6V-w@mail.gmail.com> <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org> <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316792468.3346.144.camel@perseus.themaw.net> 
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, Ian Kent <raven@themaw.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Fri, 23 Sep 2011 17:40:07 +0100
Message-ID: <13920.1316796007@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> We may indeed have to revert for sanity at this point, but I have to
> say that I think the arguments have been very weak, and the logic for
> when to auto-mount and when not to seems to not really be based on any
> real logic.

Can you look over the patchset I've just posted.

It moves the policy on whether or not to suppress automount out of
follow_automount() - which is probably the wrong place for it anyway.

Depending on which patch you want to stop at it can reinstate the pre-Miklos
behaviour; reinstate the Miklos behaviour, but without the regression; or
reinstate the pre-d_automount behaviour.

> For example, I think the whole "let's consider lstat different from
> stat" model is broken. It works for symlinks, but that's because

That's a reasonable way to look at it; the difference between stat and lstat
is about handling symlinks only.  Furthermore, we have fstatat, so this isn't
really an issue - that can be given flags to let userspace decide what it
should do.

getxattr and co. are trickier because they don't have an AT_ flags form, and
it can be argued that these, lgetxattr and co. included should automount.
However, that would seriously upset ls, so I think we have to leave lgetxattr
not automounting, and so getxattr should follow.

We should consider adding an AT_ flags form of the xattr calls, but that's
another matter we can argue over later.

> So *that* is why I thought the LOOKUP_DIRECTORY flag was so nice. And
> I still suspect that if paired with LOOKUP_OPEN, it would actually be
> a complete solution that avoids the crazy issues with "random
> implementation detail" and could give us something that is both
> accessible from user space *and* something we can explain to a user
> from a logical basis.

I don't like this because it's fragile.  We're giving an implied second
meaning to LOOKUP_DIRECTORY/LOOKUP_OPEN, albeit a reasonable one.

Can we please move the policy to the pathwalk callers instead?

David
