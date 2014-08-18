Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:51516 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbaHRU7e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Aug 2014 16:59:34 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so5102711qga.8
        for <linux-nfs@vger.kernel.org>; Mon, 18 Aug 2014 13:59:33 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 18 Aug 2014 16:59:26 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RFC PATCH 0/7] nfs-utils: support for lifting grace
 period early
Message-ID: <20140818165926.434dfb1c@tlielax.poochiereds.net>
In-Reply-To: <20140818200456.GC1096@fieldses.org>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
	<20140818200456.GC1096@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 18 Aug 2014 16:04:56 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> Thanks for working on this, it's currently a major annoyance!
> 

Thanks for looking at it. I think I might go with a different scheme
for managing the v4.x grace lifting which won't involve new procfiles,
but I need to code it up and test it out. Stay tuned for v2, but I'd
appreciate any feedback that you have on this set.

> On Fri, Aug 15, 2014 at 10:45:08AM -0400, Jeff Layton wrote:
> > This patchset adds some support to sm-notify and nfsdcltrack for lifting
> > the grace periods early. Allowing this actually work depends on the
> > companion kernel patchset, but the approach I've taken here should deal
> > properly with userland/kernel mismatch.
> > 
> > There are two main pieces:
> > 
> > sm-notify: in the event that sm-notify isn't sending any NOTIFY
> > requests, we don't expect to see any reclaims from clients. In that
> > case, we should be able to safely lift the lockd grace period early.
> > The first patch in the series implements this (though we'll probably
> > need a bit of selinux work to get that working in Fedora under enforcing
> > mode).
> > 
> > nfsdcltrack: if there are no v4.0 clients and all v4.1+ clients have
> > issued a RECLAIM_COMPLETE, then we can go ahead and end the nfsd grace
> > period. The remainder of the patchset adds the support for this. This
> > requires revving the DB schema for it, and making use of the environment
> > variables that are passed to the upcall by the kernel.
> 
> And we get to skip the grace period on first start, and on any restart
> during which no clients hold state, which seem like big improvements on
> their own.
> 

Agreed.

> Mostly a pointless digression, but I've been wondering if there are any
> further improvements that are worth it.  I'm feeling skeptical:
> 
> As long as nobody uses deny modes we could deal with them with a big
> dumb hammer (e.g. synchronously record something if anyone requests one,
> insist on a full grace period if they do).
> 
> But we're still stuck blocking all new opens as long as there are
> delegations outstanding.  (Well, maybe only new read opens, until we get
> write delegations.)
> 

I think you mean "write opens" there, but yes.

> Would it work to record a count of delegations on shutdown, to speed up
> the restart-after-clean-shutdown case?  And if it worked, would it be
> worth the effort?  (Alternatively on shutdown we could stop giving out
> delegations, recall everything, and wait till we had no delegations till
> shutting down completely.  Wonder how painful that would be.)
> 
> So anyway maybe our best bet is just to hope people upgrade to 4.1 soon.
> 

Those all seem a bit tricky to get right. Slowing down reboots will
suck. From the client standpoint that seems somewhat equivalent to a
grace period delay. The client is stuck either way.

Counting and recording delegations is an interesting idea, but you'd
have to take care not to record anything until the grace period has
ended.

That said, I personally don't have a lot of interest in speeding up
v4.0 reclaim. I'm not opposed to any of the above schemes, but I think
we'd be better off just pushing people toward v4.1 if they want the
grace period to be shorter.

Given the annoyance of the 90s grace period, that might act as a carrot
for encouraging people to switch.

On that same note, we probably need to discuss switching the default in
mount.nfs to v4.1 sometime soon. Maybe a topic for discussion at the
fall BaT?

-- 
Jeff Layton <jlayton@primarydata.com>
