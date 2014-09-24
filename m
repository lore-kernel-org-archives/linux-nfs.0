Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:43525 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaIXT51 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 15:57:27 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy10so7021428vcb.5
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 12:57:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyE8zt5iUQUFp+2iz9oP37HJhQ54YtSgesWs6Cu66A6qZw@mail.gmail.com>
References: <CAN-5tyGT71Y3DZ-V16ikjDa-+6Bt_j_2QwkQZyQMSZSLun5CaA@mail.gmail.com>
	<CAHQdGtSoowMb4tz1gVTTf1xRY8jwwgQOX_2CxPC_xziWurmw4Q@mail.gmail.com>
	<CAN-5tyE8zt5iUQUFp+2iz9oP37HJhQ54YtSgesWs6Cu66A6qZw@mail.gmail.com>
Date: Wed, 24 Sep 2014 15:57:26 -0400
Message-ID: <CAHQdGtQ6WYe0qgn7b7s2TW_HFsq2ZCwyMuMW8PO_10xLh79QFQ@mail.gmail.com>
Subject: Re: nfs4_lock_delegation_recall() improperly handles errors such as ERROR_GRACE
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Wed, Sep 24, 2014 at 2:20 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi Trond,
>
> nfs_delegation_claim_opens() return EAGAIN to nfs_end_delegation_return().
> issync is always 0 (as its called by the
> nfs_client_return_marked_delegations) and it breaks out of the loop...
> as a result the error just doesn't get handled.

Ah. OK, so this is being called from
nfs_client_return_marked_delegations. That makes sense.

So for that case, I'd expect the call to return to the loop in
nfs4_state_manager(), and then to retry through that after doing
whatever is needed to recover.
Essentially, we should be setting NFS4CLNT_DELEGRETURN again, and then
bouncing back into nfs_client_return_marked_delegations (after all the
recovery work has been done).

> Would it be useful to provide you with a pcap trace?
>
> The easiest way to trigger it is to enable the return of inactive
> delegation and have simple get a delegation and local lock, sleep and
> reboot the server and see the lock recovery error with err_grace.

Thanks for the reproducer! I'll see if I can get round to testing. ;-p

> On Wed, Sep 24, 2014 at 2:02 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> Hi Olga,
>>
>> On Wed, Sep 24, 2014 at 1:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> There exists a problem in the code that was easily reproducible prior
>>> to the commit b757144fd77cf5512f5b60179ba5ca8dcc5184b4 ("NFSv4 Be less
>>> aggressive about returning delegations"). The same code is used during
>>> delegation return and is still reproducible (with highly coordinated
>>> setup of triggering just the right actions).
>>>
>>> The problem lies in the call of nfs4_lock_delegation_recall(). In the
>>> nutshell, when the LOCK op gets an error such as ERR_GRACE, the error
>>> is unhanded which leaves the client in incorrect state assuming that
>>> it has 'successfully' acquired a lock that was locally acquired while
>>> holding a delegation.
>>>
>>> I believe the problem stems from the fact that
>>> nfs4_lock_delegation_recall(), unlike normal version of LOCK
>>> nfs4_proc_getlk(), lacks the do { handle_error(do_proc())} while(err)
>>> structure.
>>>
>>> I believe the problem should be fixed by something like the following:
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 6ca0c8e..78d088c 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -5936,11 +5936,12 @@ int nfs4_lock_delegation_recall(struct
>>> file_lock *fl, struct nfs4_state *state,
>>>         struct nfs_server *server = NFS_SERVER(state->inode);
>>>         int err;
>>>
>>> -       err = nfs4_set_lock_state(state, fl);
>>> -       if (err != 0)
>>> -               return err;
>>> -       err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
>>> -       return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>>> +       do {
>>> +               err = nfs4_handle_delegation_recall_error(server, state,
>>> +                       stateid, _nfs4_do_setlk(state, F_SETLK, fl,
>>> +                               NFS_LOCK_NEW));
>>> +       } while (err == -EAGAIN);
>>> +       return err;
>>>  }
>>>
>>>  struct nfs_release_lockowner_data {
>>>
>>> Is this an acceptable solution?
>>>
>>
>> In the current code, I expect the EAGAIN from
>> nfs4_handle_delegation_recall_error() to be propagated back to
>> nfs_end_delegation_return(). It should then result in the client
>> waiting for state recovery to complete followed by a loop back to
>> nfs_delegation_claim_opens().
>> Could you explain why that isn't working for your case?
>>

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
