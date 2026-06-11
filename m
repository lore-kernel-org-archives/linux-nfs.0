Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55EBB3537C8
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2026 13:34:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781184848; cv=none; b=Z6Ft9HJSezynxK0Eq2zbYQYLX1boTEImouhfwujQ483nG5dgaBNxzG3uFS6mOJcOmQRguNi9B8NHGjlmTSMWJ2xc7MR2w+IzW5GGP0+axkzttNHyAKi9rqfeyDFKbJFdk0FhLWFXJveZpd2Mh+33oVWJ6nhdOG3bvUl39K8+DyQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781184848; c=relaxed/simple;
	bh=Zh5Lq5SIdBw8uswK/awBUg+R6JWgir7BRFs4wXffPu8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=J7frwce1z8SEWmbfGguNxxDijZF+9WGS51BpUNiLQ1ZPqc22ld6InoBjjOJJZZq4IG60asQIjHzntlM4xQP72xfNQ0Xgv9LFt9ztwMt9RJku3dWxGpsAVYkQg2Ypkvorsl6U8U0jyUcL1QqEWJhNlFOgBSLEkHGRRNhrt64JDmo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kA2ymodR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kA2ymodR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 26EB31F00893;
	Thu, 11 Jun 2026 13:34:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781184845;
	bh=YrCaXLRjMbPT/r0saqerFdBuaSUjjExOi7v0xlzL/sk=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=kA2ymodROs2MRharD4HtUd00ISGEg0sLs8LkD7r8xJqC3Soc6hynFeIu080+F352Q
	 gorXnraKP5B/Ed8XFjEhVcI4Pyn2VEw8C8l0uv84dPpZBIn8OHhAlBSpKm/qz0MQbt
	 4iaHw2KWh/+7CvsLn35bhjBc9J3+/28DhJwSluJnJZLBkxAhyMDuUWo47808DF2wjM
	 RFtYE6bdh66qOrmmnwz1WWplvD5wGw7ctJnQ7JFhP9pKMpCAvLsElFAYgx4fRKm9sv
	 GdOMd01wkVKQUfO34RCy1UTXs+xDaX7T72sp4SOny3nEGpNAyQkUVO4JylrpR8yGSU
	 0V+Ox19PpLHNQ==
Message-ID: <3ee10d50-d6e2-40a5-86f8-915e1a17656d@kernel.org>
Date: Thu, 11 Jun 2026 09:34:04 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 4/5] NFSD: Document and rename the NFSv4.1 session slot
 shrinker callbacks
To: NeilBrown <neil@brown.name>
Cc: Jeff Layton <jlayton@kernel.org>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Benjamin Coddington <bcodding@hammerspace.com>,
 Jonathan Flynn <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org,
 Chuck Lever <chuck.lever@oracle.com>
References: <20260610-nfsd-slot-growth-clamp-v1-0-7b966700df0b@kernel.org>
 <20260610-nfsd-slot-growth-clamp-v1-4-7b966700df0b@kernel.org>
 <178114882392.3002522.3941860594407359120@noble.neil.brown.name>
From: Chuck Lever <cel@kernel.org>
Content-Language: en-US
Organization: kernel.org
In-Reply-To: <178114882392.3002522.3941860594407359120@noble.neil.brown.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 6/10/26 8:33 PM, NeilBrown wrote:
> On Thu, 11 Jun 2026, Chuck Lever wrote:
>> Clean up: To prevent their reuse by generic code, rename the NFSv4.1
>> session slot shrinker's callback functions to make it clear they are
>> for use only by the shrinker.
>>
>> Though they are static, callbacks are invoked from outside nfsd.ko,
>> so they need appropriate kdoc comments that document their API
>> contracts.
>>
>> Signed-off-by: Chuck Lever <cel@kernel.org>
>> ---
>>  fs/nfsd/nfs4state.c | 36 ++++++++++++++++++++++++++++++++----
>>  1 file changed, 32 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 9735e9a59f0e..7ce8462e3697 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2196,22 +2196,50 @@ static void free_session(struct nfsd4_session *ses)
>>  	__free_session(ses);
>>  }
>>  
>> +/**
>> + * nfsd_slot_shrinker_count - report reclaimable DRC slots
>> + * @s: shrinker descriptor (unused)
>> + * @sc: shrink control (unused)
>> + *
>> + * Return: a positive count of reclaimable slots, or SHRINK_EMPTY when
>> + * there is nothing to reclaim.
> 
> I would add to this comment and note that slot zero is not reclaimable,
> so that the subtraction of nfsd_total_sessions is explained.
> 
> But either way:
> 
> Reviewed-by: NeilBrown <neil@brown.name>
> 
> and you can add that to all patches in series.  A definite improvement!

Thanks for the look. I'll address your specific comments before
applying these to nfsd-testing.


> Thanks,
> NeilBrown
> 
> 
>> + */
>>  static unsigned long
>> -nfsd_slot_count(struct shrinker *s, struct shrink_control *sc)
>> +nfsd_slot_shrinker_count(struct shrinker *s, struct shrink_control *sc)
>>  {
>>  	int cnt = atomic_read(&nfsd_total_target_slots) -
>>  		  atomic_read(&nfsd_total_sessions);
>>  
>> +	/*
>> +	 * To prevent deadlock, one slot of each session (slot 0) is
>> +	 * not reclaimable while the session is active. Thus the
>> +	 * number of sessions is subtracted from the total number of
>> +	 * target slots.
>> +	 */
>>  	return cnt > 0 ? cnt : SHRINK_EMPTY;
>>  }
>>  
>> +/**
>> + * nfsd_slot_shrinker_scan - reclaim DRC slots under memory pressure
>> + * @s: shrinker descriptor (unused)
>> + * @sc: shrink control; @sc->nr_to_scan bounds the sessions visited,
>> + *      @sc->nr_scanned reports how many were visited
>> + *
>> + * Return: the number of session slots NFSD will release.
>> + */
>>  static unsigned long
>> -nfsd_slot_scan(struct shrinker *s, struct shrink_control *sc)
>> +nfsd_slot_shrinker_scan(struct shrinker *s, struct shrink_control *sc)
>>  {
>>  	struct nfsd4_session *ses;
>>  	unsigned long scanned = 0;
>>  	unsigned long freed = 0;
>>  
>> +	/*
>> +	 * Each visited session releases at most one slot. After
>> +	 * nr_to_scan sessions have been visited, the list head is
>> +	 * rotated past the last visited session so the next scan
>> +	 * resumes from there.
>> +	 */
>>  	spin_lock(&nfsd_session_list_lock);
>>  	list_for_each_entry(ses, &nfsd_session_list, se_all_sessions) {
>>  		freed += reduce_session_slots(ses, 1);
>> @@ -9120,8 +9148,8 @@ nfs4_state_start(void)
>>  		rhltable_destroy(&nfs4_file_rhltable);
>>  		return -ENOMEM;
>>  	}
>> -	nfsd_slot_shrinker->count_objects = nfsd_slot_count;
>> -	nfsd_slot_shrinker->scan_objects = nfsd_slot_scan;
>> +	nfsd_slot_shrinker->count_objects = nfsd_slot_shrinker_count;
>> +	nfsd_slot_shrinker->scan_objects = nfsd_slot_shrinker_scan;
>>  	shrinker_register(nfsd_slot_shrinker);
>>  
>>  	set_max_delegations();
>>
>> -- 
>> 2.54.0
>>
>>
>>
> 


-- 
Chuck Lever
