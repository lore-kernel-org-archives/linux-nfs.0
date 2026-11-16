Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.221.51
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794859450;
	b=vWyDjK42kxtqV5TrAyAFiXvxemy/wUCaLKyytAFLHbtHganLTCGN1DPZheJ2V53I60Hz
	 ktfD3vuTnGJrYA0XjzJC20uyMzyVthDIRWK+8ItYUBNidxV1xs2BQV4lFEdwZX4hEzdvH
	 cVP3A4Sl1mlscASolleJbimAtdUzSUt3CQ0mstkl9z7DotKAfN7c0rjbK+o787FkKb9ot
	 JNMWFH4+asHkQdQSArz/LCdUQtZ/vf98YyqLPTEb9guk9ObSeF0TUh0l+CU7RzZfDqbfU
	 giVuqhOtH36PdSCILKvCWVXVxSDGZ7CgyyEIJXtdDtZcz1Mihx8pBe4QVZ4+SPwvt5g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794859450;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=FEtpE65JhLGyAYaL/FOW2ebUIws2WwBZ/4Zy8VNXUuw=;
	b=dwcRpoBooEVA6BSC7sCdpTo53wrbjxnP+G+zeeg2ZVq1xQbjiCzIkgOZTr0kpTEaGpJt
	 q/ImPoD9KqEJ3dobiugr3t18zol79dTPSNRNtYOzrUCuCJ9cLtWWt6caSEHmC7BsyR0PT
	 0ylezpuDoSKy1bvzjY7LVfOk+ylesSH0F4aDeLLXAnvNQEtYAKXr986Z/jKT/CbBr+dty
	 r1IsJCPftRLt9llteh/tAr1btK6CvgmFs9wHkpwxvdBPns4DVvUHF4qiWIJPpsqF8XWFT
	 4ovzROq7tBbLZbAffLo0OBHqm8kMXtoOzaD6Rnu3zSMmTOV4M2BREi0PLNP8+2FuZeA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=hnqDx80H;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.221.51
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 361F9606A333
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 20:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 361F9606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=hnqDx80H
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-498f5fa5103so1736452f8f.2
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 12:04:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794859448; cv=none;
        d=google.com; s=arc-20260327;
        b=ordTXJuxDLJFFe2kqtzrIPaXrutWjet7GOVP41khazzjtYsCpvjE0HCzSNrpzvBf8F
         gjfZj+b5goPigZrxfFE9yOkpm1Lm7viQir4wOVnAI+AFET9CbHtkNvqEVo+U3TM5YGV+
         B1Vb713teMxjyb9V795xq4rE0RHd4JpWpOX69A30AUJE0+XBZjTClq2iOGhPY3ipV3Ah
         7PfsRCORWF6xDQtRoGGYy35hssnkbVVmoshc6+U15niasLD9HX0a1GmJyjXWdiSw4yaa
         iZK8Hm/hYlZLxdan4uH2TryRC1G2b/RLVAkmwPax24SB/Z+sX0oJHYJ7/YAYu6UfmVn9
         c7gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=FEtpE65JhLGyAYaL/FOW2ebUIws2WwBZ/4Zy8VNXUuw=;
        fh=rxQ8C1vpJq+OrBpkaRSs+gOBlUW/EzmDo1OTLGkAY9Q=;
        b=pe8o/GlDD4YYrR6mRNIrqLvCk3gGd1epT6oX2dFBZR2avO+95+UpdI0Ja0Sy4Q/MBq
         XdzrP9NqXFdUJ7LeKmGBLJWHcF9CADB+0A6zBgemf3vQW0xvh18NyzAH0KmSEglTqO2b
         n/mB/KGWHaveylJEDFU+gAhsRFxfDF6DeAl9GswQG9qdhQfdj+ACbS0ovSJr5LQEkFXv
         Px0wD46GU0wTmMC1Pta/1Ikdy8hPldMt8GkrTLpWjlr1cQLmFxjZCJEDAbkJO8PNt27T
         kSMOaYyRPTI7RSd4IDZIY/TSkoSQBbwA5z26yLMZOSJtKOGXBMql3628VSyprthaaZiJ
         Nkfg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794859448; x=1795464248; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=FEtpE65JhLGyAYaL/FOW2ebUIws2WwBZ/4Zy8VNXUuw=;
        b=hnqDx80H1BHGMZ+jCw863LQE2wm4hG6wTw//ziQNWkZpZIjdyNNCtFJNcbykSvuJWZ
         RrqgQGru9l+9Rlw9NCoAO7RXSeH6CHzRwb+h6TsbT77V+vTLtC7o5AslWzWJ8+7yhciq
         sbJxN7Yoz6y6VYO91QUyEDVlXVHt5e/uzOZriYhKEljZIduQH6pNfhdOY5sHlJFueOxf
         bN/uTLfuNBjnHaTZ+WukZQS/Wa30tWyiKsfqEPmOKtkcPCgN1gGIeLsa9pfco/3ZvP3P
         koo3Bb9/+esUnHdHS2hTd5qtXE/k/xctadMJUuU/zchcL0VDKvTRNofZgdIQ6mLOou9W
         X5rA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794859448; x=1795464248;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=FEtpE65JhLGyAYaL/FOW2ebUIws2WwBZ/4Zy8VNXUuw=;
        b=mtcAeN1G9N6s2558Wfy09l7Ra2Dekwa3pr+q32yx4nZvhLbdWv6bCQXDFQVCuT/zZQ
         2yHD8Oo46Ghtgs7qfPbCJ6+tUdT9jVOc89R/w+XZyoAqCR1Q3MmbONG/tGR4jNy4SUXN
         ENpLOywy0C+n4aoSTAUVdjQhNMydduJNYbtxBnDNiYf+QvT+NkWyZehLEi/2FqyZyTjG
         mEph/YzqNTz2o5owmeJS+UUH0BNyFr6R0boG3FZLWu/au35Pl+KD3YMadTurjjXGc6OD
         uGzy/brAZpTWyEXHsQ5yZHOBOUEPqva59EChHv/zLnzfAFy0mgq7b4OlebZQ0+EBtJsb
         b9wA==
X-Forwarded-Encrypted: i=1; AL+hErHfbiIVfjUBcJl93UvktZJjT+UfOMRKobXNmQEV8rv3x3O6c7PDg0G5jhN0BE50g3HibJXto3HTpeU=@vger.kernel.org
X-Gm-Message-State: APuU4Z90bjSAl1IGlUgPvCimo4i7IbZGNXfUU8l7V8V5f5t6hWM9vC3u
	MkUBJRnlL9yX1KGE4bpq4W3jiZt/GLCX0NP2r9z7ByYhNAhYZ5LpnFY/7tjxFl3deH6kxKhtV2/
	0fKO1OHflirUqcSbUZHvqVRBVRg6YYnQ=
X-Gm-Gg: AZFdTZcutOnvoE+XB3KlP7nsEvmPHelYKTtUlB+xSymrObH1Y8EFNxRr8auzJLXWDFe
	fYKqijbTSa3XyA+EQ0ax8fZNzxfvHpjWGLZSKIg5WE38+M3fvCh2njp8UqV9/T6GhR1yVrpxe5d
	DgMY95puGO7UO/8qzhv+R0fJ/j8FSEnxGORTZ7GXfO9XUCaDlQeqSYxifpFw9mzk8NPusv3t3Q3
	Ir7N9k7vCL5ymW8asT36+6qrpTxqEDvwZtIDBOKA84/w4ZhbJ51lTwv1JgHFDWrkKIpQh79GEKV
	TzAdHAvn6dUqd94F6p92vTDJrLGVJPZp1TEyRVr60hPk7zUO9ndIAHBWGtU6MguvRmapJOiJUv0
	bYIOVwTjn8ylAr0WgozKNJiJJBf9K1omYCKh/M8YWzu0uZ0LiAilRknFawiQ/2T+rUYa+uq2pOp
	C+suuQZmS8kvAzS3dSYHE=
X-Received: by 2002:a05:6000:4692:b0:491:3fdd:af34 with SMTP id
 ffacd0b85a97d-49d61c80db3mr13343868f8f.36.1794859448335; Mon, 16 Nov 2026
 12:04:08 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org> <20261116-work-loop-pseudo-v3-9-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-9-8cbbea1cf34f@kernel.org>
From: Andrii Nakryiko <andrii.nakryiko@gmail.com>
Date: Mon, 16 Nov 2026 12:03:57 -0800
X-Gm-Features: Aa3M54q6P4M0RFDCKQ8HHGNCWJafItTSPdWR1qNwVGtToDAv2VOv8vDfWHzYR6A
Message-ID: <CAEf4BzbLFVawibuX0wk=8uzy0WZSYHbkgK55d7rqLab2qAM1Fg@mail.gmail.com>
Subject: Re: [PATCH RFC v3 09/44] bpf: use fc_init_pseudo() for bpffs
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, 
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, 
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org, 
	Alexander Mikhalitsyn <alex@amutable.com>, Chris Down <chris@chrisdown.name>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 16, 2026 at 3:21=E2=80=AFAM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> Initialize bpffs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
> Reviewed-by: Chris Down <chris@chrisdown.name>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  kernel/bpf/inode.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>

Acked-by: Andrii Nakryiko <andrii@kernel.org>

> diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
> index c6f328e4752e1..57cf3775c0766 100644
> --- a/kernel/bpf/inode.c
> +++ b/kernel/bpf/inode.c
> @@ -15,6 +15,7 @@
>  #include <linux/namei.h>
>  #include <linux/fs.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include <linux/fs_parser.h>
>  #include <linux/kdev_t.h>
>  #include <linux/filter.h>
> @@ -1197,8 +1198,6 @@ static int bpf_fill_super(struct super_block *sb, s=
truct fs_context *fc)
>         sb->s_magic =3D BPF_FS_MAGIC;
>         sb->s_op =3D &bpf_super_ops;
>         sb->s_xattr =3D bpf_fs_xattr_handlers;
> -       sb->s_iflags |=3D SB_I_NOEXEC;
> -       sb->s_iflags |=3D SB_I_NODEV;
>         sb->s_time_gran =3D 1;
>
>         inode =3D bpf_get_inode(sb, NULL, S_IFDIR | 0777);
> @@ -1261,6 +1260,7 @@ static int bpf_init_fs_context(struct fs_context *f=
c)
>         opts->delegate_attachs =3D 0;
>
>         fc->s_fs_info =3D opts;
> +       fc_init_pseudo(fc);
>         fc->ops =3D &bpf_context_ops;
>         return 0;
>  }
>
> --
> 2.53.0
>
>
