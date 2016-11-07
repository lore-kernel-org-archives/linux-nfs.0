Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752952AbcKGOu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Nov 2016 09:50:28 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        "Oleg Drokin" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Mon, 07 Nov 2016 09:50:23 -0500
Message-ID: <AB669741-1EC9-4C08-86A8-479755398679@redhat.com>
In-Reply-To: <F1712484-1131-418A-98F0-272A4A1BAE59@redhat.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
 <34B1D68A-1A1C-4B59-A19E-467D48F7A9D0@redhat.com>
 <F1712484-1131-418A-98F0-272A4A1BAE59@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 7 Nov 2016, at 8:45, Benjamin Coddington wrote:

>
> On 7 Nov 2016, at 8:09, Benjamin Coddington wrote:
>
>> On 4 Nov 2016, at 12:02, Benjamin Coddington wrote:
>>
>>> Hi Trond,
>>>
>>> On 22 Sep 2016, at 13:39, Trond Myklebust wrote:
>>>
>>>> Right now, we're only running TEST/FREE_STATEID on the locks if
>>>> the open stateid recovery succeeds. The protocol requires us to
>>>> always do so.
>>>> The fix would be to move the call to TEST/FREE_STATEID and do it
>>>> before we attempt open recovery.
>>>>
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> ---
>>>>  fs/nfs/nfs4proc.c | 92 
>>>> +++++++++++++++++++++++++++++++------------------------
>>>>  1 file changed, 52 insertions(+), 40 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 3c1b8cb7dd95..33ca6d768bd2 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -2486,6 +2486,45 @@ static void 
>>>> nfs41_check_delegation_stateid(struct nfs4_state *state)
>>>>  }
>>>>
>>>>  /**
>>>> + * nfs41_check_expired_locks - possibly free a lock stateid
>>>> + *
>>>> + * @state: NFSv4 state for an inode
>>>> + *
>>>> + * Returns NFS_OK if recovery for this stateid is now finished.
>>>> + * Otherwise a negative NFS4ERR value is returned.
>>>> + */
>>>> +static int nfs41_check_expired_locks(struct nfs4_state *state)
>>>> +{
>>>> +	int status, ret = NFS_OK;
>>>> +	struct nfs4_lock_state *lsp;
>>>> +	struct nfs_server *server = NFS_SERVER(state->inode);
>>>> +
>>>> +	if (!test_bit(LK_STATE_IN_USE, &state->flags))
>>>> +		goto out;
>>>> +	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>>>> +		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>>>
>>> I bisected a crash to this patch (commit 
>>> c5896fc8622d57b31e1e98545d67d7089019e478).
>>> I thought the problem was that this patch moved this path out from 
>>> under the
>>> nfsi->rwsem in nfs4_reclaim_locks() so it ends up with a freed
>>> nfs4_lock_state here.
>>>
>>> I can reproduce this with generic/089.  Any ideas?
>>
>> Hit this on v4.9-rc4 this morning.  This probably needs to take the
>> state_lock before traversing the lock_states list.  I guess we've 
>> never hit
>> this before because the old path would serialize things somehow - 
>> maybe via
>> taking flc_lock in nfs4_reclaim_locks()..   I'll test that fix.
>
> Well, that's no good either as it gets stuck in a NFS4ERR_OLD_STATEID 
> loop
> in recovery since we'd want to retry in that case, but taking the 
> state_lock
> means we won't use the new stateid.  So maybe we need both the 
> state_lock to
> protect the list and the rwsem to stop new locks from being sent.  
> I'll try
> that now.

That one got much further, but eventually soft-locked up on the 
state_lock
when what looks like the state manager needed to have a TEST_STATEID 
wait on
another lock to complete.

The other question here is why are we doing recovery so much?  It seems 
like
we're sending FREE_STATEID unnecessarily on successful DELEGRETURN and
LOCKU, but that shouldn't be triggering state recovery..

