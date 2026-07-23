Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39C184963A4
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 12:26:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784809601; cv=none; b=Q2tMCkVE/d4DlmU6GWwUBuGGIFmLz3ncoTj76B2SNxcRH/Rq70xeeeXgJkhBiZp0ZxNnl9T4p66HUs7I4D8FqToa0zCL6cLp1A57RiNa3husKPqLKsbEbEh0b2jnlnXiIttR04Ou7bqe2xAnzeJMkGfjEs2QPAawYhrnZbUP20Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784809601; c=relaxed/simple;
	bh=Gl0Taoyb5uCt46ZR7B1CDIQeufnG8D3rH+PJXOKA+7w=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=b3dWssPCw7PnW1Y1qy2Vm6UN3cnLPAVj/XkTkUAUZ3h+GvX6Vtpk0eCGVpmcsdqhqUV2+EHClaoJuoVlaA0tAeuJtajSAh31jZGX2/bMtjheuchDWtq3tmPX05bbltCwaK4t/ts75Q0FU+aUSz/xRyeZXzHuEdzilaXWRQxDUk4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=bT4zPsNE; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=JD+6763a; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bT4zPsNE";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="JD+6763a"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784809599;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=n2KAkhNZSxf8FD+Ug85QW3Jz29t4fKh/YWHQoMZuTLQ=;
	b=bT4zPsNEcdgZLB1pjNavu7qovIzHoaYEYIgGSIGiOy65KMU3XN+F4mj/TZzwWeSEpmeH71
	zngeZqpzZR6IBdXAKIAqJc66HO//lfxJohHFyYsA7E54TaJxCV+Gtusg2ZfG4fNkCISL+w
	oO1MNnbXt+Plz2arsiINcJ+OjywrZCM=
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com
 [209.85.160.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-344-SAdPdUezPGGb5Qj-im7Apw-1; Thu, 23 Jul 2026 08:26:38 -0400
X-MC-Unique: SAdPdUezPGGb5Qj-im7Apw-1
X-Mimecast-MFC-AGG-ID: SAdPdUezPGGb5Qj-im7Apw_1784809597
Received: by mail-qt1-f198.google.com with SMTP id d75a77b69052e-522de3c645dso16673901cf.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 05:26:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1784809597; x=1785414397; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=n2KAkhNZSxf8FD+Ug85QW3Jz29t4fKh/YWHQoMZuTLQ=;
        b=JD+6763aZRq7V08qsX0OQmkLHE9i4UFJ51iHXU/huxO5JYmLuaSJa7oGuUFkcEuU85
         YFj/ZZOFN/MnaZgKEMFBYSjbeSkSzV3dxlV11fd+cuJjzXN+etK35/z/88a2XEtyeBzj
         +t4xtzLbGYIQS1b/vDuWre1rBPnWQmtPOp+xujmcig9nf46Sidhh7eFUZ3lzrytpnYxc
         iTCy5FBd0bkEHhWPWsZRj8Ii97IKUmeRVx3DwJeGvwHE9KROKC7Ro4ndgdiwQyv18usE
         WvQRGNYwD6DNdmGTUldtHZ9gSc3dcKtey8OcXpyzi2zcN6c3KfQc6qAQFIfnhZ5Qksrg
         Tjag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784809597; x=1785414397;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=n2KAkhNZSxf8FD+Ug85QW3Jz29t4fKh/YWHQoMZuTLQ=;
        b=i19ukiGAaW/M9wH/dZDnBmi5YJDwhUFuOjMx5ZznKoZHnFFKlQk4kCGBAYriV0LQNA
         xNsEu4GKzOab4VgYmJv/IUv3chX5bsr0/Kh7+03ZyWnNQ5H4Y0PJtaMhQvdBnHxXJ2Ll
         XD98lwpXf7aZN62IUrm3/YCLU2cn9LbwLQdQT90F2U8/gZo9YqUSdeSMNR+ifcu4+HFx
         oPwFniMNT0fFGEYfX4NPOzA8K/TDlDkDfWwUenvcIBRlM6+FCIgqIHQBj1Fk/uqIyK6Y
         Xy6fs8TT1COGBZmwEZ/UMQJRm8z4JAQck4QjtNvT+xoCSEUyou8HxH+yTWwTn68RXZgC
         0jNQ==
X-Gm-Message-State: AOJu0YxNiA/7OvoSG0SF9o16NAMoROgTPSC2Fa8w49gW/z+FKm3vED20
	juT6VKMFYCTiUnrAz6bWJYkqWU+XSPh1jwox5A0rOyXyU5MWyu61MMI8ds3VYo+Ak0dKfMIHYoF
	v4ZDYPIyQVq/DZcd9O6pp9N3kgSrEmtVIohVCCviDc+N+cZClB93c0fyfs+kfjA==
X-Gm-Gg: AR+sD135FoOUckYa7Udwjoq7vB60hJhVk3YDBkU9fQeUdz+UompP6zPudgAVZ23S+Pe
	uNlZ0D6t0W2SRV+p21pVoGLEXGomBE8zOOxt/yNDDqKXsP12sZS4uqi3JYDxJzmeSiKpZ/OL4RF
	hkTEh/Sv2/DDOmbp9rVrF3yeGzt31wfneU3iv/K29FAtMaHEPz990fT+qoLtEzi7arW4/X6kh6X
	ED/3QMwBmx7Vk3iSJQEcazLaUkXDqta6ylE7soItdE/Nb+yQM++U0LnAj506hDUW2BrxYMHN+dI
	ysp2Q1NY/9EknvTMIw5t/u57qJu+sw/+dM/4SN5EE0HqsnxpVXrtSzz0+DT4BV2UmXvm5IjDBC7
	f
X-Received: by 2002:a05:622a:400f:b0:51a:8dc5:bf89 with SMTP id d75a77b69052e-5283ddd1617mr27088871cf.5.1784809597360;
        Thu, 23 Jul 2026 05:26:37 -0700 (PDT)
X-Received: by 2002:a05:622a:400f:b0:51a:8dc5:bf89 with SMTP id d75a77b69052e-5283ddd1617mr27088551cf.5.1784809596948;
        Thu, 23 Jul 2026 05:26:36 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.243.135])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907ba8b31dcsm43697476d6.3.2026.07.23.05.26.35
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 23 Jul 2026 05:26:36 -0700 (PDT)
Message-ID: <edef7e36-215c-4d04-b35e-acd090e9bd56@redhat.com>
Date: Thu, 23 Jul 2026 08:26:34 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: gssd: fix memory leak in gssd_free_client
To: "zhangjian (CG)" <zhangjian496@huawei.com>, chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
References: <a0df2e1c-27fe-44cd-9a97-f04134f029f5@huawei.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <a0df2e1c-27fe-44cd-9a97-f04134f029f5@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 7/14/26 4:42 AM, zhangjian (CG) wrote:
> clp->servername is always not null, so upcall_* is never free.
> 
> Signed-off-by: zhangjian <zhangjian496@huawei.com>
Committed... (tag: nfs-utils-2-9-2-rc6)

steved.
> ---
>   utils/gssd/gssd.c | 24 ++++++++++++++----------
>   1 file changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 1c901991..bad92321 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -360,6 +360,10 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
>   	clp->prog = program;
>   	clp->vers = version;
>   	clp->protocol = protoname;
> +	clp->upcall_address = NULL;
> +	clp->upcall_port = NULL;
> +	clp->upcall_protoname = NULL;
> +	clp->upcall_service = NULL;
>   
>   	goto out;
>   
> @@ -414,16 +418,16 @@ gssd_free_client(struct clnt_info *clp)
>   	free(clp->servicename);
>   	free(clp->servername);
>   	free(clp->protocol);
> -	if (!clp->servername) {
> -		if (clp->upcall_address)
> -			free(clp->upcall_address);
> -		if (clp->upcall_port)
> -			free(clp->upcall_port);
> -		if (clp->upcall_protoname)
> -			free(clp->upcall_protoname);
> -		if (clp->upcall_service)
> -			free(clp->upcall_service);
> -	}
> +
> +	if (clp->upcall_address)
> +		free(clp->upcall_address);
> +	if (clp->upcall_port)
> +		free(clp->upcall_port);
> +	if (clp->upcall_protoname)
> +		free(clp->upcall_protoname);
> +	if (clp->upcall_service)
> +		free(clp->upcall_service);
> +
>   	free(clp);
>   }
>   

