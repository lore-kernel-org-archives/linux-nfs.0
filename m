Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2.shareable.org ([80.68.89.115]:49372 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab1KUNaL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 08:30:11 -0500
Date: Mon, 21 Nov 2011 12:46:50 +0000
From: Jamie Lokier <jamie@shareable.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20111121124650.GA12942@jl-vm1.vm.bytemark.co.uk>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
 <20110821165029.GA9296@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110821165029.GA9296@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Aug 19, 2011 at 08:08:29PM +0100, Jamie Lokier wrote:
> > J. Bruce Fields wrote:
> > > I'm not sure how to approach the lease code.
> > > 
> > > On the one hand, I've never seen any evidence that anyone outside Samba
> > > and NFSv4 has ever used it, and both currently make extremely limited
> > > use of it.  So we could probably get away with "fixing" the lease code
> > > to do whatever both of us need.
> > 
> > I've never used it, but I've _nearly_ used it (project took a
> > different direction), in a web application framework.
> > 
> > Pretty much the way CIFS/NFS use it, to keep other things (remote
> > state, database state, derived files) transactionally coherent with
> > changes to file contents by programs that only know about the files
> > they access.
> > 
> > The SIGIO stuff is a horrible interface.
> > I could still see me trying to use it sometime in the future.
> > In which case I really don't mind if you make the semantics saner :-)
> > 
> > Now we have fanotify which does something very similar and could have
> > generalised leases, but unfortunately fanotify came from such a
> > different motivation that it's not well suited for ordinary user
> > applications.
> 
> I'm not sure what you mean by that--mainly just because I'm not as
> familiar with fanotify as I should be.
> 
> For my case the important difference between leases and the various
> notification interfaces is that leases are synchronous--the lease-holder
> is notified and has a chance to clean up before releasing its lease and
> allowing the conflicting operation to continue--whereas the the various
> notification interfaces tell you "tough luck, something just happened".

Hi Bruce,

My apologies for not responding earlier; I just spotted this mail
among an ocean of mails.

Fyi, fanotify is also synchronous: It blocks the conflicting operation
until the fanotify-using application allows it to proceed - or
alternatively it can prevent the conflicting operating from proceeding
at all.

It's got a nicer interface than leases (like inotify compared with
dnotify), but because it can interfere with legitimate applications
it's not suitable as a lease replacement for non-root applications;
and because it doesn't provide enough information about directory
operations, it's not a drop-in synchronous upgrade of {i,d}notify.

All the best,
-- Jamie
