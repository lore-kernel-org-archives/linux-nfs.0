Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564657;
	b=EXzw2wKK5Q79WpUOc0L/kDnq72Ev1Dg+aE8m1Mg8JcmsaB3fX+GubxaagK6LxmNoSIJz
	 +RJeJNRBpl9Np8H+UTkT9+sM/UwROjAvhgmKMzXPXMUBMdZaW3whWdpDGqfp3ZMTrIWzi
	 gJJrYqCvlN31oeJGntF/x0g7MeMmD73V/9otkJNmAUbh/FPabvknTw8ItQBL3XEeH9DLT
	 xP3LYokYtSGLyDakA5db68df2y4oIssmCx5c1U3nZ2Q5GGa4QE/YJC7BlpusjCsmjrVa1
	 5fay6JopQtLGhI1GVftz8/jVBP5R7RuFyUDox+cGdv5J0rkgOVwj5B3plWWv8gunCfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564657;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=RUn5HyOzv5zK74OCIfLVACQcizuS/sHn5qpIQd0Zvv8=;
	b=rBA+RZtgjt9vahPw3h49G8IGLaZssDZLcLYt+CeYD4R28G2NGIqbSTHbgdshMP6yCaBC
	 K1Kp+ODCcad+DLNWUUxp5n2jWTqoGvCGduD3fBB5doiFgUm0t8ZybUY4CfQamu2hk2hYD
	 w/fv2qTg27Pj2Q6GHlN2WAsKlSJd8akKD0TXEtb/M1fq7LR7uihlF1jM8/+Ob+nnCSF4p
	 /2Z/sNNCpcn1vVZE031xoJm6MxsRHRxwv7W0ocDOY716E/lzpx4x1R84D9Vwv4DESlfLW
	 skRMp/9k0utT7GAhIzP8wgyBWU6ZVVEC7UpNGTuk99ZTQ6NdRr1ERPLljvjIl59/aKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=afSYRRYW;
	arc=none smtp.remote-ip=209.85.221.43
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 168F4606A332
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:10:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 168F4606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=afSYRRYW
Received: by mail-wr1-f43.google.com with SMTP id ffacd0b85a97d-490f38e9688so497690f8f.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:10:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564655; x=1795169455; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=RUn5HyOzv5zK74OCIfLVACQcizuS/sHn5qpIQd0Zvv8=;
        b=afSYRRYW0Lzg1RjNF5a8Z8fp4FTD8+wBAkqEEgX+uXVLN6iB/1Oe+S3s3pjBsHkfPy
         t+OYs+BeBV0n1jEyBb10NVx3dBSZolIBqoZV0sAqk1NmAyPkc8BtADcPrCcEDzdTW4+p
         zgkm0FzjpTOQt7I53MJB0zmRNwJ5JPK+9oiFhFL/qPiFq6x22bgZ8fSq9Se2ho9ikF+q
         rg0gx4TedCmdQu2h6zCkoXcFHWmQ+ZQsRVeKTv2sVCXhncyHGZ2k8DCVvoh7926dtvhd
         5w+l12l3Dd1UCqA4z70s6tomNhqNtGqcJuf3lRDB60cxVt/wNhZpOgzeegjchzcaCyfn
         tojQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564655; x=1795169455;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=RUn5HyOzv5zK74OCIfLVACQcizuS/sHn5qpIQd0Zvv8=;
        b=DLnzR33PI9xNGH+Eiu4fSQQJbOUAnQhvG9yF5WuPXKUQl2SA+3EGOV0XA1rPVqBn/b
         +qx0FdPpdEhwKPH1Qt8inX+hCCV2dwy3o58YOHE+0DD4s0+g4pPYgAAEPYJSzHR+NZxz
         jL4bxn0jqifYM1g0bhY6n5i8/K0G10ShimuYmxmeleYgsoLggleupGM3v27oa4MOs1e7
         xs+wgqxOMMGxybHZPzx23g566cqpy3v0uLMtSaXiyTEU36jQpb0p6HngBmwZVlcPm3Oi
         5+0MNfW/Spgc4Ig0XlZMJ4xfxmy1MXY9fIHFIFqU/sJ7NN9VZEuLWgdi3Ovgy+0M+Ll5
         mxNA==
X-Forwarded-Encrypted: i=1; AL+hErHks8ZsRmSdWECMBhzKlfu3F0CzmrLzrM3pyNHil6f6yamNgZL+2ICp0fXnDvbYxZW+LVaM1r/hd3A=@vger.kernel.org
X-Gm-Message-State: APuU4Z9zjOBAcUGHeKHl+x529C1XMZXJ1g8yl1G4DjB2CM4jSpuXV5lj
	zWa4pRe8Ua43aPUvL2pTepJSSKjrKBX8sLUx0bUNFG9fGqUmZ58qaDcjbgw0XlJD8FXK
X-Gm-Gg: AYBFou1V5Iz2Qv3KsrG4M2CV0cJkPkZlgEWV16pNX6zF3axZ9U9sxAzprqX3hBgn+EC
	67NxIsFByGxWQjdJTyOjjewZZ4xJ6+UJmtYZw8bF9leohDNZxVWTXOryqFlhM0X95GG6aOgVt6I
	wgFgMzRY7XMXKBxOO0t0WkPaQrwlXB0UImqNRBmG4f6KMAo1gSiXjZC5mxynJmEyvQ9VoK4uyMq
	v6/oaKnAn5N0CXQhiz6VXSavnn717M/yruoy9oP2On9+M4z569ZvuyjuQO3rMBZX03z/6b4KanM
	dteITKUDGAXQstI8c3xVjENT9P1g9gZ8DJmw40xrXcZiJjPdx2myo3jxg9Lzu6tnuWVOahx716F
	0bcfwiGky05FKQ2vTrPc3XYyxwIyxzzxbnhuRe2zon5NdtbVNY5too90VJ533VJwFU9KfvTRue1
	dhAG5ezE6uyKobiIJsAPsyNoKZjWUGBG6rVD5PdhTQufylL6U0q0WbFBusXVNESLWjm7pxbgrPS
	NaSZgBYHGZ+3hDsqIPR5BeIdsl1tpAGFdTs3BiNeORoy0va4ppAs6eEJHldGSlZFH1PtVkQgnnn
	R5eoFjlK9zc3/7fMNecDbR7+n39XWOQwuspa6wiAl15uyKAAiMmNoDFgoe9Lxo4=
X-Received: by 2002:a05:6000:470e:b0:499:ffd4:f519 with SMTP id ffacd0b85a97d-49b02d4c2cfmr11662822f8f.23.1794564655454;
        Fri, 13 Nov 2026 02:10:55 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c5a32d336sm4988050f8f.0.2026.11.13.02.10.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:10:55 -0800 (PST)
Message-ID: <0894c601b3f3c5b92008c6c399faaa539b658307.camel@amutable.com>
Subject: Re: [PATCH RFC 17/41] securityfs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:10:52 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-17-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-17-4c998976c6c7@kernel.org>
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
> Initialize securityfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. securityfs never holds executables
> or
> device nodes.
>=20
> AppArmor puts a .null device node into securityfs but only ever opens
> it via dentry_open() which doesn't care about SB_I_NODEV.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0security/inode.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/security/inode.c b/security/inode.c
> index 080402367674..93997a9f16fc 100644
> --- a/security/inode.c
> +++ b/security/inode.c
> @@ -14,6 +14,7 @@
> =C2=A0#include <linux/kobject.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/mount.h>
> =C2=A0#include <linux/pagemap.h>
> =C2=A0#include <linux/init.h>
> @@ -64,6 +65,7 @@ static const struct fs_context_operations
> securityfs_context_ops =3D {
> =C2=A0
> =C2=A0static int securityfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &securityfs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
