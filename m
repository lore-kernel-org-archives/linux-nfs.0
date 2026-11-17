Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904598;
	b=J5yTRp+hmmnGJkxd2jeF0MsQxbeJWh3qqDEsjlaM9grkfCi8m2yZwJTmdw3Uu9sJy98p
	 oVNPDJphFClG9m5T446IOb7ICtINhw1bibpKgiFXPMybNRsKAlOuL1DziblvgTbxAE10G
	 teWFnsbaNq9v2ZYl1P1GLwb1npJ8z0sEqZlFrPvdiRuw8qlbe82mvr/5WNtGxnU3NtFnn
	 FN13GOE5r0QfeP1wvZuI2RwVJ2fC7Ut+VO0XX3JzE1HBkuBABu0V0FbJlmYsrvbktkjCg
	 dqbbqQW5+9IlJcXIQlgNkicr/yDQsFdBgLGJ7vPsASp6oKXcnDv2/ORNkOjB75i1/1Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904598;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=u/hxpfxH2Ygjpkkpn+gEQ4NFMpeA+YPAHTw9d0qdSc4=;
	b=rm71aZT/KGydBkkcgb/TfwHdeVbS695eoHzn5c1bfZxnd9ZhcqvIxP4P0I9Sq/UeeCl7
	 L95Frzw9jAR+fEEN/A4fOqfhXN0w+/4kt7R6KQ7d0yfzY1jw1KYCx+PkS3FGivd2VcEPs
	 ZZCJswkLME7wAROd1i/k2dKfw9bOZKo+Je2RlipvEP96rH1uOs967ZiBgZDGp7qgL7PQT
	 xZPSpya2YgXd17oWqW/lkq4Py/xaI8eZiIXbJCWyKuDYEs7IrcPCGG4fsCCNuYLGWbNW8
	 NHqoSxsVzC6aStZEKNY1hWMgWH+SA+rXI1koz7lC6BzT2jPA7se71EcK1Ob47l4RUcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=VB84C1sh;
	arc=none smtp.remote-ip=209.85.128.47
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1934606A8A3
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:36:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D1934606A8A3
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=VB84C1sh
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-4bb64ef5a00so17252425e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:36:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904592; x=1795509392; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=u/hxpfxH2Ygjpkkpn+gEQ4NFMpeA+YPAHTw9d0qdSc4=;
        b=VB84C1shjSG034pSk2oK3egXlQwWjuu3VjrdbAKPawk/Twv4Yif6yhPlbROFWtMgPQ
         3tz2NQZOgPBk3fq0QRZC/paJXFCSb8aJt/mhh+A0iXMTZvR4a2C4xo37cxqDT+bS5wyK
         cFfqQ64HX4H+WtOYlqmaNWk53bLD4rVzH3Dam/22N7EldMgTIeT60YiznWNjIzN+eEJD
         Zc6kl9xoD3REW2KAU35dfm9/7zuNgWUL6hteTTxoqyJmYKiacM/NYuvwNSKHsMwzezat
         1L4qftGlpMPZouPAaee8sA2dATEpRVvU+RzrgkUS2mvSj/+KFRi5Npjbd19v9tUdsF88
         Zbrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904592; x=1795509392;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=u/hxpfxH2Ygjpkkpn+gEQ4NFMpeA+YPAHTw9d0qdSc4=;
        b=GywM4jQ8CSYCL7cU35D+eHiC9LE9oTF48UPFSkxhvePD+rU1vRd7QsXW3+Wby8pdCR
         kcm+jtFzc0ySqcCFnlNlstY1WvzMXJlqA0LHV35TX/E57FEVmr/Js/q4yN5ZEN++WLHC
         drAM8N5o1n4EUky/wEYNR/k6Jewi6sMgBAdx7DYbFoVDFwC8v3Swtk0XcNDZaJFJUKpU
         uufUmY2al0yZsMOubmaaDgsHrUnm04fuA0JCvuRCcf4AzfIwpue+6YOoC3ebQ47+Ol3S
         STjidGEduf54OOCnPpZu0uqzUMlExJttkx6UFKM8KRZshg4TIGThQJdyYTBnYl7wibLj
         ifWA==
X-Forwarded-Encrypted: i=1; AL+hErGcKiQvuGUVjOn9ob9MtjUOO4vBsDoqspRvv901OvWL05NbGksZnZ7t2W0e1lgMC8r1jedXy7dZzxI=@vger.kernel.org
X-Gm-Message-State: APuU4Z918hGcEm35HuFz25yR6yj8mJFw5B8rxxHy6KrT/OBGWcnlobAB
	pm9pnz0YkkExUp39Lp2ctqn8KqfbWj05dfnaM2UnLLgLs5/PgM7er/9RUaulM0Gb7Z37
X-Gm-Gg: AYBFou3z3sDQrKVIB3Oo131luwtEHzuw2Uno4TcZCYRGjZUFgcMzE4/+J8aZDG4jene
	K2Yf4IgTvBuI55VXovT0Xqi6d8/KyKLYvb+lqsc6QBtseAkYlpzQqe1PsBhZKdWC3U6gakcRZK+
	yZg4D0GZu2/dxUPnDJnRyoOyu7PN5Vwizp2ULm7wcQWaNu4Qi/YHEorguXD0f29yUwF+/6wkL2/
	ZygIk4AXarWKsNPGJVmCQIPzB76U3GYFrOyPkl2fSFG2zCOchqbJ5z42amKlj05SSvheOyHXsdq
	LT3pEhMvBzl3xV5Mdp+bkQKUbse9nZwXxk67FuKfCxFB0nM276gE/GGNEVAHxuyUrqojI3d12K+
	2ar+96+UdMtimkX9yU9TfzRQJgKB4AUKIauZn/Vws3KZ3zSfx6HGKHB2fEMlUEhnAKOZ8Zzab/q
	ZxTwYLt3Z3K+PWqw8b06uNb+W3lZqYTQi5UphDcQOV0DnrJb2mkWIc0h87V2HMcIODmmB9nzgCb
	snBNy3ZRqcv5U4vKXfwE+ajuexv4fKJuuYiE0CKmSQTBiw8FpwSzOzh0utL4oZ/wZvEsrlOHZ3t
	MsYpIwiu01JJwLK82AG/ErFhlBzLMjd4lz6acs1jdkEM80xilDZAcQxQuDGn0YlRvimgz69hRfz
	JDIwa9I1z81pR3qcrJZKkgK+/63Yyo9i/7uRHAtGAxZQTqz4nt2cb0FO4
X-Received: by 2002:a05:600c:1f90:b0:4a7:76fa:87e9 with SMTP id 5b1f17b1804b1-4bb55ab281bmr266345525e9.21.1794904592167;
        Tue, 17 Nov 2026 00:36:32 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb78430752sm52548565e9.12.2026.11.17.00.36.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:36:31 -0800 (PST)
Message-ID: <411502f9a4f940c223b2b88d7e19fafdce63172e.camel@amutable.com>
Subject: Re: [PATCH RFC v3 29/44] s390/hypfs: use fc_init_pseudo()
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
Date: Tue, 17 Nov 2026 09:36:30 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-29-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-29-8cbbea1cf34f@kernel.org>
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

On Mon, 2026-11-16 at 12:05 +0100, Christian Brauner wrote:
> Initialize hypfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. hypfs never holds executables or
> device nodes.
>=20

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0arch/s390/hypfs/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
> index 559b011e68800..8662169de477a 100644
> --- a/arch/s390/hypfs/inode.c
> +++ b/arch/s390/hypfs/inode.c
> @@ -12,6 +12,7 @@
> =C2=A0#include <linux/errno.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/namei.h>
> =C2=A0#include <linux/vfs.h>
> @@ -301,6 +302,7 @@ static int hypfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	sbi->gid =3D current_gid();
> =C2=A0
> =C2=A0	fc->s_fs_info =3D sbi;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &hypfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
