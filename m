Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564809;
	b=GgUMWXMMwFuhchm+KtktE5AqeskzKPqiJrwf0DDN5zywF49Xr9JVJDRbbV4R9CgI7VV6
	 xwzqcyZAF2ueu2bRG+t/2M8Kpx1MXH96dWQvmdBHoKdHS//iORLmyYuWOTKvW8pqJPU/E
	 JX1V9QufqQG0nGdwFn0gh3kw388m7q2ZIk/SvpmTEqaTU6FlXFJqGFWll02M/pxbvCTdG
	 HoKZ/nO0FRkdx9ROnQqBmbZ50imPJl6yNDjlFlypoTboSvZz07y6mOtrJ/+cK7h86//Ig
	 8QKG62DF6VJKJW6H17Gtf3O2hT+25aG3QQtQxTg14otXVPJuimCT4dg17fXLCknyzkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564809;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=UX3uQO58FXw3i2m3kzI3o8uINYIcsljrdUAfEKBly4o=;
	b=WPcy8eKeRao/QcXGGBYkREO+qUyqtfF3IHGDMnDifCkrdgmhVADRe4YjOjA9ZvrzEvYc
	 ivMoE4FJHTY5t2R1Y/6WNFk7N3b2j7qLOTA/vlawi36cRcXh9E653RjD9OcgpLZnZePHZ
	 BB0bzgt7vfJy4Mgvpj6E2XSpZfBFpGmvVwE8EwiB39Nx1l5hv/yqtJV7Dye6EhIUt73je
	 lsR2fKlM7lPiO+qPRS5cE+dSRzGVDbPZS0u+xTqgbp5bvyGFwleqe6LELIc8msa7FLK0B
	 w92vxz5PlkP2/P3+HIHec0irFva8kimtvdbBKPw1RkkVUwP4801DagAPdprKcPGNWSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=rqBNEWhe;
	arc=none smtp.remote-ip=209.85.128.54
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E11C6606A33B
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:13:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E11C6606A33B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=rqBNEWhe
Received: by mail-wm1-f54.google.com with SMTP id 5b1f17b1804b1-4a35d5d4a20so13721175e9.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:13:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564806; x=1795169606; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=UX3uQO58FXw3i2m3kzI3o8uINYIcsljrdUAfEKBly4o=;
        b=rqBNEWhefqtER2dpEJNVPTElbe19fVdkNyIzbVbNULqUnWk9JP4TtodfrAxZg35Ufq
         +ciPTMXXDC3Fn73QdDq1nxL10hoZ0LEMTSuk+HTluWLCH3mNQBpp5ecm/W/Lr1PQghIv
         NQThaRjLVubmwKFzY9W4H2pkvpw752j1vTd8XwcKuq70wsUgwzLrChjclsxLFe4j6CXh
         P2+zI4RYwkyiSmtYnxi7mmM5Yw0kfqLENKBervoD5JNkytp6QIULxp+qmuf3k5WOFN+d
         HC6ACfaHkSpUVoBZwd9XYoAangfmrtxV8FymQjjH9iY0qoozDauX1oxEdXhYxV5zTWYW
         c/fA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564806; x=1795169606;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UX3uQO58FXw3i2m3kzI3o8uINYIcsljrdUAfEKBly4o=;
        b=kMscA5P178iqpSTwByR6JULosshxwaLjOBIDz6QcvIUm/dlRSDBDafzVNM7iREPEz9
         89LQmwk/t3dl1jCer6zIsbfHV5gJZN0DMElIyssOFEov+9iDfsqeTV9H6FSM9c0S4gGd
         m4QlkH522iaHxJjnHbcbE94Y/DZPmSBTuEB7+88EGRoyeebH3jNlSL945IqoIb/GjQj9
         GKHRRtAKIJwfYDxF+smMz3yJb4+K6o2fSz/C3p0LdElMTEYD3bDgfhhv+imSkPkK95Dg
         m17dLPJk9+lw4+ZzIb9Xht6LrY8wzl7hPn1yI2Yc5IUrGCYn4FJaKg3hKjjMAhccKK1f
         y5Tg==
X-Forwarded-Encrypted: i=1; AL+hErHcNMjWR3sDYxIrID3r/bDmsYRiSLKzomf6tpFuDEzI2jNRA7BrhIC6HpR0CRPopXIEGUa8hgj7F7g=@vger.kernel.org
X-Gm-Message-State: APuU4Z+Nra0GTsVyY2wdtq5DVqEp8FUxsbhzGOh08VoA2KGBFybmlKuT
	IXMVVRNZiFo9OW12u0yZrGKsma1C40kVbfqPeW4vKFvpys046+9YL+RpOaVvy1YRhZW8
X-Gm-Gg: AYBFou09KxF9grUcM+sJPeJyq9qOHksVTGMt3ls6CBVJY55a2FsQ66p8kI61lyE6cZ8
	CSm4zwz4w9dKyx9rx/ZVLbhZA1LFUTXzJPiGussmmQu9HiWEhCJ2UKXyesBkhVrURc5wcM43uVI
	enSFyNudPe7G+nXT4j2FaRxiT6pMhnKmRvI5tFyTzSHe0ZufGOjI7zW1gNOGfuZ0n5HCOPhpZMD
	vZ/OR/rDO2lFx1qaXujSzUSmMWbO6dMn/tQBgKcO1JnxRhR11O7jXJzIrzID/P8G/xO+y9jQKwb
	jw1PvUbs0hT/QeXNvaPmS9KubRCKJROgFx2nlNhV5hkajh2bcWH++vyeqwyfc47Pi4J4dyB/3Ca
	Hv8Gad/ngO8AONdtigjEi5qZ618j4rjX3mxJrjxz7a2RwDnrGY9euz+cQ4nsUYNhGmlm6EKvLJN
	4ahmIfsJx6zJDz/6f4w/Bo/v7hHEalrKHx2LMvBqkNYoUzwtOB/WqlII6rNtjpbq+qIrhZg7iRN
	j5+2qdjopS8azwHHrqG50+JOlDxJYtmvFXIQBK1jlYFguQdcXD1t5ArggzcFu8sCZdvkQHJ85Dg
	qj93DGMIFoI3XgQK6Q92Hld9KBeVQ7n/Cfghz6VnrX94qGm8OdTC/SkMpcyItMU=
X-Received: by 2002:a05:600c:45d4:b0:4a0:23f:8b0d with SMTP id 5b1f17b1804b1-4bb559f6f31mr43583035e9.2.1794564806374;
        Fri, 13 Nov 2026 02:13:26 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c609c8a77sm4362275f8f.49.2026.11.13.02.13.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:13:26 -0800 (PST)
Message-ID: <23edc29c421f5d4c1103004f79e104e9f94d42c2.camel@amutable.com>
Subject: Re: [PATCH RFC 23/41] fuse: use fc_init_pseudo() for fusectl
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
Date: Fri, 13 Nov 2026 11:13:24 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-23-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-23-4c998976c6c7@kernel.org>
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
> Initialize fusectl as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. fusectl never holds executables or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/fuse/control.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/fuse/control.c b/fs/fuse/control.c
> index 21ffde596d61..4497362e7df0 100644
> --- a/fs/fuse/control.c
> +++ b/fs/fuse/control.c
> @@ -10,6 +10,7 @@
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/namei.h>
> =C2=A0
> =C2=A0#define FUSE_CTL_SUPER_MAGIC 0x65735543
> @@ -334,6 +335,7 @@ static const struct fs_context_operations
> fuse_ctl_context_ops =3D {
> =C2=A0
> =C2=A0static int fuse_ctl_init_fs_context(struct fs_context *fsc)
> =C2=A0{
> +	fc_init_pseudo(fsc);
> =C2=A0	fsc->ops =3D &fuse_ctl_context_ops;
> =C2=A0	return 0;
> =C2=A0}
