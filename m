From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 0/3] NFSD EOS deferral
Date: Fri, 17 Oct 2008 11:59:05 -0700
Message-ID: <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@us.ibm.com>
References: <1224104426-12293-1-git-send-email-andros@netapp.com> <20081017174454.GB11884@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:59740 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbYJQS7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:59:09 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9HIu5ql028662
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2008 14:56:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9HIx8Y6100096
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2008 14:59:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9HIx85P006406
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2008 14:59:08 -0400
In-Reply-To: <20081017174454.GB11884@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux-nfs-owner@vger.kernel.org wrote on 10/17/2008 10:44:54 AM:

> "J. Bruce Fields" <bfields@fieldses.org> 
> 
> On Wed, Oct 15, 2008 at 05:00:23PM -0400, andros@netapp.com wrote:
> > Here's a patch set for review - it compiles and seems to work, butI 
haven't
> > done stress testing, nor testing of all of the combinations of 
> deferral cases.
> > 
> > A deferral occurs when NFSD needs information from an rpc cache, 
> and an upcall
> > is required. Instead of NFSD waiting for the cache to be filled by
> the upcall,
> > the RPC request is inserted back into the receive stream for 
processing at a
> > later time.
> > 
> > Exactly once semantics require that NFSD compound RPC deferral 
processing
> > restart at the operation that caused the deferral, instead of 
> reprocessing the
> > full compound RPC from the start possibly repeating operation 
processing.
> > These patches add three callbacks, a data pointer, and page pointer 
storage
> > to the sunrpc svc deferral architecture that NFSD uses to 
> accomplish this goal.
> > 
> > Deferrals that do not define the callbacks act as before. Care hasbeen 
taken
> > to ensure that combinations of deferrals - those from the NFSv4 server 
with
> > the callbacks defined, and those from the RPC layer without the 
callbacks
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

But I thought that the problem here is that the Linux NFS client doesn't 
handle this return code properly.
Marc.
 
> 
> I do sometimes wonder whether continuing with the current
> deferred-request approach is best, though:
> 
>    - If we're saving out large parts of the request anyway (the
>      response pages), then maybe we should just keep rqstp's
>      on the deferred request queue instead of copying to a separate
>      deferred_request structure.
>    - Then as long as we're saving all that request data, is there
>      really significant savings from not keeping a thread around
>      too?
> 
> So I wonder if it'd be better just to let threads sleep (and be more
> aggressive about starting up new threads if appropriate, and add some
> other heuristics to avoid a situation where the whole server stalls on a
> temporarily wedged userspace daemon).
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

