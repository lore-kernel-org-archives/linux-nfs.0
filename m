Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.225.139
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794573425;
	b=Omv4IJozQKucV+58+FEL+hQQqjLQM8OgRmsEPfh0xcxXa4qZnw9YtD5G3yTG0G8uf7go
	 wOFF2H8vcSK2bRjv3E2Rztdx6i3/sKcaYxdzd21LNJ2oTz1eASKS6MOIf6Nd8KORbJLRn
	 7VLKV4vHAp5wXXBzpbBX+3IUlc8wyv4zepymTupcxUcXDDMStx/NPtpCCNpNaHh5HBjr1
	 cZolU/UxFkgnrCaLKH5kgOW6B//o9OHOezjBb2beD6LJx9FFwyxz6S3L+v4f81EdNGYqL
	 aNrHKs8Wdua8TdLoWhlteTYa3SjbmPLJHr6LWbpW25aj2Q94Vybb2IuAdUqd0bG/WYA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794573425;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=87/Ge5NhXdmtGpcXCLUvnqWpWEAxiW5M6eWOW+m4zUs=;
	b=Ox03DTHtUAI8+bDNMKnBe9l15y/Y9nIw7DObI0WGM/HIQjVFB5iezE92RRwAZgkjGmP1
	 qRHqS4MEAnkiFs8KZPD1HwG5lFH1SfKvTVXMvHcMXput/q4ILND3zz4hlGAq6JyAeNyW+
	 CmrPQU4QcgzeA39C8Ke++kWRgTdGjYrWroa+hY4bZpyO1DeBY8CGuPZPbEBusIW50wNlS
	 8EuaiXEKoA9rkhJ4e6rRKPYRPsBX3TGgn24uSFmbjNavFIJmcyIw8AvCrKCv6kbIvicJy
	 vIWTjE0FM+0ZYn1i/KrLg7pqYYA01XgT1th5DOBuAPfp5jEYhNvcrhkoVgHPSgBafIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=n2XPHptJ;
	arc=none smtp.remote-ip=74.125.225.139
Received: from mail-wm2-f11.google.com (mail-wm2-f11.google.com [74.125.225.139])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D913B606A335
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 12:37:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D913B606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=n2XPHptJ
Received: by mail-wm2-f11.google.com with SMTP id 5b1f17b1804b1-4a5f76661b5so3542095e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 04:37:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794573423; x=1795178223; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=87/Ge5NhXdmtGpcXCLUvnqWpWEAxiW5M6eWOW+m4zUs=;
        b=n2XPHptJWAiGnWBjuWK6g5NkFljgiKFcabC8Vn0J/U7Rs5oCxIs8ae//bm8icbKFtW
         GhaGag1Xoi7ZyXwdHESo4gzqQGVIFHJ4SWyDVffZrMrzihrR6J8Y41NroO1pUm4S3UEM
         GevRMV87lpSFNCzDE68IInZGbL5X+gYDk7IApotAPKeUo9xOfBbHGBSC5mcggp0KJBcK
         Nc+e1mR1SmgmgC0Frha4Bk72pKDTzd14yUseYASwtvG8qZfbG+gNn4GmoQhA8ODET64L
         X6SskqZIriPJvj35d5mhI8G8hobVKdLKjnxeG6bMHAYcCPTjUD9dRkaaJK3nWVTXV/IA
         bDIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794573423; x=1795178223;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=87/Ge5NhXdmtGpcXCLUvnqWpWEAxiW5M6eWOW+m4zUs=;
        b=2odnH0QQqbb64GYitExw/qulyDeTTlKoTswXydn8J/RST/CU22AJwiB9BisyuY3KKp
         IdGP5gDDWt0rPX+I/tWhpzPEbxlzOI1tj30Y3acptzacapeu0h16uY8M1zcIrrTusr7h
         AZMz3vgmyjxfp8QtKG0EgsyD3PXhotRFUYDPYn+NALYbpKrWypSxT7aNM0mR8+sqs8mX
         +YqB8KdTw53bfFINXNdV/2xHqlmtC+tpaD2dmqoiYSOsQtxPCCI11K5KvRWT1aefYfbh
         sz7e0bnilsF+wbjAPeYm50TQRuDzhBbtJys9YNOx6RvxGW9fRiVctOOrOJZiTqjIzGKO
         p/Og==
X-Forwarded-Encrypted: i=1; AL+hErGS6MRpp0u277JvyeCv0mB1a03atUTPztrtNLa3LosOKMog2kB+KRKmEKkbbVIFy9pP8fJlRXgAtF8=@vger.kernel.org
X-Gm-Message-State: APuU4Z9C/PCtFkpfOK87pzixyqRUiSfplKAhmJ4y1tGszS7tMXFsEZ03
	0SPmDdVO08wCe/9HTyDo9CEIgGb4VHcT5G2+EsvkB0Ux7QfqPNLm/Hkb3c2WYbYf7KLz
X-Gm-Gg: AYBFou2p32atVM6GqK/WzPR2zYhfcVvTEQOXPiTS0jxYLZX/2z6OgB6TudldGxcFnap
	HrRTuFef3EpKRASczvgupcpEG8b5IUDYIbgR5wVPkk29I+9y/yv60cKldB1O6d/ZoP3ObZrtITT
	5oHDs+S8NqivDDRSh07Xodkg2rVg17bNbzhn0E58ma2HtZ5/zB4vv5RepSUzvi51pWpy2any7nj
	s4MKWpnDvp3YHfbqWNaTcCWPZQ5PhgfLsnwoR/K+G5sBKmmFTB58KFfCpSBX6wNQqbEh6fzzmeo
	eIVsDVxDm85Xa7oIMqaUdlT2ezatDkBtipFaUO7T2W0QbD0D1oN0j9IoHuUP8yPHCPVWsKmSRlH
	Q0lIbKhG5GiGjCnVbknKool8FqX73z669xVftJYh87i85JR71tXmPNqPwFl+5bmkSRDOd0BvscS
	dt329maE6bOOzHYaX45D9yt9rPVGEpAeC0WXQaWSUso1QvzUKEjJkZ5ch5n0muJmJ0Fml5OL/dW
	ETn3oMS6+JM2L8Jar7Q7OT32xXyR3z//DnnJq3M/0BhcxMBIBP+E4uOzhsV9aawOhLuF6wXQNut
	nedHOT2WUH0IqPCpmLam4G/hBh2jrUhTT4sp/RhEvQDvHX60d0k3AQkOOroachbUTGUcEzAy/wB
	qvM3w5vLK
X-Received: by 2002:a05:600c:b86:b0:4b5:d95c:2378 with SMTP id 5b1f17b1804b1-4bb55ac4030mr49782945e9.34.1794573423157;
        Fri, 13 Nov 2026 04:37:03 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb55af2901sm57437255e9.13.2026.11.13.04.37.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 04:37:02 -0800 (PST)
Message-ID: <f12140be54ffc4d1e8e4026f80c41c75cf5727e0.camel@amutable.com>
Subject: Re: [PATCH RFC 39/41] usb: gadget: f_mass_storage: refuse files on
 pseudo filesystems
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
Date: Fri, 13 Nov 2026 13:36:59 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-39-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-39-4c998976c6c7@kernel.org>
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
> fsg_lun_open() takes any regular file as the backing file of a LUN.
> The
> file-storage kthread then reads and writes it with kernel_read() and
> kernel_write() on behalf of the USB host. With a procfs or sysfs file
> behind a LUN the host gets to read and write kernel interfaces with
> kernel credentials. Refuse files on pseudo filesystems just like loop
> does.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0drivers/usb/gadget/function/storage_common.c | 5 +++++
> =C2=A01 file changed, 5 insertions(+)
>=20
> diff --git a/drivers/usb/gadget/function/storage_common.c
> b/drivers/usb/gadget/function/storage_common.c
> index 75831f2c7abe..83683ade20c2 100644
> --- a/drivers/usb/gadget/function/storage_common.c
> +++ b/drivers/usb/gadget/function/storage_common.c
> @@ -211,6 +211,11 @@ int fsg_lun_open(struct fsg_lun *curlun, const
> char *filename)
> =C2=A0		goto out;
> =C2=A0	}
> =C2=A0
> +	if (file_is_pseudo(filp)) {
> +		LINFO(curlun, "file on a pseudo filesystem: %s\n",
> filename);
> +		goto out;
> +	}
> +
> =C2=A0	/*
> =C2=A0	 * If we can't read the file, it's no good.
> =C2=A0	 * If we can't write the file, use it read-only.
