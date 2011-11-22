Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55023 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789Ab1KVVoo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 16:44:44 -0500
Date: Tue, 22 Nov 2011 16:44:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20111122214441.GB23243@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
 <20110821165029.GA9296@fieldses.org>
 <20111121124650.GA12942@jl-vm1.vm.bytemark.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111121124650.GA12942@jl-vm1.vm.bytemark.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 21, 2011 at 12:46:50PM +0000, Jamie Lokier wrote:
> J. Bruce Fields wrote:
> > On Fri, Aug 19, 2011 at 08:08:29PM +0100, Jamie Lokier wrote:
> > > J. Bruce Fields wrote:
> > > > I'm not sure how to approach the lease code.
> > > > 
> > > > On the one hand, I've never seen any evidence that anyone outside Samba
> > > > and NFSv4 has ever used it, and both currently make extremely limited
> > > > use of it.  So we could probably get away with "fixing" the lease code
> > > > to do whatever both of us need.
> > > 
> > > I've never used it, but I've _nearly_ used it (project took a
> > > different direction), in a web application framework.
> > > 
> > > Pretty much the way CIFS/NFS use it, to keep other things (remote
> > > state, database state, derived files) transactionally coherent with
> > > changes to file contents by programs that only know about the files
> > > they access.
> > > 
> > > The SIGIO stuff is a horrible interface.
> > > I could still see me trying to use it sometime in the future.
> > > In which case I really don't mind if you make the semantics saner :-)
> > > 
> > > Now we have fanotify which does something very similar and could have
> > > generalised leases, but unfortunately fanotify came from such a
> > > different motivation that it's not well suited for ordinary user
> > > applications.
> > 
> > I'm not sure what you mean by that--mainly just because I'm not as
> > familiar with fanotify as I should be.
> > 
> > For my case the important difference between leases and the various
> > notification interfaces is that leases are synchronous--the lease-holder
> > is notified and has a chance to clean up before releasing its lease and
> > allowing the conflicting operation to continue--whereas the the various
> > notification interfaces tell you "tough luck, something just happened".
> 
> Hi Bruce,
> 
> My apologies for not responding earlier; I just spotted this mail
> among an ocean of mails.

I understand!

> Fyi, fanotify is also synchronous:

Oh, I didn't know that, apologies for the confusion.

> It blocks the conflicting operation
> until the fanotify-using application allows it to proceed - or
> alternatively it can prevent the conflicting operating from proceeding
> at all.

Just grepping for "fsnotify" (which fanotify is built on?) I find a lot
of hooks in the vfs that all appear to have void returns and to be
called after the operation is done.  How does it fail an operation?  No
doubt I'm missing something.

> It's got a nicer interface than leases (like inotify compared with
> dnotify), but because it can interfere with legitimate applications
> it's not suitable as a lease replacement for non-root applications;
> and because it doesn't provide enough information about directory
> operations, it's not a drop-in synchronous upgrade of {i,d}notify.

OK, thanks.  I don't think it's directly useful to me but I should still
take a closer to look at it to see what I can learn.

--b.
