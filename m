Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59305 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750946Ab0IHBd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 21:33:58 -0400
Message-ID: <4C86E7FA.7020701@cn.fujitsu.com>
Date: Wed, 08 Sep 2010 09:33:46 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
References: <4C592F85.8070308@cn.fujitsu.com>	 <4C59306A.9090302@cn.fujitsu.com>	 <1280925913.3011.23.camel@heimdal.trondhjem.org>	 <4C5A213F.9000506@cn.fujitsu.com>	 <1281013423.2948.1.camel@heimdal.trondhjem.org>	 <4C5B8B48.4050008@cn.fujitsu.com>	 <1281101448.3586.11.camel@heimdal.trondhjem.org>	 <4C68EDAE.5000201@cn.fujitsu.com>	 <1282087012.18385.30.camel@heimdal.trondhjem.org>	 <4C7DF56B.3040206@cn.fujitsu.com> <1283897068.9097.15.camel@heimdal.trondhjem.org>
In-Reply-To: <1283897068.9097.15.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>>> OK. I see agree that is a race, but AFAICS, your fix means that we end
>>> up with an nfs_state structure that has cleared NFS_DELEGATED_STATE, but
>>> that did not recover its open stateid.
>>>
>> Hi trond, what do you think about this one?
> 
> Hi Bian,
> 
> See comments/questions below.
> 

  Thanks for your answer.

>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 36400d3..c0c0320 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -900,8 +900,18 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
>>  
>>  	rcu_read_lock();
>>  	deleg_cur = rcu_dereference(nfsi->delegation);
>> -	if (deleg_cur == NULL)
>> +	if (deleg_cur == NULL) {
>> +		if (delegation == NULL &&
>> +		    test_bit(NFS_DELEGATED_STATE, &state->flags)) {
> 
> Any reason why we can't ditch the 'test_bit'?
> 

  Because i am not sure it's ok that we just clear_bit at here.
  If you think it's ok, i'd be fine with removing this test_bit.

>> +			/*FIXME: If the state has NFS_DELEGATED_STATE bit, 
>> +			 * we catch a race. Maybe should recover its open
>> +			 * stateid, here we just clear the NFS_DELEGATED_STATE
>> +			 * bit.
> 
> Can this ever be called with both deleg_cur==NULL and
> open_stateid==NULL? If so, then we still have a bug.
> 

  Yes, i will add a checking. Thanks very much.

>> +			 */
>> +			clear_bit(NFS_DELEGATED_STATE, &state->flags);
>> +		}
>>  		goto no_delegation;
>> +	}
>>  
>>  	spin_lock(&deleg_cur->lock);
>>  	if (nfsi->delegation != deleg_cur ||


-- 
Regards
Bian Naimeng

