Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795046191;
	b=DDj7krn+V8LltQDCg0MT3JafwSflMq4q0xq+e1INORQkt9UaqTrTa14AB5zsbbjETBBq
	 kTC0+o7WdnIfi9RCx0dm8nPGHX0667IyVqZQrR1X6KrwO1aLVqKZJ3zWc3E9EfXC3/nfx
	 3hPPqTFOgVKXBWZ/ihrL4gTUU/f34FgSaAmLB1NugsQB2iZtXxkTmmtQ5ux5R2kpijrxT
	 hCYZkzEVffYCh/ISnKfrPp6BsCa5Nap6Db2GOO+QfsF1TTyF8UW+nL/8T6kf29OO1+dQe
	 FQJXt0pkqaYJM/VR4xirBVG3u4wnd6Jc20/+Klc/5u0LmuuYN4Gt3qOFG42D7N69sjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795046191;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=fWb/KlwmWqUKlchoe6fMQgzivFC2C/Re0xgS0ZD5es4=;
	b=BGq1UV/wtVC7UPhw7l6EetKewBIEyrHQJT8U3tMNkJ8Xa1+cCCfSEYoGL1a1qIJ1K8nq
	 b6Vsc1VyQLVjHP/Phd8FsPfpDUQrpspmf2EjkNx68CmcYrGMaR9rN/X0ZDrFkRHkJeMLE
	 GhMwZlSkJFaRCwmBC3p4WE+wErQQ1ZffCLoMzPCQ5YejwtK051Tb0tDKJWD2Bi8wwrDqN
	 VPRl6dZI/qR20PM8fE9Bn4qQhwD3mwhmGpFiVJy78rAOluGmHqhjXxYKpNYtwh4tepW+L
	 vNP4dYcLwNCe+j0Z59Zvp2LacfrYslJ5dHMha85e03I+KxlhWMV6D9VSnrg48gBhjyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HIiYU0v6;
	arc=none smtp.remote-ip=209.85.160.47
Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE517606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:56:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AE517606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HIiYU0v6
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-4ad89c49e0dso575083fac.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 15:56:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795046189; x=1795650989; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fWb/KlwmWqUKlchoe6fMQgzivFC2C/Re0xgS0ZD5es4=;
        b=HIiYU0v6hj8CnwMzOSDVMF3kaNi1H8zx2R96NnGnSdC5SI3Scc6ZqyA0hpo8PozWVb
         hXdRyRVi15iNA1TFITp/tfMcZd2yVVpiumDWu7+C73FLFnZoVfhwbQDqS9xUbRAl4WQx
         gz2my0YJJevIzJLQADxS8c03XyKY0vL+n24AZsbU1O+dJDagFkpL26A3ixV/l+IEsTae
         MnuDGoLNgtDZYLhPRp0RddAwZjVQrv/dc3Bhri4RpSwluQwnjdPLZu8hSHX0HDTU4Z7a
         2gQKs9LdbchcJo6stQsj1TBPonqCEzXHD1qaD0hKM4U0OMrK0tMxMmXjiUSN/atMsNvc
         spyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795046189; x=1795650989;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=fWb/KlwmWqUKlchoe6fMQgzivFC2C/Re0xgS0ZD5es4=;
        b=UpodE7Qstpv6KIoYwamuZklg1tuptGg8YSQDsHN5ekG4V0F5O0O8Q/BzDWtwoDSLeR
         ifyRv/nI7LZDG1OhgCpCVtKCJkddornkuOQ166DoCArmRz5CkQ5hV2QSWLYQ6+G7aZp1
         y73vR8b1rgW1L61/eEaeHW3fcFRXZmB0sNyCSURIkQOfpOXT4EWotIHuTZklvq7LJnoC
         0CndBY57N+r4u8rdlEpAo0eOdTtvU8sHxTZbZjckAoQ5aQ68xfVE6mupN/glKEhZtzkP
         X3r7pVrSr+naHuU0xgaJ31nDDgwdwu7dVx3msKaWv+qKlA/OW9Xwi7Yc3mURAKc3dljP
         3/tw==
X-Forwarded-Encrypted: i=1; AL+hErFOdQ41cflBsE5+pyypuKAIfsaOvYhUFl/vSjGWbbbXMjhQa1t5t8pCztfZEqo6nqfg5SEC2fmq9l8=@vger.kernel.org
X-Gm-Message-State: APuU4Z/IqJg4svDdq2FuLObpEUSJo7JMfiBc6xCFm6x5zmYF9vKsOSlU
	q1BhunePVtKFa4ykd8uOptdJKBRzZEjqPLZMLno2HCUcaXCHy0Pmcg7yCJtH+t/bCHU=
X-Gm-Gg: AYBFou2vJ6F2OZoixanxHYu4IXc9LxLub7WZ3V0OxN4UfP3qNI1DQdliMbf/hg7Ypbi
	32pA/ZYoi+i0gO5rEZHsCm1G98E2kiMeJ+8M+IuaAmdYLDPVbpNBxDkbXX8uB4DppGVL6BJwObb
	Cm2+mWx0m0/0ao3X1R3/5BBAzBHvzwjhqe28bZw4/9WxbLkS71A7O7o8epwZWOFZqZu3xIjuqPa
	R7P9Y2xbPdb+oWmrebZavWa8kmPhm+rW4SMii0tCi8xSKtqJP3nn/e0R6ehl7TF5OYgWWxqt0bt
	F97KiBvbPqr1ZW4Uu51Gdc0rfQGomccGnJx7dBGrFFYdaWbtpH4SYJl9zxLRfbq8rgiQGWG8MfR
	sY6xtKlpMR2rRo2w2ELeAxE7fPwcI3euZXYxyJ4qH+DyB/e3Za88GztTUwZW6HB8vYPFUjP+BGF
	SVfNHy7gc9lO4ZJhGdOiNmWbJzh6FtuMBuEXaG3inulbHROTlUYlShSGfhMRcCsJggArx94A7Sp
	Y598Y6yY2zN0AmnZU1D1FI31ZAxo/9rYpeBppCISObNGvpzN1JmNxaLW8qrZDxfFj5VsTJG7inN
	FkKCXbsXkgtW+YHWcZInMypj+BGWtdbDEmCG/ZAOHxRFYkHyPPQP
X-Received: by 2002:a05:6871:c301:b0:49b:a2da:91e1 with SMTP id 586e51a60fabf-4b75c856472mr4068848fac.9.1795046189287;
        Wed, 18 Nov 2026 15:56:29 -0800 (PST)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4b74412113asm3686313fac.8.2026.11.18.15.56.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 15:56:28 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, Mike Snitzer <snitzer@kernel.org>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] pNFS/flexfiles: use the MDS for locked-folio
 writeback without a layout
Date: Wed, 18 Nov 2026 15:56:27 -0800
X-Mailer: MailMate (2.0r6272)
Message-ID: <7E838AB5-0712-45F4-AE37-65A34907CBCD@hammerspace.com>
In-Reply-To: <1addac19-9415-40a5-af21-9ccd8e86b6a9@app.fastmail.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
 <79610683ae2bb6d39feb578a27481d588c245d45.1795024981.git.bcodding@hammerspace.com>
 <1addac19-9415-40a5-af21-9ccd8e86b6a9@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain

On 18 Nov 2026, at 15:22, Anna Schumaker wrote:

> Hi Ben,
>
> On Wed, Nov 18, 2026, at 1:36 PM, Benjamin Coddington wrote:
...
>  	trace_nfs_writeback_folio(inode, range_start, len);
>> @@ -2091,7 +2093,16 @@ int nfs_wb_folio(struct inode *inode, struct
>> folio *folio)
>>  	for (;;) {
>>  		folio_wait_writeback(folio);
>>  		if (folio_clear_dirty_for_io(folio)) {
>> -			ret = nfs_writepage_locked(folio, &wbc);
>> +			ret = nfs_writepage_locked(folio, &wbc, force_mds);
>> +			/*
>> +			 * -EAGAIN asks for a resend, which can't wait for a
>> +			 * layout with the folio locked: resend it through the
>> +			 * MDS once any part of it already sent has completed.
>> +			 */
>> +			if (ret == -EAGAIN && !force_mds) {
>> +				force_mds = true;
>> +				continue;
>
> I think I've managed to confuse myself thinking about this. If ret = -EAGAIN,
> we restart the loop with 'force_mds = true'. Won't folio_clear_dirty_for_io()
> return 'false' the second time around and bypass the nfs_writepage_locked() call?
>
> I would not be surprised if I'm misunderstanding how something works here.

Its not obvious, but nfs_writepage_locked() ->  nfs_do_writepage() redirties
the folio before it returns the -EAGAIN.   That same pattern is in
nfs_writepages() which relies on it for its resend.

>
>> +			}
>>  			if (ret < 0)
>>  				goto out_error;
>>  			continue;
>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>> index c38e4b380be5..d64332afc374 100644
>> --- a/include/linux/nfs_page.h
>> +++ b/include/linux/nfs_page.h
>> @@ -120,6 +120,11 @@ struct nfs_pageio_descriptor {
>>  	u32			pg_mirror_idx;	/* current mirror */
>>  	unsigned short		pg_maxretrans;
>>  	unsigned char		pg_moreio : 1;
>> +	/*
>> +	 * Set when the caller holds the folio locked and can't wait for a
>> +	 * layout: the write goes through the MDS instead of waiting for one.
>> +	 */
>
> Any way to whittle down this comment to just a few words so it matches the
> style that we usually use? (See pg_mirror_idx a few lines above it).

You bet, will do.

I'm holding v2 for a couple of fixes that should go in ahead of this series,
and I'll fold in the sashiko findings on 2/4 as well.

Thanks for the look at this!

Ben
