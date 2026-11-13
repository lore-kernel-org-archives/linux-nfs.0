Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564237;
	b=ezolif0xRwN3IzGGwcddEcmYhm/j7apxjHAaqp2Gw9t4JRu3nSR77kQ49srLZLgSDNpR
	 XaodEAp9AICH0hK1tV2HhUfpPn5881g5/RcoCKjt5ZULHzEkdCrk0EFw6E2bbR6NoriT3
	 GGj5oozp4fM3BhZxD6BXU8a3T8Yo9RfOVRS4wVN3T2ohdJQhjmKSetH4smgnh24T15k5b
	 9/6NZnyTMKVaO9zoYPadMbh62R0L5jfIgOaL2ZFqolXFOg1DdpkMWLomPYZtSVm5iNX3e
	 NGJVoI4G/1rrmbr9kXuDQKvrYBW93CaMgofZSoJejXy7B7VuvJUVLrXRJCw2Jfrfebg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564237;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=isfwHOSFEU1THdAtyjNR/BymwB+TGu4CpGjFt5oul8o=;
	b=MtY8rJk1CTbV+x6QBLCDIU6tYu29jG9xln9bDXLH4FcYfBz7JXJKWe2rtNnkJXGLQk90
	 Az0UgIUS+BgCgeCfyWat/pofAhCLHBt9p+UCK+NSelAPOVy5dl2NL0IqvRDkGQgkwnSbQ
	 xzEjJBMMfWmumYVYUYuhSTFKIbnIm1bWec9ZkkAcvGt0+9rSDnfph3EWNjCnG9HLUg1Mi
	 oFyzAJNxeFZw2Ej0lQukioXy795AJMzFSu4kR3iLNxl+r7vMTtCrWt05XbkQ9uOyU+afE
	 +ZrDn4SwkljP3sW/XpL3qWl8DlwrejJEOr9pVvQxyL9uKiZnMEh51cHq58vnbHsZLwQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=HmOhZp1a;
	arc=none smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEB68606A8B7
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:03:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CEB68606A8B7
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=HmOhZp1a
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b56c428212so1145028a12.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:03:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564235; x=1795169035; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=isfwHOSFEU1THdAtyjNR/BymwB+TGu4CpGjFt5oul8o=;
        b=HmOhZp1aysVRSGcApaAZDLI81xyeSldeu7ePLUPKkH54FsFfnK+QDVFY4+VQQZDD5I
         H2HloBZm5LZmO+0yz1W9rfEhaL+YICMUwpLNmuFaGXNfAv5LYB2fsAN36refSeHGX9fO
         cryYVQ+kM2KCw8u+OcP3112ltvgpCHGvfl9d9GfdLtqmNcwNDmKz3KTPAT46qO03zj8M
         uuWZNkUaGTWe7Ooua9eiEAKQiiHx3qf0rn/l3lNWMOa2sfege5hzg+R5XNTSj8AN0bpY
         dCBAZCrR4vjcQdomnF2hzC3FA98LaruL1WYTiCQ1DC9kzlEXZqoLyeQdM7U6VrMRD1VV
         Lr3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564235; x=1795169035;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=isfwHOSFEU1THdAtyjNR/BymwB+TGu4CpGjFt5oul8o=;
        b=rRktboRPC/sfpYKZiG0AibDN7m2oIXELIhbJL45Q+RUPa3B03DYRQgDXVI8SQzncob
         asMHWVr1z3+Pvok669ZuAM7LoeTOE//miXTURiMe3onMHEqtalkYUV1YsYW5cRxcZP3s
         qhRLRm2ArPehjnSkVJ2+QOlrE6B7ouzrtZD7IX+1vVlI3zPi6zJKhwaKheRTn/BPP6Ca
         vfuLbRXFopxh30UE/yFyQrjKZwv5RFRj/GjQS4/uvBGT0jqWVwavW4KSLkW+mh2vFgf3
         P3VfPucs7FUwAj7bgruRwR3px74Ildq7J3BOhhi0s6f0Brzt3CinHWgVnrpPwtmADF8L
         eVlg==
X-Forwarded-Encrypted: i=1; AL+hErEXzPojOJb58gY0dCZ2WumRgipEkMWAKtM0Mn5pvk2GYnZ4itTL0tYpdVCjGGSCvTn9KVPgJvOk7mU=@vger.kernel.org
X-Gm-Message-State: APuU4Z90+AIn2lNYBUVh2lafe70mu3npKLvuP86/2s5vSXAyLtxfgr8k
	+Kd2GBBYyLdINrXa3DvCf6W6XgOIG2n/MI6CUoCqwnkz2/wWj2OLiujk+O/TUcUzOkki
X-Gm-Gg: AYBFou2KrJ8hBqPDp47t+pV7GYA8/8Uod2CDhC6whPahY3ILtDVsL2blAqttlf93vlm
	frXe0BMb41pNfTszaBIOodN5ZboTu6Ymkr6PGDVMu4qex6y68etkPiV6aKxgKzFFNWyiUQbSLmt
	ZJ0yJyWm99k+jRRfG87n3Ig2OyVRoUjFTARbSbiRIkGxhpr/WqXAS93Hee5Wqzrjwox9ZqqB8WW
	Ev5gwAreN23aPc7twXbw8/daJRQioInaxcw0xN8GHhl8U1jPRxhGjB/8yndZVnmoZMw5s1OVZ/M
	YW6bAnUK/tGVJ2H87Ptwvrz4ei9wNm0XQJguDxd5z5GKr/ctv5cHAQ1i5+Nyl/A9CBUEk2izNkS
	er6gBFC3krqIL2rrEOzSBWdDfTa9MQg4Y5/j4w5Q7d9BNp2uX1rYA/unXfp3Gf66/QsK21l6og0
	V3eGczzXq7vdmp790/QLdCIUg241YW9FuEpMN5md8a5f5BvHgNAAl7XY8JMwnOQPoX0m1xbI4uN
	POuN8UfABwnd9f7bjdn0g1KvCT6bS9B98jDor2P4nMsnmGo0Vk7IPJY9YVpQDS+XAYJq7GAQY29
	1YvLQZTaeZGrSNqpAKtQNsPJ5cfH5LfNDWsq1fYhVrIAGgInm5PIRFS+j8xXFCg=
X-Received: by 2002:aa7:d556:0:b0:6b5:96e9:ae97 with SMTP id 4fb4d7f45d1cf-6b7c0ccaafdmr1234919a12.34.1794564235160;
        Fri, 13 Nov 2026 02:03:55 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b7c23611casm766458a12.9.2026.11.13.02.03.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:03:54 -0800 (PST)
Message-ID: <16dbddeb5cbb9613dc806b43fc681eb26aa3b0dd.camel@amutable.com>
Subject: Re: [PATCH RFC 10/41] nullfs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:03:52 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
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
> Initialize nullfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/nullfs.c | 3 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nullfs.c b/fs/nullfs.c
> index 319c2f5c5a67..2fe24cb97160 100644
> --- a/fs/nullfs.c
> +++ b/fs/nullfs.c
> @@ -2,6 +2,7 @@
> =C2=A0/* Copyright (c) 2026 Christian Brauner <brauner@kernel.org> */
> =C2=A0#include <linux/fs/super_types.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/magic.h>
> =C2=A0#include <linux/splice.h>
> =C2=A0#include <linux/uio.h>
> @@ -174,7 +175,7 @@ static int nullfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0{
> =C2=A0	fc->ops		=3D &nullfs_fs_context_ops;
> =C2=A0	fc->sb_flags	|=3D SB_NOUSER;
> -	fc->s_iflags	|=3D SB_I_NOEXEC | SB_I_NODEV;
> +	fc_init_pseudo(fc);
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
