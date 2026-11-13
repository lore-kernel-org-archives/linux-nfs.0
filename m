Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564338;
	b=GgFMp6VnqBACOouvNKy0OjhVy+H2KBK0Amsn3CWHwwg9twgU4DY716vyAPGR+k9q0cse
	 J/k7Nw2q4/IkHqztzpYjo3NoG5vXxcibMROlPeNQNmaF1EAQjQ78tM6tF0JEcz3GyzaWe
	 vZHaLivH+gXwelEeV5YPlyvajFSw3Gkbl8U88buG7kZDbe4aY/vtC3nvEIGb3l2UMqpBo
	 MJQpP9xoKslMTpevnvW+eFnR+IS1o32ztcwNm23CSs4Gli/adcgs3VOEZ75V2dhZbiYhc
	 R//bNMnR1Ybz/F4k3s351FlDPt6jz0fttbZ4b3koyzcm+5uMgaFGcabKsqF0ciYgdjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564338;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=/ZNAGjGCHSUHK/hbpNrctHFuArQcFUaSPHFuYTd8W2k=;
	b=ZXM5pgO9o+bKakgFP3sRgECasTzHJRwauErjxP1c54tFgYTyWhbYvI6Xf6Jq1ONBE6FS
	 yfuFC6nrcSFW+6q1j6RKC9g8xwt6oy+d6FWUFFzW84uTV+YRGes+LBojsvvpORPlQjZvX
	 TI22ERCvHQAbI7XUjqGpMM58sZZ4szs06m9Q73khs6E7wlF260KUbCItcvasNVnGXeWJv
	 Yd1xbuUzO/gQJ/rFgwt+Z/+68Jk2wadh3BQOxrXKtgUVV28GxTniWumq71GaoTxj1ODSA
	 LgV7150INrnQ7JX82EnKU08vm9PHFn5E5F9DFpny+VzfhnyaeHIkrgzxONA17wHSYFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b="BcN8/JZ3";
	arc=none smtp.remote-ip=209.85.218.42
Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5461606B136
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:05:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E5461606B136
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=BcN8/JZ3
Received: by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-c4322d310e7so190391566b.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:05:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564336; x=1795169136; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=/ZNAGjGCHSUHK/hbpNrctHFuArQcFUaSPHFuYTd8W2k=;
        b=BcN8/JZ3o8G8RngOszXG3JTNOcmRF7Y5HhcgHfEFuj8bd59D6/ZB+k5Qh/rpeFRCcR
         ddACGgLLZgU5b3f6uROOjMlLzNHxLpnDWTvmFTIG7dNNkaJHDW07G6TO1gom3Rvc3G6a
         phj31A4a6/nEoCYWD8i1KXLteYhy5qLcfDwMY03tf9yOOPsaa+sC0St/LDVgowIEHsk0
         tZO/CMI2RrlSiK2F32OSWBbCdipxonxIIN0DBtho56nDsRF+fFDKa92VHmnJVt2oHACg
         qH7hz+1dQBsoiVIgFoQGohYiLAIIKP/PCGAm0hHsixZQutOWB167lk9DbkeNw+vQ2Hrh
         L2Sg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564336; x=1795169136;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=/ZNAGjGCHSUHK/hbpNrctHFuArQcFUaSPHFuYTd8W2k=;
        b=zMe74vmlk0U0oanO54NLJcouMu3nOD7dsbmYyW/8joQ6IS4xRsAFcoFh803l4f963S
         eTtUfB/NZNmPKNiv851d27ETB1mO9vhIJTmrzGVY2581jBMIEWfgalQ+7LS4lArYSdzc
         RkIl3N26tE9bLBxpgHTttCj/tyA32agH73/Nu6+LwEAh1lv+jh/AHl/K31uLEa9qZID6
         D/kQ08oe3cL71omDpZgU5fg8e/Fq7nQMM7+uG6Jqrpp5bdZ01U0N8fHh1KdezTs688T+
         35cL2lTiLSc1QMFC3cNXBPbfc0nvWpIkKbCKqJC+vXZunEjg255zC+wP0z+EYvGGSFmx
         sJLw==
X-Forwarded-Encrypted: i=1; AL+hErH9yghD6GCcla4GjsLM0TlSSL1YZVG0AdcnOHMPpdqnEW0XveRSlkUyfM2XjW2uP/OXk76WQegWKyg=@vger.kernel.org
X-Gm-Message-State: APuU4Z+0Ln7t8GLS2FaHb4UGlo/uX349sDTlv7PA7tpQOMZLga3mSPgi
	scOKaCEhLmebs6FmcXo52kifNbvsj/HzQ1QMHfoOCnuFiIdfKdLWomxshaASnXyfLBaI
X-Gm-Gg: AYBFou1pX7KQp4PDbc8quPzGz5qKV3DqMLYMvvk7AR6QjBqezdS2CQehf0vOOeX+Dvp
	QC17YwG+M9Ug7SQJNpnipui3cmZWY6I6TgFkC4Ibzi5C6cdNRb3s+8qaT6RYxK1UH3Jso9Q3VVa
	Mx9fMuPEdPOr2CBQdpRvNcSuJtYoPuQJijkg9jdY9a2SDDjjJk+C0qmLDusx+Vu++LhxdRcPNq0
	izuTCs/oA91DXBYjHyNbUzKqV+vJuYLRrZqZwkX6rfs3yiQEYJ9f0cfp6DxD73bQl6NQjAZirxZ
	PTZQmZ3PpVAkow5D1uI1Uc53yZEm6RNuatfQ8LiRG8R2cOrQlmiFP7dvwdzzgWuEZSMmJUCvOPF
	O17yeaI8Rilieo7PiA9EeEndSzHO4cgkcH40UEpDFeOM98WSUtqFEfyzrDizOlgxUiP9XrQTEFt
	bpdrpwCGJ/iw7z7uDM31Y52LM4KFY4Kx0LNYyvT6wLIw6Nf5z18dxCDYE1Pi1JBWPbynSfe0j1J
	k1W9lBold0kaafnoN0CRkt6ZnlsWZ7Qvg7bC7cAq3cJ8ENunI89/MoplfwBB1LRwwGwuyD5U3Il
	bhZSdif6FR9PB1imMe2fKJbhpGiEwfVSUsqzwgR9QHk/hB6helFsSG3/Hjzunss=
X-Received: by 2002:a17:907:94cb:b0:c2e:3a72:ffbd with SMTP id a640c23a62f3a-c5096389759mr162937766b.41.1794564336347;
        Fri, 13 Nov 2026 02:05:36 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095a5b93csm75365566b.5.2026.11.13.02.05.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:05:35 -0800 (PST)
Message-ID: <8f532a01f6cc2eb73582864343e25be4ec990919.camel@amutable.com>
Subject: Re: [PATCH RFC 14/41] debugfs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:05:34 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-14-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-14-4c998976c6c7@kernel.org>
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
> Initialize debugfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. debugfs never holds executables or
> device nodes.
>=20
> SB_I_NOEXEC also refuses PROT_EXEC mappings. The debugfs files that
> can be mapped, kcov, relay channels and powernv's memtrace, map data.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/debugfs/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
> index b4915551ad31..f163f0bc5703 100644
> --- a/fs/debugfs/inode.c
> +++ b/fs/debugfs/inode.c
> @@ -15,6 +15,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/pagemap.h>
> =C2=A0#include <linux/init.h>
> @@ -317,6 +318,7 @@ static int debugfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	fsi->mode =3D DEBUGFS_DEFAULT_MODE;
> =C2=A0
> =C2=A0	fc->s_fs_info =3D fsi;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &debugfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
