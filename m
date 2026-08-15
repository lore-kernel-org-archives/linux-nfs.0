Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9493E230BE9
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 20:46:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786826808; cv=none; b=ISu4PuSFqR/78AmGOh5xwrp171x530JeT87I+ZgIvwGkIS+yVcNpIFT0WqiYWAt2hmTV8HVHQKs3rc5JOPYB8GTH8Hj9dhWX5sk/+SFy6SOtGU2zWhvQPoVTKezfxOwGWeC6BTEAq/aPA1yBb8mXAJqxrtwFwQ2ekvPKVvX5NJs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786826808; c=relaxed/simple;
	bh=TQfNKP22bKcbNhhZK2BRVYXu9bcBcEuN7wusyrlD+c0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=d7yDDUw4mDpi6ps6UGFXSRer8pV/MZkoYslMTDFqCUFKh/Nz4cva58+aZvzBiqis+WnQgjasIHwZd6zkCGbmj7HsAh5uMIiqUMqRkn+/oqOP6j2IFHRbM8F3m4CHMnfwsS7LxDQ508Q14VDJDa8g2hsjM+Lt6m9zHXYDgYUHNlU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=L/Hu4cbS; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=OZGxa339; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="L/Hu4cbS";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="OZGxa339"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786826805;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=AuQv+RQSgg6IvSNsJiAyClMWfmlMxSjbvbK5o6qdnsE=;
	b=L/Hu4cbSPbp9Vn/tvjOFvov1qosLgY/6cbV0bdZIzuao64p1zMtnFCJP0wT7UF9wLmlvrX
	KR9YgDAgPTcEuXQFelvoYnABxK/cJdHDnq+KF4NXsoI49Wrxcqj5+pWNB+9O30KsRjM8QM
	6DlzyQdXvXcJz3BkK0Rgd/rqjqyd8Ww=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-6-W_yfhXi5N3q8sqsIrcVZqw-1; Sat, 15 Aug 2026 16:46:38 -0400
X-MC-Unique: W_yfhXi5N3q8sqsIrcVZqw-1
X-Mimecast-MFC-AGG-ID: W_yfhXi5N3q8sqsIrcVZqw_1786826798
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-8e9489f62bfso25327066d6.2
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 13:46:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1786826798; x=1787431598; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=AuQv+RQSgg6IvSNsJiAyClMWfmlMxSjbvbK5o6qdnsE=;
        b=OZGxa339SAyvkcgEYIgd4iy9+8/EakEqIOZIJMZschRtMPDEjE0WvthaelVc2YUzci
         KJBwMtNRtbSnjS11sAYgOjnuHoSDapztv1uW2R/5X8pVilLzXMPLLSn814UeuHimK7K7
         PbrXMtXBrcZCy0cYSr/15J3vc5Gf+jh3OdaZA+o9MIOzntYr5OMGDfDjJuNuCwgnn/CF
         iHOe0sdiGZsZuhsRjX9m2XUDQJiBOoT2D2gBtyY/e06qMQl0TYxaXyw4x8K44rgqvAIl
         Q7dEisv4oZ4Ii46ONdXtGVpa1WpaBCo4hada0k+c33+u+d2DAXg4ALnd34Z8fV5CxTsm
         y35g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786826798; x=1787431598;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AuQv+RQSgg6IvSNsJiAyClMWfmlMxSjbvbK5o6qdnsE=;
        b=XhsCUK1tENtDfonSmx1ri8X4LiPPU8DxV0gwxNo+7z65zjo4DObvkvPoSi/S0Ej8cE
         CQw2QA58/O7YqL/JpDd5fvcGzrmsplCmQfWdxa7IR1zS14zPdXYibcOxQT4o/JcIwoem
         jDOwhKLbDud9V23Imj0ZW9shDw9lFM5c+h0TJIJhe020YIcZsKM+/gTjmBaKSMOhAIk7
         UAiH/w3GdsgrRsXyn6BmMXY9AFn+y9wXDc3r+KT0ifcFp6o20rJkruwVgag50btTCBC6
         SvbcEDQzwGdFWtG6eSWb5lkajwLIe/P3c2INlY/AAWv/cbFh/D4dUCK4F+YAhn4PyuWA
         1eiQ==
X-Forwarded-Encrypted: i=1; AHgh+Rqk1ZZGVmjwKkZQQwmEUlZ9v6eylXS3Rrre2J6WZN0dbRLHGJ0TpK3viF4uvFoqdSmiEDNITzkqoxc=@vger.kernel.org
X-Gm-Message-State: AOJu0YwRXDGKj5JIQU4z1gkNu64LgZhlqpHx5bN6MBEgNPVbkI/schaw
	njRm5cymFe0TrJuPRZMyH8g/uNDBNjpac/zRRF7IQ0mNrrx5euMe0IdQkL4TrmgDhNYkiyUEpzS
	uqvgJR9MOE9wOCxI073hjj6UMAGEKMQvyinj6VY+MibcxZVh/vgJaMJIZUAv7aA==
X-Gm-Gg: AR+sD128EuyWVh4tIW7S2IqbKyOEKJvFo2/aXSJwxKQIbX7xWUhuB3QAbYCXm3Ghbwh
	nCniXskORKyOdoI//tgDNIm5JP+dflAGssk6HeEX6AJf16k0D4qorn3iP8o7v1F7XiL/lXg/O0z
	bBw5TJk0eq6n2LFwM0rMP/z+L7qiBqjOIQpVGk3Yk5Qk6fco1YlxT4/kEBQCrsQ4sWLwWdDCpYj
	JcL7ZfHBcBhWaoKVhFkW+exMbLZpaRnrVqn6m1qtdvP50y+EL0mAB4eXOa6pEeuZ/RlQXApqN/2
	6pxCBeAwRPZGLPAmTgQbvmKQe8O9t0mh++TA0noVSk4xvhSJltcBf/3rcxRU7HBV2Ar4f9YkFg=
	=
X-Received: by 2002:ad4:5cc5:0:b0:8ce:e651:5d63 with SMTP id 6a1803df08f44-90a91dda541mr164979106d6.31.1786826798307;
        Sat, 15 Aug 2026 13:46:38 -0700 (PDT)
X-Received: by 2002:ad4:5cc5:0:b0:8ce:e651:5d63 with SMTP id 6a1803df08f44-90a91dda541mr164978896d6.31.1786826797917;
        Sat, 15 Aug 2026 13:46:37 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.57])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90a93544957sm47220206d6.34.2026.08.15.13.46.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 15 Aug 2026 13:46:36 -0700 (PDT)
Message-ID: <df08f184-2fdd-4102-97dd-e7b513f33868@redhat.com>
Date: Sat, 15 Aug 2026 16:46:35 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] statd: fix memory leak in sm_mon_1_svc() when existing
 host re-monitors
To: xuchenchen <xu18736995897@163.com>, linux-nfs@vger.kernel.org
Cc: xuchenchen <xuchenchen@kylinos.cn>
References: <20260728083347.6132-1-xu18736995897@163.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260728083347.6132-1-xu18736995897@163.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 7/28/26 4:33 AM, xuchenchen wrote:
> From: xuchenchen <xuchenchen@kylinos.cn>
> 
> When an already-monitored host sends a new SM_MON request with a
> different priv cookie, the code sets existing=1 and reuses the
> existing notify_list entry. However, clnt->dns_name is overwritten
> with the newly allocated dnsname without freeing the old value,
> causing a memory leak.
> 
> Since statd is a long-running daemon, repeated SM_MON requests with
> changing cookies will accumulate leaked strings.
> 
> Fix by freeing the old dns_name before overwriting it.
> 
> Signed-off-by: xuchenchen <xuchenchen@kylinos.cn>
Committed... (tag: nfs-utils-2-9-3-rc1)

steved.> ---
>   utils/statd/monitor.c | 2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index c76589ca..76ef16f1 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -187,6 +187,8 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>   	NL_MY_VERS(clnt) = id->my_vers;
>   	NL_MY_PROC(clnt) = id->my_proc;
>   	memcpy(NL_PRIV(clnt), argp->priv, SM_PRIV_SIZE);
> +	if (existing)
> +		free(clnt->dns_name);
>   	clnt->dns_name = dnsname;
>   
>   	/*

