Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
To: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
	<trondmy@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
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
 <AB669741-1EC9-4C08-86A8-479755398679@redhat.com>
 <6ABCDB9B-997E-49C1-9363-D59AF9BEC0E9@primarydata.com>
 <B41EEA6E-B168-4DE3-AC73-F4270287EF0D@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Oleg Drokin
	<green@linuxhacker.ru>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <806bf204-eb35-5a3a-30fa-612bf22fb09a@Netapp.com>
Date: Thu, 10 Nov 2016 10:01:52 -0500
MIME-Version: 1.0
In-Reply-To: <B41EEA6E-B168-4DE3-AC73-F4270287EF0D@redhat.com>
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On 11/08/2016 10:10 AM, Benjamin Coddington wrote:
> 
> 
> On 7 Nov 2016, at 9:59, Trond Myklebust wrote:
> 
>> On Nov 7, 2016, at 09:50, Benjamin Coddington <bcodding@redhat.com<mailto:bcodding@redhat.com>> wrote:
>>
>> On 7 Nov 2016, at 8:45, Benjamin Coddington wrote:
>>
>> On 7 Nov 2016, at 8:09, Benjamin Coddington wrote:
>>
>> On 4 Nov 2016, at 12:02, Benjamin Coddington wrote:
>>
>> Hi Trond,
>>
>> On 22 Sep 2016, at 13:39, Trond Myklebust wrote:
>>
>> Right now, we're only running TEST/FREE_STATEID on the locks if
>> the open stateid recovery succeeds. The protocol requires us to
>> always do so.
>> The fix would be to move the call to TEST/FREE_STATEID and do it
>> before we attempt open recovery.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com<mailto:trond.myklebust@primarydata.com>>
>> ---
>> fs/nfs/nfs4proc.c | 92 +++++++++++++++++++++++++++++++------------------------
>> 1 file changed, 52 insertions(+), 40 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 3c1b8cb7dd95..33ca6d768bd2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2486,6 +2486,45 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
>> }
>>
>> /**
>> + * nfs41_check_expired_locks - possibly free a lock stateid
>> + *
>> + * @state: NFSv4 state for an inode
>> + *
>> + * Returns NFS_OK if recovery for this stateid is now finished.
>> + * Otherwise a negative NFS4ERR value is returned.
>> + */
>> +static int nfs41_check_expired_locks(struct nfs4_state *state)
>> +{
>> + int status, ret = NFS_OK;
>> + struct nfs4_lock_state *lsp;
>> + struct nfs_server *server = NFS_SERVER(state->inode);
>> +
>> + if (!test_bit(LK_STATE_IN_USE, &state->flags))
>> + goto out;
>> + list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>> + if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>>
>> I bisected a crash to this patch (commit c5896fc8622d57b31e1e98545d67d7089019e478).
>> I thought the problem was that this patch moved this path out from under the
>> nfsi->rwsem in nfs4_reclaim_locks() so it ends up with a freed
>> nfs4_lock_state here.
>>
>> I can reproduce this with generic/089.  Any ideas?
>>
>> Hit this on v4.9-rc4 this morning.  This probably needs to take the
>> state_lock before traversing the lock_states list.  I guess we've never hit
>> this before because the old path would serialize things somehow - maybe via
>> taking flc_lock in nfs4_reclaim_locks()..   I'll test that fix.
>>
>> Well, that's no good either as it gets stuck in a NFS4ERR_OLD_STATEID loop
>> in recovery since we'd want to retry in that case, but taking the state_lock
>> means we won't use the new stateid.  So maybe we need both the state_lock to
>> protect the list and the rwsem to stop new locks from being sent.  I'll try
>> that now.
>>
>> That one got much further, but eventually soft-locked up on the state_lock
>> when what looks like the state manager needed to have a TEST_STATEID wait on
>> another lock to complete.
>>
>> The other question here is why are we doing recovery so much?  It seems like
>> we're sending FREE_STATEID unnecessarily on successful DELEGRETURN and
>> LOCKU, but that shouldn't be triggering state recovery..
>>
>> FREE_STATEID is required by the protocol after LOCKU, so that’s intentional.
> 
> I thought it wasn't required if we do CLOSE, but I checked again and that
> wasn't what I was seeing. I am seeing LOCKU, FREE_STATEID, CLOSE, so it is
> correct.
> 
>> It isn’t needed after DELEGRETURN, so I’m not sure why that is happening.
> 
> I think it's just falling through the case statement in
> nfs4_delegreturn_done().  I'll send a patch for that.
> 
> I think the fix here is to manually increment ls_count for the current lock
> state, and expect that the lock_states list can be modified while we walk
> it.  I'll send a patch for that too if it runs though testing OK.

Do you have an estimate for when this patch will be ready?  I want to include it in my next bugfix pull request for 4.9.

Thanks,
Anna

> 
> Ben
