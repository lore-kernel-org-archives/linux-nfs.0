Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564728;
	b=rYkeWRdhA9g6HqGpdzRP/A+CcyLpIF6oUjVVtSVRHs0uCOY7VUorj1oZSpq+IrEhXb1u
	 dD3031h4JM+oho85II8rWPi87flwXk10iB+W3CzztVGqunZmrp/8lGrTAzOHjez1wBBSb
	 gXvJsfcFSEComt4dsfMVjpHsI/HbtD3p/r+9ANnO1+peqas4P+2ODahOREfsiJpHwasKu
	 9S+1d9Vjj5hRSMDjeDHjmuRJMTJ/RCA72cCt+73GCxArjdOcU35giFEKNLCyRQNAFl8CJ
	 qx3oPI6QNcXEYynaqwsrpa2p7fUciT6UvzUmavcJ69Z9odqeHJZ6ggeBIkLf5Sb1hJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564728;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=C9TZKYRayQVC7UyXoancZRI4bPIYIHY06/n7s/4tB9k=;
	b=VsRAn2JHxgfgu+zd3neG3Slq+2OUSqIxUA9g4Y2UkZ/z85GuMGzV015wOyd4aW9rmT3j
	 ZSa0Wx8Xg2+4ZaRnY7va1sRyFaZiQVtz8R5myGfBjdS6Jl2qOnsV+3Apx84dTs0MkSu3H
	 Ah1hZIa9R3aNHN1eryleX0SBUwnEK6QQhOLrv1dudFi4H0U/6Ih6XnqCQePAZU2EXZUkE
	 q2N1327FmhPJ7DvT9Li/Nwna1384Yq7KabvoblXXgBdAtOmZbERKgpgJHbtFi+iajfRf9
	 9V1H/Y2ZOP6SjvpNNVKiq+/M23xghxEF+PA3ruBGDsqdKkPr07QfMKe72qoB8UYBm7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=JofFrwon;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB2C7606A333
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:12:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB2C7606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=JofFrwon
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4a1fbd52ab6so8032525e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:12:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564726; x=1795169526; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=C9TZKYRayQVC7UyXoancZRI4bPIYIHY06/n7s/4tB9k=;
        b=JofFrwonLml2YmEXhdcViuKQhdgodt9TPfkjQoH5bRE5MuhkX9eapeBcuLoN9BMOMG
         mg62x7tr1NIo2ce3//xfxGBo2Glw1JnMwrRUE5PKg9cgXRmANAsmerUzgfn4I+APSoic
         nLUkrr6h7Ej/6ZnsBOEx8OEPXrCx3CvMaGkTszs9w9WOs3gF62hftbL3MH/tr8iwAkM5
         IEqdn+20vI39qrHT5Lu5B20ux21tBPJwfptIyU9tNUhlU5QyFDk51k8ZhbiJowoQswf0
         13eatahih0uhEB44iQMwucAarD0vNvZBAG3aTkRmepVuKD8cgol5N6Bgv+DPTP+kX4Yt
         YdFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564726; x=1795169526;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=C9TZKYRayQVC7UyXoancZRI4bPIYIHY06/n7s/4tB9k=;
        b=QfCDP77oj32WHvLpOmcLvvkigLHpLyM4oGBFLumWxS/B/8IjktH9dZL9nYut59MpwM
         yNUvgCSCNJg8+0Z/ZRP8m4dH+D6rOEGmjfIOt3c4psglwPXO0tzjiSRRkA4skd9YPYPa
         w+2Z7Vz7wvtsMvO0D+e5C77I/1l0H3gd0c4hNcrjUy3vZz3WSj0ZFPLUpWzW/Yjie0wO
         rajdNuayOgcjhTDGa1TESwfMZKvxkEn6JKju0oDZMPwi1gXRM8I0qQ4PfVAmKvx6+z8a
         IV7IhWVI01zwN2ZaeL2+rR8/xhfnPJXbR6SpxivbRnpMovGqbV9HWsjht/C2klcPA4rW
         aHZw==
X-Forwarded-Encrypted: i=1; AL+hErHvSxgO3PPiCyh/EhGswjnBI5tuQIaS0HZCEZ7cdlxIXz5a27sqPPC4zZ+KBor/oFsQmw+QT5IRCuw=@vger.kernel.org
X-Gm-Message-State: APuU4Z+VBGwP1FUE09xXjIHoCCUftcTHUM2BqvxcBllSGUdKKUeequa1
	qh2Cs5ltCAWqw052r3NNJnuE1VpRglEj3qYsUFtYVU9owZI69GLpEQbX33AYWT8HYfXZ
X-Gm-Gg: AYBFou3mhFFfepGre8X/gE9qF7vnLfUR4jP2GFFYFPJJYkIHab5ktCTcnY5P4EATrXU
	OxSb+vdNSO+49aSxHu+nI7Hyy0Wu2Vbv1iajJFNkeuZRtwFDHGP5O5mgrANVkkciPcZ2QnwwIJ/
	llQCJi+wgjIDC8KxXLNyiVYR4rdQ54K/+M0EJ5DrOdR+wLMBI4FZAlgIFYsmddqVarvSucSfnxT
	dChrAn5vHqBLfyM2mW4fetgld39aBNaTlBoJAqG94VHvoKT4/JUN065RmJI24ocYQ1Id+WsMKKO
	UrraJgT0gza48+YUZeQMsQhkCCzOWHMklDz5wMTY348KXXTFH1DwnhXxA7X37Gsiy3WIPZ3Jdva
	nNrfXjAPgXKL/3RSJmO1SX5MC6KO8F0u4+Ko6GL6rLn/vDWGVR6LSbgIplPjhLRSUifNXMY17lK
	D7lEQK9eebNGGwfWoTxOU9+zJeitlPP0ICG6P7+g9flfb8a9xsSHuT6V4uYgIdYnfPfO17pk2PM
	1/oLBwRO+zVo7q/L9hUx776AjMGnF4H25DYQKAqzU4u+qHFzIInkzmDJv9AdGt4TGRJLO5YOt99
	5hcBB7/EemxZojpOr6OWX0MqvXxRrtaYDJ0azSnA4d08JTONfYtlV+o3howQzfOUiIv86iufW4Y
	MAZ0Rkyxn
X-Received: by 2002:a05:600c:c4a3:b0:4a1:6992:f861 with SMTP id 5b1f17b1804b1-4bb55a02932mr40317635e9.1.1794564726124;
        Fri, 13 Nov 2026 02:12:06 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb4e2842e6sm142085915e9.4.2026.11.13.02.12.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:12:05 -0800 (PST)
Message-ID: <82d691d2db7579d9630bf89f73132e36124bf74e.camel@amutable.com>
Subject: Re: [PATCH RFC 19/41] smack: use fc_init_pseudo() for smackfs
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
Date: Fri, 13 Nov 2026 11:12:03 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-19-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-19-4c998976c6c7@kernel.org>
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
> Initialize smackfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. smackfs never holds executables or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0security/smack/smackfs.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index a72bc7fabea9..4a56bbeaeca3 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -25,6 +25,7 @@
> =C2=A0#include <linux/magic.h>
> =C2=A0#include <linux/mount.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include "smack.h"
> =C2=A0
> =C2=A0#define BEBITS	(sizeof(__be32) * 8)
> @@ -2880,6 +2881,7 @@ static const struct fs_context_operations
> smk_context_ops =3D {
> =C2=A0 */
> =C2=A0static int smk_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &smk_context_ops;
> =C2=A0	return 0;
> =C2=A0}
