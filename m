Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D71A74B0482
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 07:30:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786347055; cv=none; b=BoW0y5zfH5IEiVgrFBfdHMdPCt9KQZV5jlRC1ZUb+TOZVidyEL4v57Tu12Qmf5pNAwiTlkxY2H6jSKrXitBUaG9SOAs/TkLFZpqNA9dOAntTtNL3pE1MON9fMuJlsiGQiguA7ZcgtyCZmIAz5Mi7Gi6oMsEUZTmYzWTwGXqjfTc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786347055; c=relaxed/simple;
	bh=yhtyt1vBw/PRbtQOTJpH9DH1ezHTNqQa8y+7AD1hzwU=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=q37XmYXebJf0lRknAQ2e26kKtYApZvJCOM0IUvcbuA8YKgsEAwj5f2GjZ5lpf7voVBC2SC5+QjVZk2BxA9bn35N/lvV95FhFD0rMbwGPSufWif4BbpIZlcjxio0M9ylEeBZhQUIpSuyCf5g5bpy0kxqzwG9uzajOijf9uRJauQY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com; spf=pass smtp.mailfrom=vastdata.com; dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b=JKlqR5Ri; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vastdata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b="JKlqR5Ri"
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-495757ccbc1so19422435e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 00:30:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=vastdata.com; s=google; t=1786347052; x=1786951852; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EZT3xRDKqnOW151lqfcn/WA7kKK8OfDiYOkNYvuqKHQ=;
        b=JKlqR5RiRPePd8EcvPWrpu2VOWZvaFIaAwEMZ7Lgw5mHhmeVCEUC2fvPx7MnGJz8Ao
         l1HtrWXPAPyZ4WlIXfkn1GSTiWo5hGaHVQMvUJgQrKPCAsZaEEsKbNh+4X/gIEVqpGJM
         dNqLJ5vzylhBwwyDA5ZhxWYGnCZRTEG5HEazfg0KzOQcN7cOXi3VB5j1EBqxkz2IQ/Vd
         Tm0af1WEbbl8I5ZUImJUozfAO+irXFuGbgv1vhnYvziu6b6r7uZgIZrrNTvOsuBLYfZa
         Ppp70YbR1j7T6UKtfdp5idmLXFWdLlrMsPX7rWqUBEw4vvS9Suq3Jz+H9zuZ5pNXyYZV
         X/eg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786347052; x=1786951852;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EZT3xRDKqnOW151lqfcn/WA7kKK8OfDiYOkNYvuqKHQ=;
        b=kujV2onxvPctcBxSAt8/puZLTnyC9wCD3JEHEkkpe/wGB1wDyt9vZ5gGJ/ptZkOJkB
         hjZd+gcC+az3Uh5kayjR0AZ2Rm0+Rt5PiqPDcj9i7EjpTaCdahKuG9OHJIh14834Ic0J
         5Dr+ia0Hruon4PdZl8uiqINu8lhCS+CdF7jMsNcY8JhcnE24Pydb0zcNdXjreZcA7i/C
         lGYy2K1DuwjFYQJX5nWMar30lSla7zdVNbomniIWF2Rr79UCbATQmi2pqtPTJhUgeLXe
         mMh5OhLRQ7RILjeHSglDWJRm1rmPa54yG+JKIYaYq2UVGHk3E2qey/nP+HVLYHjfXDCO
         R+tw==
X-Gm-Message-State: AOJu0Yxm+xjp+v40S+zu554qyuxS7pypjcdbznc/82XlYP1AGGn2fYek
	COhJnIWl73gx/ApELJ5MMLJHY5FvpiC0nazLAf172zwP2xY9lARJ/HTCbFmd27GMKaa1uQ80T10
	SRfor7w==
X-Gm-Gg: AR+sD10L4MDniYwvzTLcpVX/lsfJ3399ZncnTBA3pEhopqaMCkYkXN4JuenmJxc1n44
	anHbRywqnK7wXQx/9ZDCnutnkz/BhSLgqaQZZOlyhcJYoAhpitmOjOn53L1Bw4e0u9UeYkmFCmu
	uEdCAVS8zSqO+aOVgRg4t6QX/6oMmvy3QGKLT9iaSNe4bC7sWCWrEyc0PAK/a/K+6maeHJuHZh3
	7z7F43tGKqECVVyQeIwxzEg+5zj7ld9UsSCq5eutgOSxwTXbfaBqThz4BnKbROTm3IptE0SjlW/
	2bOQv3Adatq+6VcNy6rRf+4SnENtfgWv32wtzQ+zV1UeU+DD9QhnaiRantHrCbWQtzqjidMgpv+
	kuNtzlrAXeFqLdyDVSvlBOM6X8L/tJGEK9xYSTRc7k2mzCJrEs3DRNIaoBl8/5fx0BFTtX8bYPF
	8ixpg5i9Tm7s89tXQCwDKy8FtrColq07c4n3aUdkSsPkTw8Vb7EpjW90DTwyu7nvuvWO/XwgWfl
	e9oNLsMg26o6kbJtWkVfkbNwgHabq6y3xs6kCOnP8+t0BGkGDDcXyAVnqFw8QIHrsoNIw==
X-Received: by 2002:a05:600c:3b0a:b0:493:c47f:3c55 with SMTP id 5b1f17b1804b1-4994e71d7b0mr514051525e9.5.1786347046796;
        Mon, 10 Aug 2026 00:30:46 -0700 (PDT)
Received: from [10.50.4.59] (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4995e9f9424sm236608605e9.8.2026.08.10.00.30.45
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 10 Aug 2026 00:30:46 -0700 (PDT)
Message-ID: <e940b620-7f6d-4d4a-a0f4-644d880c7b6a@vastdata.com>
Date: Mon, 10 Aug 2026 10:30:44 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2] nfs: fix ENXIO on O_CREAT open of existing symlink
 over NFSv3
To: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, neil@brown.name
Cc: linux-nfs@vger.kernel.org
References: <20260806131358.398096-1-michael.nemanov@vastdata.com>
 <c887ed23d456542f97168ffeda4abb5d55ba0fa6.camel@kernel.org>
 <1c8a4b344ffa6617ba20891a9094899595346007.camel@kernel.org>
Content-Language: en-US
From: Michael Nemanov <michael.nemanov@vastdata.com>
In-Reply-To: <1c8a4b344ffa6617ba20891a9094899595346007.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit



On 08/08/2026 19:53, Trond Myklebust wrote:
> On Sat, 2026-08-08 at 12:34 -0400, Trond Myklebust wrote:
>> On Thu, 2026-08-06 at 13:13 +0000, Michael Nemanov wrote:
...
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index e9ce1883288c5..c3481d9c74334 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -2317,6 +2317,13 @@ int nfs_atomic_open_v23(struct inode *dir,
>>> struct dentry *dentry,
>>>  	if (open_flags & O_CREAT) {
>>>  		error = nfs_do_create(dir, dentry, mode,
>>> open_flags);
>>>  		if (!error) {
>>> +			/* With UNCHECKED mode, a server may
>>> return
>>> NFS3_OK for
>>> +			 * a pre-existing non-regular file (e.g. a
>>> symlink).
>>> +			 * Let the VFS handle it; calling
>>> finish_open() would
>>> +			 * hit no_open() and return -ENXIO.
>>> +			 */
>>> +			if (d_inode(dentry) &&
>>> !S_ISREG(d_inode(dentry)->i_mode))
>>
>> Hmm... I'm changing the above to "if (!d_inode(dentry) ||
>> !S_ISREG(....))" so that we don't inadvertently try to open a
>> negative
>> dentry. That can happen with NFSv2 if we hit an existing directory
>> that
>> has been renamed on the server.
> 
> Actually, "if (!d_is_reg(dentry))" is even better.
> 

Agreed. Would you like a v3 with this fix?
