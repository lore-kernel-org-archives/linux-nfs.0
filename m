Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904007;
	b=LwpNgZ8C1CFRhpjGJfhITV/Z50/BqL54/ROutghSXYMK37Wi/Vgg27/f9SximrRhVEuP
	 F4emi0lfgEtGv7Jfz895F5/65LViZ47DrySURF4cyv81lA5uK0PQXsfcMvBnXWZBk36km
	 Ce4In1DnAcB2JrOPoO8/Wgt5zCXRBAQvrNAt1uLw4S6YKcP9yqbinU7/dt/AojPxNpCjh
	 YmFRupYfsZR9jLG4dRs4H5EzAL6raFw/+yxV1JeVyAA7LKWK5U4uvZ0G8as+lLidTrOto
	 QD2sgri0QCe8x6Ys1EUp8/RSBpFm5yc8f1+yG9Fw1S7GhL2dHMFV3cTPgCTm9kBSjTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904007;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=zuUcsMvbqw5dxN0Fzu67367bPJAUtTqv88LLlRQCTVU=;
	b=VMVK03QZqspS4G2aajPJKEVSikXX/v87QsHu/shwHEE3ka1jqN+koIhpae1Wu4VcZK4w
	 nKQIN0fkKIp/kJ3Ml7HgUcWILQfvK1BfjtQBKojo7V0Q4faUVUN2Y4PEIrSXebz2BZrH3
	 cYOtcxwQdAlybbygSAEOQczODxLH/qIr3pk7jgIQT1UjJypqPA0ZzJGuhm27v6oJgjn/m
	 3+Hv9701cxO1G06rMsQALeS2pdgvoU/A382dfI2oKvZ2JfJfdn21zYWRTyB7tJAAwFLJG
	 kvkEwG9xioes2ZqJmFjnQGnxEyykLl516wlCzQ2qLSTilbiSgk5QHbRa2r3yVgFqzmQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=Bh3COd7Z;
	arc=none smtp.remote-ip=209.85.221.42
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 475E7606A339
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:26:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 475E7606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=Bh3COd7Z
Received: by mail-wr1-f42.google.com with SMTP id ffacd0b85a97d-4a3e706b5dfso174954f8f.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:26:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904004; x=1795508804; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=zuUcsMvbqw5dxN0Fzu67367bPJAUtTqv88LLlRQCTVU=;
        b=Bh3COd7ZzI6TmZdb32Fg462zWvuh7WQNnrUpXucHXcpV5t+t8gMfKKxOWwhkcHBcNt
         zIJKpUT9Ten8K9xmb0ZHj3p/ljeyNVefWtOpjWCo7Igmb/P1wzmYs63YOxLg7f+WXmDC
         wf3ao9cg3f1DrvZE/oBKoQiWFPBKSPnWk+jCT2CGoQgxeoDuJREjXd8oRMM0GizRyDLq
         q7c8W4Fdq61I08pJrjWNPm+S1jXNjmZ2MpEutx4SYZ/JoE6iRzvUZ/uRuGO7TyWDBzw1
         OlncqX8aSwrA8zDhY0Cn+N6eWM3qFfFk2ULf9A0Yk8lhKFDJjJXQbcxKbI+h6RZ2p0E1
         0Fcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904004; x=1795508804;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zuUcsMvbqw5dxN0Fzu67367bPJAUtTqv88LLlRQCTVU=;
        b=Etmt0pHo9ySLj8RAcdpUUHn/9btyvOU0KesbbnL0e5DPeTI1xNwUoEn4f3zgkmRemo
         G1tYWv6tstkEDpTXsnEtpahNlQg0kEjxgM+UDgsY/lX7vGnAtHwIuGbg14nh5l1ibrU5
         6ckJKFHjizsLmCsgm1i3pTrq2i3mSSIu0I/2a9A7J0AlWL5Phqx/1p5Z1Fl2Bv2oyrse
         qKOORkZhAKHBYzCY/8xSCl4pRuka1kRpaSAosdSIT3VQyFxze81HQL6RIc/HzvKooH7u
         VjBj+tnsv0aZLmvu764hFLOvn2oEO55MapUQ5olxBRyAxJ6XFCj44bjV+Kb3ZyfSeqkZ
         9Giw==
X-Forwarded-Encrypted: i=1; AL+hErGLkutBUCJOTsf74hhMowvpiGwdvuUPnomfhbn56HYRjLk++hZmCASK2bKW3XG0TqihLQYcoEuBj4s=@vger.kernel.org
X-Gm-Message-State: APuU4Z8ooKpsYNoWBmltt8blvQykHrmApzo1DNM66Ql278wVBoL5UqD1
	t5eQiT3+tHx1C+kCX7XqKYW3LxFp/oH9kaxRQ4vhLN7X5iEVwVSnp9qboEqzO4YsJ56n
X-Gm-Gg: AZFdTZeEIx8v5z6CSjmWaBakaJKCuw6Ge45E1E7FdBZa4YC+Uf4Pa34CnkJEknKdQ7+
	KTzgRMFD+Q1jn8RlmbFmvI8SbsyHDsL53fqIavesBcQA3OqGDpkHluUIrHhiuuN6mlOmpLIRTb7
	MqtHEd3BEV2Zwsr12convAiPtp+fJORN00xn82+fUezU6RedoGeFAwWJ9g4/U5p/6z9kiYlIVi/
	c0w6lsNB6kWG/oYqafbSybA2LPAbD2VxXWXmmLHkhw2WvObXxNM3ur83DfNaspQTPrSoyBiYkKW
	YN/TELM8zoIOkl1f2TEyDdu2TmC7e7jTj+vZqVX55G2j2Ex0f0nsIHlF+R9yA62MLN/WAeqitXh
	PCYOs/sO+AXDPlcj7T0AdqIUFX4vsh9SJzg9TEdhdisU027lmfbwTEffIGuCNblb2pqaS+OG55w
	jHlGPC7pX2LYR05RMdz0UTRS7SsEI8RvjKXKJMcYrNzKaJqQMcfeEiHVGuXiXzLxE726heYuQro
	B3Qb+zpVwWoYXJ4DB3jDDkO1RCpOC5/Fo1SHBwuLq7MUHI7ksY49IZS2eCxG3qsAS1WeC1sR97l
	vUlo0vrdFck4L/mnR5IqKpSPp4CE4wkpMvMbxytXlFoc+13p0tvHYCO+pA5u7Tuc8kQxH6dIL1q
	v/7HAnybbsTRUfVQFCpNMUhtcuu19hmzNGDvwsQK2h2IDWvi8eTCv35S0
X-Received: by 2002:a05:6000:2009:b0:4a5:2e5b:51c2 with SMTP id ffacd0b85a97d-4a52e6a947bmr243585f8f.29.1794904004601;
        Tue, 17 Nov 2026 00:26:44 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4a4de4cb1c3sm977858f8f.8.2026.11.17.00.26.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:26:44 -0800 (PST)
Message-ID: <c43d70badf41f62f8e149ac024bab3df979fa756.camel@amutable.com>
Subject: Re: [PATCH RFC v3 11/44] failfs: use fc_init_pseudo()
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
Date: Tue, 17 Nov 2026 09:26:42 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-11-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-11-8cbbea1cf34f@kernel.org>
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
> Initialize failfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
>=20
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0fs/failfs.c | 3 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/failfs.c b/fs/failfs.c
> index 437cdc981c2de..f03334f361c0e 100644
> --- a/fs/failfs.c
> +++ b/fs/failfs.c
> @@ -3,6 +3,7 @@
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs/super_types.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_struct.h>
> =C2=A0#include <linux/magic.h>
> =C2=A0#include <linux/mount.h>
> @@ -132,7 +133,7 @@ static int failfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	fc->ops		=3D &failfs_context_ops;
> =C2=A0	fc->global	=3D true;
> =C2=A0	fc->sb_flags	|=3D SB_NOUSER;
> -	fc->s_iflags	|=3D SB_I_NOEXEC | SB_I_NODEV;
> +	fc_init_pseudo(fc);
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
