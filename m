Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:58683 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726Ab1IWK5Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 06:57:16 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jeff Layton <jlayton@redhat.com>, David Howells <dhowells@redhat.com>,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
In-Reply-To: <878vpfvhxt.fsf@tucsk.pomaz.szeredi.hu>
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
	 <1316740873.9186.19.camel@lade.trondhjem.org>
	 <878vpfvhxt.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Sep 2011 18:57:09 +0800
Message-ID: <1316775429.3346.118.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-23 at 09:25 +0200, Miklos Szeredi wrote:
> Trond Myklebust <Trond.Myklebust@netapp.com> writes:
> 
> > On Thu, 2011-09-22 at 18:04 -0700, Linus Torvalds wrote: 
> >> On Thu, Sep 22, 2011 at 5:56 PM, Myklebust, Trond
> >> <Trond.Myklebust@netapp.com> wrote:
> >> >
> >> > Your assumption is that in the majority of cases, we do _not_ want to
> >> > automount the final directory unless we know that we are expecting a
> >> > directory.
> >> 
> >> Umm. That is the assumption yes, BUT THAT IS ALSO THE CURRENT STATE.
> >> 
> >> So it's more than an assumption. It's a fact.
> >> 
> >> So when you call it "assumption", you are basically ignoring and
> >> trying to belittle current reality. Why?
> >
> > AFAICR, the whole point of doing the ->automount() stuff was to fix what
> > was perceived to be a broken situation in which the application was more
> > often than not seeing the properties of a directory which it would
> > _never_ directly access.
> 
> We are pitting one set of applications against another.  There's no
> Right(TM) behavior here.  In any case there will be applications which
> will behave strangely, be extremely slow, etc...
> 
> Changing the behavior of stat will cause regressions.  Period.  If we
> just fixed up those apps which behave badly with the old kernels, there
> wouldn't be any regressions.

That's the point isn't it.

Your patch changes the pre-exiting behavior of NFS and probably CIFS and
AFS, but restores the pre-existing behavior of autofs, which is
something I've wanted to change for years.

My suggestion of using LOOKUP_DIRECTORY at path walk sites that need it
is still a possibility. I'm still looking through path walk call sites.
But that resolution will still leave NFS et.al. with LOOKUP_FOLLOW only
calls having changed semantic behavior.

There is no resolution to this that will satisfy everyone. Passing on
the lookup flags is, I think, the only way to segregate the sub system
behaviors and I'm not in favor of that either.

Ian


