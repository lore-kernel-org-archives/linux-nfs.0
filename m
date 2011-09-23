Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:45578 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709Ab1IWPlQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 11:41:16 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
References: <1316747758.3346.89.camel@perseus.themaw.net>
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
	 <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Sep 2011 23:41:08 +0800
Message-ID: <1316792468.3346.144.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-23 at 07:46 -0700, Linus Torvalds wrote:
> On Fri, Sep 23, 2011 at 7:34 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > My objections are due to the other cases that I pointed out, where
> > Miklos's patch introduced changes in behaviour that IMO are unnecessary
> > and incorrect.
> 
> Guys, it wasn't Mikos' patch that introduced the changes!
> 
> What's so hard to understand here?
> 
> That's why I'm so upset. People talk stupid sh*t about "correct
> behavior" when clearly no such thing *exists*. And people talk about
> Miklos changes as if they were some radical change that changed
> behavior, when they were only a revert to old behavior to begin with
> (at least as far as autofs is concerned)!

Sorry to hear you are upset about all this.

And, yes, it is me that is to blame, since I pushed David to do it. I
did so because I feel strongly that the semantic change to autofs is
needed based on several years of experience with reports of undesirable
behavior of autofs.

I thought I had put forward quite a bit of the reasoning for that, and
on topic with what you've asked for in this post, at least most of the
time. In its simplest form I claim, for autofs it is appropriate to
automount in almost all cases where the LOOKUP_FOLLOW flag is used
(these should be considered as not regression with the semantic change).
For the cases where it is preferred not to automount user space should
(and nowadays almost always does) use ~LOOKUP_FOLLOW type syscalls.

I expected some problems from the semantic change, sure, but I expected
they would come from user space. Those problems just haven't
materialized so far and I'm glad of that.

We haven't had any non-trivial problems reported that I know about. As
I've said before the problem Miklos referred to was an inconsistency in
user space which the new automount code exposed, and a change has been
accepted to fix it and this was done prior to Miklos posting his patch. 

My point is that, since we haven't had any non-trivial problems reported
due to the semantic change, in what six months or more, why change it
now?

Ian


