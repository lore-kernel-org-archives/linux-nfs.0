Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564140;
	b=2wrOhtOGHUpStsXKqjiGZ/85nGv1FjvYhMBoUqulSZUKygjW7iZwIvUhHysG24D6O6xO
	 QV0Wut6UZM54cS604zMzyNn7a38QuAHG0/6BgrSL7Vu4wgjEdkwkYuXYsvF+oS3iBTGTk
	 hrxHO6NhRiieozkKt9ieWd6kfDlIjx420CDWCazrJz9uWy/dsCfElzGC0Fo/7SJzXlrk/
	 ZnCjYe+r6cAQVb9sXfspwzkWsFTGAYpngW8AVQd6Y8e4Tlz/8QgmRMXOuzW4mmrtrjo+Z
	 kruJ1wHsfc5yzWGBoTt0CUb4PfwM5GFUv7PBDWnbSVffsYTlcVD+YSqfB9o0XZFamJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564140;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=Ee4ggwaa7pvqsvjnONVsvhhjx7Blw4b1QTFG8P7u7TE=;
	b=hV08zoe7qvnmc+dCQSbUTrMWEpTQ0Jrfk9VYVU2RI1PMdJAQ5u89Jj1CShTAU0BC5EC7
	 67k2Q8pjNWlHK5MnNfMkexQLYLHaVmNk8/oEEQSK7TxOtCyerpXssnN65QuxDqCdxca5H
	 B7sGmItNffk/ghG2Grk2z0+N20wJGANlLYYbhlHTncC59TFZIcXgwOY3hpRQ2fPsmH4g5
	 bnRQjtBSjWf3olSKJBmsC0ktpQFTkQ+cjgpRXQcqacDwBcT8BqOvl8ivhZ9YaoruEbGnA
	 lgj8gAkB/uxMfTwfijjs7K4JEeDuWYwcKB50FFVOOdQL0KxIEXW2frO24UdLW7NtfSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=mxnEK0OE;
	arc=none smtp.remote-ip=209.85.208.51
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E35C2606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:02:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E35C2606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=mxnEK0OE
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6b587591414so1162410a12.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:02:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564138; x=1795168938; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=Ee4ggwaa7pvqsvjnONVsvhhjx7Blw4b1QTFG8P7u7TE=;
        b=mxnEK0OEI7AZoc/CfUYBfL7b57vnPAty4yH1m7TS29a3jfzgxF6O21C+4eoAVH56Q9
         piX6TGhock7wjcI74HawyxxvBGzm9YxMDwhPO59HW6wNIzGY38ltasaZh4hFELwGRqEv
         EACaW/+rYd6+QPU5/79gIyHIHlnigPDAQAFlfCT0ngxFbKNdFkIgPJ4AQQVbJxYRU4kd
         sGda4OaUFoBKprw0qaI3K+cYJzK6vhQ24s+osuqJwxviEyFLXhcz7lQ/DUhHhDlN7iYr
         P/EQDWGz9doNbLrGEB0hB+YKjuFHlmGHIGpXLhiZ/HiYA8bpaS50WmEcn/ZjJ0UCEMyu
         vVpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564138; x=1795168938;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Ee4ggwaa7pvqsvjnONVsvhhjx7Blw4b1QTFG8P7u7TE=;
        b=uSbKAJxh82vNgnhubjYoywlwqmr2mfhAGq4wSUunLr00a0McwNa1dzuf3mVpLV65RZ
         gH2W/feD5QCHk0h4eDZFDQ6u4Bcxm2/5NxTCNrMq9t/WBzADP1O3PdL0z2jTFMDYaT7t
         ton2pVxDGGag/7xQuhAPMC2atZWaQehKkH4ynWeden1U+m8GbhLTJ4veBi02wj0arZ50
         WYltwN3BbIt1aKb5VZDgD4L4VUMuiIBrdmLs6f3Sjn3M6OoQaKVRP7ikQDDXLivCy8U0
         mbbRXb37dF+uDvafcnltOSulQqFXdvOCT4x0awjKnXq7va6D2aptbfMFhdWxrOC2J5BM
         a/qg==
X-Forwarded-Encrypted: i=1; AL+hErElsN3Lb8jmoMWIarvFEcV7hnOhZkFi/DWB8aUS0EirJOBjyQSYbK6EKF1wLVrsrJA+njX12qLqyQE=@vger.kernel.org
X-Gm-Message-State: APuU4Z+5m+azHzX4D1A4BXE4uE1bPKBYUmk3c9R0yt7+L3n7ST4hy/vb
	6QqA6NHgIX7C1Fm/INPM6kk9fJy1p8LK/g0LMfr0Yu2pC2Utw41g7C01pj57lSxpKiM5
X-Gm-Gg: AYBFou3WTnZFAqP3cNMdiC72/trqTGUdHQuO5g21Ydp+3OVfeJAzv78WTPc27KukouW
	X2FLz+vWx/b378c0p8SMvPf9uxkTIWwbbndIEouvdGrUkX+iYGUacpZfllPuY7UqYkvzlVNopyO
	Ie7cdyG1x2ghMBtP/Ps/LvE8ir3VMse25Tz2qfO0cXunW8tHeBnHqKzcV7fNdhhb265BsvKJG5I
	nyVKwVwgicYqkI5p8YglTLygHqqsr3lIuXaULlvEDOVbTCDImpZlTTNk+NRf+HUqO6kNBlc3kWR
	/XmdpUW3N/BXDVPUjROHhE3H6ZLygtJ4MImgR2kRPinX6gvrEUxAWuwOvrDPQZXL9Brun/0PBOk
	evqEOUOMKJvNelCPnzf07oM0FqZkVUPOyhQnftPVWxOuuLGgM670L8Cuj4jGL8FZXC+LpPHloUZ
	IjYNAEVFC0oKivPsmSY+9huOLwdTD3IuJz0cg5zavUDGovZ+R49BE6XkN39m/+8NH7HxWMtrN4x
	6YIA5AUJ5upOCuVtkPWc09HWn5O4pA3sG7cBPDO9Vn/sBiGldVDV3uXf11+IvGswEvo4GSlV9lB
	4ZATgJ/C0geSa2J8V3E0hGICM3/qADgwj5UyHPtXs041Q8BotOG6NwSInbAo6YM=
X-Received: by 2002:a05:6402:c4e1:10b0:6b6:eefc:ae7a with SMTP id 4fb4d7f45d1cf-6b7c088f8ecmr1236733a12.4.1794564138223;
        Fri, 13 Nov 2026 02:02:18 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b7c23c672asm734155a12.15.2026.11.13.02.02.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:02:17 -0800 (PST)
Message-ID: <f4ce8239f22046e90cf4807853282a570c73707a.camel@amutable.com>
Subject: Re: [PATCH RFC 04/41] fs: add SB_I_PSEUDO
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
Date: Fri, 13 Nov 2026 11:02:15 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-4-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-4-4c998976c6c7@kernel.org>
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
> Currently, there's no way to tell whether the files of a filesystem
> store data or whether they are kernel interfaces. Files on pseudo
> filesystems such as procfs or sysfs generate their contents when
> they're
> read and writes to them are commands to the kernel.
>=20
> But a few places in the kernel take an arbitrary file and use it as
> storage: loop, zloop, the nvme target's file backend, the scsi
> target's
> fileio backend, fuse passthrough, the usb mass storage gadget and
> erofs
> file-backed mounts. At most they check the file type and whether the
> file implements ->read_iter() and ->write_iter(). That's not enough.
> kernfs provides both for every sysfs attribute for example.
>=20
> Add SB_I_PSEUDO so a filesystem can state that its regular files are
> kernel interfaces and must not be used as storage.
>=20
> Pseudo filesystems also never hold executables or device nodes. But
> currently each of them decides on its own whether to raise
> SB_I_NOEXEC
> and SB_I_NODEV. Some do, most don't. Add fc_init_pseudo() as the
> common
> initialization point for all pseudo filesystems that raises all three
> flags and switch init_pseudo() over to it. The following patches
> convert the mountable pseudo filesystems.
>=20
> Nothing checks SB_I_PSEUDO yet so no functional changes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/libfs.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 2 +=
-
> =C2=A0include/linux/fs/super_types.h |=C2=A0 1 +
> =C2=A0include/linux/pseudo_fs.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 11 ++++++=
+++++
> =C2=A03 files changed, 13 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/libfs.c b/fs/libfs.c
> index 96a6e9b1535f..8c8789489fdf 100644
> --- a/fs/libfs.c
> +++ b/fs/libfs.c
> @@ -735,7 +735,7 @@ struct pseudo_fs_context *init_pseudo(struct
> fs_context *fc,
> =C2=A0		fc->fs_private =3D ctx;
> =C2=A0		fc->ops =3D &pseudo_fs_context_ops;
> =C2=A0		fc->sb_flags |=3D SB_NOUSER;
> -		fc->s_iflags |=3D SB_I_NOEXEC | SB_I_NODEV;
> +		fc_init_pseudo(fc);
> =C2=A0		fc->global =3D true;
> =C2=A0	}
> =C2=A0	return ctx;
> diff --git a/include/linux/fs/super_types.h
> b/include/linux/fs/super_types.h
> index 72f4288e16c5..472200bdf081 100644
> --- a/include/linux/fs/super_types.h
> +++ b/include/linux/fs/super_types.h
> @@ -359,5 +359,6 @@ struct super_block {
> =C2=A0#define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on
> this superblock */
> =C2=A0#define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this
> superblock */
> =C2=A0#define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee
> data persistence on sync */
> +#define SB_I_PSEUDO	0x00010000	/* regular files are kernel
> interfaces, not storage */
> =C2=A0
> =C2=A0#endif /* _LINUX_FS_SUPER_TYPES_H */
> diff --git a/include/linux/pseudo_fs.h b/include/linux/pseudo_fs.h
> index a651e60d9410..0ca408aa60af 100644
> --- a/include/linux/pseudo_fs.h
> +++ b/include/linux/pseudo_fs.h
> @@ -2,6 +2,7 @@
> =C2=A0#define __LINUX_PSEUDO_FS__
> =C2=A0
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/fs/super_types.h>
> =C2=A0
> =C2=A0struct pseudo_fs_context {
> =C2=A0	const struct super_operations *ops;
> @@ -15,4 +16,14 @@ struct pseudo_fs_context {
> =C2=A0struct pseudo_fs_context *init_pseudo(struct fs_context *fc,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned long magic);
> =C2=A0
> +/*
> + * Common initialization for all pseudo filesystems, mountable or
> not. Their
> + * regular files are kernel interfaces. They don't store data and
> pseudo
> + * filesystems never hold executables or device nodes.
> + */
> +static inline void fc_init_pseudo(struct fs_context *fc)
> +{
> +	fc->s_iflags |=3D SB_I_PSEUDO | SB_I_NOEXEC | SB_I_NODEV;
> +}
> +
> =C2=A0#endif
