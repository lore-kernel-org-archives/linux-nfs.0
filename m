Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:60308 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753225Ab1IXCb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 22:31:27 -0400
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 24 Sep 2011 10:31:20 +0800
Message-ID: <1316831480.3346.178.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-23 at 18:44 -0700, Linus Torvalds wrote:
> On Fri, Sep 23, 2011 at 6:30 PM, Ian Kent <raven@themaw.net> wrote:
> >
> > Perhaps, but that allows modules to circumvent VFS policy which is what
> > allowed this situation to come up in the first place.
> 
> So, realistically, what's the downside of just adding LOOKUP_DIRECTORY
> (or LOOKUP_OPEN) to the nfs_follow_remote_path() case?

I'm continuing to look at code and think about that but can't give a
decent answer yet.

> 
> And if we decide that we really *really* must never bind-mount a
> automount point, we could certainly add LOOKUP_OPEN to that case too,
> but my gut feel is that's a "doctor, doctor, it hurts when I put a
> nail in my eye" kind of case - do we really care?  Is it a sane
> operation to do to begin with?

I'll get to all the bits I need to look at eventually.

Preventing the bind mounting an automount point is something that I
wanted to be able to do for autofs. That's because there is a dependency
on specific path oriented external information which means a bind
mounting elsewhere is undefined. But I'm not sure yet that holds true
across all automount users.

I'm a bit surprised this has come up actually because I thought it was
possible to do that before and after the vfs-automount changes. So it's
a separate problem and I'd rather not get caught up in trying to resolve
an ongoing pre-existing problem at the same time as trying to work out
how to handle the current situation. 

> 
> My gut feel is that either of (or both) of
> LOOKUP_OPEN/LOOKUP_DIRECTORY is a saner flag to check for than
> LOOKUP_FOLLOW ever was. Let's keep LOOKUP_FOLLOW as being the "acts on
> symlink or the thing it points to", and nothing else.

It is hard to listen to what is being said and change direction when you
have committed heavily to a way of doing things but I'm trying, ;)

That's what I'm looking at doing by using the LOOKUP_DIRECTORY flag, all
be it slowly, because I'm trying to listen to what is being said, think
about it in relation to this, and understand the implications.

Let me continue looking at code and thinking about it further for now.
At the moment I fear that it won't quite cover all the cases, time will
tell.

Ian


