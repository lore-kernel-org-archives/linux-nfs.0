Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752812AbcKGNJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Nov 2016 08:09:47 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        "Oleg Drokin" <green@linuxhacker.ru>
Subject: Re: [PATCH v7 13/31] NFSv4.1: Ensure we always run TEST/FREE_STATEID
 on locks
Date: Mon, 07 Nov 2016 08:09:44 -0500
Message-ID: <34B1D68A-1A1C-4B59-A19E-467D48F7A9D0@redhat.com>
In-Reply-To: <599EE56B-46DD-411B-805D-11C2FB5E30A4@redhat.com>
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
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4 Nov 2016, at 12:02, Benjamin Coddington wrote:

> Hi Trond,
>
> On 22 Sep 2016, at 13:39, Trond Myklebust wrote:
>
>> Right now, we're only running TEST/FREE_STATEID on the locks if
>> the open stateid recovery succeeds. The protocol requires us to
>> always do so.
>> The fix would be to move the call to TEST/FREE_STATEID and do it
>> before we attempt open recovery.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4proc.c | 92 
>> +++++++++++++++++++++++++++++++------------------------
>>  1 file changed, 52 insertions(+), 40 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 3c1b8cb7dd95..33ca6d768bd2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2486,6 +2486,45 @@ static void 
>> nfs41_check_delegation_stateid(struct nfs4_state *state)
>>  }
>>
>>  /**
>> + * nfs41_check_expired_locks - possibly free a lock stateid
>> + *
>> + * @state: NFSv4 state for an inode
>> + *
>> + * Returns NFS_OK if recovery for this stateid is now finished.
>> + * Otherwise a negative NFS4ERR value is returned.
>> + */
>> +static int nfs41_check_expired_locks(struct nfs4_state *state)
>> +{
>> +	int status, ret = NFS_OK;
>> +	struct nfs4_lock_state *lsp;
>> +	struct nfs_server *server = NFS_SERVER(state->inode);
>> +
>> +	if (!test_bit(LK_STATE_IN_USE, &state->flags))
>> +		goto out;
>> +	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
>> +		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
>
> I bisected a crash to this patch (commit 
> c5896fc8622d57b31e1e98545d67d7089019e478).
> I thought the problem was that this patch moved this path out from 
> under the
> nfsi->rwsem in nfs4_reclaim_locks() so it ends up with a freed
> nfs4_lock_state here.
>
> I can reproduce this with generic/089.  Any ideas?

Hit this on v4.9-rc4 this morning.  This probably needs to take the
state_lock before traversing the lock_states list.  I guess we've never 
hit
this before because the old path would serialize things somehow - maybe 
via
taking flc_lock in nfs4_reclaim_locks()..   I'll test that fix.

Ben
