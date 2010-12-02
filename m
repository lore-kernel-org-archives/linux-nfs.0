From: Li Yewang <lyw@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
Date: Thu, 02 Dec 2010 16:32:15 +0800
Message-ID: <4CF7598F.2090008@cn.fujitsu.com>
References: <4C592F85.8070308@cn.fujitsu.com>	 <4C59306A.9090302@cn.fujitsu.com>	 <1280925913.3011.23.camel@heimdal.trondhjem.org>	 <4C5A213F.9000506@cn.fujitsu.com>	 <1281013423.2948.1.camel@heimdal.trondhjem.org>	 <4C5B8B48.4050008@cn.fujitsu.com>	 <1281101448.3586.11.camel@heimdal.trondhjem.org>	 <4C68EDAE.5000201@cn.fujitsu.com>	 <1282087012.18385.30.camel@heimdal.trondhjem.org>	 <4C7DF56B.3040206@cn.fujitsu.com>	 <1283897068.9097.15.camel@heimdal.trondhjem.org>	 <4C86E7FA.7020701@cn.fujitsu.com>	 <1283911036.16070.1.camel@heimdal.trondhjem.org>	 <4C86FECF.2050103@cn.fujitsu.com> <1283978245.2905.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Bian Naimeng <biannm@cn.fujitsu.com>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52511 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab0LBIdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 03:33:06 -0500
In-Reply-To: <1283978245.2905.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi Trond

    Do you have plan to fix this bug.
    Because our custom want to solve it.

    If you have any comment or advice please let us know.

    thank you.


At 2010-9-9 4:37, Trond Myklebust wrote:
> On Wed, 2010-09-08 at 11:11 +0800, Bian Naimeng wrote:
>> If there are not any delegation at this inode, we should clear stateid's
>> NFS_DELEGATED_STATE when update it.
>>
>> Signed-off-by: Bian Naimeng<biannm@cn.fujitsu.com>
>>
>> ---
>>   fs/nfs/delegation.c |    1 +
>>   fs/nfs/nfs4proc.c   |   12 +++++++++++-
>>   2 files changed, 12 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>> index b9c3c43..62f296e 100644
>> --- a/fs/nfs/delegation.c
>> +++ b/fs/nfs/delegation.c
>> @@ -106,6 +106,7 @@ again:
>>   			continue;
>>   		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
>>   			continue;
>> +		clear_bit(NFS_DELEGATED_STATE,&state->flags);
>>   		get_nfs_open_context(ctx);
>>   		spin_unlock(&inode->i_lock);
>>   		err = nfs4_open_delegation_recall(ctx, state, stateid);
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 089da5b..f7e45b4 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -919,8 +919,18 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
>>
>>   	rcu_read_lock();
>>   	deleg_cur = rcu_dereference(nfsi->delegation);
>> -	if (deleg_cur == NULL)
>> +	if (deleg_cur == NULL) {
>> +		if (delegation == NULL&&  open_stateid != NULL) {
>
> Well... What I really meant was that we should make sure that we don't
> get into this situation.
>
> I think the clear_bit() should be unconditional if delegation == NULL,
> but if the (delegation == NULL&&  open_stateid == NULL) _can_ occur,
> then we should probably mark the nfs4_state for recovery using
> nfs4_state_mark_reclaim_nograce(), and then fire of a recovery thread.
>
>> +			/*
>> +			 * FIXME: If the state has NFS_DELEGATED_STATE bit
>> +			 * we catch a race. Maybe should recover its open
>> +			 * stateid, now we just clear the NFS_DELEGATED_STATE
>> +			 * bit.
>> +			 */
>> +			clear_bit(NFS_DELEGATED_STATE,&state->flags);
>> +		}
>>   		goto no_delegation;
>> +	}
>>
>>   	spin_lock(&deleg_cur->lock);
>>   	if (nfsi->delegation != deleg_cur ||
>> --
>> 1.7.0
>>
>>
>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>> index 36400d3..c0c0320 100644
>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>> @@ -900,8 +900,18 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
>>>>>>
>>>>>>   	rcu_read_lock();
>>>>>>   	deleg_cur = rcu_dereference(nfsi->delegation);
>>>>>> -	if (deleg_cur == NULL)
>>>>>> +	if (deleg_cur == NULL) {
>>>>>> +		if (delegation == NULL&&
>>>>>> +		    test_bit(NFS_DELEGATED_STATE,&state->flags)) {
>>>>> Any reason why we can't ditch the 'test_bit'?
>>>>>
>>>>    Because i am not sure it's ok that we just clear_bit at here.
>>>>    If you think it's ok, i'd be fine with removing this test_bit.
>>>
>>> How is it different from just clearing the bit?
>>>
>>>>>> +			/*FIXME: If the state has NFS_DELEGATED_STATE bit,
>>>>>> +			 * we catch a race. Maybe should recover its open
>>>>>> +			 * stateid, here we just clear the NFS_DELEGATED_STATE
>>>>>> +			 * bit.
>>>>> Can this ever be called with both deleg_cur==NULL and
>>>>> open_stateid==NULL? If so, then we still have a bug.
>>>>>
>>>>    Yes, i will add a checking. Thanks very much.
>>>>
>>>>>> +			 */
>>>>>> +			clear_bit(NFS_DELEGATED_STATE,&state->flags);
>>>>>> +		}
>>>>>>   		goto no_delegation;
>>>>>> +	}
>>>>>>
>>>>>>   	spin_lock(&deleg_cur->lock);
>>>>>>   	if (nfsi->delegation != deleg_cur ||
>>>
>>> Cheers
>>>    Trond
>>>
>>>
>>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>

-- 
Regards
Li Yewang
--------------------------------------------------
Li Yewang
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
No. 6 Wenzhu Road, Nanjing, 210012, China
PHONE: +86+25-86630566-8507
COINS: 7998-8507
FAX: +86+25-83317685
MAIL: lyw@cn.fujitsu.com
--------------------------------------------------

