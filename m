Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564824;
	b=WF0f+1xecaI315c+5jx89mWlX57jss0Dz+rAUGEIAeB/lZ6R1ehCCwq9c6CUICJ5yrKl
	 3ClUy/wZdK8Hh16IbSoyUxj/zGeJG8DtjJI8g1rv9FZn9j1J/pjsMlDncnI4KNQiEb1PB
	 MH4XBCEdm2aXwfdCBJOelN7cBT/AaqPjLXCvSBQ7jvvtiedToUl8wIJTmxktwrbkV04BK
	 VltL8fy9D9k8S03yuCt+JAwwiHS90WCXmtcPdh3Le3iomGAVh34vm3ytszzI1Tcau4I25
	 pgc4TxP2TRWkBetIJnkYyNLQdH9Xg4jfblUfyi+wWAX4dtHobGBrJbmBOttJBIY4Urg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564824;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=ycFr7tcHP3BtNSevVHScuCcUOF/OuOrXOdu+rsUd7U8=;
	b=Q+559VvRG1Mzqt0IHkwAyR9WXg9ie6CO/RAzUzn2ub7wNEIoILdKk0owsqofULYMX4p4
	 Z7T/nOlBaOeIuS3ewys52rj1G+8e2XjoB1iCz6WPyzXHFdtJbvaOIt8BKpw7uGQzUGewM
	 w91tK9PwlhXCjA3lELee2w2l3TmP5dw8cIXEvTv2ECvdNrRlTiSm8sWBoxThsB+2Hrstr
	 CPSy0alQDmsYcrCwzQ5DzUDisWOgM559ZIM1N+pmj9FGZmNwehvOLMxWsUPd/P0ErqRia
	 1U4J3D3MXb3xUC5M6B0Wqi1b3jTMOb0REovHwLLP2xvFngPFDT0TNj921bcTNTet1bA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=tBSDp3uS;
	arc=none smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6945606A894
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:13:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E6945606A894
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=tBSDp3uS
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6b581b6b0e9so1096346a12.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:13:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564822; x=1795169622; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=ycFr7tcHP3BtNSevVHScuCcUOF/OuOrXOdu+rsUd7U8=;
        b=tBSDp3uSBFgypsbtBQgsadIQZQK7UWodMC4WHZVi1N1ipHHYu6WywVfCa4AZ6QIaRM
         wIcOajhLTVFUJp4yf9/N65gePrg5n4K0AYKI0yA+7KNwnMoUY/irx0jTqY91Kx7jR9xZ
         Pm03fPe9TdsIWGPKhcU7A4Ssshd7c8Dhe1zzS2a/pwsZLiwc6FmAy6ptf2LWGhArJX18
         uzRhPjO9k+hyhG0ceM77HGUPCflD5+7VnbyODCgVUFUm1PdMwYT1gZdGgKWe2z5NHlJg
         Ao5qYJPp+rBAoBURzi6iHuHACVVyoOXqBDLcaaEy2+qVTTu+93IkZN11FbEDMtWMDX2T
         mB4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564822; x=1795169622;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ycFr7tcHP3BtNSevVHScuCcUOF/OuOrXOdu+rsUd7U8=;
        b=cCQO9/Qk0qRmFtG/92hVFXX98yE7iPWRclI5Q+Ftp1VX+xwNRbVwHuse0NfYViGP4r
         FjAWCz1snrkpS7ndYbWkWGEGWGowd79jUBU0QNGF+IB7DpCI7qCJgHGUJW+NM+3PncjQ
         V4+MJHKEcgVx6RGaXivlwzd7uWQsRy+iTfe7OYPjFu47m8m/DCXSJrpdMADzGQtyRUfA
         RRvj3YURHAt70DhbNXERrbErjNh3TFlQI+K7esODY9lzVmg04NaehaFIBOvbhQXxNXQE
         QK3OPFcsOF6QNShK+U14T49WavvSUgpr23NdW5ULvF6p9yt5uSBFc7x/1suGjXqSup/r
         JArA==
X-Forwarded-Encrypted: i=1; AL+hErEjugzbq+hV/4EzJu5rLpTxxVqoN6L972564b64KzjwBTrS8GfvVDqUEF2eC0rg2Y59bash5fjh4mo=@vger.kernel.org
X-Gm-Message-State: APuU4Z/MPKnYt8l5q6ua+H7SfpcWlwW3XbJivaZ/VzKrtynUtFxwlIT1
	zeuftaFDhQ6lcK677DkDR6QnUaxMIVvElcIlgtFUcypqvXW2ynNXG3LUz7D37KO5Amqa
X-Gm-Gg: AYBFou0K0f7LRV3ozsmAby4Zxcnv0alzO2OHNwd2YildWNFX5njHjUxn+qUSY3ggPu+
	16yoD/FLvZNU/XehfECXqPigqnXzYsdKucBis5FPIx0LVAZ38gMMdZbfb98bQVEVuAbDuzAbwQk
	602wPiS2vLCTKYY5GrcMBiH8m+CxSJxtxT3DJ8zYKTYciUrRVYy1JB1/DsuHsjAZeRxUlTRBhRt
	CerkxhuTre69JX4Vng338WeFgGNLTCzJ5iPkQdUNJvUV+sXYZ6w6sDy/LmeT2Lox/L38BPir+xM
	XQmsCUWw1USfViLUolYGVjP1rYvvzPjn9D3y/gp8uPgNM/5AjsGqupyz4z+CuLZBo3T0FleZINN
	uUeMyziB2DdKk+Gf3Z6rXx7sNNXf4cgHuf3cm34ACG8rAYTTgx/77PzVkAnUzcKfrPOS90GtV5j
	shJ9IhGvn7ymbExns71QnZ6x7X84fETHiXRzNHl0eMh3LMJa82xnmO98GQPXEu+XsaAWJsAdRPy
	xodkMn5uhiUN6O1h8h8hzsnWrod70GvSmyYhemvGoOmRHMCr/HlGTULmglBRWSIaQq727eq/VXG
	UxTbEO+hGYqeTcxZnpwHdZJS6Jr2FGgsaKUePC0xgItQWC/Ct5XppZsfww7q85bhXGnryPF8vys
	In6MLcXcn
X-Received: by 2002:a05:6402:208c:20b0:6b5:69f4:e7ce with SMTP id 4fb4d7f45d1cf-6b7c0c62bacmr1415990a12.39.1794564822367;
        Fri, 13 Nov 2026 02:13:42 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c603f4d29sm4332158f8f.35.2026.11.13.02.13.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:13:42 -0800 (PST)
Message-ID: <3546dd28b1d63c1478d391a2015fff4c1b976639.camel@amutable.com>
Subject: Re: [PATCH RFC 24/41] efivarfs: use fc_init_pseudo()
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
Date: Fri, 13 Nov 2026 11:13:40 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-24-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-24-4c998976c6c7@kernel.org>
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
> Initialize efivarfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. efivarfs never holds executables or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/efivarfs/super.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/efivarfs/super.c b/fs/efivarfs/super.c
> index 12746ced6dc6..e598d42c5f42 100644
> --- a/fs/efivarfs/super.c
> +++ b/fs/efivarfs/super.c
> @@ -8,6 +8,7 @@
> =C2=A0#include <linux/efi.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/pagemap.h>
> @@ -554,6 +555,7 @@ static int efivarfs_init_fs_context(struct
> fs_context *fc)
> =C2=A0	}
> =C2=A0
> =C2=A0	fc->s_fs_info =3D sfi;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &efivarfs_context_ops;
> =C2=A0
> =C2=A0	return 0;
