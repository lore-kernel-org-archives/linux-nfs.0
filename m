From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 1/3] nfs41: Mark stateids in need of reclaim if state
 manager gets stale clientid
Date: Sat, 05 Dec 2009 13:12:11 -0800
Message-ID: <C7400CAB.108B0%ricardo.labiaga@netapp.com>
References: <1260045253.29208.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24645 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbZLEVMH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 16:12:07 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5LCDkI013302
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 13:12:13 -0800 (PST)
In-Reply-To: <1260045253.29208.6.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/5/09 12:34 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sat, 2009-12-05 at 12:11 -0800, Ricardo Labiaga wrote:
>> The state manager was not marking the stateids as needing to be reclaimed
>> after reestablishing the clientid.
>> 
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> ---
>>  fs/nfs/nfs4state.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 630199d..ae90df8 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1157,6 +1157,7 @@ static void nfs4_session_recovery_handle_error(struct
>> nfs_client *clp, int err)
>> case -NFS4ERR_STALE_CLIENTID:
>> set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
>> set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
>> +  nfs4_state_start_reclaim_reboot(clp);
>> }
>>  }
>>  
> 
> So, why do we need a special nfs4_session_recovery_handle_error() that
> just mirrors the existing nfs4_recovery_handle_error().
> 

Good point.  The early exit from nfs4_state_end_reclaim_reboot() if
NFS4CLNT_RECLAIM_REBOOT is set makes it equivalent.  I'll make the change.

- ricardo

> Please just get rid of it...
> 
> Trond

