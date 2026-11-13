Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794573510;
	b=YFGOCG65se/TXu3U3zkLoyL6DVFWRSPRRaxehme3y5VXGouCZa0gxkL0nh194Iyp8y+r
	 5ekXS6IWS3olMb4Df3HBBMzhDMOUJIQ39oD2O647DwhgirYNvV8U6jmnVl/W0fLEAMBMC
	 IdJpvjx5qhOtACu8YKT1Fvhf2LALuJWIlvLHb+GjJUyE725zV4D6x5zgSnUX7mA6g3Oi8
	 E9G2fPnsh3gAMS3Quap/f0sMr+ELi/T2hbLIjEElJ7ROtBJtPcH09aMpM49Xgn0udm/R/
	 E1Xj/PvbIhREf1GTrFr5wpzYKYDQh95RNy+j9Dnv7HZCK9y55ad349HB69sgR4GR5CQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794573510;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=Ny+1veWg8VD0eIDxFJ1X48Kguf5Oe9PbJZTpbcgMiOk=;
	b=Kt49DC4r9O/sUkMh0ouX4pvLWbtlFv4bDk0qTbhK4EjsB5UMeUHY4qLMwT3lMWC/ydo3
	 Re1JG/WEfKdJK9uR0uZ9vNvAkDxTy4RLn9hShDMRj0mHKDGbaZFuP4kgye/B00bMVExky
	 /LTd9m5JduVxbH+O8fQPBbl8W9ML/CpcqLU4M3doLE4AL4te4KECHwT6C1R/I+yLSjPfa
	 EJ0Ygdo1/+/HR4WAiOxRzhVhJpMDA+h46pV08rVvjLNkgBwmCqa98MY+ySk5Prcgp5uAN
	 u7b/wIvV7TAhTwWptcLTnpNMPxk0QoMtKU+7QYwZ2R6Go4hXStHY6wSparVMqzGWfkg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=Bz2+TnPI;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D592A606A334
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 12:38:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D592A606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=Bz2+TnPI
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4bb55cda775so3649035e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 04:38:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794573508; x=1795178308; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=Ny+1veWg8VD0eIDxFJ1X48Kguf5Oe9PbJZTpbcgMiOk=;
        b=Bz2+TnPIApHKvsf08kyiSuJZ5AWViHONwTwuNXVAuo2u8JGXjKnEoxSd3hG/r/h3b1
         tdsUEBtaZSOWfU3+mD3LjyqvBKt9Vc6RBsvkZZTD05u5eCDGhnWto1Wbu/C0r64DVVdd
         h2TGnt6meedDH7Iwjf2Hw2JxWOY8jwAvEAcAC10FURsf5jjp4p/KJzFYjzuPwuYFNKea
         Iij0h8HoPs5opXKf2XwMBJpd5hsYSV0+BHP/DvKdCCgwNFtbeIFAwqDf2ag0NBOCbqs2
         OXWiZmXbdGCixyOlqQBMgrkFkrhg1VmbSdmvvBdeQ4Vz+QMvhYl+k9AO6FJ5UW1pg6b2
         DVuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794573508; x=1795178308;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Ny+1veWg8VD0eIDxFJ1X48Kguf5Oe9PbJZTpbcgMiOk=;
        b=lN9iyecLC0tDAKKKsIq1rHESMFKu5GACN6pWPO/dqpDDjW8S3fbVL37Mkn9Rg7EHVs
         1Zf9c7xlISnZqIF+s1uGe3R0OklPvSv2J01mNSqVurHRXex0hK8ID24qXKIiPDtSIKWu
         DOWSREoVd+q0aBf75t5tRwuPHtbDuuUNXaW9jDb4R5kAnagH44u+fZnSYzvRb1dczwik
         58rsplPSBFItoqoJbL6iSzpx9AdmOYRLKo40Mrt3FFihav24n38wvQd/G1yFKLaxqyTI
         Zd6+900xmEUC/FXjNrAtqapaXKwYSBOaiTnyjDw/6I5NfQB8GWdlH4qLC4l5+WjZ1Zmx
         mYQQ==
X-Forwarded-Encrypted: i=1; AL+hErGwpDDQfKJ3OCQp+qZDlrmkxKOmCaCrYceygW09qBnf+CxDlwf+erRoov2iNJMy9EtW8B0lSU8ofSU=@vger.kernel.org
X-Gm-Message-State: APuU4Z/ontvYcNnqgSSsNZxiQrhpwBNZkN3jxSZxzGf2usXJ+UJmbtZM
	SpTxzWZ6Yyxxh3/vO4HAcV2p6dxqVvc47RgyLHgQ+gzpsRuFGYbiaTK3SbSqSD+31dG8
X-Gm-Gg: AYBFou12s2KehXRWT2WG4CtGcuC5HD0ZwlXSnyaOdlYDjUphw3fddeo8tiFzwY/Mnyn
	yaRSNPWQAf3QrtNkghuXhi0LgbohYsTHwV4wxUmzxgaz+7QHd0TD7eTuP20k7ouGWe1qQ17Uz3D
	1kGEeEgxtq21gth9yZY+Jmubg/eQu+E34VL2iWJh+ECuyz8nRPftkNHVzWgeZy4UEABKN2g/+PU
	RKDFFLD9tG7BPG/1R14U8dUTZpnXlfzf5Ifh2xDpJ0TDycl0meMqBx7z9zvcs5OFrqFJa3qIvIc
	+w/gPsOtTBCQVnm6cCpZyntFkGu8PyPy+M0Hz7b4WVvDFypQyv2e5bqYqv8q8GLyrR0I65SmtD3
	3XRc1W0SMspEBj5s+V0YS/eNn/lwzVHp+kpf4NAEwgrVQCRix9+x0U/yPWB6qdaLAL5Bek5ww7U
	MwR+kD8tu+WKEV9nacRqrT0nk6ZXYm1P8ejF4kFVY9e2cvd00BgGhQMp5yeqWsWwtt300Xs4H2K
	zRu4gWraKAseV3LQ3LUDZbguGdnhH+5UDiDLXftifwiPXxODj/U04gjubAy2AX+reCkZUT9yKCW
	d1AzqQVFY3gSR0pYbhHo+V77tGESPQk7YVPMXmcVYnrMQ9W067uvO6rhlLweomk=
X-Received: by 2002:a05:600c:a596:b0:4b5:d95c:2380 with SMTP id 5b1f17b1804b1-4bb55a86fb2mr24790785e9.11.1794573508217;
        Fri, 13 Nov 2026 04:38:28 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb571cfa2esm48348475e9.2.2026.11.13.04.38.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 04:38:27 -0800 (PST)
Message-ID: <28a33fa649dcaae2eadcc934ec49fa591ec1c283.camel@amutable.com>
Subject: Re: [PATCH RFC 20/41] apparmor: use fc_init_pseudo() for apparmorfs
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
Date: Fri, 13 Nov 2026 13:38:25 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-20-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-20-4c998976c6c7@kernel.org>
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
> Initialize apparmorfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. apparmorfs never holds executables
> or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0security/apparmor/apparmorfs.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/security/apparmor/apparmorfs.c
> b/security/apparmor/apparmorfs.c
> index a99366467217..351ea3a7120e 100644
> --- a/security/apparmor/apparmorfs.c
> +++ b/security/apparmor/apparmorfs.c
> @@ -21,6 +21,7 @@
> =C2=A0#include <linux/rcupdate.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/poll.h>
> =C2=A0#include <linux/zstd.h>
> =C2=A0#include <linux/string.h>
> @@ -263,6 +264,7 @@ static const struct fs_context_operations
> apparmorfs_context_ops =3D {
> =C2=A0
> =C2=A0static int apparmorfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &apparmorfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
