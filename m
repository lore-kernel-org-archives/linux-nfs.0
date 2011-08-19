Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144Ab1HSQEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 12:04:20 -0400
Date: Fri, 19 Aug 2011 12:04:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110819160416.GC30856@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110721001542.GA15644@samba2>
 <20110721163520.GC1114@fieldses.org>
 <20110729022758.GC20317@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729022758.GC20317@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 10:27:58PM -0400, J. Bruce Fields wrote:
> On Thu, Jul 21, 2011 at 12:35:20PM -0400, J. Bruce Fields wrote:
> > On Wed, Jul 20, 2011 at 05:15:42PM -0700, Jeremy Allison wrote:
> > > On Wed, Jul 20, 2011 at 08:07:58PM -0400, J. Bruce Fields wrote:
> > > > So it's a question about the protocols samba implements:
> > > > 
> > > > 	- Do they allow an atomic downgrade from an exclusive to a
> > > > 	  shared oplock?  (Or to a level 2 oplock, or whatever the right
> > > > 	  term is).
> > > 
> > > Yes. Exclusive can go to level 2 - in fact that's the default
> > > downgrade we do (unless an smb.conf option explicity denies it).
> > > 
> > > > 	- If so, can that happen as a response to a conflicting open?
> > > > 	  (So, if you're holding an exclusive oplock, and a conflicting
> > > > 	  open comes in, can the server-to-client break message say "now
> > > > 	  you're getting a shared oplock instead"?  Or is the client
> > > > 	  left without any oplock until it requests a new one?)
> > > 
> > > Yes, this can happen.
> > > 
> > > In SMB, we only break to no lease when a write request comes
> > > in on a exclusive or level2 oplock (read-lease) handle.
> > 
> > Ok, thanks, that means we need a more complicated fix here--I'll work on
> > that....
> 
> My attempt follows.  Lightly tested.
> 
> I'll probably try writing a test or two for it, then queueing up
> something like this for 3.2, absent objections.

Second take follows, this time after a little more testing
(lease_tests.c from git://linux-nfs.org/~bfields/lock-tests.git), some
bug fixes, and minor simplification of the logic.  This is what I intend
to queue up for 3.2.

--b.
