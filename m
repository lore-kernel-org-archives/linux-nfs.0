Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C05B236F8F2
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 05:05:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789362360; cv=none; b=tNZEPog6IXZaUcZrfqZQWktjmnqQyb0nvQQXbur3X85FVw4d3tFj9o2O2eW1FjF9Y5+QtMnFHR7GYjBGHA/eS6INNBtq3UUFBDUE74AMcH9+ZpjU6v3pWRQMPYKBZdi6MHGaKkBIdOcRynKGL1hWNk88aCxj4kJGQjU1QRmsV4Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789362360; c=relaxed/simple;
	bh=zcF+d8QqoS7LYz+3HpIsA8oBnVW7IkA4qUZhNj3Uwtc=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=lKM8DcVJv2Ba4UeY5R7xfe1e4hhe5Dnn3pre3SaJHPvM3a+Nmr/7fJqMXei1w2+Dlj+OMl0t+UWtlxKY0M/01XwavP1Rlrky0obZJ4PDMB+AXphwg1Zd/nxxcGW5PMl4KCNAbrwGfpzeZdKAfyB1WwOKxtr02eCC56hJ8v60AuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IkOKTOLP; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=NZ7v5NVO; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IkOKTOLP";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="NZ7v5NVO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789362357;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gRBigp4qh8TFPQ5GJrLs1GVHs+2RlYTN4XTrx1btnfg=;
	b=IkOKTOLP9TdVHtxlGnjSU6O1Ef6uN614DE9XFl3ZmFl+bYWK9oWm4TftmRE3178b+gm0Am
	bXe9Nm4cp5VvBYv21/AkXIIj6QeAqAbuRNVJf1S3GeU9zgneCH1vtXWoN27LakTiavAsbD
	s4XQxs3y6oykE0kmDGwHwBXRN839HOY=
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com
 [209.85.222.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-61-0AqUb44POhKwG8wHY4gc2Q-1; Mon, 14 Sep 2026 01:05:55 -0400
X-MC-Unique: 0AqUb44POhKwG8wHY4gc2Q-1
X-Mimecast-MFC-AGG-ID: 0AqUb44POhKwG8wHY4gc2Q_1789362355
Received: by mail-qk1-f198.google.com with SMTP id af79cd13be357-93a082c014aso370853585a.0
        for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 22:05:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789362355; x=1789967155; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=gRBigp4qh8TFPQ5GJrLs1GVHs+2RlYTN4XTrx1btnfg=;
        b=NZ7v5NVOT9I7u4OnwtNTcttMaCbXs9i4AipDGTJ5evjrqHa2lmYsIlA0xdAH8BZ05k
         uLGJCUQtEd93tMimuJNnrr2SgTNwR/eQ1qhxSblzgQULM9uN4rQQdBLQmJOCM3JDtR8f
         Y0DhnX0AmwEh3GON26FTPxsRIaJkFMKGnbcJivAovYJEbKK/jYI3gXGKz5twt9ceXBlL
         WKFdQOQ+fsv/qxpxZ5azTOsYKItXnzG52NnDRuAiK9RtPQrDkjyzJPnX5ilq4bHreWKD
         RJKaiw6kjCav586oaBh+Tujpj+7fw1PwXVrc3b+P9+Eu/+VdluJM8LVy+Vqe+ODqM9JP
         yluQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789362355; x=1789967155;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gRBigp4qh8TFPQ5GJrLs1GVHs+2RlYTN4XTrx1btnfg=;
        b=TbSoz/ON7rWvORLxQ5XqgU0aaGD9x5MqE6IsSyv2pSLYoggTDFJ82iKkmW1Mo4E9FK
         zMDehxuAKIYBscD9SrLuMszFqr6pQb5gt3WReathUm+o3ZuyFkBo94EeHWcARXrcg2O3
         sScf9R/UCrTl802zz2fv2olZq07W5L/WkTRFp0av6iZVTpmYUa2cp6cG5TMd423J1+oW
         ZRNdtb4HJVU21c3S24bXAnfdX6c9+Pn4A/pu4a1iwiGN/3RSYgudnV8AWr/xtYLGdOin
         ytvaKxPb3zPoSN0PtWWTMRdomaI4F4OQEJuTvjHlYI6VznHS8Otrkl6/ZTXjCVWvv5Dn
         q0Wg==
X-Forwarded-Encrypted: i=1; AKwUvByQ0gyhO4ovUDyA7nRdsqKF9TOtcPBr6Ww1jQf2mZjDmwA6vPIWlohuGrn+oPA/RLDJxVAXZ0kcdDs=@vger.kernel.org
X-Gm-Message-State: AFuF++kKNhm5RT5mrW1etJSKzqrg5G3LbdO/SupYmgVA96NXElgvFBC8
	xDaXDUaHa+0JGREausplC7izPIxyDtM7NlhCFe6oFo/P95Ur2BVYd17RMX/K4hEog+9GKvGw1gI
	uV/shnQSBgA4SyaPVxL5rKY61z9A3ZfF0MBGoVC6ssibbzKrY9QgpftUMZZocQD9y9DSxzQ==
X-Gm-Gg: AYBFou0oxzOre3xIZy0Mv4Q2h6pPMPlTc9CII8+qLb3sv3sMcE8SEr+ymaIKzlbbuTY
	24XeXzo5XkWA3JGxmySfss161DVpmiW5trFfR3r9+KqxttH3ql1tCxDX1UNhO+Sh5PxlEW1EYIY
	QWP4QE8gTWymn5VhaFM2j98Pn367WRfFHJfVB+kR2tx4bXsXB/Mb5tLcOS4R0ZxuFxufTdw8ggv
	rYUpvn+UYBSRnsShXOW+zICRCWVZZK4fzIdCHybeNOKbe39J58RUfAI8aUG/F0/TcHgy5FCnEX8
	jZoH5p1VGeiKO+rIJCJVZBovUWFPfSnO36p5SJ5uqnTdregIgMofqcVNqU9KZJXj/3XWM5rwIKQ
	=
X-Received: by 2002:a05:620a:27c1:b0:939:5d22:d1f0 with SMTP id af79cd13be357-93a185557bbmr479730085a.2.1789362354992;
        Sun, 13 Sep 2026 22:05:54 -0700 (PDT)
X-Received: by 2002:a05:620a:27c1:b0:939:5d22:d1f0 with SMTP id af79cd13be357-93a185557bbmr479728685a.2.1789362354572;
        Sun, 13 Sep 2026 22:05:54 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-939f81b022esm730661385a.25.2026.09.13.22.05.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 13 Sep 2026 22:05:53 -0700 (PDT)
Message-ID: <a620192f-57c7-443f-b09b-3d50517122c6@redhat.com>
Date: Mon, 14 Sep 2026 01:05:52 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/2] gssd, statd: correct command help text
To: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org
References: <20260831104221.2310-1-prabhakar.pujeri@dell.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260831104221.2310-1-prabhakar.pujeri@dell.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/31/26 6:42 AM, Prabhakar Pujeri wrote:
> Bring the command help in line with the options accepted by rpc.gssd and
> rpc.statd.  The first patch removes a stale rpc.gssd option and adds its
> timeout option.  The second adds the existing NLM port options to rpc.statd
> usage output.
> 
> The series is based on current nfs-utils master.  A fresh autotools build
> and make check complete successfully; the statd integration test is skipped
> when its required service environment is unavailable.
> 
> Prabhakar Pujeri (2):
>    gssd: sync usage() and man page synopsis with actual options
>    statd: document the NLM port options in usage()
> 
>   utils/gssd/gssd.c   | 2 +-
>   utils/gssd/gssd.man | 2 +-
>   utils/statd/statd.c | 2 ++
>   3 files changed, 4 insertions(+), 2 deletions(-)
> 
Committed... (tag: nfs-utils-2-9-3-rc3)

steved.

