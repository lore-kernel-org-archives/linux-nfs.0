Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885Ab1KWTIz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 14:08:55 -0500
Date: Wed, 23 Nov 2011 14:08:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20111123190851.GA680@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
 <20110821165029.GA9296@fieldses.org>
 <20111121124650.GA12942@jl-vm1.vm.bytemark.co.uk>
 <20111122214441.GB23243@fieldses.org>
 <20111123003057.GA2385@jl-vm1.vm.bytemark.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111123003057.GA2385@jl-vm1.vm.bytemark.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 23, 2011 at 12:30:57AM +0000, Jamie Lokier wrote:
> J. Bruce Fields wrote:
> > > Fyi, fanotify is also synchronous:
> > 
> > Oh, I didn't know that, apologies for the confusion.
> > 
> > > It blocks the conflicting operation
> > > until the fanotify-using application allows it to proceed - or
> > > alternatively it can prevent the conflicting operating from proceeding
> > > at all.
> > 
> > Just grepping for "fsnotify" (which fanotify is built on?) I find a lot
> > of hooks in the vfs that all appear to have void returns and to be
> > called after the operation is done.  How does it fail an operation?  No
> > doubt I'm missing something.
> 
> The hook is fsnotify_perm(), called in security/security.c.

Got it.

Hm, we could almost move a lease_break() call in there.  We wouldn't
want it turning into a no-op in the absence of CONFIG_SECURITY, though.

--b.
