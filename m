Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833Ab2AYLmG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 06:42:06 -0500
Date: Wed, 25 Jan 2012 06:41:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125064158.4551a012@tlielax.poochiereds.net>
In-Reply-To: <20120124230855.GE12426@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
	<20120124230855.GE12426@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jan 2012 18:08:55 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 23, 2012 at 03:01:01PM -0500, Jeff Layton wrote:
> > This is the fourth iteration of this patchset. I had originally asked
> > Bruce to take the last one for 3.3, but decided at the last minute to
> > wait on it a bit. I knew there would be some changes needed in the
> > upcall, so by waiting we can avoid needing to deal with those in code
> > that has already shipped. I would like to see this patchset considered
> > for 3.4 however.
> > 
> > The previous patchset can be viewed here. That set also contains a
> > more comprehensive description of the rationale for this:
> > 
> >     http://www.spinics.net/lists/linux-nfs/msg26324.html
> > 
> > There have been a number of significant changes since the last set:
> > 
> > - the remove/expire upcall is now gone. In a clustered environment, the
> > records would need to be refcounted in order to handle that properly. That
> > becomes a sticky problem when you could have nodes rebooting. We don't
> > really need to remove these records individually however. Cleaning them
> > out only when the grace period ends should be sufficient.
> 
> I don't think so:
> 
> 	1. Client establishes state with server.
> 	2. Network goes down.
> 	3. A lease period passes without the client being able to renew.
> 	   The server expires the client and grants conflicting locks to
> 	   other clients.
> 	3. Server reboots.
> 	4. Network comes back up.
> 
> At this point, the client sees that the server has rebooted and is in
> its grace period, and reclaims.  Ooops.
> 
> The server needs to be able to tell the client "nope, you're not allowed
> to reclaim any more" at this point.
> 
> So we need some sort of remove/expire upcall.
> 

Doh! I don't know what I was thinking -- you're correct and we do need
that.

Ok, I'll see about putting it back and will resend. That does make it
rather nasty to handle clients mounting from multiple nodes in the same
cluster though. We'll need to come up with a data model that allows for
that as well.

> 
> If you'd like to make that patch #1, I could apply it now.
> 

That's already patch #1, but I might need to change some of the
operations to take an additional arg with the server's address. For
now, let's hold off on applying anything until I'm clear on what these
ops need to look like. We still have some runway until the 3.4 merge
window...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
