Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 707A7363C64
	for <linux-nfs@vger.kernel.org>; Sat,  5 Sep 2026 17:36:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788629769; cv=none; b=sFww+di48IxvGW6mB/4ICHnKu8+Ey8riIEu7GsZbDavjMhh1TG0opJrt7CDdE8efHonUvs3eVVUhWIeTQ3eDL3nqr5pUqHxIitiODkOi/IyonA8pYuqgY8uztwlEo7cfu2Mdn2DdnIcoq9jAep6opVxKY/LEjwpE6M8J/r32cq4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788629769; c=relaxed/simple;
	bh=4a1yd9hzKD59M/Mohc+vPm6DN9clk91/GsP7rlHOmsc=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=J3HmnP8sPWDy9tQnQH5Bvhiy/1FgG6z3860PHi/CsP3FW3MSW3h6XTIgKYs2fWV57IVsj9mswAe+f35PuE64E0Ql6IkcIgIhNJJBXzy8MiJWZ366MFFG4984sUp2Fma8Qw6he/N/X/Jq4cESul8uxM1Z20SgCeFTWQUfM1rB8YE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=jHN6Z8H1; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=X+0Iy3mC; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="jHN6Z8H1";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="X+0Iy3mC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788629766;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=8aSslSTwXqUXmFGOiC1a+DOoVLYlz3P3CDQJlwkdXWs=;
	b=jHN6Z8H11HpKpWmbBZ0votceqxe+39CAUgX6xinhOnTBT6e4b+9pgrm9frp+L598eR5EWh
	McnT5t7tvb4WvW//ukvxqpTyh3iR23IKi0JZ4+LzoVpj3s7puDVNcZ/zKm2tv9XY1CbXeQ
	PAQp00lqDlD4OkSj2ccmqVJIHjkV6fk=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-628-CxeD0Z6wONW8_I7c7UjaGQ-1; Sat, 05 Sep 2026 13:36:05 -0400
X-MC-Unique: CxeD0Z6wONW8_I7c7UjaGQ-1
X-Mimecast-MFC-AGG-ID: CxeD0Z6wONW8_I7c7UjaGQ_1788629764
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-9102f07f2fdso55183666d6.0
        for <linux-nfs@vger.kernel.org>; Sat, 05 Sep 2026 10:36:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788629764; x=1789234564; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8aSslSTwXqUXmFGOiC1a+DOoVLYlz3P3CDQJlwkdXWs=;
        b=X+0Iy3mC8NujjYRC5jpXUo+qS90uRiqFJ3jBBPqPOqASRmy1RjiB4xjAW97bGFJkQ3
         4BnRZ4CBqNo9iCQtM4MMYn7rLknz2v23bVRjCwBDz/85e5Bw1HtD9qVIYxhOEcoj4L/C
         AxOIb+g1hDp+Oi6bXEvlk9f/ZVP7sWNznKFMUkG9oPCRyshUtnpYbNP+UworxutuNz6R
         ycrsXDSqiCSCX/KiFxXeRirln29KzTDJr3MR7VmRvNHFkjMgqyJJvo1MEmSq5sbESSXu
         pKHbSylH9t9hQ2nIPkMLqgFEPzOiS5NBN4g8jG5R8NxG1/+osHkkcDREOQxKgpRRP1fl
         9cyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788629764; x=1789234564;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=8aSslSTwXqUXmFGOiC1a+DOoVLYlz3P3CDQJlwkdXWs=;
        b=DHLW33hSwFBUzeeN3zasU+I36bhna42IRnuxXCRWFbhyhLDGdvngjsAWdcMoRyh3yM
         HpPEn5csOjNxZOHG7RWAJ+0kXLBMmy8Koekj8rFN0jp2NaQg8V5kDuFfWa+KAc4tndpi
         ZywpukozPlCEHdwyH1B0Lkdt65+nIWdxl/vK7l/JpHZn6bkoobKBN10MysitAItdF/TP
         2yc8x3nIS9aEEUudPp/BZnKbg03WaM/zRdGcsRuvBIe0Wr1U1fJwzQN2mIED224JwsYP
         SJL6Z9xMAGsEFvxewfA/+fskF8sg9XXPhpyCNx6rpQJlmcUMxyNf4pVNm0mjEc55QrrP
         MqFA==
X-Forwarded-Encrypted: i=1; AKwUvBzZ7ZQNikawQvC0Sv9dnzit+IdVl+LWyA1Ckr3GS58oOGPrGEEt0hbYydOIsZ9arawNr6cY5B9SjGE=@vger.kernel.org
X-Gm-Message-State: AFuF++mlgUPdSGQ5kZXXUGEgF6XTS+0PePG3//O3yzStKDN5+0b7U/Jj
	REwtLJrG3i/V/aaJC0hXTK3M7vTHYoncw29r3Eqb0PlOemrYgegCngv218hT93MhBPtlzKvOem0
	IZFL8BjGd1zlAHVqxuXIAI4SoZ63Br0mcF41LX3rDeJFN/Adb6MazdAkNpP1WGQ==
X-Gm-Gg: AYBFou3nbmItnUG2l1UaJqUXCaIqU/P7jnGGTMb5NxSVHe+fveol/ysUqFneKgvPybk
	gw/VrvVR+ZZQYF5ICgCmuMn8leiqZXQYKid41ohmOz6925xoYLuD8RPG1lPc3j3ByUP/yTBmaqa
	Ejrm1etZ0vd5l0n1ByTk1uiBLgXMkm+UKhSlu5Vm1wmw2UE96juQUXTHroUQu3Qdnpz6WrZhrzl
	x2yzUUrpFMcAYPA62acvf5CNNZGsm/gIa9yKUCyffG1iK5h8jCX3AQWklWCMq8dilzfvgnNFayX
	UtBc2hJzxL3M/WOD/qDk6K0qmM+2LgB6n19OQzcnBuGIXBlYP19GQl+PgX53GLSvDEyWlsUX5lo
	=
X-Received: by 2002:a05:6214:488d:b0:90e:9d5f:d3b with SMTP id 6a1803df08f44-9103476d4b8mr181288126d6.16.1788629764468;
        Sat, 05 Sep 2026 10:36:04 -0700 (PDT)
X-Received: by 2002:a05:6214:488d:b0:90e:9d5f:d3b with SMTP id 6a1803df08f44-9103476d4b8mr181287816d6.16.1788629764029;
        Sat, 05 Sep 2026 10:36:04 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.245.121])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91040646d59sm49184006d6.8.2026.09.05.10.36.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 05 Sep 2026 10:36:03 -0700 (PDT)
Message-ID: <7371fb8e-acda-4871-86ae-72c39170a9a4@redhat.com>
Date: Sat, 5 Sep 2026 13:36:01 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] rpcinfo: stack buffer overflow in rpcinfo rpcbdump()
To: Krzesimir Nowak <qdlacz@gmail.com>, linux-nfs@vger.kernel.org
Cc: Krzesimir Nowak <knowak@microsoft.com>,
 Michalis Vasileiadis <vmihalis.tmd@gmail.com>
References: <20260828153829.1034658-1-knowak@microsoft.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260828153829.1034658-1-knowak@microsoft.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/28/26 11:38 AM, Krzesimir Nowak wrote:
> rpcinfo's rpcbdump() formats a server-controlled list of versions into
> a fixed size buffer with sprintf(). A malicious server returning a
> large number of versions may overflow it.
> 
> Reported-by: Michalis Vasileiadis <vmihalis.tmd@gmail.com>
> Signed-off-by: Krzesimir Nowak <knowak@microsoft.com>
Committed... (tag: rpcbind-1_2_9-rc2)

steved.

> ---
>   src/rpcinfo.c | 12 +++++++-----
>   1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/src/rpcinfo.c b/src/rpcinfo.c
> index 30d535e..9917913 100644
> --- a/src/rpcinfo.c
> +++ b/src/rpcinfo.c
> @@ -958,17 +958,19 @@ rpcbdump (
>         for (rs = rs_head; rs; rs = rs->next)
>   	{
>   	  size_t netidmax = sizeof(buf) - 1;
> -	  char *p = buf;
> +	  int l = 0;
>   
>   	  printf ("%10ld  ", rs->prog);
>   	  for (vl = rs->vlist; vl; vl = vl->next)
>   	    {
> -	      sprintf (p, "%d", vl->vers);
> -	      p = p + strlen (p);
> +	      l += printf ("%d", vl->vers);
>   	      if (vl->next)
> -		sprintf (p++, ",");
> +		l += printf (",");
>   	    }
> -	  printf ("%-10s", buf);
> +	  if (l < 10)
> +	    printf("%*s", 10 - l, " ");
> +	  else
> +	    printf(" ");
>   	  buf[0] = '\0';
>   
>             for (nl = rs->nlist; nl; nl = nl->next)

