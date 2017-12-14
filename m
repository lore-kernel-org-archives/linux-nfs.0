Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:45489 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754305AbdLNSX4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 13:23:56 -0500
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1513275773.3888.20.camel@gmail.com>
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org
In-Reply-To: <87bmjaq89r.fsf@notabene.neil.brown.name>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
         <1512398194.7031.56.camel@gmail.com>
         <87indksq9q.fsf@notabene.neil.brown.name>
         <1512565420.4048.21.camel@redhat.com>
         <87bmjaq89r.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Dec 2017 12:22:53 -0600
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-12-08 at 13:10 +1100, NeilBrown wrote:
> On Wed, Dec 06 2017, Jeff Layton wrote:
> 
> > On Wed, 2017-12-06 at 10:34 +1100, NeilBrown wrote:
> > > 
> > > The new semantic for MNT_DETACH|MNT_FORCE is interesting.
> > > As it was never possible before (from /bin/umount), it should be
> > > safe to
> > > add a new meaning.
> > > The meaning is effectively "detach the filesystem from the
> > > namespace and
> > > detach the transport from the filesystem", which sounds like it
> > > is
> > > useful.
> > > It is worth highlighting this, and maybe even cc:ing
> > > linux-api@vger.kernel.org ... done that.
> > > 
> > 
> > I'm not thrilled with the new flag combo, personally. Given that
> > we're
> > introducing new behavior here, I think it wouldn't hurt to add a
> > new
> > UMOUNT_* flag for this (UMOUNT_NUKE_FROM_ORBIT?).
> 
> Suppose we did... MNT_FORCE_PONIES. What would be the semantics of
> this
> flag?  Once we had it, would anyone ever want to use MNT_FORCE again?
> 
> MNT_FORCE is already fairly heavy handled.  It abort an arbitrary
> collections of RPC requests being sent for the given filesystem, no
> matter where else that filesystem might be mounted.
> Is it ever safe to use this flag unless you have good reason to
> believe
> that the server is not available and there is no point pretending any
> more?
> And if that is the case, why not use the new MNT_FORCE_PONIES which
> is
> at least predictable and reliable.
> 
> We've talking a lot about the one NFS filesystem being mounted in
> multiple containers.  MNT_FORCE is already a problem for such mounts
> as
> one contains can kill requests generated from another
> container.  Maybe
> MNT_FORCE needs to be restricted to "real" root.
> Once we restrict it, do we need to keep it from being too harsh?
> 
> What would be really nice is a timeout for umount, and for sync.
> The timeout only starts when the filesystem stops making progress for
> writeback.  If it eventually does timeout, then the caller can fall
> back
> to MNT_DETACH if they are in a container, or MNT_FORCE if not.
> (Maybe MNT_FORCE should map to MNT_DETACH in a container??? or maybe
> not).
> 
> There is a lot here that still isn't clear to me, but one this does
> seem
> to be becoming clear:  MNT_FORCE as it stands is nearly useless and
> it
> would serve is well to find a semantic that it actually useful, and
> impose that.

Trying to keep the discussion going... does anyone else have thoughts
on this?

Thanks,
Joshua Watt
> 
> Thanks,
> NeilBrown
