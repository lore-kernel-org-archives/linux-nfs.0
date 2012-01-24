Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35727 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761Ab2AXXLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 18:11:00 -0500
Date: Tue, 24 Jan 2012 18:11:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120124231059.GG12426@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120124230855.GE12426@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2012 at 06:08:55PM -0500, J. Bruce Fields wrote:
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

(Doh.  Counting is hard.)

--b.

> 	4. Network comes back up.
> 
> At this point, the client sees that the server has rebooted and is in
> its grace period, and reclaims.  Ooops.
> 
> The server needs to be able to tell the client "nope, you're not allowed
> to reclaim any more" at this point.
> 
> So we need some sort of remove/expire upcall.
