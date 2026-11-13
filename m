Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564190;
	b=jEqHI1VTtR9YSXTz3TOL+2L5fvcTchzn3Xfu53/QvDwJ3igjaA6JI2eR3P06vE8t3AmK
	 t1o0d0/P4vJA5YMkctp2DwSNsBcnKC35WB043hnBGytfzAxy7meqX1JFoxgZyeimUJPKt
	 qRlRRp234VTP+rvpWfq484mPOGq3KzqLh5EKzM9bozkVwaWWicXPS8hR/7jHOb4kC/U/x
	 scEYIhmOVxPlD+IddyA40VHIjaeRQnvFtp5d6fjrzEhb+5rwbpEK34WKIXK0UPguAQD8X
	 oTBMFy2sdPTxJCCADRwGu3sOgEiV0VX+1YNEi0MLXg8rsD6qv+75nkkfMKwme1ayqVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564190;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=SoW/gPie2WRRtXdhiV6ow6HDYwH4jtR4w1oiMzBwW74=;
	b=SqxsdTvtebRcNTF6BdfpRS9aEKfa1J03xVp7oQzPDFA5vCJNUqAf07s5ktKjuLyvjt06
	 gRwS4epMjDK9vgNkHghc46F/IshcR7T8WF2cSs8c8b2jxJWM6IdqxAMtabUUwrsa5noQq
	 OWIdT1jon2eNNIBVMUxB0QvoIy2RXXaUqFEsYuPK2H3Jhr8YG0jlb97Q2whOBd3LqwxIO
	 LLVfv/FOxV8HJxij6FHMhu6g2iPzaIF8oHLV/s49BtL9XV8VmDNBZqaA5onnytbgiFcQb
	 AcFwzRGNA7NZRO9Xz1NlqJoF823Ws/odaMe/cG9TKfHZLFCpjUd/G+azJC0g8MA4hjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=PwLaWWEZ;
	arc=none smtp.remote-ip=209.85.218.46
Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D81FA606A8BE
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:03:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D81FA606A8BE
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=PwLaWWEZ
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-c4d581da0aaso117517266b.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:03:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564188; x=1795168988; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=SoW/gPie2WRRtXdhiV6ow6HDYwH4jtR4w1oiMzBwW74=;
        b=PwLaWWEZlovk3BcnO0ZG64105bcHT1OuSddm6BbnvIqxbrPzt9auj7esmk6BNbh6fX
         VcVz0Fb5EO25ZFbwJkkdsGMVKdakOQPzqU2f6LPhtUiDBhEZmXH+cAuxyn5j0/PSwsaT
         RO2aU2TU8aCmd84MLoXz7vnHjZWZq5qT0/Sc6gtTAg3UhyfQddRWFsH5ep7YUVPW4oOS
         ZJYdPFjeA/srAxsT7bXr7CLtpXwYO3HrhRePJ9C+1IlKmxOGPfhyvFsMUb4DHUYdYyHA
         n68GAxpj0xAii+OfqqKyb+8UpP8WFZF+WeKZ9rpWrZ/4EfgHnKqz0J1mnDjnDglQmq1u
         ISGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564188; x=1795168988;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SoW/gPie2WRRtXdhiV6ow6HDYwH4jtR4w1oiMzBwW74=;
        b=tFMHNzfxZz0VNs4hRuZPEf4qsi2l4LANg4XcsYR6pXJ5PpdB15Ye242usa9JHr2fv/
         XGqb3RQ4xIVPpOh+XPa6aS2a0LfCiT+n2rSB8ktT4KgRZwjsqNwj/QTiYzAoW+L+5cDI
         zGzTVVff7hrQ+7FoeYe/7ynC1CTsKSS8knROzJYLF0sU+XNUV/mPBrYKxiw0k2sh8Cjf
         1JopDKxK2hAbZ6bxYMtq4f2NzKN9jeZiEztpVkonXW7uvGsVWJBHZeHFy20YnmGYp9KV
         vyGWuzN2DYrZ1dM9hvrxiY/LYcEFld1c4jplUgEE0l8m4yD55dbVhuHhQq3nqk/W2Nt5
         80sw==
X-Forwarded-Encrypted: i=1; AL+hErG4MzELfUAVtdfu1Jb0qs9l2huEzbTYH4v3R/XvIKcOq23lbfiPHHNhWsp3m9NE2Dr5EdlPJrZ5XfU=@vger.kernel.org
X-Gm-Message-State: APuU4Z86v7p8VMuS9ClrsesY7q0OlLXiCUND/7ghUMoylkHSUU8T1Ncj
	jT/9tmiKruRBV8Yvzosysllmr7mFUtfn96dgf/jBCA4pBsuo4a923bwu55ytB+HaJNGy
X-Gm-Gg: AYBFou28P711Dc8PjSTmBOOlDlgBW6E/4QZ9+rd8kzxnTl1ohcfVhhTwgBj2yRjq11f
	Md9Wot6mYTNnXgCKkElCWDAN6azR+KolgD7tlPs4KS0m1mn1IfZ3Dcd56cJj+Rr6vIHDoxNiBB7
	j0g8qFaYBHnK2+xSmRuxeNdhHgGABG95wODTgk5PW3MgP/60FwogJM7vEbHFfTK9FIIjv6T11Gj
	O+6z7OUvFXKuulELHZrOgsbvGFW5vFcqK/7RcsKwGWd3AjQHoz4cLICpxPnfpZAis2nMVWfzxIV
	p8d3kd7dQnsxZpRkthOsRuYPdwP75LUtqbqdA7qebvQCDoG3SuCMrjCL3nt9F+iwJoBUOTkquX/
	Vu4Zhi8G/2u11i28kXdLluC3uwdkIIwAo0fXL4PLJTSjinaPn3qpIqRzw3xxRt8I6FyBttCbm88
	fn5OhgIrBCtXbEQva0a+XulEmFTknKJaDFBwec7mak9OQBSOMcTrC8wBl110eB0mYySvqfLEEWK
	8ais6f+aJnGOvLbzVyqNg0j+ohE5bDbADHGV1KdfqJO/PG849a39GbhlSHi49V7HVBLgXgCaEGo
	A2tvffVMVz7IjfTgmbd55QLhN4OotBUWByRFGXN829ZDhAx9
X-Received: by 2002:a17:907:d12:b0:c4c:b4fe:c9e8 with SMTP id a640c23a62f3a-c50963dbee5mr161853166b.38.1794564187801;
        Fri, 13 Nov 2026 02:03:07 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b3dbaesm74933966b.32.2026.11.13.02.03.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:03:07 -0800 (PST)
Message-ID: <fffc4f7f87fd5f03d1ef409df76f71ddad552213.camel@amutable.com>
Subject: Re: [PATCH RFC 07/41] binfmt_misc: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:03:05 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-7-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-7-4c998976c6c7@kernel.org>
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
> Initialize binfmt_misc as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/binfmt_misc.c | 5 +++--
> =C2=A01 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
> index d945b4f6e158..7dc233becd98 100644
> --- a/fs/binfmt_misc.c
> +++ b/fs/binfmt_misc.c
> @@ -22,6 +22,7 @@
> =C2=A0#include <linux/file.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/kstrtox.h>
> =C2=A0#include <linux/limits.h>
> @@ -1575,8 +1576,7 @@ static int bm_fill_super(struct super_block
> *sb, struct fs_context *fc)
> =C2=A0	if (user_ns !=3D current_user_ns())
> =C2=A0		return -EINVAL;
> =C2=A0
> -	/* Never exec off this instance and never let anything stack
> on it. */
> -	sb->s_iflags |=3D SB_I_NOEXEC | SB_I_NODEV;
> +	/* Never let anything stack on this instance. */
> =C2=A0	sb->s_stack_depth =3D FILESYSTEM_MAX_STACK_DEPTH;
> =C2=A0
> =C2=A0	/*
> @@ -1660,6 +1660,7 @@ static void bm_kill_sb(struct super_block *sb)
> =C2=A0
> =C2=A0static int bm_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &bm_context_ops;
> =C2=A0	return 0;
> =C2=A0}
