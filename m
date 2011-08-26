Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545Ab1HZVyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 17:54:55 -0400
Date: Fri, 26 Aug 2011 17:54:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period expiration
Message-ID: <20110826215451.GF16090@pad.fieldses.org>
References: <4E45C164.1070604@panasas.com>
 <20110826203924.GC17196@fieldses.org>
 <4E58119A.3090403@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E58119A.3090403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 26, 2011 at 02:35:22PM -0700, Boaz Harrosh wrote:
> On 08/26/2011 01:39 PM, J. Bruce Fields wrote:
> > On Fri, Aug 12, 2011 at 05:12:20PM -0700, Boaz Harrosh wrote:
> >>
> >> locks_in_grace() was called twice one for the "yes" case second
> >> for the "no" case. If the status changes between these two calls
> >> the Server would do the wrong thing. Sample it only once.
> > 
> > I don't see how this fixes any bug.  The only thing that could happen in
> > between those two checks is that the grace period could end.  In that
> > case op_claim_type must be NFS4_OPEN_CLAIM_PREVIOUS (otherwise we would
> > have jumped to out and not hit the second case).  The second condition
> > will therefore be true and we'll fail with err_no_grace.  I don't see
> > that is incorrect, as in fact the grace period is now over.
> 
> OK You are right it is not NFS incorrect. But I still think a single
> sample is better coding practice. no? Though I agree that the commit log
> wording should be changed.

Sure, if you want to resend with just that, that'd be OK.

> What about the other part of the patch? The print. Should I send a separate
> patch for that?

As a general rule, I try to avoid logging client problems:
	- A malicious client could fill up our logs.
	- A bunch of broken clients could do the same unintentionally.

If it's really necessary then maybe do it with printk_once().

Which clients are you worried about exactly?

> > One fix might be to take some sort of reference count as long as you're
> > processing a reclaim request, and not end the grace period till that
> > count goes to zero.
> > 
> > Another might be push the grace checks down into the core lock code and
> > make sure there's a lock that provides mutual exclusion between the
> > locks_end_grace() call and lock reclaims.
> > 
> 
> You might get by, by rechecking the grace period at the end of the
> processing and if passed issue a "reclaim request failed" anyway.
> So the first check is only for optimization but the final disposition
> is the post-check. (Just as if you dropped that refcount above)

I guess that could work, but you'd have to back out the operation you
just did if the check showed you'd left the grace period.  I'd rather
avoid that.

--b.
