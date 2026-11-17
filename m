Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904032;
	b=tAyKqjIqyQKrjODq2LLBz3rbxJSNnxHcqgIreLvcKCoUzxW3ueZZ4kMbBPA2x53c1Zug
	 xTlKxtMQTjwlDIBwnu6YiEcDgbCCpaNZGjBAvQECEmw+AQ0mXtlpubJLLR7H6NY3XX+jn
	 19iGjepxPtJRI5JAI93KZyvT8tKoBBdAlv5clfBaOa80dhveTl+kQQAi6dJSjUWoKM958
	 SoVwKxc0rZPKZ9xzBATIJtO4FHOaRxz71nIe3hy9xAF2o/nrwlIkgn0oNj79k+QJMs2M6
	 on1/Mt1lHXX+eHSetv4O0+d0DjBc+VDIQTMKddxlBidzNbxesUaY4vfBfo2KREcbvGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904032;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=o7Ds5Sp5DChQJ6GHa3pEkVZuOErJkij7LbLCUPT9+Pc=;
	b=kcKGedXi5iVLPDOs8hlyksC4LCZAHd4wWNINyC9RD6FaR539TNascqBdTmZggpT2cnjv
	 BptB9rRBMZ6lbnaOqbq28CJoVbFxz4utZIQB1mGnb6WWM2sF4OniayTpNq4SpsubhRuUJ
	 fBS48cjcr0JalzBhtWXPds6IW6fSzu12Vzu446rcOmjXpYeOf4Bv32ABEI7slkY00aM4y
	 GaCgtouYpJ1TCJ5CCPVwbEPfkrkaPO9OgzBq0ejhBm4xd/6kSthMn33a+J0lBO4oFTjyH
	 3Egz0tu0sneyEXYyT3jn1any6T8TeLHIEWgwoMnylj+/q7Mzvj/yce7OdccevMV4nHg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=m3Y+iV2p;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E56FF606A323
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:27:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E56FF606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=m3Y+iV2p
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a210470b49so35729615e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:27:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904030; x=1795508830; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=o7Ds5Sp5DChQJ6GHa3pEkVZuOErJkij7LbLCUPT9+Pc=;
        b=m3Y+iV2pelmutPYORVxza4CHQMpjq7iS5lmecWgDjvax6Coso4uWa+KMaCm+CB3bWY
         yM9xDjlaUDqClL2wfFs+3EgMKFX4Q8fuLgup7VSVEO3iDYFOyh4nyeN0Shri07+KD82b
         UFGbuWvBELdRnXkiKa1GIWjPRb4Wz8WRQUErt4eMboeCaxWHABbQwTZk6BuPw2NopAXW
         5935wwOL0Ggt8LD7VeJmtmL6iC6DgtiD4S4DRbEtkaj1swNFS1XEbe90cWaNyokAE8Lz
         Ulc1c4G0eNVUIpLzTdbViN3HgCOMoyHpu6hnCIZ+utcpbQY02w1kBKtCyN8iaUfGq6tI
         6sqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904030; x=1795508830;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=o7Ds5Sp5DChQJ6GHa3pEkVZuOErJkij7LbLCUPT9+Pc=;
        b=0YDmB7O163sl/vSOW/EHdObAtm6fcuOW9Xq2PfWcSei39GVJy2yv8Xt3aTIOB0ZFAD
         NoyGr+I7MVRWb4FRcAH5pCoYZkNU9PbOKsR2RhUkC9CTJae5NcK1VgPEjHn9sWB/KMRt
         5wBcVCKqlrzLT03VJCvWQshRO9RvABp8OlsQEuBJzS7CFfuPrt3Vgjik028aJt5K2Q5z
         AA5hwiXDv2RXlM/JS//5tVW9fNs9azKIGyNTyhiz2ICNiSGKmTDkhcuTn5hQiH1peZeT
         W8ObXL6/CQ7DEVoV6XIfX5yDsxN9MOnvHrfqda6gBl6ZiZ64WjnCyqhGL/36Ym9lR/x5
         pS5A==
X-Forwarded-Encrypted: i=1; AL+hErHN5M/2Up71y1CRM5WBD50XyMSaZLFtv4Tb3qM7Fdpe7MMmhq+xlet5oJHWGSSc3hBpmYtqXVekCIA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+qJd0JqRfxr7BKKNO7quloh+7T1JTgyxhdw4cG977ORtzEbFg0
	dUg5guh/gzhQEEZhSbNLOc+KTtBzTMTS3YK/39rr39MrHSfCJFxxdNAl1HH/nl9MRes1bwwAOMF
	nY1lIzqtW
X-Gm-Gg: AYBFou2n4rplZoNr4REEpM1GWl/FsccqAOYXqva3m8p591jvfVo9ih65oDcjuEUYOZk
	BdckZf/52SCqmf6vr+iQBoOD3RlEQ6IoauWhjwEDuk9oNMg6FJNwVf1wDHPEa7z9joDkvuX/7iM
	H/5nYR3BbW0EWYPhH1rrMu0RaFDQUieqBIpPydIXyCUiL9HemasZhhEw1Y/JKpUQ5giCGqxUWPr
	0fDKcjSKd1CfEgBDzUMCKmDCbrSOE6gjiSJd2SgAobufuJcZU2hmRBgxcVtJfHw9ysNUotXG2Jt
	3FhIh2ZNnE0T0EC1+sn4BvW4s17p2cp2KzRMnh5pCW3cQXG9GnKwl/CtoP731/p8YIqDERFXnJK
	8My3wWdV2oRzKaRJxP1d8AgM4rWuR5o7tGNzafxOpJCcNfk9BcyKVqlvgD5l53maW+iRI/nx/df
	gkYDWmsxxMIHB2Q3L6w09jbDELHf4qrYY8BF7JNShF4i/NCy2aX+RIUBhWPX9rgssI3AcjnvqLh
	PTyvjYilXGJsx1Dwla2d5WopEYFM9E4JcDinVA5o0IgfYE4alqzdlc0+9pyXTh/ukWmV7eToWAl
	QN2kb5hyP4VZFLeUh+JxhPDDvtTWFpoot0F8a17NVPLkFPWpJ7CY15QBBI7qlUKNIqFO3L1U20n
	6yMEr234Je3M8/YTe9DUsJcbZ28Iy+kVN150/2RZA1r+u7dhgx04sqtro
X-Received: by 2002:a05:600c:3494:b0:4bb:6c71:b268 with SMTP id 5b1f17b1804b1-4bb6c71c232mr134135095e9.6.1794904030378;
        Tue, 17 Nov 2026 00:27:10 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb7838c912sm45730155e9.4.2026.11.17.00.27.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:27:10 -0800 (PST)
Message-ID: <0ec7b8c90cc456b24e5b19c1db673d497ae43735.camel@amutable.com>
Subject: Re: [PATCH RFC v3 12/44] rust_binderfs: use fc_init_pseudo()
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
Date: Tue, 17 Nov 2026 09:27:08 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-12-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-12-8cbbea1cf34f@kernel.org>
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

On Mon, 2026-11-16 at 12:04 +0100, Christian Brauner wrote:
> Initialize binderfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC
> by hand. This adds SB_I_PSEUDO. binderfs_fill_super() keeps clearing
> SB_I_NODEV for the binder device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0drivers/android/binder/rust_binderfs.c | 3 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/android/binder/rust_binderfs.c
> b/drivers/android/binder/rust_binderfs.c
> index 5f020226720db..04468c5b5c116 100644
> --- a/drivers/android/binder/rust_binderfs.c
> +++ b/drivers/android/binder/rust_binderfs.c
> @@ -3,6 +3,7 @@
> =C2=A0#include <linux/compiler_types.h>
> =C2=A0#include <linux/errno.h>
> =C2=A0#include <linux/fs.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fsnotify.h>
> =C2=A0#include <linux/gfp.h>
> =C2=A0#include <linux/idr.h>
> @@ -667,7 +668,6 @@ static int binderfs_fill_super(struct super_block
> *sb, struct fs_context *fc)
> =C2=A0	 * necessary and safe.
> =C2=A0	 */
> =C2=A0	sb->s_iflags &=3D ~SB_I_NODEV;
> -	sb->s_iflags |=3D SB_I_NOEXEC;
> =C2=A0	sb->s_magic =3D RUST_BINDERFS_SUPER_MAGIC;
> =C2=A0	sb->s_op =3D &binderfs_super_ops;
> =C2=A0	sb->s_time_gran =3D 1;
> @@ -759,6 +759,7 @@ static int binderfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	ctx->stats_mode =3D binderfs_stats_mode_unset;
> =C2=A0
> =C2=A0	fc->fs_private =3D ctx;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &binderfs_fs_context_ops;
> =C2=A0
> =C2=A0	return 0;
