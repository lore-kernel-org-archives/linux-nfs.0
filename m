From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 2/3] nfs41: Handle session errors during delegation return
Date: Sat, 05 Dec 2009 13:58:09 -0800
Message-ID: <C7401771.10980%ricardo.labiaga@netapp.com>
References: <1260045516.29208.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58893 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756916AbZLEV6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 16:58:05 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5LwBif024281
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 13:58:11 -0800 (PST)
In-Reply-To: <1260045516.29208.8.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/5/09 12:38 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Sat, 2009-12-05 at 12:11 -0800, Ricardo Labiaga wrote:
>> Add session error handling to nfs4_open_delegation_recall()
>> 
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> ---
>>  fs/nfs/nfs4proc.c |   12 ++++++++++++
>>  1 files changed, 12 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index fb94ed0..97d4a82 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1169,6 +1169,18 @@ int nfs4_open_delegation_recall(struct
>> nfs_open_context *ctx, struct nfs4_state
>> case -ENOENT:
>> case -ESTALE:
>> goto out;
>> +   case -NFS4ERR_BADSESSION:
>> +   case -NFS4ERR_BADSLOT:
>> +   case -NFS4ERR_BAD_HIGH_SLOT:
>> +   case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
>> +   case -NFS4ERR_DEADSESSION:
>> +   case -NFS4ERR_SEQ_FALSE_RETRY:
>> +   case -NFS4ERR_SEQ_MISORDERED:
>> +    dprintk("%s ERROR: %d Reset session\n",
>> +     __func__, err);
>> +    set_bit(NFS4CLNT_SESSION_SETUP,
>> +     &server->nfs_client->cl_state);
>> +    goto out;
>> case -NFS4ERR_STALE_CLIENTID:
>> case -NFS4ERR_STALE_STATEID:
>> case -NFS4ERR_EXPIRED:
> 
> BADSESSION and DEADSESSION should call nfs4_schedule_state_recovery()
> instead.
> 

Will do.  I did earlier because I was still based on the master branch.

> The rest can continue to call NFS4CLNT_SESSION_RESET, but should also
> call nfs4_schedule_state_manager().

The other error handlers (nfs4_handle_exception, ...) call
nfs4_schedule_state_recovery() instead of setting NFS4CLNT_SESSION_RESET.
Should all of them be changed as well?  Not sure I understand the difference
in the handling.

- ricardo

> 
> Trond

