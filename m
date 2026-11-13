Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794565073;
	b=1u3V78qCYx//LCr1+mfqGgRcB47KLNNMeZs3TFfshMBh0TStn/2vJ2Po6egD0x5w8Bb3
	 DvREl6dau/4r0nOH2wY5Vim3W4LhmpR1Ihz4P8j6XNcWpBBYs9z+b363zxqF0YQdza+Qb
	 kNsDhE5i4yOubkTvwv2fnrHKBU1KZ1fKqpdl8bJWVn26EsEJHkbaz7T5OY3Q0lFsrdi19
	 YEmqGBucP+ea21AvZXa57MUS8nZEPL5nJkjuCJQR8jcxLq/4+HF1+yj5RgMuKXaYtZnC5
	 sJXRnt0ADt1NuK4Ornf1QQM3M5DNLIQtlD+X/F6UuN4JHpKvFZL0pGGnpUKmKZXVqCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794565073;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=zqPqkCGOaO5RL/5NE1UeXRxAO7AqEHmUDDsiHSGxDsA=;
	b=bnfsdV3bHlywQlFW1aaolZkzwaDzj7Cosy2/BPVjm976mWaqQOfQn4CowoTLQ764limz
	 iw1IvIGhFwOfJ3hryXAXF+wgCmeOAE/H0JYje3d8l3bWFSKq0E20lsIDqi8eokKu7p6Rp
	 mxh01hKSLxcLKlNzfpbX4/H0NgyNod5b8HXgrEPzchNX2a8siP1cO8fse856HDqCIwvc7
	 cdxzEFHV3W0o+vmG5jILw9zwnhZpWceH3/QOp2lQ2DMMuww2JKRjJFBLBBijUWS4drGJH
	 kLqGQ2N2rzMRN7CNRENirEAWydhhHrnVFNGh4wiqScsuu4vbpVcoVHE1vm6BzuPzAww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=hEEG7fG6;
	arc=none smtp.remote-ip=209.85.128.42
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BE87606A338
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:17:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5BE87606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=hEEG7fG6
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4a35d5d4a20so13807555e9.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:17:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794565072; x=1795169872; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=zqPqkCGOaO5RL/5NE1UeXRxAO7AqEHmUDDsiHSGxDsA=;
        b=hEEG7fG6RzQkOoGSL66zkn+hWpy0b8TxpW+CxGFBwGxbhLfdgmFqwESmbjaY7MScGa
         1TTEC4ZDzMo/nTmQbATUq4OC5CVK8FiegRjrCOceUr+V68t+3IyOPEhrmauT/typpuMH
         7BtZ7bLX9twnpc3pST7EzNdPnkg3BFhqHXhYG5RTwPNXEKUOMAEYxir+CLBCGEbp4xnq
         ot2tG8XA7sYEn5cZCga4RcL6w3I4tCQX2A1rGgTmCQohN7lvb4NCOhavzOt0i7fRXz7K
         0fiOYrUI/s1Mo3f+qCL5v2ciULr5WU1WUhy3OFmgCMCM2mU4bZM+JgAT1J65gELN03wt
         2Tdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794565072; x=1795169872;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zqPqkCGOaO5RL/5NE1UeXRxAO7AqEHmUDDsiHSGxDsA=;
        b=f9lvD8cHeEkybaHUjHWprqndyU+5MjTU+8OWYBkkZbpbqOB+n/vDPVzRquN9wnAfdW
         9IGNG+LOJC3LaLaI7Epyk++6tGtd2OmTKugOJ++ah/MKTqGk38gpp+9a9CO2RPxKL4Cd
         s8ykSg0tGDeKXR+GlRwHmlJWRytHyLcfZAw2uSCJAmYTRsChJ1KxuDBvaj96wHKlXn2Z
         JAuejwmx1y6MKqQBkoTzS39F17xIeG/0CqSuxJWsE9b1CXGChgG4XnA08XGSCjKVle1o
         JcqWgrn59lViIy+uGjFz3jODLTRxhd4o8GM72k2lnB0eNWsMwTtHbXZxvJoHiuie6Pqe
         sefw==
X-Forwarded-Encrypted: i=1; AL+hErH6sb1/PJqF4ZQDGYVmKLJtSQcgCFe15jRb57t8vJ1MPSsAlFu9M2mfq/J9ku8nHvq9gZectmuFqBA=@vger.kernel.org
X-Gm-Message-State: APuU4Z8Bm6ixVfQcWW7nDijarknSVLSNZVvwwo7AbHopsNbjMDhpwKZ4
	QfUFOEJO+IULrMg5TUCmSdY+ytXO5LAz4yONNFDZp+ecpYdU2sZc2fnzLUQoQGBFKyt3
X-Gm-Gg: AYBFou3ilu+SOPehcsr0T8sdS5N/rFxCvQ+scIFk0uG7lCKP8aCTDu9h4qsW0nDqi3n
	qwbWoUFX95kJ+mTdU+E48w+fW5DtvBVulND7NqTU1k/fl5o8rcrP8bD+SuuZi6900Y+NyZ/W/zH
	tv9cp+R4bo/anASO/0tBLjP54HRT6wIPuBbkJskryHNTyNIr489HX9jPGF7YbCDaIQrb4O7Kw4s
	uDL8QvsIGkOmgZaXdA1Rka+1JAi8iGmYNFFNVuj0SF5+FhD5dZu+bBOCd7cIJxsZ4q6wJXWMX+V
	XZk4Ws3TjNUKncgmPePB9F34s0ArHkl2npq/EJK/O6jFiT8NgekVaQvDKFOQFLZ/BPJC13s3Vga
	efOFn6YYHA8aUBQpnCdNoDdPJrA0hY+kOXz4mOlvgccrCDmzKgrVkWGwfbcT5vHpG15cF094TWt
	DmOG9GsEHs4ClbcehzqtoFYyFRHfiUui6YcQi2qn4ZkoVsuSw8zkgwPrWVHUPV0YQQCLHj/JoVa
	wXOZ9MSQTXyQEd0PYTNOOXevCtjDIyZebj3dGGEFRhpyTwqpxrNmifn/ofV3UyohGEBTVXI4kcF
	4sr7+CBCrxbW+Z2Gs5NhCLfm+E59HrOaKTDsOKMnVMwjLpg4UN8m7zs8vaLP9ww=
X-Received: by 2002:a05:600c:45d4:b0:4a0:23f:8b0d with SMTP id 5b1f17b1804b1-4bb559f6f31mr43851425e9.2.1794565071804;
        Fri, 13 Nov 2026 02:17:51 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c7da37b19sm3937770f8f.5.2026.11.13.02.17.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:17:51 -0800 (PST)
Message-ID: <7cde6f3091f9d90593e4a6441723b6b889cc4024.camel@amutable.com>
Subject: Re: [PATCH RFC 35/41] zloop: refuse zone files on pseudo filesystems
From: Alexander Mikhalitsyn <alex@amutable.com>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef
 Bacik	 <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, 	driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, 	fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, 	xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, 	linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, 	linux-usb@vger.kernel.org, Amir Goldstein
 <amir73il@gmail.com>, 	linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
Date: Fri, 13 Nov 2026 11:17:48 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-35-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-35-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2-0+deb13u1 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-11-10 at 10:14 +0100, Christian Brauner wrote:
> zloop opens its zone files by name below the base directory but a
> bind
> mount can put any file there, including a procfs or sysfs file.
> Refuse
> files on pseudo filesystems as zone files just like loop does.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0drivers/block/zloop.c | 5 +++++
> =C2=A01 file changed, 5 insertions(+)
>=20
> diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
> index 65634a39b0bf..dcc06dd47b04 100644
> --- a/drivers/block/zloop.c
> +++ b/drivers/block/zloop.c
> @@ -1137,6 +1137,11 @@ static int zloop_init_zone(struct zloop_device
> *zlo, struct zloop_options *opts,
> =C2=A0		goto out_fput;
> =C2=A0	}
> =C2=A0
> +	if (file_is_pseudo(zone->file)) {
> +		ret =3D -EINVAL;
> +		goto out_fput;
> +	}
> +
> =C2=A0	if (zlo->block_size) {
> =C2=A0		ret =3D zloop_get_block_size(zlo, zone);
> =C2=A0		if (ret)
