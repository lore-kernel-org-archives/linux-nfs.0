Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793756721;
	b=ttFlVEJ1yWSwpcuAKqe0TiLuQLGzv0vCSDCkXc4cHaloxU3L0wG5deU5Qsxj6j9dHGjP
	 AtIkY9t16SgEbwtATbno7Sue2mdQiPL/KorvKhIYBPN/kX0abPWMb1iNAW5xGN+ljK+gX
	 OjdbXxD0jaIdSOS2nzPJYxF0mV5EINDI2d1r9TAZLcsTwKo/Nv7a049Ym5kpi3dDH6qIQ
	 dKVX3fpZuzAahHx1kJVZYs0bet1x2ZZw5t2TAnUNzXdHO9f0Gb9Kcj13qBKj1iZFdLWxA
	 eB1+N4Pa2z9XiiE2Z+N9rX4kxgGqDHcXov1ZL77NaFBDhD07LuXsd0bGLMjPE4RODyQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793756721;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=Yu7A9IfCons4QnPv1aLDZ6F+N4gkwUfnVBA3JUeiHFk=;
	b=C3jYQPkDxBfT1De5yotagxP1KRrLpS/YWQqoTeTWU1ndkYOo8puJ2MGRzwW8gs9B/Mcw
	 ksLwUPUWXJofRDo9fUHuI6IAxvTTnfKrCgklFhMGYVe1kqwnCYjXUf+4nUC4Ib3OXd+tk
	 9+ThTA9g9a+d7pVkKBi83828g2S8uUvpJ6avaAhmgBqVcltCdhljUeLdkLI7C6gNrivLU
	 rU8YSNgmCFj5nI5PP5MYVH0TK6kzlqF762l/JbiwTe6qIa3H8drizexvZJmnhxTrR4nRk
	 IlAIHRdJtfLb1mnR7i1V++dSCH/aiYEAht7Yn/1lepDR89zEl4I8xgFUz3qJ1hk1M1Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=IbycN2wi;
	arc=none smtp.remote-ip=115.124.30.98
Received: from out30-98.freemail.mail.aliyun.com (out30-98.freemail.mail.aliyun.com [115.124.30.98])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E536C606A328;
	Wed,  4 Nov 2026 01:45:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E536C606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=IbycN2wi
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793756717; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=Yu7A9IfCons4QnPv1aLDZ6F+N4gkwUfnVBA3JUeiHFk=;
	b=IbycN2wiHbBLY8b7g8Mj3PbaRtQ9MiA+qd19HIv4OrvXt7hLs85bF0+SCFGHBFP96fJkLLeD9n1YedeMfu0MblNwgmtrGIIfVKcd0uDytvy9XUnSJ/SbfvoJPXmk9OYKK9A3wdWTRQekMrrm1zdwVtL4vLCnD6gTLDvPuSoz1og=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037026112;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0XE4Irvx_1793756716;
Received: from 30.221.129.178(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0XE4Irvx_1793756716 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 04 Nov 2026 09:45:17 +0800
Message-ID: <50188292-83d9-4721-8f1f-76e4759ddb80@linux.alibaba.com>
Date: Wed, 4 Nov 2026 09:45:16 +0800
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] NFS: don't raise i_size for DEALLOCATE in
 _nfs42_proc_fallocate()
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
 <0c67f568-586b-456a-be28-65d2ea16b633@app.fastmail.com>
From: Joseph Qi <joseph.qi@linux.alibaba.com>
In-Reply-To: <0c67f568-586b-456a-be28-65d2ea16b633@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi,

On 11/4/26 4:11 AM, Anna Schumaker wrote:
> Hi Joseph,
> 
> On Tue, Nov 3, 2026, at 1:16 AM, Joseph Qi wrote:
>> _nfs42_proc_fallocate() raises i_size to offset + len on success, so
>> that the cached size is not left stale when a delegation blocks the
>> post-op attribute refresh.  The helper is shared by all three
>> fallocate modes, but DEALLOCATE always carries FALLOC_FL_KEEP_SIZE
>> and never extends the file on the server, so punching a hole that
>> reaches past EOF now wrongly enlarges the cached i_size.
>>
>> The post-op update would normally restore the size from the returned
>> attributes, but nfs_update_inode() applies a differing size only when
>> no delegation is held, and then only when no write is in flight or the
>> new size is larger:
>>
>> 	if (new_isize != cur_isize && !have_delegation) {
>> 		if (!nfs_have_writebacks(inode) || new_isize > cur_isize)
>> 			i_size_write(inode, new_isize);
>> 	}
>>
>> With a concurrent mmap writer (nrequests != 0) or any outstanding
>> delegation, the shrinking server size is therefore ignored and the
>> client keeps reporting a file larger than the server has, in violation
>> of KEEP_SIZE, until some later revalidation without writebacks happens
>> to fix it up.
>>
>> Skip the i_size bump for the DEALLOCATE procedure.  ALLOCATE (mode 0)
>> and ZERO_RANGE (which nfs42_fallocate() accepts only without
>> FALLOC_FL_KEEP_SIZE) do extend the file when the range reaches past
>> EOF, so they keep the update.
>>
>> Fixes: 35168eb947f2 ("NFS: fix eof updates after NFSv4.2 fallocate/zero-range")
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
>> ---
>>  fs/nfs/nfs42proc.c | 11 ++++++++++-
>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index ab86246fc364f..914499d30d47e 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -84,7 +84,16 @@ static int _nfs42_proc_fallocate(struct rpc_message 
>> *msg, struct file *filep,
>>  		loff_t newsize = offset + len;
>>
>>  		spin_lock(&inode->i_lock);
>> -		if (newsize > i_size_read(inode))
>> +		/*
>> +		 * DEALLOCATE always carries FALLOC_FL_KEEP_SIZE and never
>> +		 * extends the file on the server, so only ALLOCATE and
>> +		 * ZERO_RANGE may raise i_size here.  A wrongly raised size
>> +		 * can persist: nfs_update_inode() ignores a shrinking
>> +		 * post-op size while writebacks are outstanding or a
>> +		 * delegation is held.
>> +		 */
> 
> Is the comment really necessary? It's just restating things from the commit
> message, and could quickly go stale if the behavior of nfs_update_inode()
> ever needs to change in the future.
> 

Thanks for reviewing this.
So any review comments on the code change? I'll update the comments and
send v2 if you're fine with fix.

Thanks,
Joseph


