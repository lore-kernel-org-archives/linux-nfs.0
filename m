Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904113;
	b=3AfNjOpwXwDey49XtEWBauD78jnXeMDJETSnfx08x940Eucg/y/gKd342c7LcmaoF5Hu
	 pe02Nx1kO4FB37/ViXkE4z1jZCKgg/fFFuaXy491IZhp/rxe6/Q0d1R62Ocr4S1bzAeGb
	 9RcxXJZO+R+OFg+m8hAkCUXhAWrzeRBk6f+JQGcCdUG7hK8U1Hf83d1Ddd82KRRZCR+YX
	 IXADIuavDnc27GErmnbbEDAFlCB9098KK87im64uZW5dh8VXFLdwO3FnadXAwvzMEwMfj
	 2allGICbI5ZDiIjt+Lv2/eT4f/VtEDq7JrSzCgC2ypASRKSg/3yNhBwkVAX4DFzZ65A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904113;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=80nJ9mfJsz3UGKSZAnLQ0A7kD85nyx4H/r5vYSV/3QM=;
	b=WLABvVQPJbGtGBLOvXHWbUyq5ZIGYDWejho2FGAwXqeMNP/Ba6Hbd9SJKNXuKRdtfW48
	 RYfDmujE7e+15GA5p/pr7I8oHkwKXhUz3Q94gCBusobGSN3et70ugSIbsFhYB1pWtBMld
	 BC/DxiKE0IChYA4wiIinxxGae9i3GlATVqu0c89aNTmrSIY47qgtHGC9xHzbud+auUavr
	 88okX792HeGPDGbRWS+WUshiVrGtN5cjpBDfJVkgTo72qyxdbH6e79LLd8hDOHl7XpA2+
	 9SH7rFj110w8g9lNhkLv8YCk1TTVwl9A/KNOJraqYitEaQSAZlm1R3/n1wMoWdZ5Y9A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b="lDHE/E60";
	arc=none smtp.remote-ip=209.85.128.43
Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E041660A2606
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:28:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E041660A2606
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=lDHE/E60
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-4bb72b44a97so12248095e9.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:28:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904108; x=1795508908; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=80nJ9mfJsz3UGKSZAnLQ0A7kD85nyx4H/r5vYSV/3QM=;
        b=lDHE/E60fAF7y/GcfWe7zssqpibfABjaDWc4DbPAbANFwY7mipSCQzk/tGna/Yk9Yp
         5M31Ja6Q4S90Eg4jWdoE2GH6TurYV9Y9Yxd6SoBGFySZlSGgcD3Nf8Ac20Morq/IEeLi
         HZNDCkpilOoqmPVEk/N5paMQG+RjNO9OhPzIDtVn6k+5pNMY8rSlnV+zGCrptyxwBw8i
         uHdMwH/Pby0zhrQLCKl2b6izfUmExSZrUoQCnWP4NFP78u9vhGGyVwUcvE3no1VAV9ln
         DDlxdlg3j7mlBLcF1wQFzdXfstbmRKgVspXMjOajtHMeg5NsSNAba7k+RMZ1HFntU+s+
         8A0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904108; x=1795508908;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=80nJ9mfJsz3UGKSZAnLQ0A7kD85nyx4H/r5vYSV/3QM=;
        b=bAmX1/yf7YWTrw06h5KAmTFoCHmYk/fz7OfeoDw+prMshYb3xBo7ics44syMtoa3b+
         ynSkzd8OFEn7GJL5lGgsAlpnSCrXi6h4NYNGKKyI0mn1Il2+PRQWtp8C0hECP2qXQpAw
         yT9w4B+jmuLSy97nBzM28pgpofwqMi9OwAr5Jo7bdNAiB8tMHijOiWjVLSy90lOkkscT
         pAJKHOpQpFfpgNP7oiPjrPdJWJTB52WmUTbF2MQshYLdkHdAf/X8mQdQ7UE4ulY5q8p7
         Zk86dc0RZvRbxas+sLf7yLShPxBH9RkFTeeIOwfnAp21IbmiaZs9w6sR+zoJ5U0luf5l
         91RQ==
X-Forwarded-Encrypted: i=1; AL+hErE2l7cdwtITEmsNBp+qQPXVmXpeg97Y2T29JceEKuBtZzTpiGauNlQtt7pkWGrIhhHpBYk4/wmFmcw=@vger.kernel.org
X-Gm-Message-State: APuU4Z9w+0Kl7Ef4T/Ajz6bOtigVPjWKgLBvlUmttTIVavqeUmS/T9M2
	LW8eV6PKP/e7QkjuF1PS9+3LZwU+6zkGR/+MRDg69j/hguu2xiLDi99UzEb6nqCW7DJ5
X-Gm-Gg: AYBFou3uk/Ty93h6dij8Cq1x6jvRZkFA/sCohcnOM0yL3fLAuNwO1gnrnmQc3DUQtUU
	AMwjedDx+pVyJxbIprUY2JYoO4D/OE2qbwE1oSjJWpeWICV7JqK2hOWalssdGyStUW1T7JKR2Ep
	ZWVpmuNGjjNrNNbILA+mwH1BNyFca4omv//tm+FClIwWW8GKaHGV4TspcgpolKMSVxZVXb87JLk
	wRL5SrGuBV3rkVU6qtKuX40DpfKnQDnKkhpYl3PpdYHmrVZ6XR4KqzbWVN2vsOAkbauX/FWxqqO
	g7WbZECRELyIAJWHdiIU8KmKg9fFP0MrnAP9SjRrb+iWyhRiQypIdKlxThfXWVu3d/2cQ8Lr0GP
	jY1uuAB6G5Dxn2FGDHpNXvTqedOgVu1oYXEjuypwOYg1nJD05gXjH+VfoLgZ8kLflCfTkujLkAo
	8HfFPjhuz5opqXIQNTGNvuyQ/mQn2CAjX6N+oI3oCiFedq7G0WUckD+5wvUXCQca1VXVOyiENcb
	LjUBBH7gpGwv73qbiQ0XQnYwJROYpRBYEjSmWdqVvkeBUzksGwwkEOi34N3/3qgeVA/gFtUWgc4
	n5+2vtW3NMxzlAikoTpQ90WWx/gkbox7itx6gsKB9B3OAQVF22VsagIbd5tNqSbuFXco9kRKeA4
	qxcHrn5i3PghkwY/NXQfs9iVdC8/Vx3JaHvzQ3zfSTx5PBnMLABfQLTGI
X-Received: by 2002:a05:600c:6286:b0:4a1:7e77:c382 with SMTP id 5b1f17b1804b1-4bb55a5d634mr255399085e9.5.1794904108278;
        Tue, 17 Nov 2026 00:28:28 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb78422d2dsm75197335e9.10.2026.11.17.00.28.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:28:27 -0800 (PST)
Message-ID: <afc070a816e3ae5eb3c9e2d62d4f25c59ee61df2.camel@amutable.com>
Subject: Re: [PATCH RFC v3 26/44] xenfs: use fc_init_pseudo()
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
 linux-kselftest@vger.kernel.org, Chris Down	 <chris@chrisdown.name>
Date: Tue, 17 Nov 2026 09:28:26 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-26-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-26-8cbbea1cf34f@kernel.org>
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
> Initialize xenfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. xenfs never holds executables or
> device nodes.
>=20
> SB_I_NOEXEC also refuses PROT_EXEC mappings. xenfs maps the xenstore
> page and guest memory through privcmd, both data.
>=20
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0drivers/xen/xenfs/super.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/xen/xenfs/super.c b/drivers/xen/xenfs/super.c
> index 37ea7c5c03469..aba7d038ed735 100644
> --- a/drivers/xen/xenfs/super.c
> +++ b/drivers/xen/xenfs/super.c
> @@ -15,6 +15,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/magic.h>
> =C2=A0
> =C2=A0#include <xen/xen.h>
> @@ -80,6 +81,7 @@ static const struct fs_context_operations
> xenfs_context_ops =3D {
> =C2=A0
> =C2=A0static int xenfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &xenfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
