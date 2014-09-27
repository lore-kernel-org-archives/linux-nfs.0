Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:37518 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbaI0NFC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 09:05:02 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so6985565qae.34
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 06:05:01 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 27 Sep 2014 09:04:58 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140927090458.62806936@synchrony.poochiereds.net>
In-Reply-To: <20140926194616.GE27412@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<20140926183949.GC27412@fieldses.org>
	<20140926145446.21a99698@tlielax.poochiereds.net>
	<20140926194616.GE27412@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Sep 2014 15:46:17 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Sep 26, 2014 at 02:54:46PM -0400, Jeff Layton wrote:
> > On Fri, 26 Sep 2014 14:39:49 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > By the way, I've seen the following *before* your patches, but in case
> > > you're still looking at reboot recovery problems:
> > > 
> > > I'm getting sporadic failures in the REBT6 pynfs test--a reclaim open
> > > succeeds after a previous boot (with full grace period) during which the
> > > client had failed to reclaim.
> > > 
> > > I managed to catch one trace, the relevant parts looked like:
> > > 
> > > 	SETCLIENTID client1
> > > 	OPEN
> > > 	LOCK
> > > 
> > > 	(server restart here)
> > > 
> > > 	SETCLIENTID client2
> > > 	OPEN
> > > 	LOCK (lock that conflicts with client1's)
> > > 
> > > 	(server restart here)
> > > 
> > > 	SETCLIENTID client1
> > > 	OPEN CLAIM_PREVIOUS
> > > 
> > > And all those ops (including the last reclaim open) succeeded.
> > > 
> > > So I didn't have a chance to review it more carefully, but it certainly
> > > looks like a server bug, not a test bug.  (Well, technically the server
> > > behavior above is correct since it's not required to refuse anything
> > > till we actually attempt to reclaim the original lock, but we know our
> > > server's not that smart.)
> > > 
> > > But I haven't gotten any further than that....
> > > 
> > > --b.
> > > 
> > 
> > Ewww...v4.0... ;)
> > 
> > Well, I guess that could happen if, after the first reboot, client1 also
> > did a SETCLIENTID *and* reclaimed something that didn't conflict with
> > the lock that client2 grabs...or, did an OPEN/OPEN_CONFIRM after the
> > grace period without reclaiming its lock previously.
> > 
> > If it didn't do one or the other, then its record should have been
> > cleaned out of the DB after the grace period ended between the reboots
> > and it wouldn't have been able to reclaim after the second reboot.
> 
> Yeah.  Is there an easy way to tell nfsdcltrack to log everything?  I'm
> only seeing this occasionally.
> 

If you can make sure that it's run with the '-d' flag then that'll make
it do debug level logging. Unfortunately, the kernel doesn't have a
handy switch to enable that so you'll need to patch the kernel (or
maybe wrap nfsdcltrack) to make that happen.

Maybe we should add a module parm to nfsd.ko that makes it run
nfsdcltrack with -d?

> > It's a bit of a pathological case, and I don't see a way to fix that in
> > the context of v4.0. The fact that there's no RECLAIM_COMPLETE is a
> > pretty nasty protocol bug, IMO. Yet another reason to start really
> > moving people toward v4.1+...
> 
> I don't belive there's a protocol bug here.
> 
> A correct NFSv4.0 client wouldn't send the open reclaim in the case you
> describe above.
> 

It would in the partial reclaim case.

Suppose we start reclaiming things but don't get everything before
there's a network partition. The server ends the grace period and then
hands out the conflicting lock to client2. It then reboots again and the
network partition heals. At that point, client1 could try to reclaim
everything it had before (including the lock that conflicts with the
one that client2 had).

I'd still argue that this is a protocol bug. Without RECLAIM_COMPLETE,
the server simply has no way to know whether the reclaims done by
client1 are complete or not.

> As I understand it, the rule for the client is: you're allowed to
> reclaim only the set locks that you held previously, where "the set of
> locks you held previously" is "the set of locks held by the clientid
> which last managed to send a reclaim OPEN or OPEN_CONFIRM".  So for
> example once client1 sends that unrelated OPEN reclaim it's giving up
> on anything else it doesn't manage to reclaim this time around.
> 
> Any server that loses client state on reboot has no choice but to
> trust clients to get this sort of thing right.
> 


-- 
Jeff Layton <jlayton@primarydata.com>
