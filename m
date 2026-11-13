Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794605263;
	b=jx+cwRkTwaMDX17eKXXKTuUQop2asY/+BlZXfulAVXoFXcmSP+L7SeGCbBkGxeayRAui
	 NO2G53kYOoCfGlJ9i7fMlkz132FWpVDiPmjehrG8p6L8rxiL5jU5wf/abLIeC7RGWc7qW
	 oQSxqzhO2QRe0PmGK7pDPVeVG0t5m6BvXLTMadoTOz3chWG1staTgaI+eI9u9GY57Cdpb
	 AzOfH7Pk0VdaOgO+mxcOqYyACBemLJVF60pGI+stEysRA7+ud0feVHkU6pdpmLmnpdsLG
	 EQPM0NPayH7aQijH8zwQwXEnVmCJJFjUTJ1Y4FPKuI/k0aFan4H/Q/dVayukKXB7HlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794605263;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=bS0DvVihlvNRN9WIlzdJdEPONCUIAgdEli9+Mryd+mo=;
	b=CCqPdDWSQx2m33CvW4eAe/vIMMaYGHGVRY66ZQ6aT5KbYN7o41nCJBnQ+CT/Je0rPCNY
	 OB8AhhzUNsQBlN+/fR+QPz9Bh5ZRXDFuaAbzVKNXXdkZwRzGkXkAmCX2SVKVa3FiPD/hn
	 RaYapuwND7BgE0t4ymdSGw9nUZ4aBIRFOkFb7lETqpLNCwNyKYxehXQ80dietuK/xMy+9
	 XXe2Pk47/tEyJeCMsfqwLa0JXMiwFutyQ+cQPPBbAdI/hyx6667zSUs6X/S6lTrfXMIUl
	 mTvxC9ulAUKkrxpsZ46EJpUYh26WAp2/Wj6i1Y3WJvthdzw0HnFPfH2Y4k/vhKEiDdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KZFrc+qh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD0A9606A337;
	Fri, 13 Nov 2026 21:27:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KZFrc+qh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 66C881F000C5;
	Fri, 13 Nov 2026 21:27:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794605263;
	bh=bS0DvVihlvNRN9WIlzdJdEPONCUIAgdEli9+Mryd+mo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=KZFrc+qhzGnDmBgFj+CYBKgjH7r3dpiz5Jwc+6C7MoWmT1vxk0aiItMi2LHnvZrJk
	 i9D/uL/7iMya3boS8csJQEl0IIPMD3C5lgjxljA/KS9sBEbUoVqR+hjHxBxo8CG75T
	 zegOLncCwKA2dElmKOVMRgfPFiaQGG8bvIMoWcNY/NogQ1MZXCsYC9UQqAr9Jd4l85
	 7/uLM/M5Kpn/U02INudadMKtIPGex1G+RV/R3Eo7/OgjvpuNxPCoEh2ReA6PHYPH15
	 hrJaN3N1NwkBOr8aD7LmYskgsDlzZdYA1yjQ3IqJ0xCJ+ZuZPwLj5bpE7s30I2u+fZ
	 8dksaFNJoRI9g==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id B5BD9F4006B;
	Fri, 13 Nov 2026 16:27:42 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 13 Nov 2026 16:27:42 -0500
X-ME-Sender: <xms:zoD3au34q9rLngOFq1UZipnq6JzHb0rItvsMVbCxSnDyfoI2vmcRhg>
    <xme:zoD3ar6-6HgNt5KDYYTJkCDa3-txfvQnyLQ8qJTmwjblI2VEUggcy_XdfJgql5F-l
    STgtK8Ss3Mtmx4yQlAW4ww-xJv9JTkfloKiyAO7lnA8XVfN5OuFqULC>
X-ME-Proxy-Cause: dmFkZTFWafa0NwuTL3mJyKkEAzbTO2EdmlJQ2pSARNrb/AmwEAzXufhcrGQ5UC/hDzDRJS
    Ytg0t4a/OwnSZZXtvz8v0LiGhh2ACpENncOHjob/iYD+08xgOhchN/yYhFVef8aTTeSnB1
    VbAss/4uVioXNC8GQLgCglxinSo6O/eZzu14h3ZIjekrc+KsztidVGeob4LqcZSpwwkJow
    NuOl0C5Lhgv0Q1s4LtHGyhKqA4quDzaRcE4VRYsqjQ/hBB4BE9m+BozyIUH1JjUjx64B4q
    acDSKs0n4sJ9IuJPXAuH8/DyFB7zVMET1LhTQobbeoGhApHgtVUsoTWTl2YQWSrgdbaNQc
    npmitT5+ilUvXS542xdKEVAb4he4NGfqKMCZo/s6T5k8JX7VAEocnCvtvXWSPfhCZAw94O
    M9oPCyuSc9rsfi7UIbdtPgBqokAj/jat5pUR9+UC4A6NSVq7XBolsF2PSGxMAWnWolBmSy
    LFRMFH2KAlLlbNgykBuQHDJ+qa9qTPo3nQx64kqwS1h2T6ecri47TtLAyQQBUguRMKAsSY
    C/aAzh9VKfjbgBe1+oKgy8zJVELGp3nRs3zeAQPtWVAa7iP6OwyPNrzMzdj57CRlXedoYr
    77IX8Ir/Pe4swQQ1B4p3TUESgGCK/i6oojOLktsd/iw2FDOHHbuhHIVliEUA
X-ME-Proxy: <xmx:zoD3asi4D8xmE_R1d76vJRCeh8iQOg4Btop4JE-dhfZm4RUdgkrZ_Q>
    <xmx:zoD3auXMAq-s3wCSR4wTCokGOqn1Hwo3z2lhflxLAgyJPrWDh_sqVg>
    <xmx:zoD3arXK2Od35zzxnLxfI9-uMdCneSDe2TfqsGEePM--U9HyLyW46g>
    <xmx:zoD3augLeeFnhMKUWkmM6gYoFhwcud5YJqu0yvHjzsNk0wBcazVhag>
    <xmx:zoD3amb4JPmCtIEcRo9WFLhSJYK6uCvA1dXpSDMEh0jPXIqAsXKKxU8G>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 95307B6006E; Fri, 13 Nov 2026 16:27:42 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AOJsgsVqV2Ts
Date: Fri, 13 Nov 2026 16:27:22 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Joseph Qi" <joseph.qi@linux.alibaba.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
Message-Id: <1e807af5-e5f0-4a02-8e3a-312f4d394669@app.fastmail.com>
In-Reply-To: <4f83b93d-3173-4e04-9b79-df2413c3be18@linux.alibaba.com>
References: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
 <20261109113244.4136089-1-joseph.qi@linux.alibaba.com>
 <4f83b93d-3173-4e04-9b79-df2413c3be18@linux.alibaba.com>
Subject: Re: [PATCH v2] NFS: don't raise i_size for DEALLOCATE in
 _nfs42_proc_fallocate()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Joseph,

On Thu, Nov 12, 2026, at 8:02 PM, Joseph Qi wrote:
> Ping...

I have this patch applied to a private branch for my own testing and it
seems okay to me so far. I'm planning to test with it for a bit before
sending it in to a v7.4-rc.

Anna

>
> On 11/9/26 7:32 PM, Joseph Qi wrote:
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
>>  fs/nfs/nfs42proc.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index ab86246fc364f..d76bface87f74 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -84,7 +84,9 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
>>  		loff_t newsize = offset + len;
>>  
>>  		spin_lock(&inode->i_lock);
>> -		if (newsize > i_size_read(inode))
>> +		/* DEALLOCATE implies KEEP_SIZE, so don't extend i_size */
>> +		if (msg->rpc_proc != &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE] &&
>> +		    newsize > i_size_read(inode))
>>  			i_size_write(inode, newsize);
>>  		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
>>  		if (nfs_should_remove_suid(inode))
