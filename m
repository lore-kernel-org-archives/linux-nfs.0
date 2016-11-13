Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933391AbcKMNeO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 13 Nov 2016 08:34:14 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9294564CC
        for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2016 13:34:14 +0000 (UTC)
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: CLOSE/OPEN race
Date: Sun, 13 Nov 2016 08:34:12 -0500
Message-ID: <92D37C3A-03D6-42B5-831D-CA4736A5E4BF@redhat.com>
In-Reply-To: <1479005770.8210.4.camel@redhat.com>
References: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
 <1478955250.2442.16.camel@redhat.com>
 <B050FA3F-5D9A-4053-BB9E-7668814846B7@redhat.com>
 <1478969565.2442.18.camel@redhat.com>
 <98C04570-5E22-4F6D-80AF-FA6EE48ED489@redhat.com>
 <1478985360.2442.29.camel@redhat.com> <1479005770.8210.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12 Nov 2016, at 21:56, Jeff Layton wrote:

> On Sat, 2016-11-12 at 16:16 -0500, Jeff Layton wrote:
>> On Sat, 2016-11-12 at 13:03 -0500, Benjamin Coddington wrote:
>>>
>>> On 12 Nov 2016, at 11:52, Jeff Layton wrote:
>>>
>>>>
>>>> On Sat, 2016-11-12 at 10:31 -0500, Benjamin Coddington wrote:
>>>>>
>>>>> On 12 Nov 2016, at 7:54, Jeff Layton wrote:
>>>>>
>>>>>>
>>>>>>
>>>>>> On Sat, 2016-11-12 at 06:08 -0500, Benjamin Coddington wrote:
>>>>>>>
>>>>>>>
>>>>>>> I've been seeing the following on a modified version of 
>>>>>>> generic/089
>>>>>>> that gets the client stuck sending LOCK with 
>>>>>>> NFS4ERR_OLD_STATEID.
>>>>>>>
>>>>>>> 1. Client has open stateid A, sends a CLOSE
>>>>>>> 2. Client sends OPEN with same owner
>>>>>>> 3. Client sends another OPEN with same owner
>>>>>>> 4. Client gets a reply to OPEN in 3, stateid is B.2 (stateid B
>>>>>>> sequence 2)
>>>>>>> 5. Client does LOCK,LOCKU,FREE_STATEID from B.2
>>>>>>> 6. Client gets a reply to CLOSE in 1
>>>>>>> 7. Client gets reply to OPEN in 2, stateid is B.1
>>>>>>> 8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in a loop
>>>>>>>
>>>>>>> The CLOSE response in 6 causes us to clear NFS_OPEN_STATE, so 
>>>>>>> that
>>>>>>> the OPEN
>>>>>>> response in 7 is able to update the open_stateid even though it 
>>>>>>> has a
>>>>>>> lower
>>>>>>> sequence number.
>>>>>>>
>>>>>>> I think this case could be handled by never updating the 
>>>>>>> open_stateid
>>>>>>> if the
>>>>>>> stateids match but the sequence number of the new state is less 
>>>>>>> than
>>>>>>> the
>>>>>>> current open_state.
>>>>>>>
>>>>>>
>>>>>> What kernel is this on?
>>>>>
>>>>> On v4.9-rc2 with a couple fixups.  Without them, I can't test long
>>>>> enough to
>>>>> reproduce this race.  I don't think any of those are involved in 
>>>>> this
>>>>> problem, though.
>>>>>
>>>>>>
>>>>>>
>>>>>> Yes, that seems wrong. The client should be picking B.2 for the 
>>>>>> open
>>>>>> stateid to use. I think that decision of whether to take a seqid 
>>>>>> is
>>>>>> made
>>>>>> in nfs_need_update_open_stateid. The logic in there looks 
>>>>>> correct to
>>>>>> me
>>>>>> at first glance though.
>>>>>
>>>>> nfs_need_update_open_stateid() will return true if NFS_OPEN_STATE 
>>>>> is
>>>>> unset.
>>>>> That's the precondition set up by steps 1-6.  Perhaps it should 
>>>>> not
>>>>> update
>>>>> the stateid if they match but the sequence number is less, and 
>>>>> still set
>>>>> NFS_OPEN_STATE once more.  That will fix _this_ case.  Are there 
>>>>> other
>>>>> cases
>>>>> where that would be a problem?
>>>>>
>>>>> Ben
>>>>
>>>> That seems wrong.
>>>
>>> I'm not sure what you mean: what seems wrong?
>>>
>>
>> Sorry, it seems wrong that the client would issue the LOCK with B.1
>> there.
>>
>>>>
>>>> The only close was sent in step 1, and that was for a
>>>> completely different stateid (A rather than B). It seems likely 
>>>> that
>>>> that is where the bug is.
>>>
>>> I'm still not sure what point you're trying to make..
>>>
>>> Even though the close was sent in step 1, the response wasn't 
>>> processed
>>> until step 6..
>>
>> Not really a point per-se, I was just saying where I think the bug 
>> might
>> be...
>>
>> When you issue a CLOSE, you issue it vs. a particular stateid 
>> (stateid
>> "A" in this case). Once the open stateid has been superseded by "B", 
>> the
>> closing of "A" should have no effect.
>>
>> Perhaps nfs_clear_open_stateid needs to check and see whether the 
>> open
>> stateid has been superseded before doing its thing?
>>
>
> Ok, I see something that might be a problem in this call in
> nfs4_close_done:
>
>        nfs_clear_open_stateid(state, &calldata->arg.stateid,
>                         res_stateid, 
> calldata->arg.fmode);
>
> Note that we pass two nfs4_stateids to this call. The first is the
> stateid that got sent in the CLOSE call, and the second is the stateid
> that came back in the CLOSE response.
>
> RFC5661 and RFC7530 both indicate that the stateid in a CLOSE response
> should be ignored.
>
> So, I think a patch like this may be in order. As to whether it will
> fix this bug, I sort of doubt it, but it might not hurt to test it 
> out?

Doesn't this undo the fix in 4a1e2feb9d24 ("NFSv4.1: Fix a protocol 
issue
with CLOSE stateids")?

I don't think it will help with the race either, since I think the issue 
is
that the race above unsets NFS_OPEN_STATE, then that is reason enough to
overwrite the existing open_state, even if it is going to overwrite with 
an
older stateid.  What close does with its stateid is unimportant to that
problem.

In the interest of science, I'll kick off a test with this patch.  It 
should
take a few hours to reproduce, but I'm also fairly busy today, so I'll
report back this evening most likely.   Thanks for the patch.

Ben

> ----------------------8<--------------------------
>
> [RFC PATCH] nfs: properly ignore the stateid in a CLOSE response
>
> Signed-off-by: Jeff Layton
> ---
>  fs/nfs/nfs4proc.c | 14 +++-----------
>  1 file changed, 3 insertions(+), 11 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7897826d7c51..58413bd0aae2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1451,7 +1451,6 @@ static void 
> nfs_resync_open_stateid_locked(struct nfs4_state *state)
>  }
>
>  static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
> -		nfs4_stateid *arg_stateid,
>  		nfs4_stateid *stateid, fmode_t fmode)
>  {
>  	clear_bit(NFS_O_RDWR_STATE, &state->flags);
> @@ -1467,12 +1466,8 @@ static void 
> nfs_clear_open_stateid_locked(struct nfs4_state *state,
>  		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
>  		clear_bit(NFS_OPEN_STATE, &state->flags);
>  	}
> -	if (stateid == NULL)
> -		return;
>  	/* Handle races with OPEN */
> -	if (!nfs4_stateid_match_other(arg_stateid, &state->open_stateid) ||
> -	    (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
> -	    !nfs4_stateid_is_newer(stateid, &state->open_stateid))) {
> +	if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
>  		nfs_resync_open_stateid_locked(state);
>  		return;
>  	}
> @@ -1482,11 +1477,10 @@ static void 
> nfs_clear_open_stateid_locked(struct nfs4_state *state,
>  }
>
>  static void nfs_clear_open_stateid(struct nfs4_state *state,
> -	nfs4_stateid *arg_stateid,
>  	nfs4_stateid *stateid, fmode_t fmode)
>  {
>  	write_seqlock(&state->seqlock);
> -	nfs_clear_open_stateid_locked(state, arg_stateid, stateid, fmode);
> +	nfs_clear_open_stateid_locked(state, stateid, fmode);
>  	write_sequnlock(&state->seqlock);
>  	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
>  		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
> @@ -3042,7 +3036,6 @@ static void nfs4_close_done(struct rpc_task 
> *task, void *data)
>  	struct nfs4_closedata *calldata = data;
>  	struct nfs4_state *state = calldata->state;
>  	struct nfs_server *server = NFS_SERVER(calldata->inode);
> -	nfs4_stateid *res_stateid = NULL;
>
>  	dprintk("%s: begin!\n", __func__);
>  	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
> @@ -3053,7 +3046,6 @@ static void nfs4_close_done(struct rpc_task 
> *task, void *data)
>  	 */
>  	switch (task->tk_status) {
>  		case 0:
> -			res_stateid = &calldata->res.stateid;
>  			if (calldata->roc)
>  				pnfs_roc_set_barrier(state->inode,
>  						     calldata->roc_barrier);
> @@ -3081,7 +3073,7 @@ static void nfs4_close_done(struct rpc_task 
> *task, void *data)
>  			}
>  	}
>  	nfs_clear_open_stateid(state, &calldata->arg.stateid,
> -			res_stateid, calldata->arg.fmode);
> +				calldata->arg.fmode);
>  out_release:
>  	nfs_release_seqid(calldata->arg.seqid);
>  	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
> -- 
> 2.9.3
>
