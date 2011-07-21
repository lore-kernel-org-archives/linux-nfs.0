Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:47122 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699Ab1GUAZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2011 20:25:33 -0400
Date: Wed, 20 Jul 2011 17:15:42 -0700
From: Jeremy Allison <jra@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110721001542.GA15644@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110721000758.GD27871@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 20, 2011 at 08:07:58PM -0400, J. Bruce Fields wrote:
> On Fri, Jun 10, 2011 at 09:48:59AM -0400, J. Bruce Fields wrote:
> > On Fri, Jun 10, 2011 at 09:56:49AM +0200, Volker Lendecke wrote:
> > > Without having looked too deeply, just let me point out that
> > > Samba here has a plain flaw. Early Linux Kernel versions
> > > that we programmed against did not properly support read
> > > only leases, so we did not implement that initially. If I
> > > remember correctly we never got around to finally do it once
> > > it became available. Eventually we will probably, as read
> > > only leases are a pretty important feature to present to
> > > CIFS clients.
> > 
> > Thanks, I didn't know that.  (Or I did, and I forgot.)
> > 
> > When you *do* implement that, is there any chance you'd have this need
> > to be able to downgrade to a read lease in the case of a conflict?
> 
> So it's a question about the protocols samba implements:
> 
> 	- Do they allow an atomic downgrade from an exclusive to a
> 	  shared oplock?  (Or to a level 2 oplock, or whatever the right
> 	  term is).

Yes. Exclusive can go to level 2 - in fact that's the default
downgrade we do (unless an smb.conf option explicity denies it).

> 	- If so, can that happen as a response to a conflicting open?
> 	  (So, if you're holding an exclusive oplock, and a conflicting
> 	  open comes in, can the server-to-client break message say "now
> 	  you're getting a shared oplock instead"?  Or is the client
> 	  left without any oplock until it requests a new one?)

Yes, this can happen.

In SMB, we only break to no lease when a write request comes
in on a exclusive or level2 oplock (read-lease) handle.

Jeremy.
