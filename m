Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:50652 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751257Ab1IXBbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 21:31:02 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: David Howells <dhowells@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
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
	 <29743.1316791138@redhat.com>  <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 24 Sep 2011 09:30:54 +0800
Message-ID: <1316827854.3346.154.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-23 at 18:10 +0200, Miklos Szeredi wrote:
> David Howells <dhowells@redhat.com> writes:
> 
> >> Get a grip, people. Stop over-analyzing things. Stop bothering to
> >> mention what Solaris does, when the *MUCH* bigger issue is what
> >> *Linux* has done for years and years.
> >
> > So the word is Linux may not change it's behaviour in this regard from what
> > existed prior to the d_automount patch, period?
> 
> You can change behavior if it won't cause regressions.  So fix userspace
> first, introduce change afterwards.

Easy to say, not so easy to do.

> 
> >> Stop saying "we'll revert Miklos patch" in the same sentence where you
> >> then seem to not even understand that the *original* behavior was the
> >> one that Miklos patch re-introduced.
> >
> > Miklos's patch did *NOT* re-introduce the original behaviour.  It introduced a
> > third state.  It merely moved the regression and brought about a more serious
> > one.
> 
> Yes, and there have been lots of proposals on how to fix it.  There just
> doesn't seem to be a consensus.

Indeed, that's probably because of (as Linus says) the empirically
derived division of system calls that do and do not trigger an
automount, for cases where there is a question of whether to automount
or not. The old ill defined moving target.

> 
> I suggest that we first restore the original behavior for all
> filesystems.  And it doesn't mean all the d_automount infrastructure has
> to be thrown out.  A really simple fix is to pass the lookup flags (or
> some derived automount flags) to d_automount and fix up the very few
> instances to reflect the old semantics.  Untested patch attached.

Perhaps, but that allows modules to circumvent VFS policy which is what
allowed this situation to come up in the first place.

Ian


