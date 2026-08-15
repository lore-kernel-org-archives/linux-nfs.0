Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C9D730B529
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 20:47:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786826844; cv=none; b=TIbqkuKKS7wg8Io7B7ZT7OI/wIVG0gghIW8H46XqLI5yJP2aqsVp/iqykWvCvx9GcJhy/DUHGqyqDKuL87uxF3xaH/1Ebugguau7Ft80RhC2SRF8t7GVfc1vV8u3G+DNLKR/C1TpqmnkJh9NnaD3Pd0qwLoW8UkhOqpRiL66Akk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786826844; c=relaxed/simple;
	bh=I1MW398Mi+F+dzzlGW9GGPtV5pFt1yVf+AlmyA4KPyA=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=PouLVe3W2cdKUnrOgNvDYWkhGt3Y1YsGhKPzegt1z1rgrRzvaAPVRsHSBz+U1pZy6MhQy8L35T6ukXEdBi5nNVsjxFTG40rbthWZJmWRStub/Jgn0ss6GKTsH5C/bpTVMVzNBaM5CwD4StX5EcWloZABRyz4s2/t7XDPZy87Q6M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=O+8yUYlV; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=ka6v333i; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="O+8yUYlV";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="ka6v333i"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786826841;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=P/hN3HjtnFL+1ljWedR+qJiUDHBJ4cS0i+/cUMK9Pa8=;
	b=O+8yUYlVZAOWVOW/2kwmC15h7T4vMv/s6YpZsKnnebSzCWGgjyQ1cpYKmgb7TG6omNFCYo
	C7YJ5o9jNE5Xp/1Bukl96H7M3EjaxLSn5nYxW7xwoaoj4S5MqVTowulc3Jm6OpqkevC3YP
	CoiIxTfpvKvog6e0aYHYgSMD7stHh0c=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-124-hBna1KXcN9q0aWBqDMTR7A-1; Sat, 15 Aug 2026 16:47:20 -0400
X-MC-Unique: hBna1KXcN9q0aWBqDMTR7A-1
X-Mimecast-MFC-AGG-ID: hBna1KXcN9q0aWBqDMTR7A_1786826839
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-92e8004d60eso397192485a.1
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 13:47:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1786826839; x=1787431639; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=P/hN3HjtnFL+1ljWedR+qJiUDHBJ4cS0i+/cUMK9Pa8=;
        b=ka6v333i8zpjOFrW9R3vJlV2ru9gXbC+92ek6ubhuH3Tdw7/pQJS7BjFY729ntSpe5
         1XLZ90IEBlyA2XqKEQzTGVqQx23yYaFNeFMdI2Dl7ZrT0TxMBwzYZ76SdarFXqlZ1RPf
         IKn4LFFXTDxUBISTESCjhAd8In3DkMhtw/6z5y0xZBq1s+GOHAPssmnl9yPvy6hovnLh
         vp1vaSYNARh/WxPw6j3BqoIZ8MNWsYC0LfK1LxD1OIzQXvFQ4eXZhzH/ahjprqDOaBOD
         L9kIg2JFdUHQEHTeGmsEzJI+0kmI7GYr2dxih39z/b4lm9OFFC9tlgJvIBip6kpFvDGW
         hwiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786826839; x=1787431639;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=P/hN3HjtnFL+1ljWedR+qJiUDHBJ4cS0i+/cUMK9Pa8=;
        b=Q/wGnYCgTUFJZgkdfpwmc4AfEPSl1d3l6A4XcyUNPRkKfZdOlr7sue0x7KBv4ZDz9I
         7wqX3Mrf4m/ispKuZtjVvjngJOyzhIZdg5aHezkvT279xEvYYdINa7w0zt124mQtmSqJ
         nfjo0dgnOjam+5QZD12MAJaa3eFBPNSV+gksptLWrlMtbEPAboZI3TGvheCVXpdSJM8t
         p7jfYJMP75y75rALcOwFxeqOKpBsegcL0Zi1b3PnOqo73i41GU9QibS6ObNZmVfB7PAT
         m23iI06f7q5fIJl6TAar5oGGdyTi0XYK1PJhEkd8ahu39OvRdQsjWWg/YN8Ymx/hTjiD
         dowQ==
X-Forwarded-Encrypted: i=1; AHgh+RopnexXbwMv9hqq3aHWDF7pRTTWQGDRxPy57RvWrnrMN0Nn8u3kNrtohERQGPWjslwB3Jr+5SNdl0o=@vger.kernel.org
X-Gm-Message-State: AOJu0Yydk8FmwgJg7UJX4nJQtFm4u3ZxcOVGPP8ee5FxuGLzjPO8PXGc
	9NsHNYT5ADxINrUMXuMR+V6/Ma7N/JlY1jmUBUPXUa0YdRFxzr5Sdb+3Xh/iRQMdpESUFc61gPz
	Uavp7SgHpv2k/ftY0TvNOVwb5OLqBTNxY8bY7bX+Tx8gVQgan7d03gqFOZpgtPg==
X-Gm-Gg: AR+sD11rmn1w5B7sfcyv+LmdOX1H5xPeo9rmyEn82B/hXAtlqdancwNzVD6Vv5J8Hjf
	Vt7KNMolZ/T6rnfWetcG+6VRicWK6ZXuVpzPjogUXkdkxOFXeja0GpXw0ylNmgrjAg3Xgr2d6s/
	QmFZbjoeKYWqPSFZF0fQe5PIpNUw8+mmaJcZomVe6aFd3HJ9QNgSa+Jd9wx2CZwSGZds2aJlafX
	gvrwaZ4C9gjh8h2uU/CfkFcXIrtBZ/+jOIGcwPI3NDG4OSby3jqtayEDEtJQdGNVF+081+OSkVg
	2RnH7Xb/ZZmXCGagAkg5s7hCDX3I78x0SS3m8crNBLkri7JjNuU6cJ7EQ3hHgR5FLhc4b5kcQg=
	=
X-Received: by 2002:a05:620a:2814:b0:934:a12b:1d41 with SMTP id af79cd13be357-936d22ff13dmr1583095285a.33.1786826839326;
        Sat, 15 Aug 2026 13:47:19 -0700 (PDT)
X-Received: by 2002:a05:620a:2814:b0:934:a12b:1d41 with SMTP id af79cd13be357-936d22ff13dmr1583092685a.33.1786826838918;
        Sat, 15 Aug 2026 13:47:18 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.57])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-936ce250c20sm594431885a.47.2026.08.15.13.47.16
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 15 Aug 2026 13:47:17 -0700 (PDT)
Message-ID: <949be130-42e2-4ad3-a22c-4718d72f0cbe@redhat.com>
Date: Sat, 15 Aug 2026 16:47:16 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] getport: fix missing stddef.h inclusion
To: Jaipaul Cheernam <jaipaul.cheernam@est.tech>, linux-nfs@vger.kernel.org
References: <20260806112023.25090-1-jaipaul.cheernam@est.tech>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260806112023.25090-1-jaipaul.cheernam@est.tech>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/6/26 7:20 AM, Jaipaul Cheernam wrote:
> getport.c uses offsetof() but does not include <stddef.h>. On glibc
> this works because offsetof is pulled in transitively, but on musl it
> is not available without the explicit include, causing:
> 
>    getport.c:459:41: error: implicit declaration of function 'offsetof'
> 
> Signed-off-by: Jaipaul Cheernam <jaipaul.cheernam@est.tech>
Committed... (tag: nfs-utils-2-9-3-rc1)

steved.> ---
>   support/nfs/getport.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 608e185..6bd2f71 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -27,6 +27,7 @@
>   #endif
>   
>   #include <sys/types.h>
> +#include <stddef.h>
>   #include <sys/time.h>
>   #include <unistd.h>
>   #include <fcntl.h>
> 

