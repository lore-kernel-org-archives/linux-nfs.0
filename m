Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:40050 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab3J3OKX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 10:10:23 -0400
Received: by mail-wi0-f169.google.com with SMTP id cb5so6449119wib.4
        for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2013 07:10:22 -0700 (PDT)
Message-ID: <5271134C.1080607@primarydata.com>
Date: Wed, 30 Oct 2013 16:10:20 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] nfsd4: hash deleg stateid only on successful nfs4_set_delegation
References: <526F81DE.6060704@primarydata.com> <1383039561-27308-1-git-send-email-bhalevy@primarydata.com> <20131029155427.GU31322@fieldses.org>
In-Reply-To: <20131029155427.GU31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-29 17:54, J. Bruce Fields wrote:
> On Tue, Oct 29, 2013 at 11:39:21AM +0200, Benny Halevy wrote:
>> We don't want the stateid to be found in the hash table before the delegation
>> is granted.
> 
> With all this code and any find_stateid calls under the state lock, this
> isn't currently an issue, right?

Right.

> 
> The changelog needs to make clear whether this is fixing a current bug
> or preparing to allow dropping of the state lock somewhere.  If the
> latter, it needs to outline what the expected change is that we're
> preparing for.

Agreed.  We can delay this patch to the state lock elimination series.

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 405649f..64fcdd6 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -375,7 +375,6 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
>>  	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
>>  	if (dp == NULL)
>>  		return dp;
>> -	dp->dl_stid.sc_type = NFS4_DELEG_STID;
>>  	/*
>>  	 * delegation seqid's are never incremented.  The 4.1 special
>>  	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
>> @@ -3079,6 +3078,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
>>  	atomic_inc(&fp->fi_delegees);
>>  	hash_delegation_locked(dp, fp);
>>  	spin_unlock(&recall_lock);
>> +	dp->dl_stid.sc_type = NFS4_DELEG_STID;
>>  	return 0;
>>  out_free:
>>  	put_nfs4_file(fp);
>> -- 
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
