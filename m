Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52280 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab0IIB3x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 21:29:53 -0400
Message-ID: <4C883883.7070803@cn.fujitsu.com>
Date: Thu, 09 Sep 2010 09:29:39 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
References: <4C592F85.8070308@cn.fujitsu.com>	 <4C59306A.9090302@cn.fujitsu.com>	 <1280925913.3011.23.camel@heimdal.trondhjem.org>	 <4C5A213F.9000506@cn.fujitsu.com>	 <1281013423.2948.1.camel@heimdal.trondhjem.org>	 <4C5B8B48.4050008@cn.fujitsu.com>	 <1281101448.3586.11.camel@heimdal.trondhjem.org>	 <4C68EDAE.5000201@cn.fujitsu.com>	 <1282087012.18385.30.camel@heimdal.trondhjem.org>	 <4C7DF56B.3040206@cn.fujitsu.com>	 <1283897068.9097.15.camel@heimdal.trondhjem.org>	 <4C86E7FA.7020701@cn.fujitsu.com>	 <1283911036.16070.1.camel@heimdal.trondhjem.org>	 <4C86FECF.2050103@cn.fujitsu.com> <1283978245.2905.23.camel@heimdal.trondhjem.org>
In-Reply-To: <1283978245.2905.23.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> index 089da5b..f7e45b4 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -919,8 +919,18 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
>>  
>>  	rcu_read_lock();
>>  	deleg_cur = rcu_dereference(nfsi->delegation);
>> -	if (deleg_cur == NULL)
>> +	if (deleg_cur == NULL) {
>> +		if (delegation == NULL && open_stateid != NULL) {
> 
> Well... What I really meant was that we should make sure that we don't
> get into this situation.
> 

  Thanks very much for your explainning.

> I think the clear_bit() should be unconditional if delegation == NULL,

  en..., i have a question.

  If the (deleg_cur == NULL && delegation == NULL) occured, that means
  there are not any delegation at this nfs_inode, i think this state
  do not need a NFS_DELEGATED_STATE bit anymore, is it right?

> but if the (delegation == NULL && open_stateid == NULL) _can_ occur,
> then we should probably mark the nfs4_state for recovery using
> nfs4_state_mark_reclaim_nograce(), and then fire of a recovery thread.
> 

  It looks like that (delegation == NULL && open_stateid == NULL) can not
  occur at our kernel.

  And..., would you tell me  why we must start recovery with using
  nfs4_state_mark_reclaim_nograce,  are there any hint tell us that this
  state has expired ?

-- 
Regards
Bian Naimeng

>> +			/*
>> +			 * FIXME: If the state has NFS_DELEGATED_STATE bit
>> +			 * we catch a race. Maybe should recover its open
>> +			 * stateid, now we just clear the NFS_DELEGATED_STATE
>> +			 * bit.
>> +			 */
>> +			clear_bit(NFS_DELEGATED_STATE, &state->flags);
>> +		}
>>  		goto no_delegation;
>> +	}
>>  
>>  	spin_lock(&deleg_cur->lock);
>>  	if (nfsi->delegation != deleg_cur ||
>> -- 
>> 1.7.0

-- 
Regards
Bian Naimeng

