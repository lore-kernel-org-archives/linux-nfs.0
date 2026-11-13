Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564335;
	b=F6Qs9nykGfmcA5oNUDCAM5aBIqZ7zV3WMbh0/hz71rOnYdc8mHfLrRnB603jLE5YvfHH
	 LcOKJK1m3oWgas0kX/S9qMOLjCSTScRaqcEZrMLW2CmhkbOBre+G2F3R8JjH7GSLDUOnr
	 sEXG6wbY46JtZPkwe6lzTWSkqRfgTwo5qJlW7XHR66Xzz8VLHgIxHLNaiqAIklsvlvuYN
	 HsHoAuBh0yeIb50v6uxAUs8SVyM58PKXGZ6AwSYhjAiclap9JDoYNOUndjwdwv52svRSV
	 1Js5A9cgWOqb2nT0WtiB3El2C+ikwbIRLLkUFCaUzXXNUHERep3XtA0UmHKSmKQAtNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564335;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=fNM18G1T3F0ezY9f7dMoEwC6d3kOVWk14Z1vuqkOGWM=;
	b=lPShjsJV9kxIrHWtXb8sp/puzXsu530QoQQQO6XDb5I6LBov1qz4a2MTNyi5riu8mjEh
	 p2emv43jEDZX3qhRSydXzA6o7QZirKEJkTJsPMeQRzMGf2zZNVJizorCGm1ypGApk0M4r
	 qWE7HgwTuE0HVnktYDSm0s4Di411TNoWUGquK0Evb9xrF/VOFsx7lr8bPeSFPsDbYzywB
	 BBaqmbAXyveNQDbdc4kXYUtfVe9KjpxZFuI0YavytUlRQRBLoFMJY2c8lgZJJNGluG/DL
	 ztw1gvNCnCrhXwELaqCZ/fAkQ+thTe3bcfTVh8bxkdWpWciku0lXxWXjBtVlrPX7vdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=QG9grDi1;
	arc=none smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB988606A887
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DB988606A887
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=QG9grDi1
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6b7bfefba55so1543222a12.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:05:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564333; x=1795169133; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=fNM18G1T3F0ezY9f7dMoEwC6d3kOVWk14Z1vuqkOGWM=;
        b=QG9grDi1333EJ5vFrDKveygehwnROLgKvX8KCpfSFWXv+I4eyfqnua8R6KtrAOOR2l
         +HS5JCIdHH4GFYhxTGpcul1UYrqBxVEKVYtZXX+QuFjz3atGFob21cLqAoqZi5JADlHj
         naEBbS2xDydM14fm4tN8GtiKEyyXhNYXhFZ3I5ZySehDVmQo9RyEp8Ng8zKyI33PSYjC
         lTyIPU+8AziQI1Gig31BVdjw6dAVORszr2VJptJ60UUsagtzV6Rq+xhfECkHhjnaX72r
         CaBJBa1VgM+UMc6r/RVDCNlq7Fp9h/YsxbVqvvWGNdAmSmDIEy12RhSNOsQRohbebR7n
         4UIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564333; x=1795169133;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fNM18G1T3F0ezY9f7dMoEwC6d3kOVWk14Z1vuqkOGWM=;
        b=wSFMviUBXxWSu1TTiVC2iH/JlLFv7ZbTTlbC6QpcKaCZDgoGZwoT/hqN+PXuw01mW7
         1uC9Euf8PTKuvqPHr8SmGPnklI2MSee5nos+Nknkz4Rmr1MW50XzFWEl0152d3U+iEOm
         sGDzKJFi0nnzw4Uaopq6eVpvZFzREuDo90Iyqprmwga4+z/4QdxNgnRmeMpP1+hroATj
         k+a84vgSpG1IKHzQwhWzj4edaRiNGNpWHfbk1fLQ70LDAvRdIgAIsKpLWjKGS0hrwb7g
         5ocMkyYjCvZp+CSp8HNqPCt0j4YtSrUcIz5ARGHJuCSnP+MqiyhtPg6V6fH6LB38bSm6
         fDHw==
X-Forwarded-Encrypted: i=1; AL+hErGpUEnqlOIF2GyQov+emRb0biKVxbBjc9UD/24lP9Bcm9AGQ4A9Gcs8Qz8T/cxZV3XqDa5+y5A2+wM=@vger.kernel.org
X-Gm-Message-State: APuU4Z9nWzaOm7VGhZnNComjJU+Yvn3BuXUsxDb2eW61sIL5l0eby/Bm
	yJHEFBsl91nUL5+LHU1h+Wecu0yRHdPILYWqXwj5NwL1ji1i4PdCK8MLmIIoszz87xE+aQTS4pP
	mL2P0PvdNj+s=
X-Gm-Gg: AYBFou2LkfE6pY8r4dixjYQtiku+M0WD9eIXMnOJOdgw/MP8sQf4KqQscg3m955MFq3
	rZz6C4xM107Prl2EMCtsAuKN3VMNCzgVo51uTEQ1WKZwLatYrtmv7OsGNz9ciiDMkxx3hQtzyOV
	idZmCOYQ4Uoy4Ng/e7kYbVj8/HQlVGow2QUCDEVwFZS7/pGChk784+LCUGan3JLe1/hcbI8u/RB
	bnFiPV5RiGkk3vyzMDpwflnb8oA/e9a8H/Lp19LfREddalfX0dXiYYLSuetxjQr412dsnvyKNBQ
	eINNmZJcF3ZuFixEixO/4kyXH2KFl/WCv3BUuTWhOtncajXqrSWeRIwEUAENpH8cv6LWEdaWpso
	pWrz8xGJTwqPXW/JioDICBEzyNpQrRzEUVk+D95DU96WdqR4PR5K2lds5hi7NJlIjYCULkr+m14
	cEjfMBYGhiLY73/YVK12ZHxbynwnoZQK6K5bWkY34VvkiNU5dkOJ0LHzbfV1hkYOmM77Deg+ymR
	2d6cEJFNa2l9eKZZVDKPE7ksrjJ3xDE8SPHvsqKP0aeB1P6zC2FYATwmXSOK2LrQjkkme8VT4PX
	oJ/JznC6nX1V//BYMEp3XGdy3jw3po1d+5pg7PWNth4VWzo/cM3Fp6/dTyf5XcE=
X-Received: by 2002:a17:907:608f:b0:c43:eae5:ee80 with SMTP id a640c23a62f3a-c5096398b03mr148720566b.17.1794564321873;
        Fri, 13 Nov 2026 02:05:21 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b7b2c9sm75811766b.73.2026.11.13.02.05.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:05:21 -0800 (PST)
Message-ID: <08fa1be263cf4a3db6b3e5ec2847107fba7acfba.camel@amutable.com>
Subject: Re: [PATCH RFC 13/41] devpts: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:05:19 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-13-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-13-4c998976c6c7@kernel.org>
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
> Initialize devpts as a pseudo filesystem. This raises SB_I_PSEUDO and
> SB_I_NOEXEC. devpts never holds executables. devpts_fill_super()
> keeps
> clearing SB_I_NODEV for the pty device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/devpts/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index bd1e8eb26edb..47ef12241d92 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -13,6 +13,7 @@
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/sched.h>
> =C2=A0#include <linux/namei.h>
> @@ -438,6 +439,7 @@ static int devpts_init_fs_context(struct
> fs_context *fc)
> =C2=A0		fsi->mount_opts.reserve =3D true;
> =C2=A0
> =C2=A0	fc->s_fs_info =3D fsi;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &devpts_context_ops;
> =C2=A0	return 0;
> =C2=A0}
