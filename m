Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:61873 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaKERxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 12:53:49 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so8742178igd.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 09:53:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQWg+Fiyn7vH9pjU1GR-TKvMp+gcR7ssaA1zESQ8JdVsw@mail.gmail.com>
References: <1415025403-31914-1-git-send-email-kolga@netapp.com>
	<CAN-5tyHVoJ60z7WBaCYvUN3GsCEGh9jGc0evRCuiVt2aA6zP0g@mail.gmail.com>
	<CAHQdGtQWg+Fiyn7vH9pjU1GR-TKvMp+gcR7ssaA1zESQ8JdVsw@mail.gmail.com>
Date: Wed, 5 Nov 2014 12:53:48 -0500
Message-ID: <CAN-5tyEOLnq_v_8X6zNXX4u2oOdJeJHpEmxsr_yOAfHFZxyhyA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fixing infinite state recovery loop due to failed
 delegation return
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you for looking into this!

On Tue, Nov 4, 2014 at 7:14 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Tue, Nov 4, 2014 at 6:22 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Trond, can you please respond to the patch?
>>
>> As per earlier conversation, in this solution, state recovery is
>> initiated which marks the locks lost.
>>
>> Please either accept this patch or let me know what needs to be fixed.
>>
>
> Please see the 3 fixes I just sent out concerning delegation recovery
> w.r.t. NFSv4+NFSv4.1. In addition, we need to handle the case you
> patch attempts to address (however see the question I have below).
>
>> Thank you.
>>
>> On Mon, Nov 3, 2014 at 9:36 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>> If we get a bad-stateid-type of error when we send OPEN with delegate_cur
>>> to return currently held delegation, we shouldn't be trying to reclaim locks
>>> associated with that delegation state_id because we don't have an
>>> open_stateid to be used for the LOCK operation. Thus, we should
>>> return an error from the nfs4_open_delegation_recall() in that case.
>>>
>>> Furthermore, if an error occurs the delegation code will call
>>> nfs_abort_delegation_return() which sets again the NFS4CLNT_DELEGRETURN
>>> flags in the state and it leads the state manager to into an infinite loop
>>> for trying to reclaim the delegated state.
>>>
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>>  fs/nfs/delegation.c |    5 +++--
>>>  fs/nfs/nfs4proc.c   |    2 +-
>>>  2 files changed, 4 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>> index 5853f53..8016d89 100644
>>> --- a/fs/nfs/delegation.c
>>> +++ b/fs/nfs/delegation.c
>>> @@ -394,7 +394,7 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
>>>                 err = nfs4_wait_clnt_recover(clp);
>>>         } while (err == 0);
>>>
>>> -       if (err) {
>>> +       if (err && err != -EIO) {
>>>                 nfs_abort_delegation_return(delegation, clp);
>
> This exception for EIO now has me worried. If we detach the
> delegation, then it looks to me as if we will never send a
> FREE_STATEID, as required for the case of NFSv4.1.

I'd need to brush up on the FREE_STATEID op to confidently answer
that. But can't this be taken care of in state_recovery when locks are
marked lost?

>
>>>                 goto out;
>>>         }
>>> @@ -458,7 +458,8 @@ restart:
>>>                         iput(inode);
>>>                         if (!err)
>>>                                 goto restart;
>>> -                       set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
>>> +                       if (err != -EIO)
>>> +                               set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
>
> Please explain why this is needed. If we've cleared the bad
> delegation, then why should we not attempt to return any others that
> may be pending?

You are right, I think this is unnecessary because after we return the
delegation the bit can be set again for any other leftover
delegations. I have tested my patch without that chuck and it still
fixes the issues.

>
>>>                         return err;
>>>                 }
>>>         }
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 5aa55c1..6871055 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -1655,7 +1655,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
>>>                         nfs_inode_find_state_and_recover(state->inode,
>>>                                         stateid);
>>>                         nfs4_schedule_stateid_recovery(server, state);
>>> -                       return 0;
>>> +                       return -EIO;
>>>                 case -NFS4ERR_DELAY:
>>>                 case -NFS4ERR_GRACE:
>>>                         set_bit(NFS_DELEGATED_STATE, &state->flags);
>>> --
>>> 1.7.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
