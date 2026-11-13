Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564841;
	b=b3aybnUT8Ac9DziSrm/K00baKhpTydQByFPlBu7BY3pJT61WBM43cIIrehC9D0ghx5PL
	 w7E+PxBseYMoojmZSxANS13uTECKcjf4H2n3bU49yNLlxu1A6vfc1sG9CyOtzTCS139KT
	 YrOlE2binRms4QxBvXxXoRIDCryhTB2z+//VpP+o/ksmebtl/ye8dncqKZ2UFOLo+1DTs
	 iffzuuHOod2FSwjpO1UPkU+XsoCAA78fN2Tk48ATxmPU3e9OU65yO3KLZC0aL7rGdanuy
	 4/UvBsGsXr8uTOsMD/h/CzSPS22N7r/SlU3z2rwsyS/LzKvhZdH3GlfRJY/XfF4LcqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564841;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=LWRhkHq/o14g3eGvU8PB/2eVsiZ8AcgjQiitoPu4Uko=;
	b=ZqxVTxF00/XDg20GUymdJnBdVW6Y2sgJNHK8nYZOcdGILoFjY8a7O3GEeT23EMqnsSVc
	 OQw2TFMYrV6iIRf9e9T8cMvZioraLHgtrju3fvcqySubf5qu9fRtZlvZpRyLiovKP0QWH
	 li1IPuQP3QQkeHcJG1oF8AMF1HK2k605DWJeGqNv1UD2WibzQvFAjjK0h/8lSxPe9LUbM
	 xgGScb3Jo4+kyX6S3Ahk+KXC4iJjAyxmqeBhNF6mN4+oTwXfq1fkeAiOBmiJOBv8tAa2K
	 t/mGeFna17+KKH7JLaoyFu8pCw6c/IIfKw13pXlVNB8APZfy/qJXU3Jy5NK8HDG8/ZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=fgkfOyvU;
	arc=none smtp.remote-ip=209.85.221.51
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48CF7606A880
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 48CF7606A880
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=fgkfOyvU
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-48dee593f18so1055770f8f.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:14:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564839; x=1795169639; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=LWRhkHq/o14g3eGvU8PB/2eVsiZ8AcgjQiitoPu4Uko=;
        b=fgkfOyvUu8xf6W8q9zChbNscxyQBBGlOoHgKBKJ1BkQkWvPVGihrF+rRK/++Rh9GyG
         JHspcfYOBNPixo8oPKNP4HMqn4Pm5ECxNu6WadiPSEV1Ef7s5pMOTmdpp1h0qheNYCAL
         reGCPjjBuRkeLgJtvMnJj51efD/XBAnW7OBUZupe3DEOpiY9mIzToOLvbGpl9PZAiITD
         ja/hKOWfLJ2HwVqW5WbU5vpLe4u/8sEd47rKsdelsOgJDSYM8eMKS9Bg+p1Lcupp+2o7
         A8nYundFQzH4qm98PvOkGZvKdsA4h3jxn0f8A/jmsMNUP8nMz4irJ6DT1xabl6IkGIEw
         iw2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564839; x=1795169639;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=LWRhkHq/o14g3eGvU8PB/2eVsiZ8AcgjQiitoPu4Uko=;
        b=q/+WcplmmtXDeQMuMOeBDduXnmpKMqeFjyBustOPk5th28msXag+hskw7DJiQ20Q1i
         TDKLngVDMTF5RvMdY9mbjRid626XLA/uxRNRbUWWJ1STpWpIIaOiiHAdY2tDSZN4m/Pc
         do0vZyo4d9aS5JByn3Yik7pv5RPEnC2zpklWWrW/Q/IDcwuD0naDmRvLHMB7gFxRchym
         fvXthZ9xWKBEH4LrYZ39K9sghl4J+sARn7beoH/Z+DVxZdV+SnZuIjDcIo5Q8OnRwGP7
         ntdWNMdGuY+wgwGcnYFwhwFUB5ciVOZuPxzyHn2hHHeJjAw6ssuK0Yp6SoZsbLIczL4I
         0o7w==
X-Forwarded-Encrypted: i=1; AL+hErHKmp1k7+fXp5U0rCWuQEhnAoLMR0CLBDBnn+hnFNygUf/skJVFVCcbk7snrKumorSYIXmlPqGQP5o=@vger.kernel.org
X-Gm-Message-State: APuU4Z9CN1ZHCqNo0gRa+LM7muvULLK/d1AN9MED6Y133ryjxPAPMKJX
	l/qWU5D2jqe6qp19cLR/ZBmUoYcfGkms2OXzuiSASlI5S1YwC1QWD83lYvSt1GBtotkk
X-Gm-Gg: AYBFou3wPfaEGBVHkTd3vbC6wO0gUKG8Xo3P7inQWMppulEF/Qd0u1Jx71KRQ2LUSa6
	cFmGp7MgYqKVrQVwjXSQwxZcji9FvzCMlKhhI7cCczWIluxokO0AIx+PEd9d8WoVEMQIEFzWNQi
	UvtltjLhen4XHz2FTara8l8Pn/Rox7adyOIi4sucTq3FZtkEPLs2DS3Dde5Z0mV8GSJ7EHLLcAB
	LH0MfPMPNh1vxENYR2nlPezaMU7em3SowiUdssjYTxEveUzL4xcya0hHsM5iH75+rwKmo6gTt05
	GNlOlJFDkHpGspHqt36UsjSMGelZSHTBo/VW3cUner2kSFjagnnE4yLv0MCmauoOA7T7UkxAGJ9
	vQztYjt70uFIYRf4u5oB7OaF3xXvS+KQVNY4H4AyY+tzTZHc/WDS4GByiq2IgiDS67PmYaUxxaZ
	FamOQgFkmCKA+IcwSWbXN+0zyCH6B1NhgC9K2w8NqSh1VoCrpL3o1SnF8iJTWv/IlGrJ7YMGdTW
	QwxzaytSvq4GUXeTzY6bTjCwWHADuexmnk+bkkjVFk6Y/iCiuga1sx2tmZNUgovr2YYmQrssSju
	o5U/Zc4jUWj4Ji5+lPLqOMtl96Q4sxwjojciiXD6GMs1yjZHKvnXYnOxkmImnlE=
X-Received: by 2002:a05:6000:993:b0:48f:bc59:ab9c with SMTP id ffacd0b85a97d-49c6fd932f0mr4358101f8f.12.1794564838578;
        Fri, 13 Nov 2026 02:13:58 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49d673ce75fsm190118f8f.55.2026.11.13.02.13.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:13:58 -0800 (PST)
Message-ID: <77855be3fb9f0e1888c6dddc56d73a1683c820f0.camel@amutable.com>
Subject: Re: [PATCH RFC 25/41] pstore: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:13:56 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-25-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-25-4c998976c6c7@kernel.org>
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
> Initialize pstore as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. pstore never holds executables or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/pstore/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
> index cf499ba72702..4658561cf90b 100644
> --- a/fs/pstore/inode.c
> +++ b/fs/pstore/inode.c
> @@ -18,6 +18,7 @@
> =C2=A0#include <linux/ramfs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/sched.h>
> =C2=A0#include <linux/magic.h>
> =C2=A0#include <linux/pstore.h>
> @@ -491,6 +492,7 @@ static int pstore_init_fs_context(struct
> fs_context *fc)
> =C2=A0	ctx->kmsg_bytes =3D kmsg_bytes;
> =C2=A0
> =C2=A0	fc->fs_private =3D ctx;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &pstore_context_ops;
> =C2=A0
> =C2=A0	return 0;
