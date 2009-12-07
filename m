From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
Date: Mon, 07 Dec 2009 09:47:51 -0500
Message-ID: <1260197272.32136.19.camel@localhost>
References: <>
	 <1260174111-23160-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260174111-23160-2-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260174111-23160-3-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260174111-23160-4-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260174111-23160-5-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47353 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757419AbZLGOrq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 09:47:46 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7ElrPR000948
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 06:47:53 -0800 (PST)
In-Reply-To: <1260174111-23160-5-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-12-07 at 00:21 -0800, Ricardo Labiaga wrote: 
> nfs4_state_end_reclaim_reboot() can also be invoked as a
> result of error processing, so it is not a safe place to
> invoke RECLAIM_COMPLETE.  Instead, create a new state
> flag that tracks the fact that a RECLAIM_COMPLETE needs
> to be issued when all state has been reclaimed, or when
> we're done establishing the session for the first time.
> 
> If an error occurs in the main state manager loop, just clear the
> flag.  No sense in checking if the flag is set in order to clear it.
> We're not going to issue the RECLAIM_COMPLETE since there's a high
> probability that we had some kind of communication or session problem
> which is s how we ended up in the error case.

This patch looks wrong for two reasons.

     1. We only want to call RECLAIM_COMPLETE if we saw a STALE_CLIENTID
        error prior to the last attempt to re-establish the client id. 
     2. We have to call it before we can start the no-grace reclaims.

Looking at the code, I'm not convinced that we need a separate
'RECLAIM_COMPLETE_PENDING' state. It should be pretty much identical to
the existing NFS4CLNT_RECLAIM_REBOOT state.
The only difference is that in the NFSv4.1 case we want to be able to
call RECLAIM_COMPLETE even in the case where we have no state to
reclaim.

Cheers
  Trond
