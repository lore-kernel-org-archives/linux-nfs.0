Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38744 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030810Ab2CFOzy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 09:55:54 -0500
MIME-Version: 1.0
In-Reply-To: <1331045602.3260.7.camel@lade.trondhjem.org>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
	<1331045205-3031-4-git-send-email-andros@netapp.com>
	<1331045602.3260.7.camel@lade.trondhjem.org>
Date: Tue, 6 Mar 2012 09:55:52 -0500
Message-ID: <CAHVgHyW=vs126WHjSWQYRG=-h76e4ruoYCBROP70QyM55PJrYg@mail.gmail.com>
Subject: Re: [PATCH 3/3] NFSv4.1 do not clear NFS_DELEAGED_STATE until stateid
 is tested
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 6, 2012 at 9:53 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-03-06 at 09:46 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> nfs41_open_expired() will test the delegation stateid based on
>> NFS_DELEGATED_STATE being set. If the stateid is bad, nfs4_open_recover
>> will clear the NFS_DELEGATED_STATE bit recovering the delegation.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Cc: stable@vger.kernel.org
>> ---
>>  fs/nfs/nfs4state.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 7bd9822..44fcd60 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -696,7 +696,10 @@ static void __nfs4_close(struct nfs4_state *state,
>>                       call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
>>               }
>>               if (newstate == 0)
>> +{
>> +printk("%s CLEAR NFS_DELEGATED_STATE state %p\n", __func__, state);
>>                       clear_bit(NFS_DELEGATED_STATE, &state->flags);
>> +}\
>
> Ewww.....


yep, still had stupid development messages -- resent immediately!

-->Andy
>
>>       }
>>       nfs4_state_set_mode_locked(state, newstate);
>>       spin_unlock(&owner->so_lock);
>> @@ -1097,7 +1100,7 @@ void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4
>>  {
>>       struct nfs_client *clp = server->nfs_client;
>>
>> -     if (test_and_clear_bit(NFS_DELEGATED_STATE, &state->flags))
>> +     if (test_bit(NFS_DELEGATED_STATE, &state->flags))
>>               nfs_async_inode_return_delegation(state->inode, &state->stateid);
>>       nfs4_state_mark_reclaim_nograce(clp, state);
>>       nfs4_schedule_state_manager(clp);
>
> Actually, the latest incarnation of the patch 2/3 removes the
> async_inode_return_delegation from nfs4_schedule_stateid_recovery. We
> don't need to return the delegation if all the stateids have been marked
> for return, and we've thrown out the delegation itself.
>
> Let's not hurry this into the stable tree yet...
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
