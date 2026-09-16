Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15E6850C2A6
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:16:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789568188; cv=none; b=lImKC2anE8T1ddgk2PYk7t/UmdOxEtBWxg5M61G02Kh5vIUF08FbRCvzo1UUpsCM2EYMKpOgXcdqz0iPoIvQeeCPERlVI/daZGUCj3mB/L6Hd5l0iJFjWuCgDlrZ93VHwjSGD2xoOyFNq4ple+GXAExQPJut5gbqwotBMyhDWd0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789568188; c=relaxed/simple;
	bh=Ut8xEMMAcqBnJ6T3IJm8ZL2jHFbflxiwfgRVnWaxJxg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=UJjWaIZmlL8JQl3x92PI0AyGL0keeZy2qiLD68vJBXOyCK4g9bInh99RMBb+BFioYPOrN7b+tozVdsv+0CFGhj4PT7yB/Qkc6oNzrALUk2u2eZnnOI03RFDNoXj6f4kIergyeRHTN5cJ0GrzauOuoMG0x17e8kOmRKOtgAmYdTc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=C2YROn4L; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=MSinw/2f; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="C2YROn4L";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="MSinw/2f"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789568186;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gE9ahVgwWIYYBh1pOodroVqugBXbHacdHAMZrryn0j4=;
	b=C2YROn4LWmRQtQuqYzj0vpL/uOPm2/kEX6Lfv/EX2jstRrA7RpZD43aak2q7NUR7aVsDnU
	I/ukXrfymQo5m73pBlkdGahHdVlytck4dgV5pkIJfM44BSJ6aG6ij5+2/Ir6j3dmitV9TC
	rowkleZ/8ebAsK2qm9V8wjs+9YvjwSc=
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com
 [209.85.167.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-312-b47AN1aXPuyNTqO1MiVTvQ-1; Wed, 16 Sep 2026 10:16:24 -0400
X-MC-Unique: b47AN1aXPuyNTqO1MiVTvQ-1
X-Mimecast-MFC-AGG-ID: b47AN1aXPuyNTqO1MiVTvQ_1789568183
Received: by mail-lf1-f71.google.com with SMTP id 2adb3069b0e04-5b60bfcb6fcso3513411e87.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:16:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789568183; x=1790172983; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gE9ahVgwWIYYBh1pOodroVqugBXbHacdHAMZrryn0j4=;
        b=MSinw/2fGv9LB5NLCVdsBUqPi4OrZZ/SY8o4+OOlNlY1tXews/IfPtDMbeb+jk9CeF
         muiZqLhCS2+dxwC89c15gGGgvRxUVClo0E3b2YLFgEKVL+Xg7DQDMaOZOD8XrQmVDNNT
         5TREH1GGzHXjKbNhDAZooWCOASwbHmvJQnHpVEX9imj9wn4HMYpDFc4WRnKigk0dm5IL
         xjJAoEEZ9jFJth6C8TSiwt834ajf1gAtlGteptwVF04OSaWdKDg8EGuPLgNheEuKU06r
         ody9UIX8AaYwMembs7gn9Y0dkpL4YG4zNYtYam31MA8+GygnlpEKYg9pt+kYchZoLdx0
         RzKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789568183; x=1790172983;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gE9ahVgwWIYYBh1pOodroVqugBXbHacdHAMZrryn0j4=;
        b=Kqz2k1s7HfawmUuMo+M7mgyx08kcR36/4MN+IiYM0hyZsnkqZzcaWV/39RnzL0qW/d
         qRm0nId62boseIluF2WHUiitW+8TJh/wJKppFo0rt5Bbt/+4R4oj9fZO2qKtAeaY8tA/
         H6YtC06bBTQJLbvuTQDVMJCVqC8aQ2bDT2w+pEWj4a06xO0haWayfK0dOyoMdSXIb10j
         q2wuZ+aAMr0jFoFYcHqGWnSmSEEt/DBAQQKJEqtg9TnpXGBOrj2iy5dv0cS5IfetbnVO
         OMIXwHgOUDICSdOUMUpyKdDVsJABbWsSZ8NagjQw4cWHlHVxv1P72NmvIxX3TqNXVYeK
         xQWQ==
X-Gm-Message-State: AFuF++kyi/WYZ0/DfrwF4JxXYBqDuUEWcEv0voYQ3T92Vf6912oiAcgj
	8jLTM4rL66+DCzVwYyTYnuUWEjDMsTweswdZbIUf6xpTpBzc5pUuVxQTP092i2miN2AKivYfeQ5
	TxLvdixh546JOVJ658K3kTEAupor+BV8M6bAjTK6claX8rjZdPdyAhukkOofZKr+7VwDBEg==
X-Gm-Gg: AYBFou2AatDsOITYAw3etT7EcTPoSM3jYW9PGfC9oPyhKCTyo9wiQM3nl0TOE3JC6gz
	DJ1y78wb46F0ZpZoDXyMmcQtqEJ1499gU/vy0cm/2zj2SOawaAkLENdXTdmjbRQWKq1ehun9y1n
	9JGhK16ptFPPblcegZdrER2U6JCumLqjHuUMdB7F1TXPpMfy5tDqp5V7WQLpsFlegS0yqrYKTsT
	5TXzkXrCydbSpTifjOGjHyDMmEhDBlyeovdc2M8TW1uFglsdyc1VG182u5BkQbbl/82I3G19Feu
	9Go20DXZfIVbHWtPiL/jl2bfsYGwlHbLxm/iGXOedBM8QIGWLjQ5vDyozqir1JMEfmsgVJZvVsQ
	=
X-Received: by 2002:a05:6512:238a:b0:5b6:1a7c:aa14 with SMTP id 2adb3069b0e04-5b8b6643b61mr779758e87.44.1789568183081;
        Wed, 16 Sep 2026 07:16:23 -0700 (PDT)
X-Received: by 2002:a05:6512:238a:b0:5b6:1a7c:aa14 with SMTP id 2adb3069b0e04-5b8b6643b61mr779746e87.44.1789568182658;
        Wed, 16 Sep 2026 07:16:22 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5b8b57e0eacsm931923e87.61.2026.09.16.07.16.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:16:21 -0700 (PDT)
Message-ID: <2c15e85c-220a-483e-b5f5-a6dcda61122f@redhat.com>
Date: Wed, 16 Sep 2026 10:16:19 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH 1/2] junction: fix buffer over-read in
 junction_parse_xml_read()
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903175313.1214070-1-smayhew@redhat.com>
 <20260903175313.1214070-2-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903175313.1214070-2-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:53 PM, Scott Mayhew wrote:
> junction_get_xattr() returns an opaque buffer, but
> junction_parse_xml_read() treats it as a string by passing it to xlog().
> Fix it by allocating an extra byte and null-terminating the buffer in
> junction_get_xattr().
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   support/junction/junction.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/support/junction/junction.c b/support/junction/junction.c
> index c1ec8ff8..04a8ebf1 100644
> --- a/support/junction/junction.c
> +++ b/support/junction/junction.c
> @@ -293,7 +293,7 @@ junction_get_xattr(int fd, const char *path, const char *name, void **contents,
>   		return FEDFS_ERR_ACCESS;
>   	}
>   
> -	xattrbuf = malloc((size_t)len);
> +	xattrbuf = malloc((size_t)len + 1);
>   	if (xattrbuf == NULL) {
>   		xlog(D_GENERAL, "%s: failed to get buffer for xattr %s on %s",
>   			__func__, name, path);
> @@ -307,6 +307,7 @@ junction_get_xattr(int fd, const char *path, const char *name, void **contents,
>   		return FEDFS_ERR_ACCESS;
>   	}
>   
> +	((char *) xattrbuf)[len] = '\0';
>   	xlog(D_CALL, "%s: read xattr %s from path %s",
>   			__func__, name, path);
>   	*contents = xattrbuf;

