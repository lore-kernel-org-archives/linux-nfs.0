Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904088;
	b=dlQZyC3iNNs4xWyF1slNI8s+z9GZ1syu2gLZE58p03QhFvi+58lkyazf3YOEPeiXekPG
	 cMsWxpJ3DngzotCHOuQ0chPyuaqoxK3Dy5jFEF6yghbbU0L16SkawQNgRaw5rCBATFIIy
	 B/g1m3RV2y/28enqOKcmUHcR/6FQA+hTMPgfRvfNl94jMg5TRk+sli7+1Y9kZkLRL6OmX
	 Lp6JWlD3aghoBFQ8zT0kMo0a4KMsas36trpD3NTZdeDf6OJZyv6O76kY4B3YbKNWlJ14E
	 EqWpWlcWHwERMrxmf7eU+9TbWmjjTTZHTfu+5I4wF/SUUPAdK80reztbFXEkD0EEXDQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904088;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=AET1JHslkSzLNTOs00e5qdhXA33kuZnL+yhN5Q6hFHY=;
	b=Oas4zn5cdWtXqubvd7B/ipaEkBuKXiubsPLrp6g0uTWR6q5DK0xZKmNKulfC+Eje5eaW
	 2rx2/e/QyUp38gcR1ye3MR0nJQw8taEcnpvTUhNQiLFPYaNt0B5njzwf5eKsKhnfU6osN
	 S5LGNsb7cpeTuY3iUJXVpRw+XzaXNRech2dTjJkzVcflTMqYcJey3KPFgiFXk6mxUtO6M
	 oRSZr7rkNGj3h1OIkYRM9aOLVSdZwEv7sri38z4Jnx1+LqjthpdFCAhOTFMzGsqKbuw5i
	 8JkSErTzB88AMKZz+s0ftl1fZuG6Md4Bp0C7V5gyiJu8pSX1K8VzvlmnLVl1KIiDLMw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=G5kPAzk6;
	arc=none smtp.remote-ip=209.85.128.41
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CDD0606A895
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0CDD0606A895
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=G5kPAzk6
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4bb64c99d2fso31738335e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:28:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904086; x=1795508886; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=AET1JHslkSzLNTOs00e5qdhXA33kuZnL+yhN5Q6hFHY=;
        b=G5kPAzk6YKyHaocuCdT5IFslrUJH5/ldhNVhV6xYWUthrOIppv7Y8kBtZdevqAkpzI
         BDRFsu2jrF+YCozPia7EV1j3KLeZC6Lnc8BgBdPYFaePytvbOESC0m4eRkryqhoEbPxE
         WM5n2Fa2IGRg+WkSIkgfyoTemIrDdEbfzZV+2Eacmamzzj+t+HuCPRqV+GPswkKxuMa/
         2fm9UdrHUV6v7jtlgmqycAcrxGUcSbURHcUFMMj9LS/XjgTFJtp8hDDDARovdS596Fjm
         xwkar34XXNuYsLWY+RNo1AZ45FE/L69efZRvwjPbSAF3CGRgr3AaMHZz6Kf/cz8pCVs/
         RhpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904086; x=1795508886;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=AET1JHslkSzLNTOs00e5qdhXA33kuZnL+yhN5Q6hFHY=;
        b=QJwjXCZa3V5xMPay2xlisNdQv/NFYdDLxg1vPZSql2bqkiloHvmtMMyU1X4QsLk0Jk
         AkZftxQfIbpimOBAGt6CK4/0iDDprF6eSCnphMAGqGIzd7ddYT/X8VdsrOSoDN4WVmv4
         lWdSwYi966BPBGszvtrniKYQrCZz64YNanklZWqtqoKuLJN7HZQ2l+jGLt5WtEaCfbya
         +PmYI93WQSMVjmrIJzZtQyMH1F56/ohm/cZIdkR55PBFWcJRqJD1RaJvLMkUm5on8xM3
         STQfhQdtx9qGsxsLfEgex2x6GHhE5VIJKnKwZ8CB85EM9Nmav+YCtY+dGIcfcw2zS5P+
         DbVw==
X-Forwarded-Encrypted: i=1; AL+hErFQMgtJ5axMRjxDw2J2Mk3Dqo0Y2uw50lQCjtmkumOJT6ZqIP4ADzOXlmeQYnRBsSlCewuMmaLFLPg=@vger.kernel.org
X-Gm-Message-State: APuU4Z8gh0p3A4VUtP5519poxjUrjvGD66Pwd8SP1CAgr8iN2hc5wohN
	tredhHaTqQP28Zaq00CKUPwpSBmUWkt3FBlYLttUylvqTC0l63u96KSd3/KUfFM9qHUL
X-Gm-Gg: AYBFou2DtN3DPIe6MKxGO6EUU+MaZapqs5Gm+Ngb1cCpvjm9q12KTGLX+EbZSJKVCTL
	c1WhvpbtgyTVc4nfiuCPWOHS3NQmSuGu5wc+DlqZ1DVb+NCDqFegyo1OMwbp+qx7an3zHJD8i6p
	br4th/eCvXOUUiTYcyWx/YM4BBAQXuuM3BmdNVsSb1tCWosp00vtXZXDfnoip0FwyeRF7fpXpz8
	2rtZKPQFqbtHqZZOg2yBgNwfYju+wWvx5qt9h3J+f6QUvbUHAxEYMMdGt++5uxwFoduV0TFCC6x
	z+4tR8e6jTXz7P6/CCh0MusT+31F3lG+IYFWpNG2GNbHw5AqdDS39P7dxQihewnih+Zw3c33BnP
	Eb+4RvOEOG/2jEe3RbJdyCr+5lYJa6YF+h70viHI+695IM2kJKOX0+Pn3sofLBBiPw6UqYfK88D
	K+/sf68jl9SxqXEwkrVwoRgGyr5qyANQIuLyLrKkeqIUajQJAyYIhP18QRRru/kGTMGIyM+d09m
	/Eu0stmzg4CjlgB6OxB+RJek40fldYI8lZT2rz+ezI4vmjSN5qoqyfMY5JU6oNSVaP/CnoXJXjM
	WT5KvomOXNLyArISDni8Z0N5p/iIfV7+N3jK/1z+tKYoDWYImBV1/QXIk9G3IGESpd3i67F+l4a
	37WVQBwjkbAbT6AFxZ9CFBa3ie7pZ5fPShH2mrqiMW5CnxH7ApZJ/G9aF
X-Received: by 2002:a05:600c:512:b0:4a2:a9:ed87 with SMTP id 5b1f17b1804b1-4bb55a5aa47mr209766355e9.19.1794904086313;
        Tue, 17 Nov 2026 00:28:06 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb78418853sm74782845e9.8.2026.11.17.00.28.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:28:05 -0800 (PST)
Message-ID: <fa0ce0f7ecdbe91cc6773bcbe86be137d2129944.camel@amutable.com>
Subject: Re: [PATCH RFC v3 21/44] nfsd: use fc_init_pseudo()
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
 linux-kselftest@vger.kernel.org, Chuck Lever	 <cel@kernel.org>, Chris Down
 <chris@chrisdown.name>
Date: Tue, 17 Nov 2026 09:28:04 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-21-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-21-8cbbea1cf34f@kernel.org>
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
> Initialize the nfsd filesystem as a pseudo filesystem. This raises
> SB_I_PSEUDO and also SB_I_NOEXEC and SB_I_NODEV. It never holds
> executables or device nodes.
>=20
> Acked-by: Chuck Lever <cel@kernel.org>
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0fs/nfsd/nfsctl.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f32311f2d7cf9..ce2666deddbd9 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -9,6 +9,7 @@
> =C2=A0#include <linux/namei.h>
> =C2=A0#include <linux/ctype.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0
> =C2=A0#include <linux/sunrpc/cache.h>
> =C2=A0#include <linux/sunrpc/svcsock.h>
> @@ -1375,6 +1376,7 @@ static int nfsd_init_fs_context(struct
> fs_context *fc)
> =C2=A0{
> =C2=A0	put_user_ns(fc->user_ns);
> =C2=A0	fc->user_ns =3D get_user_ns(fc->net_ns->user_ns);
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &nfsd_fs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
