Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564363;
	b=ZghH25XJh6r4FRGFgdrkMXeRZUuFzTaVd8/nfULVLqKuhbuiE1lteDTyfANxOSjGgPu8
	 YEV28vT7t/OTLQM/wo2fK1enqcJ2yCR+Cil0jh5tuhaC/V91Bseahu63jE7RX/JW3DDAj
	 ++v8jWf+Tr/lzw49uFhf2T1oLCArKqQW3hy4d9ZhypRCSYPNaqHWcfLXsVYa7XioZqO33
	 ofdzuZsF5DJGLDCLxPLges8TEhww89Wfnjuthf7rOle4qJCes11JdHN9zmmQyBNkgki7b
	 mfTzBeGPEdSPaCS/qRAjfe6/ySLhLuGDOGtFCoJEtyfyGJOrS27Yl9trt97blsSBdkg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564363;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=TjkCmA8zoLhZK8u7U4HhR7QcElVzore/o+jClE5BdRs=;
	b=aKnbAMdFQIbopLUNnj1On1BqqIhRRF8MVlga5SKgMdyz3ikRjntVGmdpuJA0cbluD667
	 eMj5+qpDABYOHw3uKRG4XrpCii0o50TvnoLWMBsZNIbomtaZo2Qiv5BraJQYEkMWy+DJv
	 ZKoXsYH3IyGbrAxUl5CNxuNJOTrJmlgm8v+HRTEAOXIszX0qdVdvcvAE+cRtis0NKkmhw
	 kWlYbTk/RmGqN0RcY5vZ3Zt+OiKGEwfAVKOm/hT9rYtBSXoei/lLa3vRudoWZ2VhJv5rg
	 rH5iDsv9sctMELNuV43LFFFD+2QJ9TJd+ibHWn/qazhpuInmQPa+2wcwee8CSMEskTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cjEYfKb2;
	arc=none smtp.remote-ip=209.85.208.53
Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com [209.85.208.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BED760A3807
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:06:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0BED760A3807
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cjEYfKb2
Received: by mail-ed1-f53.google.com with SMTP id 4fb4d7f45d1cf-6b70880c0a4so1103164a12.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:06:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564361; x=1795169161; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=TjkCmA8zoLhZK8u7U4HhR7QcElVzore/o+jClE5BdRs=;
        b=cjEYfKb2ti/xguKoQF5XePY0eNOezud7K33Duf47S0g3JkHBuObkd06WZKSsE2j4TE
         DEwnxkXlTao4933EWT51qAqcKFQZzBDYUWq7IdS+RrJUrXD2u7QTXDm9Wr29l+nlsY2h
         ba2aoEFnt/fnBZ4TqG8AlHBTx7MlaAOM8MSBIpLqFecTqJgM42mukp171NeFhmx0Zx4N
         EfXY8c4e2NVT5eQpV/Fv1f87MHIzBgzN889RZpIYFKMs83t0n9Q8bpafRw7OfeQ9pMp+
         KOGhNvmnj7I3xZktgYLxquasfZAW0tMnNpo/9hpnK424qA58Vs+J+ftPxNsRzOLYAEav
         G1VQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564361; x=1795169161;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TjkCmA8zoLhZK8u7U4HhR7QcElVzore/o+jClE5BdRs=;
        b=dfCZuFdu5a2ItOLAMCav+pCDfe5sWj4idDkjYTzRThOn+qcVm05AeQC23cKOCGtk19
         NibkFMm7ejOZqQ6BnsvxRKALB5Gn07QxhUAl+cV9QXXMJspaJGd0H6vvTXYxmI5EF4ES
         0Yn/dDc64ydalCIxO5f5uXUbM3j6ezXO70QD6l5Sm6GFyPQyCOHHgVaCf5kPX8Vn0nUO
         r4jKOmwWCHFwgu8mnoZs1g0o9GpyDDo9xwaZvmvNZefYzxA15s2HyGTa9n+cjWBnwj7V
         TgaSg74pZxS6QQ4LEy2MAjhj57uThYZZTtZYC+3kPde4XfFfAM30KVBwF8Gp3ChqspHe
         CNJw==
X-Forwarded-Encrypted: i=1; AL+hErHYWjtHEXc39v+zKbdEaASlqM16VrCtIyukkdnzZBmh8O+uf6yScmSxV5Pq/jEQoQ5sNw/guEExBOg=@vger.kernel.org
X-Gm-Message-State: APuU4Z+uOYZEZtlkwaIY6M4pB9o7COkUY3IRcLrN3+GlAIJE8ycy/oIW
	an3EcFCvkUnZWO71R0XmS0eVRXuR6LqfciMsDH1BevOrJlGNTKvwjr6mMfs5h3u6VWV5
X-Gm-Gg: AYBFou14fJ7fy9CizzhusVbA0VBvFXZp9X7pc1X77y4ueC8XsdSMXtX/W+IaIiUo2o+
	TozHbGpGuSBwXpND8hJwfcDtENQ9u3lzg71yuGQ6jkEwnN2xGFdnPi3D8Nj3R5ViFCfIkCWXZqK
	2j3L7Lu9mXYBtB2kMAnNwmh1zsHlS0fsPeF//RKPqQCe8CouzBwXllmwBwMYYOhv108e51yqF5M
	Z1eiHZhycfolK7NTny+pT5UZpS93HX1oW8iPTWPFGwVFPMVc+c99sdUMaIqG4wWuSEJeuiGjVaX
	q+o9To9gcqkGZguYd1efw6d/RpmKMLCEgNKT2/zm4wVTh6NFIdLcsWuV73ne5CXs7LuIWMAEqhE
	vhJeAFDWTzMze42t27YQVil7vp2CG/hlyzHKq7ekYC5pTU+ag35GIKhRyFebO7mVd+lMD0ByU0k
	YgbA1Kfrd8Oyz1ldsuWwpqAOZyqeAmw/s0ubuaPgCqdDkyOSJbdQytB5w1ia9P1xDcZZzZzH3dE
	w4DMhbnZ1i8seqXa/d7Dq+kxd5fzt3/Y0O+EABEyeCtRTTKrSZpfj+kHGDliIZWDtjDfSKpxxmo
	mzMuEWQ/ZBxE7mQGtXfnkqvaAjaFrl1uKH7SJrAUh0JgcCOcFkgYbAoskpdrhnM=
X-Received: by 2002:a17:906:ef07:b0:c4d:5820:325a with SMTP id a640c23a62f3a-c50963dc627mr169588066b.39.1794564361325;
        Fri, 13 Nov 2026 02:06:01 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b8651bsm73693366b.78.2026.11.13.02.05.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:06:01 -0800 (PST)
Message-ID: <e8b71a2778d7d7797d433e7bac1a37ee64aaa30c.camel@amutable.com>
Subject: Re: [PATCH RFC 15/41] tracefs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:05:59 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-15-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-15-4c998976c6c7@kernel.org>
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
> Initialize tracefs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. tracefs never holds executables or
> device nodes.
>=20
> SB_I_NOEXEC also refuses PROT_EXEC mappings. The only tracefs files
> that can be mapped are the ring buffers and __rb_map_vma() refuses
> VM_EXEC already.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/tracefs/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/tracefs/inode.c b/fs/tracefs/inode.c
> index 5020365ca704..e04febd868eb 100644
> --- a/fs/tracefs/inode.c
> +++ b/fs/tracefs/inode.c
> @@ -12,6 +12,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/kobject.h>
> =C2=A0#include <linux/namei.h>
> @@ -510,6 +511,7 @@ static int tracefs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	fsi->mode =3D TRACEFS_DEFAULT_MODE;
> =C2=A0
> =C2=A0	fc->s_fs_info =3D fsi;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &tracefs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
