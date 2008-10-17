From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 0/3] NFSD EOS deferral
Date: Fri, 17 Oct 2008 14:44:57 -0400
Message-ID: <1224269097.3883.33.camel@localhost.localdomain>
References: <1224104426-12293-1-git-send-email-andros@netapp.com>
	 <20081017174454.GB11884@fieldses.org>
Reply-To: andros@netapp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2683 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbYJQSpx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:45:53 -0400
In-Reply-To: <20081017174454.GB11884@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-10-17 at 13:44 -0400, J. Bruce Fields wrote:
> On Wed, Oct 15, 2008 at 05:00:23PM -0400, andros@netapp.com wrote:
> > Here's a patch set for review - it compiles and seems to work, but I haven't
> > done stress testing, nor testing of all of the combinations of deferral cases.
> > 
> > A deferral occurs when NFSD needs information from an rpc cache, and an upcall
> > is required. Instead of NFSD waiting for the cache to be filled by the upcall,
> > the RPC request is inserted back into the receive stream for processing at a
> > later time.
> > 
> > Exactly once semantics require that NFSD compound RPC deferral processing
> > restart at the operation that caused the deferral, instead of reprocessing the
> > full compound RPC from the start possibly repeating operation processing.
> > These patches add three callbacks, a data pointer, and page pointer storage
> > to the sunrpc svc deferral architecture that NFSD uses to accomplish this goal.
> > 
> > Deferrals that do not define the callbacks act as before. Care has been taken
> > to ensure that combinations of deferrals - those from the NFSv4 server with
> > the callbacks defined, and those from the RPC layer without the callbacks
> > defined work together correctly.
> > 
> > Thoughts, comments and suggestions are really appreciated...
> 
> Requests longer than a page are still not deferred, so large writes that
> trigger upcalls still get an ERR_DELAY.  OK, probably no big deal.
> 
> I don't think we can apply this until we have some way to track the
> number and size of deferred requests outstanding and fall back on
> ERR_DELAY if it's too much.
> 
> I do sometimes wonder whether continuing with the current
> deferred-request approach is best, though:
> 
> 	- If we're saving out large parts of the request anyway (the
> 	  response pages), then maybe we should just keep rqstp's
> 	  on the deferred request queue instead of copying to a separate
> 	  deferred_request structure.
> 	- Then as long as we're saving all that request data, is there
> 	  really significant savings from not keeping a thread around
> 	  too?

True, especially if we also save large arg data, as in large writes that
trigger upcalls.
> 
> So I wonder if it'd be better just to let threads sleep (and be more
> aggressive about starting up new threads if appropriate, and add some
> other heuristics to avoid a situation where the whole server stalls on a
> temporarily wedged userspace daemon).
> 
> --b.
