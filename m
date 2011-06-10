Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932233Ab1FJNtC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jun 2011 09:49:02 -0400
Date: Fri, 10 Jun 2011 09:48:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110610134859.GA27837@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1QUwaT-00HRZw-74@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 10, 2011 at 09:56:49AM +0200, Volker Lendecke wrote:
> On Thu, Jun 09, 2011 at 07:16:06PM -0400, J. Bruce Fields wrote:
> > The lease code behavior during the lease-breaking process is strange.
> > Fixing it completely would be complicated by the fact that the current
> > code allows a lease break to downgrade the lease instead of necessarily
> > removing it.
> > 
> > But I can't see what the point of that feature is.  And googling around
> > and looking at the Samba code, I can't see any evidence that anyone uses
> > it.  Think we could just do away with removing the ability to downgrade
> > to satisfy a lease break?
> 
> Without having looked too deeply, just let me point out that
> Samba here has a plain flaw. Early Linux Kernel versions
> that we programmed against did not properly support read
> only leases, so we did not implement that initially. If I
> remember correctly we never got around to finally do it once
> it became available. Eventually we will probably, as read
> only leases are a pretty important feature to present to
> CIFS clients.

Thanks, I didn't know that.  (Or I did, and I forgot.)

When you *do* implement that, is there any chance you'd have this need
to be able to downgrade to a read lease in the case of a conflict?

--b.
