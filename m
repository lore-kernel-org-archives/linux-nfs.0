Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbaIZTqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 15:46:18 -0400
Date: Fri, 26 Sep 2014 15:46:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140926194616.GE27412@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <20140926183949.GC27412@fieldses.org>
 <20140926145446.21a99698@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140926145446.21a99698@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 02:54:46PM -0400, Jeff Layton wrote:
> On Fri, 26 Sep 2014 14:39:49 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > By the way, I've seen the following *before* your patches, but in case
> > you're still looking at reboot recovery problems:
> > 
> > I'm getting sporadic failures in the REBT6 pynfs test--a reclaim open
> > succeeds after a previous boot (with full grace period) during which the
> > client had failed to reclaim.
> > 
> > I managed to catch one trace, the relevant parts looked like:
> > 
> > 	SETCLIENTID client1
> > 	OPEN
> > 	LOCK
> > 
> > 	(server restart here)
> > 
> > 	SETCLIENTID client2
> > 	OPEN
> > 	LOCK (lock that conflicts with client1's)
> > 
> > 	(server restart here)
> > 
> > 	SETCLIENTID client1
> > 	OPEN CLAIM_PREVIOUS
> > 
> > And all those ops (including the last reclaim open) succeeded.
> > 
> > So I didn't have a chance to review it more carefully, but it certainly
> > looks like a server bug, not a test bug.  (Well, technically the server
> > behavior above is correct since it's not required to refuse anything
> > till we actually attempt to reclaim the original lock, but we know our
> > server's not that smart.)
> > 
> > But I haven't gotten any further than that....
> > 
> > --b.
> > 
> 
> Ewww...v4.0... ;)
> 
> Well, I guess that could happen if, after the first reboot, client1 also
> did a SETCLIENTID *and* reclaimed something that didn't conflict with
> the lock that client2 grabs...or, did an OPEN/OPEN_CONFIRM after the
> grace period without reclaiming its lock previously.
> 
> If it didn't do one or the other, then its record should have been
> cleaned out of the DB after the grace period ended between the reboots
> and it wouldn't have been able to reclaim after the second reboot.

Yeah.  Is there an easy way to tell nfsdcltrack to log everything?  I'm
only seeing this occasionally.

> It's a bit of a pathological case, and I don't see a way to fix that in
> the context of v4.0. The fact that there's no RECLAIM_COMPLETE is a
> pretty nasty protocol bug, IMO. Yet another reason to start really
> moving people toward v4.1+...

I don't belive there's a protocol bug here.

A correct NFSv4.0 client wouldn't send the open reclaim in the case you
describe above.

As I understand it, the rule for the client is: you're allowed to
reclaim only the set locks that you held previously, where "the set of
locks you held previously" is "the set of locks held by the clientid
which last managed to send a reclaim OPEN or OPEN_CONFIRM".  So for
example once client1 sends that unrelated OPEN reclaim it's giving up on
anything else it doesn't manage to reclaim this time around.

Any server that loses client state on reboot has no choice but to trust
clients to get this sort of thing right.

--b.
