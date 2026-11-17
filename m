Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904345;
	b=HcAdFoNzPtY+oSXTftts+xhfKBUu5Jksn2Hrtng8t1+7vWOkSg3fGYTjBlovO1rYDokD
	 MuVp4R9Se17Njx+DWKS6ppt6lU9tBhyPgBEYmuo6FGq0j70BTMwLshGe/m7Ox+FDPyhiU
	 EQarioijRY1/PMfoJPTz1fpSyHbt21s5VVHDFPEJmaOxDUn0Jct4Cqu5p3r6sf8KAvfRq
	 dXxvpGHU1FxgyNr1Ni/+Si2rj1/FTJal8H8ywr07zH4kaS7UND+sD1Jw9fT0gVEJ7Tq3e
	 ELxGvdb2wB0l4Dk6MOMIZQ3J37heao1+gc1T8jas7ALlh+meOzFHtF0NS0RcHtl6cSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904345;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=iGZ2JImQ8AaSp09QdDpLN1PoylGc+Kk+7WphF44IQ4E=;
	b=re3XkQemMn/35coHiDJyNuR2PsWNz9AqDXlnXlLJM3D9022GiQnGBc8lKhIx5azi1y+V
	 qg8qQcrD/C0QSNBnQNa78YHwrlHJQezyYclnLxZRZnEDMNMrXrIdrLOKk97nWxWwlV/Ww
	 3IRkyNWPDs58KRjYBF+vX4JRmJ7aa7+DCthexmt35/PNfahkioVovVd0UaIFcby+5xUX6
	 C9afYSLkmVglrTFnefWq+XehMb2xhh3dsIXoYf/dvcymNmKgW9K2XEe+oFh3dfC8dIYBy
	 waz1WRBdXsx+JzjvH5gjFYJ7Oxo66wOvygqJNr6Av0a9psxciISFDyejyC+tRqSGbzA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=EFPX8Vuf;
	arc=none smtp.remote-ip=209.85.221.41
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4145606A898
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:32:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D4145606A898
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=EFPX8Vuf
Received: by mail-wr1-f41.google.com with SMTP id ffacd0b85a97d-4a358881793so377440f8f.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:32:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904343; x=1795509143; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=iGZ2JImQ8AaSp09QdDpLN1PoylGc+Kk+7WphF44IQ4E=;
        b=EFPX8Vuf7iz+NzEUQG+pPgjK/MbrESqv3n9ATmra3Zopp4tpstszPHFfE2sR6EI1XH
         /MuIqTxoWkMXSLrvcYnqUGQvNVGY6YndEf7Smwels/t/G0PiJAqa5YTB3/XSR2c5vF/4
         5S685rADCuM7kD+KTHsn5xD0Bbvj+kfNJN7h3Eeu6Tgpz77cxc6E5ixV5T0A3r/KAOuP
         +pclbSVYUTOzYQ2RRiRVVs4C5Z7y/NhXCRc6Of4Q0fL8jD/Em4FfidsaQN0h6TdkChBo
         DufH5bn8tmF4fp27j4WWCE7M7sjar8yCORXmuz1wFPQxfWworU2xHCWyEC/YN83R4E+t
         3i9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904343; x=1795509143;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iGZ2JImQ8AaSp09QdDpLN1PoylGc+Kk+7WphF44IQ4E=;
        b=d27KmIxkerYdqe+KeYlsjJaytD0HR8+Rs0A+CzIPJLGEje02blgNTaYAMHeORCK1r7
         KddW33q0/0Gb5wtKbse/IhGZpjSNrvLr6gzbCf9JpUSax4a5hSi91u+zDIYtTRi8TiXt
         QUl8Dh7lwML+eOD0rhV5Q2AFoL8rzdg7eoRrCwpX4XofnZVLs8MLoIJFbRLLilpgLP1X
         eorg1vdzget2CMI7YlUhXsjBwKBfvqYV9oaFmDC2JgZYwxSYJUzICPTwKm1Awua9xTVT
         pz9s3kAtbNRW2V6v3epwVVcHRh8cihNOD7CTmZjjwpcqNUAZa1+tMdePxMrA0DNqYT7M
         MG9Q==
X-Forwarded-Encrypted: i=1; AL+hErGjVgoQkwznUR1MDbdD0fK1sRY0EK2NxmTBuH1DigncEv+YA50tOqt3YR8E2u57EJ3EWM3msy7S8os=@vger.kernel.org
X-Gm-Message-State: APuU4Z/t8tXa/nOlcTVQ91WuE6R84Jk9K7swEw3lQT8aSrpBpk2g9FZK
	vt33e7BWrFyKAPxBfNcb9FU7D2dNsMqtZHDLosWvqL3ftIjlSR4sPXJJiY4uOjOheSz2
X-Gm-Gg: AZFdTZfmTLI2BQfkdINq0BzGy+i1q9rMl0tHYpWsKyNsFu6QKpKtbgQyOkU9c6RARs/
	bbJuwiJ0lPhsv2A2uNnBgFYxkVIWwkqomonEHOxLEVRsIvD+bkiEAF3fN9z6QppM6xGPPUILMYy
	Ome/U8gsbA7d/2YucWxBN3LjPTYWchnnSz+wWnwDoipAZLs/lxGwATEK0fHD5m8NjgqYwoVdJwp
	mDBAIExR7S+DvGMxYMhZpS62HuWYa4PnMov4Xn+63VRZkhM+VPwyfoaLsL2bZIBKDr6Lwd2LVH2
	qfkSSZqP4ufal5fWloSIxK6Tn7K9NGjoP6PM5bH6MqvzW7wmuSxs0NGO9lfwXQPcJ3aT2vFrs/F
	GWHWXyWh+ZS5RPyKSrQPARUTaJQMgBq4xItYvSpPpyWMmQHMpqtqKQjr0CbJjItWQWqXxsKa5iq
	gQz8nc7t0Z4Uiw86yiGTbWk+Z9xTPDsF6C6OGmFLErImLB47/6LM2HOhv9x9+/7Stqu1PQkDV8H
	+MuMCWMzRe1wejJ4Igj/33ViHuXiHGTN0vTO8v8Q2ZKUyXuOx2a2Fc7dbBdTpFEzm+ELBNn1LSe
	UNXBED/ydm5DbaHkCA0DxDAgYNO9LN2ZvP9chsgWZja/OZY1RpaPpWZmpqcNxL0PZwPgRRLmWZT
	aG0ZWS3n06p8jfMMAtnWyVdzMVDuJlzJBg69u0mEV2RrU6aQnBvZ7AGtd
X-Received: by 2002:a05:6000:3108:b0:48d:f9dd:e3de with SMTP id ffacd0b85a97d-49c7353c415mr27089117f8f.45.1794904343236;
        Tue, 17 Nov 2026 00:32:23 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c608d10b2sm43646659f8f.44.2026.11.17.00.32.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:32:22 -0800 (PST)
Message-ID: <fd39200976086130cc82d59699a988fc3e0689cf.camel@amutable.com>
Subject: Re: [PATCH RFC v3 27/44] openpromfs: use fc_init_pseudo()
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
Date: Tue, 17 Nov 2026 09:32:20 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-27-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-27-8cbbea1cf34f@kernel.org>
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

On Mon, 2026-11-16 at 12:05 +0100, Christian Brauner wrote:
> Initialize openpromfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. openpromfs never holds executables
> or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/openpromfs/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
> index fb8d84bdedfb2..6cd02d456bac9 100644
> --- a/fs/openpromfs/inode.c
> +++ b/fs/openpromfs/inode.c
> @@ -10,6 +10,7 @@
> =C2=A0#include <linux/string.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/init.h>
> =C2=A0#include <linux/slab.h>
> =C2=A0#include <linux/seq_file.h>
> @@ -419,6 +420,7 @@ static const struct fs_context_operations
> openpromfs_context_ops =3D {
> =C2=A0
> =C2=A0static int openpromfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &openpromfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
