From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
Date: Mon, 07 Dec 2009 09:51:23 -0800
Message-ID: <C742809B.10A71%ricardo.labiaga@netapp.com>
References: <1260197272.32136.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39014 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935535AbZLGRvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 12:51:18 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7HpLJv006245
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 09:51:24 -0800 (PST)
In-Reply-To: <1260197272.32136.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/7/09 6:47 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2009-12-07 at 00:21 -0800, Ricardo Labiaga wrote:
>> nfs4_state_end_reclaim_reboot() can also be invoked as a
>> result of error processing, so it is not a safe place to
>> invoke RECLAIM_COMPLETE.  Instead, create a new state
>> flag that tracks the fact that a RECLAIM_COMPLETE needs
>> to be issued when all state has been reclaimed, or when
>> we're done establishing the session for the first time.
>> 
>> If an error occurs in the main state manager loop, just clear the
>> flag.  No sense in checking if the flag is set in order to clear it.
>> We're not going to issue the RECLAIM_COMPLETE since there's a high
>> probability that we had some kind of communication or session problem
>> which is s how we ended up in the error case.
> 
> This patch looks wrong for two reasons.
> 
>      1. We only want to call RECLAIM_COMPLETE if we saw a STALE_CLIENTID
>         error prior to the last attempt to re-establish the client id.

Section 18.51.3

   "Whenever a client establishes a new client ID and before it does the
   first non-reclaim operation that obtains a lock, it MUST send a
   RECLAIM_COMPLETE with rca_one_fs set to FALSE, even if there are no
   locks to reclaim.  If non-reclaim locking operations are done before
   the RECLAIM_COMPLETE, an NFS4ERR_GRACE error will be returned."

I interpreted the spec as you did, but I was talked into interpreting the
previous statement as:

"The client doesn't always know if the server has rebooted, so send it a
RECLAIM_COMPLETE after your initial EXCHANGE_ID/ CREATE_SESSION as well and
all will be happy".

Let me send an email to the NFSv4 IETF list to discuss it there.

>      2. We have to call it before we can start the no-grace reclaims.

My oversight.  I should have placed the check for the new state under
RECLAIM_REBOOT and before RECLAIM_NOGRACE - provided we determine that we
need to send RECLAIM_COMPLETE even in the case where we didn't see
STALE_CLIENTID

> 
> Looking at the code, I'm not convinced that we need a separate
> 'RECLAIM_COMPLETE_PENDING' state. It should be pretty much identical to
> the existing NFS4CLNT_RECLAIM_REBOOT state.
> The only difference is that in the NFSv4.1 case we want to be able to
> call RECLAIM_COMPLETE even in the case where we have no state to
> reclaim.
> 

Yes, this would be the case if my interpretation of the spec is incorrect.

- ricardo

> Cheers
>   Trond

