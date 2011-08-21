Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526Ab1HUQud (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Aug 2011 12:50:33 -0400
Date: Sun, 21 Aug 2011 12:50:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110821165029.GA9296@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 19, 2011 at 08:08:29PM +0100, Jamie Lokier wrote:
> J. Bruce Fields wrote:
> > I'm not sure how to approach the lease code.
> > 
> > On the one hand, I've never seen any evidence that anyone outside Samba
> > and NFSv4 has ever used it, and both currently make extremely limited
> > use of it.  So we could probably get away with "fixing" the lease code
> > to do whatever both of us need.
> 
> I've never used it, but I've _nearly_ used it (project took a
> different direction), in a web application framework.
> 
> Pretty much the way CIFS/NFS use it, to keep other things (remote
> state, database state, derived files) transactionally coherent with
> changes to file contents by programs that only know about the files
> they access.
> 
> The SIGIO stuff is a horrible interface.
> I could still see me trying to use it sometime in the future.
> In which case I really don't mind if you make the semantics saner :-)
> 
> Now we have fanotify which does something very similar and could have
> generalised leases, but unfortunately fanotify came from such a
> different motivation that it's not well suited for ordinary user
> applications.

I'm not sure what you mean by that--mainly just because I'm not as
familiar with fanotify as I should be.

For my case the important difference between leases and the various
notification interfaces is that leases are synchronous--the lease-holder
is notified and has a chance to clean up before releasing its lease and
allowing the conflicting operation to continue--whereas the the various
notification interfaces tell you "tough luck, something just happened".

--b.
