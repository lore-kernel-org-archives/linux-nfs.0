Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14184 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077Ab2AYNi3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 08:38:29 -0500
Date: Wed, 25 Jan 2012 08:38:20 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125083820.637c8362@tlielax.poochiereds.net>
In-Reply-To: <20120125131116.GA17873@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
	<20120124230855.GE12426@fieldses.org>
	<20120125064158.4551a012@tlielax.poochiereds.net>
	<20120125131116.GA17873@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Jan 2012 08:11:17 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 25, 2012 at 06:41:58AM -0500, Jeff Layton wrote:
> > On Tue, 24 Jan 2012 18:08:55 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Jan 23, 2012 at 03:01:01PM -0500, Jeff Layton wrote:
> > > > This is the fourth iteration of this patchset. I had originally asked
> > > > Bruce to take the last one for 3.3, but decided at the last minute to
> > > > wait on it a bit. I knew there would be some changes needed in the
> > > > upcall, so by waiting we can avoid needing to deal with those in code
> > > > that has already shipped. I would like to see this patchset considered
> > > > for 3.4 however.
> > > > 
> > > > The previous patchset can be viewed here. That set also contains a
> > > > more comprehensive description of the rationale for this:
> > > > 
> > > >     http://www.spinics.net/lists/linux-nfs/msg26324.html
> > > > 
> > > > There have been a number of significant changes since the last set:
> > > > 
> > > > - the remove/expire upcall is now gone. In a clustered environment, the
> > > > records would need to be refcounted in order to handle that properly. That
> > > > becomes a sticky problem when you could have nodes rebooting. We don't
> > > > really need to remove these records individually however. Cleaning them
> > > > out only when the grace period ends should be sufficient.
> > > 
> > > I don't think so:
> > > 
> > > 	1. Client establishes state with server.
> > > 	2. Network goes down.
> > > 	3. A lease period passes without the client being able to renew.
> > > 	   The server expires the client and grants conflicting locks to
> > > 	   other clients.
> > > 	3. Server reboots.
> > > 	4. Network comes back up.
> > > 
> > > At this point, the client sees that the server has rebooted and is in
> > > its grace period, and reclaims.  Ooops.
> > > 
> > > The server needs to be able to tell the client "nope, you're not allowed
> > > to reclaim any more" at this point.
> > > 
> > > So we need some sort of remove/expire upcall.
> > > 
> > 
> > Doh! I don't know what I was thinking -- you're correct and we do need
> > that.
> > 
> > Ok, I'll see about putting it back and will resend. That does make it
> > rather nasty to handle clients mounting from multiple nodes in the same
> > cluster though. We'll need to come up with a data model that allows for
> > that as well.
> 
> Honestly, in the v4-based migration case if one client can hold state on
> mulitple nodes, and could (could it?) after reboot decide to reclaim
> state on a different node from the one it previously held the same state
> on--I'm not even clear what *should* happen, or if the protocol is
> really adequate for that case.
> 
> --b.

That was one of Chuck's concerns, IIUC:

--------------[snip]----------------

What if a server has more than one address?  For example, an IPv4 and
an IPv6 address?  Does it get two separate database files?  If so, how
do you ensure that a client's nfs_client_id4 is recorded in both places
atomically?  I'm not sure tying the server's identity to an IP address
is wise.

--------------[snip]----------------

This is the problem...

We need to tie the record to some property that's invariant for the NFS
server "instance". That can't be a physical nodeid or anything, since
part of the goal here is to allow for cluster services to float freely
between them.

I really would like to avoid having to establish some abstract "service
ID" or something since we'd have to track that on stable storage on a
per-nfs-service basis.

The server address seems like a natural fit here. With the design I'm
proposing, a client will need to reestablish its state on another node
if it migrates for any reason.

Chuck, what was your specific worry about tracking these on a per
server address basis? Can you outline a scenario where that would break
something?

-- 
Jeff Layton <jlayton@redhat.com>
