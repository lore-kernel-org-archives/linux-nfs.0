Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564378;
	b=gsVIQY4pedw2YSm+PauCz6OBkRVhz/s2wPNroK48SzUQPG0cE9WphRVpiLRjcRQPiKap
	 DJgHUveQ2X6Yf4hKqR3mrZkI6Dy8Shp6cxr/jUZfIFB2b1HHTb++JYVEgjTKTmLeFCnSz
	 aJ77/wwgUuuuRnrRLrx79s9TYdDrnGW9HyrXm31s34ByOTSvkWOTbmWwesVXEiFzdDH3z
	 XeITrTvg0dL+G28hhaU4s967xz+zdO66/4F7MvFnUkqMApDBYrL0e03gxifiDGhShDeMK
	 uE6CEDiV4/3IGypLTvWw6u5ThnSmkQRhKM9cn3OFH5iKgPiGbhw4pXA3WamuR+D7bSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564378;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=oBVCWZMOabVq55k67Q8GIm9NBAOJHOxllLRlvncSbis=;
	b=mj4+NErY9licw0ck4fu/8eqjmqor/joWEwuGXbya/j1OC2eRV2QrN3jhRZqiRrIk0hq0
	 hdK9srr6f1xKhdJT/W07/QRjyoUJBVusl1iQRamj9nrLxXLx4B83D4ZeQlzkUpwa4Zouw
	 x1sYQa+FEGCwmd/lXqWh6lNBgPcX+bFTe9Dgb6P+GFDSiPjrnxxjw27sAJ4+iX1moJktO
	 btPXHfru1fX7zXpUdDM/ApfVbiV9MeFmlelKtOFXdc7U/FPuB/Bik1xec2Da5hTfC86TA
	 w05g4p28awFkBADDpuQPKSm+iNA2wMCNAN5vOaZ0hjJLlfhrXvkWF6RdREZkW8WgBLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=WDdVkHgl;
	arc=none smtp.remote-ip=209.85.208.45
Received: from mail-ed1-f45.google.com (mail-ed1-f45.google.com [209.85.208.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA9C6606A334
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:06:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AA9C6606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=WDdVkHgl
Received: by mail-ed1-f45.google.com with SMTP id 4fb4d7f45d1cf-6b4bd3d98bfso1517183a12.1
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:06:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564376; x=1795169176; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=oBVCWZMOabVq55k67Q8GIm9NBAOJHOxllLRlvncSbis=;
        b=WDdVkHgloKbBDmiudlEZ3ZWe+zg0BVZ0Jxwgdy+X6nc8ZJ9FIVi7F/SYJVqBRxNf3G
         3Gnq29xgDZdSKYiYaDVmU8W0xCuGm4Eu82rb/A8U6D5iLEOgHTmlDog4vSfdCU82B9rm
         qMGycG7Kl4j8h61zt+kqUkohzwqy0DPARMdjq2hKw51hdb6jylA1cwqwSD8nreSBsEB9
         DkDXk5ueYK99P4pH+jY8EwMoZnNW6BehoecLG+1JSq6wWJXsZMYgAdKGybKKFJkxuO0p
         O8Ri4u2My3QdIqEe8fwKAquZP0382+IuLTCd4KpBNa7znuGAHwPb5rxafjOggGTtG7Td
         r9hA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564376; x=1795169176;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=oBVCWZMOabVq55k67Q8GIm9NBAOJHOxllLRlvncSbis=;
        b=TScsXc455W+1+SNWgMu0b7BGZKIXSDO5dFx9J9cEGKNNREewmK1ASf7g8GUKqicgeW
         VTvfCHtT85/wtBt7/LwuRAV/YbSKGMN6ibFgjBR5B1KtFpyh2C1umB1hkUPtVOrySFPg
         BiWJJHNjfwEcRWjPR36F4noLzi9Limf97pG6c9yAfMu2wM+inb+bmPfvfqRd3eP3+GQl
         grzgBde++jo6tHLcnkRuKBiCAsKd3w3K4efFrfysJ0cAiXRk0oqkFin7w6cRqYdzF2pE
         Q+okt5BniV46WrrdLHCCmknPG5oifODFoi1R1Pc/1N7K0YRLCus4QgWWxcU15rq1YNPX
         Ha5w==
X-Forwarded-Encrypted: i=1; AL+hErFbbKNeID6+OJm2pmutyOjW1lnyw3DIrK7FFKla9wAuTLUeqgR8mwMxbwtKYQxr7XMcWUtM/HBgalw=@vger.kernel.org
X-Gm-Message-State: APuU4Z+Hb6ORRQYBq0LU67/ulycMzuSvjB+1b+CP5AUWvvaxbMnYXJm3
	N9W+H1xvKioVzw1O4GMIzTtkvDRe4IAEXmbarNZ1ZfSfERuGtWp1muJQ1X1dK6JATbOE
X-Gm-Gg: AYBFou3+T+BzrdIxFNFXKaSfusKltPC2HEGaltjGOqHmrYXPu48xaSAf2MZKomVYQeQ
	A9/Ma8jFxaJ42hsCfNgDh1wq+3CvUXSI80VsOCV6y2HupGPgbs2NNSHtgiH8IY/bpoviAjWgN4q
	yrhblp3v7ZWncy9qAUPTOhQVSiz34uzIuv1UCBGKR2OzFXV/H6antUycjqo6v7mz0OqLXZDVl9+
	KeufJTo0vfENNXaqG9mbAYO49B2BgHpU0C2z0kpY15FHY2mqAhGmAnO25VgpZNz1OKApOgmnmL7
	j4n4NS5A+KXae7s4xVKQajUXQn6gKOPiwqQIMszdfg3TqgN+35xthHcnvjtIAvFKIj4b9d+hsKC
	UnQc2Y1DHsvvxLutHJ0sSs/THgMNvlWUqn5G/x2qT0hjUfPdjUEwCuZlz3cgNLPwlNLXaB56Eqv
	uBB/dqd0/fPY69bB+zfVW+NzOaN2ikxqbMXOxVh2gGFD91HgFu38qf6/QxwIMcYYvgodtJOjpP5
	+fUOcfmmFigvZ1zRMkRtumm3TimDAuGm9L4TTE09hgS19KU9eV3ANUd0NMyb/IuPE4shIIqWaj+
	A4x17AgNVpIqSPMDV9FuxdM2rsciWuKKjcBBzrrdBaMo83kfOryjHz7TFsyEr/A=
X-Received: by 2002:a05:6402:280d:b0:6b6:4dcd:967e with SMTP id 4fb4d7f45d1cf-6b7c0bbc394mr1685420a12.20.1794564376161;
        Fri, 13 Nov 2026 02:06:16 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b7c21b1b5asm706711a12.4.2026.11.13.02.06.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:06:15 -0800 (PST)
Message-ID: <4dfa19dd41ec1a202182284d9617926a259288a7.camel@amutable.com>
Subject: Re: [PATCH RFC 16/41] configfs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:06:14 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-16-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-16-4c998976c6c7@kernel.org>
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
> Initialize configfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. configfs never holds executables or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/configfs/mount.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
> index d8cac1cbf3bd..60ba24e7ae2b 100644
> --- a/fs/configfs/mount.c
> +++ b/fs/configfs/mount.c
> @@ -13,6 +13,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/mount.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/pagemap.h>
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/slab.h>
> @@ -106,6 +107,7 @@ static const struct fs_context_operations
> configfs_context_ops =3D {
> =C2=A0
> =C2=A0static int configfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &configfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
