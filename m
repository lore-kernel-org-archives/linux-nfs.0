Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564785;
	b=y8AYB7kkEnUpUgEsSSR4OAHj5heNbXSZNVrQLabRwdnYJEcnoQuirpkVYYCSiPkywnpx
	 7/yis3HktFG5bZG7CzPTaq15oXKtKANi3LC+HOfSRUS0GU2kUzwlAb9FTqutCh08Ga1N0
	 b2SSHYQFjPkuV48/GBtL2IcLw3ys+7C0yYGfxC3Bc0+nhSw8k4zaoqLROz/2CXIy3VRbN
	 t2saqwiRlTvpTA+gt+jhle1R2fswhzQyBvZJLbsWQGy+dwyPhw2te5pqBobiaUZr1LykX
	 3U9DsKu8uneO6FTCzR03vqheLnVUuLhN4hvWbiaPjd2TebS9nVs2NlcPqUWEANOovnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564785;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=PGZ86VpI4/X6bkLIqgY54HnsW6MSps296zHbeFwxlLU=;
	b=FH8hjshmTOx6HMop4aiIJnUHmqHaulptZv0aKsQHtrscCUWT/sQZ9DLaTkRZkABs6Ecy
	 KQvf5DT9rdVF6h+dtBW4Y/vVFOOxMCAX0O4tVXJ400EgxC7kBV08QwC7/p+4PTWKC6xwK
	 0JZzY5Ke3N02makP9FJxTeN+snrtXV8Z86X6Y2cJ3mzpi1/iJ5PQ8MdPfwwObZROPOCIz
	 +jaq0TGVP/1Z9ook/0Mxu48M4MYC9QjAUQ/PE4jQsAtnoDpMnJNihWgENAuCWZaD/Jamg
	 Y85oOy8s9ccLg7nXncCwC1I0J2nKhTncX0HPWZeLTdJWAka3SiS0/MLVfHspNqVF5Zw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=qhgXZLcH;
	arc=none smtp.remote-ip=209.85.128.45
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86E48606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:13:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86E48606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=qhgXZLcH
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-4a20bdaf39cso13116845e9.1
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:13:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564783; x=1795169583; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=PGZ86VpI4/X6bkLIqgY54HnsW6MSps296zHbeFwxlLU=;
        b=qhgXZLcHEG/xp1ftPxi4Y+VtkR5xPsdZusiH6E7v1UVOpu+pQQwW0vkLZszWZiEzcA
         +BIaLUI7scE4yUL73wk7QDgrWayWPrLwdz+Upaai9wvZdfIC4mpAyM7/MboFd4cm+sgl
         6S6dsMSsgGsAMWrOW2SdAqPT3x/sY2fNDxpywpmU57N6cPKU4MQNdvXTLk3fPNzTNPjQ
         TN2vMd0rw8z+5ZJqFwtlFaNorLJKFpgZtePYZzAG9uux/UTV4iwPxrV7Aluh/WlU8Te+
         mKwCC2bzY5T7ZateqcC/h9wnCcfLq6dmSfmWCE2kpyRSPYXephvqiHzXHW2gW5l+Jqy/
         ZrPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564783; x=1795169583;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=PGZ86VpI4/X6bkLIqgY54HnsW6MSps296zHbeFwxlLU=;
        b=MNa61/dSLztcGOoyhR857Toj/IleWWaVGq+Ah3rw1dOUwfBCemxJSXLMWTqU4EggpV
         5CpNf4bYf/o6q7H6ynjanIvW6hbv/4sUq3fEmWlyGjUKkgeA5aZRz9lXk3hI6A4jvCJr
         JS9btdTk5z/dbiF1j0yXjro3qr1Zb/4iVBSrgZKHMMIRwStYQYUOc6j3VP7bFCjYThZb
         BSHm/4mxUfSHRQJYy+I10m/BURfAMljB5kt041qZT3iGsOcUmcQQPOfB8SE/rpt48BwF
         Mbp4i21ZmX0W3E3q3BOXnCa1mH5hFwJ5aaQjekgewZ6mgn+KUUqzzcPzq2QXL57Dd3b6
         m1LA==
X-Forwarded-Encrypted: i=1; AL+hErEUady84c80fhvllyydITInErLYwVKWJCvSb7fv3PucA+cCknQjkhsvTjRrS1GI0BS2RRY+EmcgYoQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z+KYiQwyZLjWnV+ifMDNzoFI/kd3c01ftKZpQuMY7zrJok6BeAC
	G9cz3GlK/xepfcmrqFrYSv2JvmcGXR7fWxDD8U8MuHs82eKSn/4Pj4/ztHftz+I88iQC
X-Gm-Gg: AYBFou3kCh+NKhsWPOiqr09bpUTi8jSrFzPO9V2TZGz4upDk6721xmMIVEK2jOHkenx
	gMja1Fps4dJAhJT4TfPH7LRsd26G42ZVMi142nNNQqRuEdvfd4Rgo9ZhXku5PwbV55V6mgrqomt
	+AVCOJhi6npUVS8eel3RnM5E9dGZ1PplEsIltu2f4zkFCJtNjHP/jjRxvQkwlzhql5WuzBsbqgv
	fpKY2O0kJBGMFUIFrKrnXL3qNtJ4Pwoc0DEdER9rhqVZ+REtmDrgGTAUevwAkg++QJHPuovBe9g
	8muNZluMXEoHgzbd5aX9mAH99g0AawAIu+aeTRZCteVLjZ3/Ns5QEhOVqDkYEoJCEkigPXL5Roz
	Q8DcwMTbT5/4d+x+n+3wP0gnmga8LwcuJqJOjuxfKkdYBLs8QB2vlVQOFSTvDMINWRo3E/Tpduo
	2+r10Njt3P8x8HrtimnuEG7iyFySIEItTX3AasykydsJ4XQ69EdN/qYCgC/dONze9gwcAhUmGrW
	5YCcjvDwFyEh4jfOKCNTO63ynkpp32TNf9N9+32UjmupogZ2QTaQawnh4FpEcNpwJFiNuGAvQT/
	D0niIlw7rHa7Exv6qglspuCOjSDGRbnlJpVmPtNRQTLdEimKi6IO49EbLKPSnGzm
X-Received: by 2002:a05:600c:4f90:b0:4b7:6c16:7b43 with SMTP id 5b1f17b1804b1-4bb55a47602mr36814615e9.10.1794564782834;
        Fri, 13 Nov 2026 02:13:02 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb5d2872edsm4056955e9.12.2026.11.13.02.13.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:13:02 -0800 (PST)
Message-ID: <94dfa5ec75f4479663dd79f3ce05c1dc6c080185.camel@amutable.com>
Subject: Re: [PATCH RFC 22/41] sunrpc: use fc_init_pseudo() for rpc_pipefs
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
Date: Fri, 13 Nov 2026 11:13:00 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-22-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-22-4c998976c6c7@kernel.org>
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
> Initialize rpc_pipefs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> also SB_I_NOEXEC and SB_I_NODEV. rpc_pipefs never holds executables
> or
> device nodes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0net/sunrpc/rpc_pipe.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 9d349cfbc483..37277a6d2415 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -15,6 +15,7 @@
> =C2=A0#include <linux/pagemap.h>
> =C2=A0#include <linux/mount.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/namei.h>
> =C2=A0#include <linux/fsnotify.h>
> =C2=A0#include <linux/kernel.h>
> @@ -1181,6 +1182,7 @@ static int rpc_init_fs_context(struct
> fs_context *fc)
> =C2=A0{
> =C2=A0	put_user_ns(fc->user_ns);
> =C2=A0	fc->user_ns =3D get_user_ns(fc->net_ns->user_ns);
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &rpc_fs_context_ops;
> =C2=A0	return 0;
> =C2=A0}
