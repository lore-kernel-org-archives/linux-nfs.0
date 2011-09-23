Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:49170 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980Ab1IWDQG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 23:16:06 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, David Howells <dhowells@redhat.com>,
        miklos@szeredi.hu, viro@zeniv.linux.org.uk, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	 <1316707443.3346.44.camel@perseus.themaw.net>
	 <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	 <1316709935.3346.48.camel@perseus.themaw.net>
	 <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
	 <20110922144453.6cf53a25@barsoom.rdu.redhat.com>
	 <1316719228.3968.14.camel@lade.trondhjem.org>
	 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Sep 2011 11:15:58 +0800
Message-ID: <1316747758.3346.89.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-22 at 18:04 -0700, Linus Torvalds wrote:
> On Thu, Sep 22, 2011 at 5:56 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> >
> > Your assumption is that in the majority of cases, we do _not_ want to
> > automount the final directory unless we know that we are expecting a
> > directory.
> 
> Umm. That is the assumption yes, BUT THAT IS ALSO THE CURRENT STATE.

With the patch that Miklos posted, yes.

But the other users of the vfs-automount didn't behave this way before
the vfs-automount changes.

> 
> So it's more than an assumption. It's a fact.

For autofs itself, yes.

> 
> So when you call it "assumption", you are basically ignoring and
> trying to belittle current reality. Why?

Lets take a step back and re-examine what started this.

That is the semantic change automounting LOOKUP_FOLLOW path walks, aka.
stat and related system calls which Miklos wanted to change back.

Unfortunately, the reality is that most of the time (almost always
anyway) that is what should be done. The exceptions are such things as
long listing directory contents where we would also like stat to cause
automounting but cannot because it causes users to complain about lots
of mounts being triggered. Contrast that with the behavior of find(1)
where users sometimes don't want a bunch of mounts done but, in this
case, they must be done for it to function.

So the previous autofs behavior was problematic for find and couldn't be
fixed, but was OK for long directory listings. Pretty much a crap
situation.

There is also the common case where applications perform a stat(2) (or
any LOOKUP_FOLLOW type) call (other than when used in listing a
directory) where the automount should also be done and complains about
that behavior were met with an explanation of why it was so and a
wontfix response. So for the bulk of cases automounting should be done
for LOOKUP_FOLLOW type system calls and not for the ~LOOKUP_FOLLOW.
Which is also a "natural" usage because user space largely does this the
way automounting needs already.

Coming back to the bug that Miklos referred to.

This was a case where long listing a directory caused automount child
directories to be mounted. But for directory listings we want don't want
to automount it's child directories. We also want the details on
symlinks, and don't want to follow them. In the reported bug there were
a couple of lgetxattr(2) calls and suddenly a getxattr(2) call which was
inconsistent usage and was causing the unwanted mounts. Even upstream
conceded that this was inconsistent and accepted a path (well actually
two patches, one for the acl package and one for coreutils), and the
problem was gone.

In the time we have had this changed behavior we haven't had any further
reports of problems that I'm aware of. But there may be more to come, I
expect we will see some complains from GUI uses at some point too but
they will be a problem whether we mount on stat on not, since not
mounting the things they want to see is no good for them and mounting to
many things for them annoys them as well.

Now Trond has identified a number of examples that demonstrates why we
should not merge (or should revert) Miklos's patch, examples I couldn't
provide when he asked for them.

Again, I believe we got it right the first time, and we should work with
user space to provide any information and assistance needed for them to
change to accommodate the semantic difference which has been needed for
many years, and has (had) now been done.

So, sorry Miklos, but I now think your patch should be reverted.

Ian


