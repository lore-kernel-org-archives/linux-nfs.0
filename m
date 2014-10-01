Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:48706 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbaJASqn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2014 14:46:43 -0400
Received: by mail-vc0-f172.google.com with SMTP id lf12so720654vcb.17
        for <linux-nfs@vger.kernel.org>; Wed, 01 Oct 2014 11:46:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141001143249.4e837eb1@synchrony.poochiereds.net>
References: <1411876498-12039-1-git-send-email-trond.myklebust@primarydata.com>
	<1411876498-12039-2-git-send-email-trond.myklebust@primarydata.com>
	<20141001143249.4e837eb1@synchrony.poochiereds.net>
Date: Wed, 1 Oct 2014 14:46:43 -0400
Message-ID: <CAHQdGtR6ec=Ucdvuuk6G4X_e-En4F55fxFBK0FGM-SaMoXhT3Q@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFSv4: Fix lock recovery when CREATE_SESSION/SETCLIENTID_CONFIRM
 fails
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 1, 2014 at 2:32 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> On Sat, 27 Sep 2014 23:54:57 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> If a NFSv4.x server returns NFS4ERR_STALE_CLIENTID in response to a
>> CREATE_SESSION or SETCLIENTID_CONFIRM in order to tell us that it rebooted
>> a second time, then the client will currently take this to mean that it must
>> declare all locks to be stale, and hence ineligible for reboot recovery.
>>
>> RFC3530 and RFC5661 both suggest that the client should instead rely on the
>> server to respond to inelegible open share, lock and delegation reclaim
>> requests with NFS4ERR_NO_GRACE in this situation.
>>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4state.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 22fe35104c0c..26d510d11efd 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1761,7 +1761,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
>>               break;
>>       case -NFS4ERR_STALE_CLIENTID:
>>               clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>> -             nfs4_state_clear_reclaim_reboot(clp);
>>               nfs4_state_start_reclaim_reboot(clp);
>>               break;
>>       case -NFS4ERR_CLID_INUSE:
>
> What distinguishes between the v4.0 and v4.1+ case here?

Nothing. They are actually supposed to be handled identically here.
nfs4_handle_reclaim_lease_error() is called if and only if the
SETCLIENTID_CONFIRM (v4.0) or CREATE_SESSION (v4.1) fail. At that
point we have not yet sent out any OPEN or LOCK reclaim requests, so
the failure will really result in a reclaim all-or-nothing for both
NFSv4 and NFSv4.x.

> For v4.1+, we do want the client to just try to reclaim everything that
> it can. For v4.0 though, we need to be a little more careful. Consider:
>
>
> Client                          Server
> ===================================================================
> SETCLIENTID
> OPEN (O1)
> LOCK (L1)
>                                 reboot (B1)
>
> RENEW                           (NFS4ERR_STALE_CLIENTID)
> SETCLIENTID
> OPEN(reclaim O1)                (NFS4_OK)
>
>         === NETWORK PARTITION ===
>                                 Grace period is lifted, but client1's
>                                 lease hasn't expired yet
>
>                                 Lock that conflicts with L1 is handed out to client2
>
>                                 reboot (B2)
>         === PARTITION HEALS ===
> LOCK(reclaim L1)                (NFS4ERR_STALE_CLIENTID)
>
> SETCLIENTID
> OPEN (reclaim O1)               (NFS4_OK)
> LOCK (reclaim L1)               (NFS4_OK)
>
>
> Now we have a conflict. I think that the client should not try to
> reclaim L1 after B2 in the v4.0 case. Do we need to do something
> to handle the v4.0 vs. v4.1+ cases differently here?

This patch does not change the existing handling of
NFS4ERR_STALE_CLIENTID above, so the NFSv4.0 code will continue to
work as before.

The reason why NFSv4.1 will not need changing above is because the
SEQUENCE op that we send instead of RENEW will receive a
NFS4ERR_DEADSESSION or NFS4ERR_BADSESSION instead of the stale
clientid error.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
