Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DF2035C1B0
	for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 08:13:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777364017; cv=none; b=Be4mXf3ksL3uYa0SDlQvHtpJOB1vqba5RtTIWvuJtYAMrh+JQBSQv4MKqHZdaHbXccCy/JYOZg3h5dT3VE5foF/kTNFUUUlv04KKlrnsse20EcJbiNnBIxq8SFS1Ilj8czMBM5jMcw1k55aigLr7Jn2g8uq2fiWwxAch9oDN9q0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777364017; c=relaxed/simple;
	bh=MuX9R7g0ibYZt/H23695t3Ljwapt0k/HhA3xqv6fYAg=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:References:
	 In-Reply-To:Content-Type; b=Eu7QQTlv8so57Q84X9MaZsGVoBumFjOpywykmq7Sn0v2NnVBOK995GkTGrH9083RlpxbnLb7B+H4/vKd2DqgtgL5BU9fd5dW4nmk9EA0GENTY2dDBmUrTuKAf4viXbRS4VuxCXyqSDhbI+hq0cp9gjNcgjdRLXHBAxpBtyG3v64=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.221.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-wr1-f42.google.com with SMTP id ffacd0b85a97d-43cf7683a28so7370935f8f.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 01:13:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777364012; x=1777968812;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :reply-to:to:from:subject:user-agent:mime-version:date:message-id
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=dTyFppfYDKUKixn17xsZIDtt9tbmNW4VBMg2jP/+dGk=;
        b=CNNzjtoJ6qCOYrLRG4hh8YFjlg4alonabo9TRCm7WK5QOWy1OkGdhANjWaKxaeKgJc
         dBvR0XSl8eV+BxgxsOLwQkaUTNSp2iYblTI0AB2xfb3hkv1uyKaGZlZAXnKxguF44Z93
         n5eoKKSzUWzPXpWkaRI/drRFcuoFA/4Syahf5V7Is19PlaC2JlS/NuWqQDocxotTNuhp
         j/pnAkHPKEpoCenHzFmeD3xmiirzWWMD+C8lkMX1mDzRPlMd/Ca/BEQLbf2A97yR1keb
         4DrNIJjT82TKEyvGwKDiOnhj/EFxcSzFhVpCmwf5Umd6jUxWFw9LRcEOjz8mksL6BlWI
         ItzQ==
X-Gm-Message-State: AOJu0Yz8n6gzZtTuh5br/yFbG/2LOKrgXWBz7gvZ1AUJZThMT3gsXJMM
	XuZrP396VZzHu6gfDgJ1+VupSuEoKKHP9fV8vXHWyD6UvLGB2/6P+oZONI93YQ==
X-Gm-Gg: AeBDievDSvHe7wL32EjERZP6XQD4IcQuU0ZAMgpm/kBeIW6Nfsx0x/Qk51+JjZtynOv
	9bVWfw3oO8Tm1JQoeXm6fu/qCvxor7L9CARf4kZGh5EUoaToxYLjRMrLMPrltCuzKXnkQBeZ2xB
	AOYQQLccDJgnfDZCuNXK9aEBKo5PxhYhyd6N1mQgInPDaa8XGfH3drpCZmpxY5blFK1mbRvFd/5
	NWAP54nR/kzCRgiZZEoaMsUQXOnL1mIvomFv/t8VfhWHW3gBr03UchK/0qSqvZxlb8a4oCsox8+
	f69je6+JbBDFyiYDkL+ZKJbH5Ryi/aHY/zmZa437AIy3rA6vZ8IgYbCDnCVHPk0kzmVIm7WnRQg
	yTsXy/xXUthbmHdo/KOFruiqelW80Ciw8eOpy7zwFGSA51UgFR4bfTEOUvciv3ibOCKyn1g4i1w
	7+I3ssmHys0CblI+ORtki5oW/8usB+oDPoUjE5DbF4ve5gvMJ0K3REERV9X5xeHW1s/FseKb0Y3
	g==
X-Received: by 2002:a05:6000:2f84:b0:43e:a70d:763c with SMTP id ffacd0b85a97d-4464a166a76mr3744922f8f.42.1777364012183;
        Tue, 28 Apr 2026 01:13:32 -0700 (PDT)
Received: from [10.50.5.21] (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4463cb59bacsm4539546f8f.6.2026.04.28.01.13.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 28 Apr 2026 01:13:31 -0700 (PDT)
Message-ID: <d61888c7-347e-4ddd-a8f8-b0095c5c8700@grimberg.me>
Date: Tue, 28 Apr 2026 11:13:29 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] pNFS/filelayout: fix cheking if a layout is striped
From: Sagi Grimberg <sagi@grimberg.me>
To: linux-nfs@vger.kernel.org,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 Anna Schumaker <anna@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>
Reply-To: sagi@grimberg.me
References: <20260427062757.647256-1-sagi@grimberg.me>
Content-Language: en-US
In-Reply-To: <20260427062757.647256-1-sagi@grimberg.me>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

CC Olga

On 27/04/2026 9:27, Sagi Grimberg wrote:
> A layout can be striped with num_fh = 1. It is perfectly possible that
> both MDS and DSs can handle the same filehandle, which is exactly the
> case in vast pnfs layouts. Hence check according to stripe_count > 1,
> which is the correct check to begin with.
>
> We should not be called with flseg->dsaddr = NULL, but if for some reason
> we do, return our best guess with is flseg->num_fh > 1.
>
> Fixes: a6b9d2fa0024 ("pNFS/filelayout: Fix coalescing test for single DS")
> Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
> ---
>   fs/nfs/filelayout/filelayout.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 90a11afa5d05..c28b3d5bfa8c 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -778,6 +778,8 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
>   static bool
>   filelayout_lseg_is_striped(const struct nfs4_filelayout_segment *flseg)
>   {
> +	if (flseg->dsaddr)
> +		return flseg->dsaddr->stripe_count > 1;
>   	return flseg->num_fh > 1;
>   }
>   

