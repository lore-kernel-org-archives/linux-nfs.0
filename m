Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:10538 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbdGaNCe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Jul 2017 09:02:34 -0400
Subject: Re: [RFC PATCH] NFS: Fix the access mask checks in NFSv4
To: Catalin Marinas <catalin.marinas@arm.com>,
        <linux-nfs@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <20170728175452.49057-1-catalin.marinas@arm.com>
 <20170731111928.g6rlpmwnn57hcexb@armageddon.cambridge.arm.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <a977bcf7-3e9f-49dc-fd65-7526aff6d569@Netapp.com>
Date: Mon, 31 Jul 2017 09:02:28 -0400
MIME-Version: 1.0
In-Reply-To: <20170731111928.g6rlpmwnn57hcexb@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Catalin,

On 07/31/2017 07:19 AM, Catalin Marinas wrote:
> Anna, Trond,
> 
> On Fri, Jul 28, 2017 at 06:54:52PM +0100, Catalin Marinas wrote:
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2236,7 +2236,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
>>  				int openflags)
>>  {
>>  	struct nfs_access_entry cache;
>> -	u32 mask;
>> +	int mask, cache_mask;
>>  
>>  	/* access call failed or for some reason the server doesn't
>>  	 * support any access modes -- defer access call until later */
>> @@ -2259,7 +2259,8 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
>>  	nfs_access_set_mask(&cache, opendata->o_res.access_result);
>>  	nfs_access_add_cache(state->inode, &cache);
>>  
>> -	if ((mask & ~cache.mask & (MAY_READ | MAY_EXEC)) == 0)
>> +	cache_mask = nfs_access_calc_mask(cache.mask, state->inode->i_mode);
>> +	if ((mask & ~cache_mask & (MAY_READ | MAY_EXEC)) == 0)
>>  		return 0;
>>  
>>  	return -EACCES;
> 
> I noticed -rc3 already has a fix here, commit 1e6f209515a0 ("NFS: Use
> raw NFS access mask in nfs4_opendata_access()"), without having to
> export nfs_access_calc_mask().
> 
>> @@ -3870,25 +3871,9 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
>>  		.rpc_resp = &res,
>>  		.rpc_cred = entry->cred,
>>  	};
>> -	int mode = entry->mask;
>>  	int status = 0;
>>  
>> -	/*
>> -	 * Determine which access bits we want to ask for...
>> -	 */
>> -	if (mode & MAY_READ)
>> -		args.access |= NFS4_ACCESS_READ;
>> -	if (S_ISDIR(inode->i_mode)) {
>> -		if (mode & MAY_WRITE)
>> -			args.access |= NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE;
>> -		if (mode & MAY_EXEC)
>> -			args.access |= NFS4_ACCESS_LOOKUP;
>> -	} else {
>> -		if (mode & MAY_WRITE)
>> -			args.access |= NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND;
>> -		if (mode & MAY_EXEC)
>> -			args.access |= NFS4_ACCESS_EXECUTE;
>> -	}
>> +	args.access = entry->mask;
> 
> However, AFAICT, 'entry->mask' already uses the NFS4_* bits, so checking
> 'mode' against MAY_READ etc. to build up args.access is incorrect. Is
> this hunk still needed?
> 

I think the code is okay short term, because all the bits it's checking against are set in entry->mask whenever we enter this function.  Long term, yes it should be updated.  I have patches to do this in a generic way that can be used for both NFS v3 and NFS v4, but they'll probably go into 4.14

Thanks,
Anna
