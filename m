Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794903941;
	b=CEm+rtCc+oj7R02wiRhb9DMHRrTyF1CfB5U6O01Bg41gyJ4p9jbV/lXxW88MNStpnUxk
	 RyoFxNJsRiQ74ZJALnTjnjXrDeXduQOm/PJvDr/RfTS4sYa1+YHtVc9y3Rwp9m6Yxi94A
	 cUUSUo6n436BEGU8kTb8RadqMxBU8Ro7WIKFxtf1Z8eO2dhUri3392tMT2MzNx5jo+rhY
	 ItKzaUpX0YnPni7N5fjZ8bMJbk7h/HKSjUC5qHB29TqNQe3oOajycFx3g/XjDP+hlI50R
	 UeXXJgbekmZUZjZfBOubcWhpGLxavZxDapSpBDrvv60a9K8tOcQ13a/6tWx/tMUlE9w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794903941;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=UGlayfD5Z/El6cdpm6ie0HDMH84kD107OWGXScU9uXE=;
	b=1+fxmonWZtEHhEeaYBVueycXxmn/bo86rHAk+jyGSJb2W9uIV3vISxjjdvEmaEuGJRZa
	 qM+E6wez3bRu35gh7+ARb7vn2e2pEU/fmt0y+Sex0gWsR80o8mVe+VLT3CY0KwS6kyEYr
	 2Mf1swMTrXj8n9iEH+3kho9PVS+K7Qmz5Pkkq3BQeBlc7KlKJmS6Cw7nsvHS+BpBc71cA
	 +yWiIsGZNs5lp8DVLRnZywrNESJJzpXOORmzV3Zi3ZjH68WvbiVbWyx93QheBAEyaFadJ
	 GPddiyHlfPXWD8gTkDrb0uQSeVwNPLPF7FG44PWKAGK6xKCzHjfxwf616Vd7YrW99lg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b="QoCmkI1/";
	arc=none smtp.remote-ip=209.85.221.49
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C58A5606A332
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:25:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C58A5606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=QoCmkI1/
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-48dee593f18so4521677f8f.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:25:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794903939; x=1795508739; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=UGlayfD5Z/El6cdpm6ie0HDMH84kD107OWGXScU9uXE=;
        b=QoCmkI1/XbLLMuB5pWQjj6w7lhYbbqiM96jQW+pj9RZ000aRRl9S7H2qSmbtORMNOo
         ePt1TXAWzVIR/TrMeI58Zu3n81XgIdPHavzyhyljr/3uEJYZwsW6Sg14gd450d308jE0
         RrvE2vSlthe4MhW9V05IsJzW8g0CM3u+nfQ1hkfntpYQW6a4z4zmXmxD0w/TiuzDbd7U
         U8xZ2FexNWbZhSQ3d3pA0tlH/f0MOfn4O69UeuIyRM8vQ/YXTKpGPDyGoQczoxEfoynP
         BDcwZppUf46pJGXZ+RH52kug0iZSl25eld2NGIqCa+XVs4XFwFr0CZI1pzljVyhbNHw0
         NmQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794903939; x=1795508739;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UGlayfD5Z/El6cdpm6ie0HDMH84kD107OWGXScU9uXE=;
        b=wuJsvXeMIHEzuKbOtB3t4q014PWKpfuzDICOcY8r1oD+9+QnjcQJB1N3a4QxJfXSxT
         mDrOtqV9S9bkUkIpISt7wyueQQx68NrR6wBnsBXw9YBKUovfZlu2WSU6bUfB3CRQQ7d8
         XQtlH4qHjaR2iMPtcqACY+hob3c3lPyYaVBf3xbIER5KNII9MASdkf+PCxKWPuMysxCV
         ciceshZTfn0EKOvBQuZXp7aMv5ttmgTfYgVVPnP0h6cglCgZFoFxEznNE3s0+OdToxkZ
         csstEZNRWreOBCNcb+SJmLDPO6xSn31y5fdQy6W+uzqD+tgUe3/hMJIl37LPT6ySy8S6
         b83Q==
X-Forwarded-Encrypted: i=1; AL+hErF30ngONjBDVE4lYMswy72bbd4LsTNXIpBg5Yi7LS6r0JNPRQ+BjGoKCO0g82TV6GpRB1VgiL/q9Bc=@vger.kernel.org
X-Gm-Message-State: APuU4Z9X2RNFsLBsfi72KnOwLtQcow7MJQz9iJC0t6mgYGxg31Jdfn9y
	9um0VxQcJdm1USpDxx7ASfFLHCwdbu3GeZR/DbLGW0ZcVoLv1p3o1DQVZFp+F9+6BvF7
X-Gm-Gg: AZFdTZcxVlVzjBasCJB2R3b36idVL48qPjpiAMrzdPpmsMT1S9oH9euomZXxGyfPLwH
	zMwYOJML/vyKnKMDDmuhfhckpos/OsZMxmF1t9qFiEd1IOUP50vO7oMrOGMF2Cph+BORbqRdxrF
	aMSOxWYHJVICz34/kmER8pY7RBB3fhKLccenvnibWlYxw6SIN8W+x3vGIku5jNT/w8RFNz7ooMI
	rwp7L5cEvAtZKdPcyJhGKQqV6/qzJhc9QuUmewwm5ElY3wjjIGtWe4Zx+4uCvxiVNFqmGEwhDMq
	AiVir1Jj1wFDfy/9Y1Zk9HAj645TTJU2yiw90Ywm7OgFzWi9q66B0j/x76xPCzj54/J2eSCZu8V
	MpVr2/9H/FPFzC/akkPyKfWTVFvGFfWji7c+vEGEh5az6qTnBCR+6yA4+3EViGTvSwnpnOhAMbL
	jRin69geK73gexBNghIhqWKIJFWaRyZjvf3NKPDHdbzwK+GJifBmMN0A+bS3bdmeSiFhBSEGie1
	CdpgxLdQMtnJvHoMLA/OcQ0u3455KiMoV55BDeNHBTZ5cDqmjtpIzVFwUiJfyrHjipJynrmxaZE
	S0MA+eySGW0kaxxC8GR47HYG2hib11arJ2mPduNrdn40mxq1XDwcfU6hDws726efRWlg/rrpdVi
	nUY2jguuriOaQGQYnIUjnywlA0eqDzuNmpyCnbGhmAyJtNQg8emvorAMDspklATjFQKO4dTAJQW
	PBfQ==
X-Received: by 2002:a05:6000:2084:b0:492:46e:d4ce with SMTP id ffacd0b85a97d-49c6fd932c8mr25238543f8f.13.1794903938925;
        Tue, 17 Nov 2026 00:25:38 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c5ff2be55sm26907832f8f.28.2026.11.17.00.25.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:25:38 -0800 (PST)
Message-ID: <a9124bf1c858cef3e8ac06b1b2396dcb0e19e2a5.camel@amutable.com>
Subject: Re: [PATCH RFC v3 02/44] nvmet: check that the file backend
 supports ->{read,write}_iter
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
Date: Tue, 17 Nov 2026 09:25:36 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-2-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-2-8cbbea1cf34f@kernel.org>
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
> The file backend calls ->read_iter() and ->write_iter() of the
> backing
> file directly but never checks that they exist. Everything that isn't
> a
> block device ends up in the file backend. So a namespace pointing to
> a
> file without them calls a NULL pointer on its first I/O. Only
> buffered_io=3D1 gets that far as the O_DIRECT open fails for such
> files.
>=20
> Refuse them when the namespace is enabled the same way zloop does
> since
> commit 0c10f8a1a7ae ("zloop: check that the zone backing file support
> ->{read,write}_iter").
>=20
> Fixes: d5eff33ee6f8 ("nvmet: add simple file backed ns support")
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0drivers/nvme/target/io-cmd-file.c | 5 +++++
> =C2=A01 file changed, 5 insertions(+)
>=20
> diff --git a/drivers/nvme/target/io-cmd-file.c
> b/drivers/nvme/target/io-cmd-file.c
> index 695963dd932ee..dfa8aa46188c8 100644
> --- a/drivers/nvme/target/io-cmd-file.c
> +++ b/drivers/nvme/target/io-cmd-file.c
> @@ -47,6 +47,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
> =C2=A0		return ret;
> =C2=A0	}
> =C2=A0
> +	if (!ns->file->f_op->read_iter || !ns->file->f_op-
> >write_iter) {
> +		ret =3D -EINVAL;
> +		goto err;
> +	}
> +
> =C2=A0	nvmet_file_ns_revalidate(ns);
> =C2=A0
> =C2=A0	/*
