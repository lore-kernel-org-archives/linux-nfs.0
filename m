Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab1IWPTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 11:19:44 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com> <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com> <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com> <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org> <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com> <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com> <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org> 
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        miklos@szeredi.hu, Jeff Layton <jlayton@redhat.com>,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
Date: Fri, 23 Sep 2011 16:18:58 +0100
Message-ID: <29743.1316791138@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Guys, it wasn't Mikos' patch that introduced the changes!

Yes, thank you, we know.  It was my d_automount patch that did it.  I've
admitted this.  It made the behaviour of all internal automounts consistent,
which as it turns out, altered the behaviour of autofs.  We started fixing
this up in userspace (libacl and coreutils have been fixed).

> That's why I'm so upset. People talk stupid sh*t about "correct
> behavior" when clearly no such thing *exists*.

The discussion really revolves around two things:

 (1) We have a potential opportunity to define the correct behaviour and to
     make all the filesystems consistent with that, but what is the correct
     behaviour?

 (2) Whether we should vary the behaviour based on filesystem.

> And people talk about Miklos changes as if they were some radical change
> that changed behavior, when they were only a revert to old behavior to begin
> with (at least as far as autofs is concerned)!

Exactly.  You've made my point precisely with that last parenthesis: _only_ as
far as autofs is concerned.

Miklos's patch instead creates a regression in the behaviour in NFS, AFS and
CIFS hence why NFS4 mount root pathwalk is now acting weird.  That's not
really Miklos's fault, it only occurs in certain cases, and it's not very
obvious that it did happen or that it would happen.

> Get a grip, people. Stop over-analyzing things. Stop bothering to
> mention what Solaris does, when the *MUCH* bigger issue is what
> *Linux* has done for years and years.

So the word is Linux may not change it's behaviour in this regard from what
existed prior to the d_automount patch, period?

If so, we need to vary the behaviour based on the filesystem being
automounted.

> Stop saying "we'll revert Miklos patch" in the same sentence where you
> then seem to not even understand that the *original* behavior was the
> one that Miklos patch re-introduced.

Miklos's patch did *NOT* re-introduce the original behaviour.  It introduced a
third state.  It merely moved the regression and brought about a more serious
one.

> Reverting Miklos patch isn't a revert. THAT is the "semantic change".
> That's the one you need to explain why the heck it would be the right
> thing to do, rather than imply that we'd be going back to some known
> state.

Miklos's patch is also a semantic change.


I'm not keen on the LOOKUP_DIRECTORY fix as it may prove fragile in future.

Can we at least move the automount/no automount logic out of
follow_automount() and into the path walk callers?  That way
follow_automount() becomes more robust and we're less likely to get bitten in
future as we can define the behaviour more precisely.

David
