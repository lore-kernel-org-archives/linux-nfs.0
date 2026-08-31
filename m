Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B18AF3C1D42
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217609; cv=none; b=uu5Is4U3ENqmY1wE5hf1r01v2P4DeOdQwnmRrkQuZFeKvdWcbu9yDmuG00VjfO1SibwIfCxBDnlQA0sh7KwgPtjTUnpSjr3bByFKZQuVkEyOmFAUaoyFu2EAE/MjS5ofN/BUQow5OzFCDwfErQDmuMtw9BniaR8jBhyOxGLkv4E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217609; c=relaxed/simple;
	bh=gGfsdft4JZGKmDdCAl4PA1gQW5JOQwl+HLxCk+t7TNQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=uyTd0TbQnxkzGkMOmqF8zpMFzQYyrucduDvzwuG+1mpJ/rsN2dtkHgy+E3/6dFsDwJK2KRcrmvAXAiBOBRm4JyPIoQE4OE22mLYaNEYEYg98DxGhW0+YY5KZIm/W7MMTDycKx6jctS+4gxAUhr+RXS3iTthvwfZcvDLVQffICBw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EKXa3NuM; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=UBOKeb/h; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EKXa3NuM";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="UBOKeb/h"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217606;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=nBoJDrhF51UEUeziZ4wXsNXkJA2meB0g5FlYvHgjq10=;
	b=EKXa3NuMH++yrHRSvS+663WVZ4bqQO5wIvuqV+mhniuMIza+FFN7clokx3exiVjwspJbeg
	ljLCrwozdg8farzVIq5+BRTKAmFCGAXJjJgzrF38h0Qe1FZ26hQbwYNwQ5BpbHMdzK8kSN
	5rbhdocRQYJawQTTWf/yXp31UeLI2A4=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-695-ZyhVyEbIMD-UUMVWGsXQIg-1; Mon, 31 Aug 2026 19:06:42 -0400
X-MC-Unique: ZyhVyEbIMD-UUMVWGsXQIg-1
X-Mimecast-MFC-AGG-ID: ZyhVyEbIMD-UUMVWGsXQIg_1788217602
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-90cd16a0bc1so94368636d6.0
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 16:06:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788217602; x=1788822402; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=nBoJDrhF51UEUeziZ4wXsNXkJA2meB0g5FlYvHgjq10=;
        b=UBOKeb/hLMMu2v5XSCV2uwmYerj1Ynxyc+2pAdbz31WKTecAXCi9XY5IKtim0tz4i4
         jtqFafPt3g6B05O9T356FAhqDUINgDjLRVPuo6icuvKyq7fvyPmPE9Rb3jdNLcP3qpYn
         9YLHm2HIbLXyz3vqJnnOywtO8Hn0WFv21JDC8u+s4d/HRqJtpXSDKKjORa9j2QHEW9Jt
         S8tH8Zn/IDhKIHqbi+uCKpTMuQQwYO+qW9AmNsS1S1wovBcqTuSnU34xPMt2hqAlpBn/
         dn8XaSoaRbnO6sCpknz+wXXCe5txnf2j1KrDqbDZN2Zxw9M2MvSMCPHbSE7aWIPi7OQu
         5ITA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788217602; x=1788822402;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nBoJDrhF51UEUeziZ4wXsNXkJA2meB0g5FlYvHgjq10=;
        b=dUixeY707VTZ1zDY4pMMuxUVG7ShXXAYIXhRL1d3Oc30NrPXGU/O0uwJKSYbHI4la+
         TzDz6Z45mO6S2SAZbgWG24pWZkils4thauSL7CA21KJEf+rZ5OD2W33MFCdlt2+KMOt6
         Kt3PaagLCBvTayPKE2DBBXybuGBIt4NqWZoj9qs2TZhnBZsC+Fds8VEqJupVfL1Hmetl
         BlwsOuYavG2wW7VXb11DxAO7+zI5tSWZgEL9VFnTRPUiFBHzqLmS88umEDGys94ROSYT
         /S/UbvUUOM21hF9GheMnTF9OK3+vIbzCW1sDkFTB3KxIAHZQTAGsPDmcaeRYYeJph9NG
         y5UQ==
X-Forwarded-Encrypted: i=1; AKwUvBxykkCTIUX5IvsdgyDvCFCQuaOxfJHDR3gg82VBDI3ofdZNyVu8vFk3JO4WrVPd1a1bwJn6j+NxfEM=@vger.kernel.org
X-Gm-Message-State: AFuF++nvkaPnufBGlL1Ek9v1GGAloz/MHkwagPOtzlySORqYsroLLAW5
	xukGSKo2/PUscBEV3r6lIazrZ6o1VH9m7scFfqKM3LToo7jdBBIe9twfZa1JWkt7Fgc3XYFeizt
	WS+B9kjDzMyLU8w3QmKSfGyV6uNIoiypZNi+gUuAGSGdudLps3z1JKQpa0WURNrJPHk8zfw==
X-Gm-Gg: AYBFou10RsBdEQQfbl5hKacldqq8khFpEqK773yeOYuvLXb4ZmZQuW5PJMtZyOpD76E
	JHcOM+Roy5iB9rNJOYlVVZbzEBzj9SevX+eyoRydLRR8z05yG82OwGPYsjJYEEked7Ej8gs4JtI
	okxYPZMH2XzGIvsgWiGlwvA4S8aD5uI+L4EA4uGHQe0LfsPLk96oliVISSI1p1uSj0fHtUvTirW
	MoRGj2CXC58ABGuIVpPBiHyH4Lafx+Mqklp796hehY0Vy5knkXljAsak2GZemVCR4r8191t7AgR
	IJ3tIUV1yx/nJNrT2N2xYZAOgWo2ECbnNpAY3XSqc41SzHLpwUxHj+pmBVYAsMXJng4rZ2RBPkO
	dh82CqO8VCfLteL/BjB9/CbNudV7uc6AGCl8VETVhhEGTv3RE
X-Received: by 2002:a05:6214:3ca0:b0:90c:4422:84d1 with SMTP id 6a1803df08f44-90ce0f6cf64mr420722676d6.30.1788217602325;
        Mon, 31 Aug 2026 16:06:42 -0700 (PDT)
X-Received: by 2002:a05:6214:3ca0:b0:90c:4422:84d1 with SMTP id 6a1803df08f44-90ce0f6cf64mr420722126d6.30.1788217601947;
        Mon, 31 Aug 2026 16:06:41 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90ce4515130sm94779056d6.39.2026.08.31.16.06.40
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 31 Aug 2026 16:06:41 -0700 (PDT)
Message-ID: <60c1127f-56e2-41f7-9a34-5bcb784a750a@redhat.com>
Date: Mon, 31 Aug 2026 18:06:40 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [FTBFS,PATCH,nfs-utils 1/1] getport: Fix switch case on old
 compilers
To: Petr Vorel <petr.vorel@gmail.com>, linux-nfs@vger.kernel.org
Cc: Giulio Benetti <giulio.benetti@benettiengineering.com>,
 Julien Olivain <ju.o@free.fr>
References: <20260819232049.438643-1-petr.vorel@gmail.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260819232049.438643-1-petr.vorel@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/19/26 7:20 PM, Petr Vorel wrote:
> Buildroot distro compiles with fairly old compilers, which defaults to
> old C11 standard (some of still used compilers don't even have newer
> standard than C11). Workaround code which requires C23 with using { }.
> 
> This fixes error:
> 
>      getport.c:460:3: error: a label can only be part of a statement and a declaration is not a statement
>         size_t path_len = len - offsetof(struct sockaddr_un, sun_path);
>         ^~~~~~
> 
> Fixes: 1a6dcd74 ("Removed warnings in nfs_sockaddr2universal()")
> Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
Committed... (tag: nfs-utils-2-9-3-rc2)

steved.

> ---nfs-utils-2-9-3-rc2
> Steve, other option would be to use ';'. Not sure which one you prefer.
> 
> Found with Buildroot, which still uses:
> 
> $ aarch64-linux-gcc --version
> aarch64-linux-gcc.br_real (Buildroot 2017.05) 6.3.0
> Copyright (C) 2016 Free Software Foundation, Inc.
> 
>   support/nfs/getport.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 6bd2f713..18ea0777 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -456,9 +456,10 @@ char *nfs_sockaddr2universal(const struct sockaddr *sap)
>   	int len = sizeof(struct sockaddr);
>   
>   	switch (sap->sa_family) {
> -	case AF_LOCAL:
> +	case AF_LOCAL: {
>   		size_t path_len = len - offsetof(struct sockaddr_un, sun_path);
>   		return strndup(sun->sun_path, path_len);
> +	}
>   	case AF_INET:
>   		if (inet_ntop(AF_INET, (const void *)&sin->sin_addr.s_addr,
>   					buf, (socklen_t)sizeof(buf)) == NULL)

