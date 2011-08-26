Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:41794 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab1HZVfl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 17:35:41 -0400
Message-ID: <4E58119A.3090403@panasas.com>
Date: Fri, 26 Aug 2011 14:35:22 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period expiration
References: <4E45C164.1070604@panasas.com> <20110826203924.GC17196@fieldses.org>
In-Reply-To: <20110826203924.GC17196@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/26/2011 01:39 PM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 05:12:20PM -0700, Boaz Harrosh wrote:
>>
>> locks_in_grace() was called twice one for the "yes" case second
>> for the "no" case. If the status changes between these two calls
>> the Server would do the wrong thing. Sample it only once.
> 
> I don't see how this fixes any bug.  The only thing that could happen in
> between those two checks is that the grace period could end.  In that
> case op_claim_type must be NFS4_OPEN_CLAIM_PREVIOUS (otherwise we would
> have jumped to out and not hit the second case).  The second condition
> will therefore be true and we'll fail with err_no_grace.  I don't see
> that is incorrect, as in fact the grace period is now over.

OK You are right it is not NFS incorrect. But I still think a single
sample is better coding practice. no? Though I agree that the commit log
wording should be changed.

What about the other part of the patch? The print. Should I send a separate
patch for that?

> 
> There may be a different bug: if the grace period ends *any time* after
> locks_in_grace() is called but before we actually do the lock or open,
> then a reclaim could be incorrectly granted.  The state lock prevents
> this happening between two nfsv4 clients, but it could happen between
> a v4 client and a lockd client, I think.  In more detail:
> 
> 
> 	lockd client		NFSv4 client
> 	------------		------------
> 
> 				reclaim request passes grace check
> 		-- grace period ends --
> 	gets conflicting lock
> 	drops conflicting lock
> 				reclaim request granted
> 
> One fix might be to take some sort of reference count as long as you're
> processing a reclaim request, and not end the grace period till that
> count goes to zero.
> 
> Another might be push the grace checks down into the core lock code and
> make sure there's a lock that provides mutual exclusion between the
> locks_end_grace() call and lock reclaims.
> 

You might get by, by rechecking the grace period at the end of the
processing and if passed issue a "reclaim request failed" anyway.
So the first check is only for optimization but the final disposition
is the post-check. (Just as if you dropped that refcount above)

Boaz

> --b.
> 
> 
