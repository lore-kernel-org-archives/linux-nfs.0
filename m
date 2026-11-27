Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795779355;
	b=ufyd7h9rbvDr8dAxAFLeAzpCEMaZhfldlCZdkr5kTmJHXrEOJH6hrhWxmDRa5LDri0dZ
	 Z4xpmsbn34dKYNGfwW1J3YFN5XJez1FwATu9LgUZnxt+g+V5bhvwvOVEyO+Z54DOqpPLH
	 R1qPyicFWpf4Iexvszw6mlxMlL/QV5WuQEdnZj4ZQWB7bsByisJb/SnYUQ4Y4ttleEcSA
	 IjNShStIukz6ZsP2t1zwVDc3LDpGmng483YFlrn/CxwDZspbYflZmwIO9eADXa7AI/Hwq
	 UF4GKoxeMcase+Id/dZSDzrC3EkYy1l1qmWL7cNLhI4xkOQPJSuNjWioBxLVsk3ZrQA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795779355;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=zckLxKTSVIvkUKQrRBT4ZQPN8xSZzGvjPSGz1nKrgeM=;
	b=UaooO9haLKCGPK2FUZbRyvYfhvD9c2j/lSsIcABLFndkCngn8u72J8EQkNSPFGbek/bf
	 /FOeOydzWJTOeQlwHgpecxxsfOF9gMOW/cs+Ibnt8R/EoNeWIkg3fdol0B4yLvo2gEKDb
	 ygg6L5SfKgzz6Gvh/Gz5p8XKj1HfsDuSdIPp5eShqWYOPluwEPYGsoE8o10XUEMRtrecO
	 iZZXzrogaFapSEmzjruiogcbr1QZuMOjHOHSrR3i67hwpN8o/Fvb42si1quyV4+VQXDM/
	 AG03HbXgscbwaVYFxFNyXLqEQMhQTqyG/7gl33QkebEJ7Sx4CTlCT7AiuVTT5Hfs+FQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=vfl6nsas;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12516606A326
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 11:35:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 12516606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=vfl6nsas
Received: by mail-ed1-f54.google.com with SMTP id 4fb4d7f45d1cf-6b87a240de3so10020986a12.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 03:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795779353; cv=none;
        d=google.com; s=arc-20260327;
        b=MrtajDC3q00wUQrbsIayVf9QwBL7rnElK+oybDkAoCU56UTLHN4hrmKYWXLZ2A/aiK
         R54qQ5U47XTZTbHtuM2Ia4NXBF7JjH0rTz0ADIsoAJ8DaORS65pBKTwrBZpAUgBmnaLH
         hoTx8gage71cvoE6HCmCZEy8C3Kpin65KlXxJ5MF+vqVdYKR64IZHKF8d28tUBP4G0KX
         1dPeSwNRBvqIZokikYVVmOIF+dpZdlkj8MSnsUH04Y9gSMh86/YAnHZIpDT4I2qktxG7
         wIgxb7yu2c7I9AbjxIcHMPRvYJeUATBc+2BFkhXEV860anKGYPDCPm2BsVm85aa1NEEo
         Cqgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zckLxKTSVIvkUKQrRBT4ZQPN8xSZzGvjPSGz1nKrgeM=;
        fh=5dZRHZ6kmJTjmjEuYIp7EMikAKpjHjIrH63oc/scMYE=;
        b=fhNMOtKh3wNeJJn6cBTvB4IKae2YSi2RFzpHXu763lLjOZCoAkLHSzxdshIhAlY9L2
         iYJkV8SfhGVipwxXracOTIXiP7wKeF5YYo5avyEn62qNTCotXPJXroQ+4z76pt0NC9UL
         IpY9VzDin4lFsyP/DEMGYqvRq9xLEGSJfJVFzc8TrUPFY4bxSZXGKpM/l2b6AHUsLVpr
         M7mH2Nfh+MOaarDS0+OAWEMI3n69P219aGlAt6kP0mnwyoaou/pLMPGS3HK9D7TzGh/e
         CFCiqc/LJnaaUABeev050a8q0mo/1T6q9CBETBtEfPC4hIr+HswgV3c9EOWEJMlkquhy
         ifNg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795779353; x=1796384153; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zckLxKTSVIvkUKQrRBT4ZQPN8xSZzGvjPSGz1nKrgeM=;
        b=vfl6nsasnL9MeKJC3PKlnSrIcRDT85xssIPtgR+brRFXXZVzFiEq6BssOPBNi+U1NX
         rACDgNvbgFoECMBGeOSxlv7f9ZZPlw8jbFZGiBU72Swu1vfaeCoxTTziHNw7UcLrHWJR
         AKKiFDsyO93LUbEmoG+hHJdZEh650ptJD3odyQ/w9fPYc4PvSJ0mm2Sf5PxZt3k35+Xr
         wxob5ZuRAYUg/cXXu2K92l8bOQgHSH8rodtPWHXJuG7bBF/5TfgeoeRbDB0Wy/K1sCCD
         uVtxcxA6CrL6WBmCavRtirj9U2/SaEAzfTB9jrKlSoL4xIH/1z47TjHh6YE/4ycLvzHM
         m/vA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795779353; x=1796384153;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zckLxKTSVIvkUKQrRBT4ZQPN8xSZzGvjPSGz1nKrgeM=;
        b=xjqwmHCvEZpvN8b9HGa1NCnMqlWFCWMQf9YZuELLwXCoeI9TFXvvwohfj6NFJnzbtb
         7aQaTJUPkTScYAIt8deJGlx5KN3SaeZqz1D4MGc9mLddPCU6y2LUrK9AWPpxpTPbTXdB
         us879tVJoX5nXG6Lo9GhXjzU4sVv84ZpsYqGmNcu9Ct2LQZnnV/Id1EDU6trBeMZ2Jh4
         fHxQlnspcV8CtVRWC/h/nq+6c8HtjjchsuX26BnZWD0Lrvp3keUh3z3wLh9uALXLYOgl
         obhMvrPoAcKG0ypLkW4tLPFcQ5NvQc6cEzfjKY0KnLVZxQu8JSwKWo6mdBXuFJ7GS461
         9MWg==
X-Forwarded-Encrypted: i=1; AL+hErGZysjh4wo/h2n3qgRsjSS2YpTWq2hD8C3Llv6Y0srgAfjCxEz1/60OAjqw5whlJWp84MwKH0/CBto=@vger.kernel.org
X-Gm-Message-State: APuU4Z/Xr+82cyWBxalvPTCMo+PMwE7zSiZvn6Iklig5zWHzVGezkMOc
	FDJEKgLQv8tBBnkDk5eGcN06N0bhzZT+CY0bFo1muNFiAPYdDDkS62WL/nAcN2JOdPkA/HqnVwg
	HmI6uO2hdlU4yowz6UH7uZOM9e1caKPM=
X-Gm-Gg: AZFdTZfO7G1zDhlLCNVCSIXAtDT/YQSspp7jJLz0h5wRPGkVoN9vA8u566gcQjIrMV9
	VwCewRzeWh4dBYUQ0fikYMFHe+OVrvERaOQWyWNBRIzUseqeXszqt1QpXnAYJY2TzZ2lkBHmFO9
	6LVHT/I/aZ1ZrDXlKPTmZ+gBHeDrel+9PH+Qu2qQneWGYiBLRyxMRmYTzuQS6S4/J0sKZjecjMI
	fwWFVaolcE3bkLVfPoyhBsoK083DqTuxOZEgl/fd1SWuL29G30tfMs68Ihu0lT6/1D4K+5iAy1Q
	+DH/M1K7hsAwC8CuqXY2E5tbEWp3UgBj4RATXubTyBd9LKUtnAn878aX+AdKo+KtzcazV74La6O
	dB8gCMbxc5EqtuQPXlLE4l5UV3YZMpT8OYBk/HcOZvDHWQRtdkVxb+j3veYSxR5DXetLPSA==
X-Received: by 2002:a05:6402:42cd:b0:6b7:b872:27c0 with SMTP id
 4fb4d7f45d1cf-6ba37ebff16mr18720566a12.44.1795779353347; Fri, 27 Nov 2026
 03:35:53 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261126163114.403846-1-koray.fra@gmail.com> <20261126163114.403846-3-koray.fra@gmail.com>
In-Reply-To: <20261126163114.403846-3-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 27 Nov 2026 12:35:41 +0100
X-Gm-Features: Aa3M54oDVUmD4L041vA_Ja2kzcuIcnu49jvnV20FPfNA1gUDEEUT8nV16GU1jvk
Message-ID: <CAOQ4uxjGLfuZMFABCwMvdXwnU+P24G_aTJLudWbjeSmWwyDF6Q@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] fscrypt: update fscrypt_prepare_setflags() to use xflags
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Eric Biggers <ebiggers@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	Alexander Aring <alex.aring@gmail.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 26, 2026 at 5:31=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Update fscrypt_prepare_setflags() to use FS_XFLAG_* xflags instead of
> legacy FS_*_FL flags.
>
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/crypto/hooks.c       | 10 +++++-----
>  fs/file_attr.c          |  2 +-
>  include/linux/fscrypt.h |  6 +++---
>  3 files changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
> index 149498bdab94..52d6a33fc9e9 100644
> --- a/fs/crypto/hooks.c
> +++ b/fs/crypto/hooks.c
> @@ -182,10 +182,10 @@ int __fscrypt_prepare_setattr(struct dentry *dentry=
, struct iattr *attr)
>  EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
>
>  /**
> - * fscrypt_prepare_setflags() - prepare to change flags with FS_IOC_SETF=
LAGS
> + * fscrypt_prepare_setflags() - prepare to change xflags

prepare to change the file attributes with file_setattr() or one of
the legacy ioctls

>   * @inode: the inode on which flags are being changed
> - * @oldflags: the old flags
> - * @flags: the new flags
> + * @oldxflags: the old xflags
> + * @xflags: the new xflags
>   *
>   * The caller should be holding i_rwsem for write.
>   *
> @@ -193,7 +193,7 @@ EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
>   *        another error occurs.
>   */
>  int fscrypt_prepare_setflags(struct inode *inode,
> -                            unsigned int oldflags, unsigned int flags)
> +                            unsigned int oldxflags, unsigned int xflags)

This here is a backporting landmine -

Changing the semantics drastically without changing the helper name
or signature.

Please rename the helper something like fscrypt_prepare_fileattr_set()
so that backporting mistakes will be caught at build time.

Thanks,
Amir.
