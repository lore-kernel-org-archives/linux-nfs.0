Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794903967;
	b=sbeLsItTBEGLzaEb6OgpsnGz6BwUtlkI9CG9LyRKfqsG7i+J+xqvvtwiib7T+cgVGOAI
	 mNYRGakNmlZSxs/Qu/ht5KiE2FijDrMOwqm+WHdJS9pMctGveglOzFWAgR3q4W/yCUv0I
	 I704AzDSMzCZLCkZkcI3+kgff+hq7rp/TV00G5BFfa65P0JAA/O0wHgTL8k3/5WrGEY/k
	 5A94YrJIq61kyEMO8p7n+RUnlg8CaNQ52G7zkZ13goBHmqwSwe3Lvt43WYezfbpQ0Mgov
	 SdcoVhygXWzKjZZU3Ur2Gb/Zw8nqZzeGs1Nds8Eev5PbSxQIAzCbggClzjDHAJftSmA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794903967;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=z/NZRmC5bENRF/WsK1hUt6gARTy1xozW3x04wBCWbAk=;
	b=wj/y53Cf+Den8Zn25eW4PZ7QSA5sJiGN/LsR4+Y6UDOdudgSFWfGjReWCvnJjAHRW7HS
	 MGFJyBfciCnp2z+kJRq4ZXrJpR8Y3Dpxavf016o9Ev9k1hZTtcB0F8KLZ/Zjj/e6WbYzD
	 Nlbs2J0vn6cbcUO91xIYm9U57F4TohRgYsPNI6iW2GR1dX31RERdib0yjY2LpQqSYFW1i
	 FrMuNvaZ/x7TgwLBAZzoBxNuf/8qAtUdmOlExaqozCE+Ts9Fl1O4LPGDvMmbnVPxMgA6K
	 g1+G70Q6ijeVhvZYLR4nwgl/EWuRVy9fRMWhBSDzGzhNrS/+mVcyDZ7+kvxX4tDo4Jg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cds43TFp;
	arc=none smtp.remote-ip=209.85.221.48
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D5DC606A332
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:26:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1D5DC606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cds43TFp
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-49d64a88222so365984f8f.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:26:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794903965; x=1795508765; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=z/NZRmC5bENRF/WsK1hUt6gARTy1xozW3x04wBCWbAk=;
        b=cds43TFp7I9j7WPcDQvYfHpQ9LovbzzVif9J1GAb84gdrUsjaaD/ks8/CxWEGRZF0/
         68hyeBKuGnu6JbonI+DUrAk+S9ERoS7tOFFA4H5eAQDr7L4jclXV2ELfZ8mKm2Ufg0Vf
         wmDFKHpSFXtb9q6HdOEKHOgWOeHJI7n45fohFUmuSejGQMSPwWlozLhppiRP7NP6/RTN
         Xh3C0JkZ12tnXvLGCknth+xcOYp3m/oSfXqUlVI9cwzFe0Rue3P0S85bM03sQyFUoXwh
         8JJkMFcg0oB6zhSAQwaixAlqp7dYBZf2pow5RK/cSK97CWugz7jqMDtCMqYWg5eRSPcE
         y3pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794903965; x=1795508765;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=z/NZRmC5bENRF/WsK1hUt6gARTy1xozW3x04wBCWbAk=;
        b=GjU6qc1Gi9gOwjAssjhzpGO9z9iZcZTEY0N4lXz91Vwiiu9AaHRpoJOYSmu8W5xE8g
         atirvSDZV/E64m1cn9GknO1hoxXPMvcSNCwBTqkXotLBrsHosXwAiqZX89Tr59bbvLr7
         a0HepqxG6eqCUT7SjTsLo8lkbd7Xv6pkmMjWveUvwExCLr5+exzyB89xGI+gx2clD+a0
         /RV5oHGe0CEqTMwfRLTt2Xx5TXs84Lp5ruwiQylgTzwLSXiNl0bsERInumeXiSCoMBQf
         HeHpvWD1W9fzMzD5w3a9nVH2+RgTjQuCbR1lT5v2oCDCnsTxx+dSHBZgx9B0K2qO2NxV
         H8DA==
X-Forwarded-Encrypted: i=1; AL+hErHctemnjRshqLB+oU/81sO/dw9Blamm0Ct8BXqCxGaE06l553L7JxbUualFfkTv0jHoVIJm28iBTTQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z9ooxHMB13ar2VLNBtwaQZN7fRcsKQgwbPIIgHgVDsqyZC9A9+w
	uyXJqV2IwQFU9/6tmlevTfvc/RwQYoyQVHipOALZ0UAZQ5hKI+QlkPLrUTNZ+Vlz9VdN
X-Gm-Gg: AYBFou3CwntijefglS8AmzkYbWUS/6qjqwZNuCWQ6I75tflVZwbvGd62XI6eIed7lCA
	TFn9VPq6kmxvBK5wlT/Eyh0Ak7Rauiz1tcbIdFEuHmYuT4gHdSnl2XO3zv+J0KXzPNHmgMFPESO
	d35WGABFCtkQ0Y1MwF8ZbGGDam+dF8iJqCZetKOKWV8GVAar7G9S3Mnh1jM2uiaAV6r9IbLhEiQ
	L5p36jTrWE3RjPCXMb8XfQ4KnH3IBoNcGM0pnk0RDFpv96gwMYvgQdFL4WrrUsPIiZJy6OpU7QI
	06E4jplpIxsFjOoAhLVK/JWLZAWb0rt1oIdNms0ahoUOAlurVWw7l8IGvH25JNtBcHP/dl+j3FU
	8YP6AzVsuOmxYrgAg4MhMn8swivLeTzvWB5xpwiPEYDurW50lB3Zf56B04pKrPLuSpeSy/5UbEV
	ku4wOraLUgxncvrF+fxOlQO7P6aRvDPTyMLsc6PeLjGah9D3gkKcvGQbqNqo3MAuY2sPvKKf+7m
	1lNNsyBNoPgiC4B/soLBWTbjvepqkL7nn9alE3+ev/QgDhv3xEBqSUe37tzvlq42HEF5ykZwWFd
	C4wqlbSJ+9CIFpu6ME444VltzgKHvFb5AIIjbxsWIbaQ0/H0v5q+DElFSp2cNr6+XxcKJEP/uoo
	DxUZfr36b1VzdDckDUXVv5KaMXHM+1TIxS8pjBpHrOi9i4TAbU+kL4CS/
X-Received: by 2002:a05:600c:5493:b0:4a1:c27d:e1a8 with SMTP id 5b1f17b1804b1-4bb783813a7mr42606245e9.10.1794903965400;
        Tue, 17 Nov 2026 00:26:05 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb7ad9430asm12629125e9.15.2026.11.17.00.26.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:26:05 -0800 (PST)
Message-ID: <88041240268f70b218de7dfd58c41977d03a60d3.camel@amutable.com>
Subject: Re: [PATCH RFC v3 03/44] target: fileio: check that the backing
 file supports ->{read,write}_iter
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
Date: Tue, 17 Nov 2026 09:26:03 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-3-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-3-8cbbea1cf34f@kernel.org>
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
> With fd_async_io=3D1 the fileio backend calls ->read_iter() and
> ->write_iter() of the backing file directly. The synchronous path
> goes
> through vfs_iter_read() and vfs_iter_write() which check for them but
> the aio path doesn't. So a backing file without them calls a NULL
> pointer on its first I/O.
>=20
> Refuse such files when configuring the device. On the synchronous
> path
> every read or write that needed the missing method failed with EINVAL
> anyway.
>=20
> Fixes: 769031c92c8b ("scsi: target: target/file: Add support of
> direct and async I/O")
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0drivers/target/target_core_file.c | 8 ++++++++
> =C2=A01 file changed, 8 insertions(+)
>=20
> diff --git a/drivers/target/target_core_file.c
> b/drivers/target/target_core_file.c
> index ab9824a4852f1..a5391e57e9aa5 100644
> --- a/drivers/target/target_core_file.c
> +++ b/drivers/target/target_core_file.c
> @@ -144,6 +144,14 @@ static int fd_configure_device(struct se_device
> *dev)
> =C2=A0		goto fail;
> =C2=A0	}
> =C2=A0	fd_dev->fd_file =3D file;
> +
> +	if (!file->f_op->read_iter || !file->f_op->write_iter) {
> +		pr_err("FILEIO: %s lacks ->read_iter or -
> >write_iter\n",
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 fd_dev->fd_dev_name);
> +		ret =3D -EINVAL;
> +		goto fail;
> +	}
> +
> =C2=A0	/*
> =C2=A0	 * If using a block backend with this struct file, we
> extract
> =C2=A0	 * fd_dev->fd_[block,dev]_size from struct block_device.
