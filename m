Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794904513;
	b=cAZgfRnSLPdo4v1brBjDF5V5M98cjxH2VQeni4ZBEovjnfMbJKXmuNMTmAOppYa2wG42
	 IDy+e1h91Q88c5iETE6sRiUWanwIuv6VFDvX+synQRUN3UPm5KwdGmJPnknsDzuQg4lUH
	 BzpdPEbhYiqPlZxE76op2GKTruCjmZq6mTlYp3wBrjqfGqkYEkNDG0PMnwoVZaJt5VnwV
	 wupTUxaOQTfQz2/19Q1xNZ0oEXHUEpBRwxZszDutCimpNvYMJ9qO4PY/7D/ddg0HVRydd
	 mESnvuT//Y+tpZJvxW8IgcSPJxhFht8UTdsc/S0piucnMViAXmQX6cg+41x2U4krNiA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794904513;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=+cVfVc99Mj9JzDjRqkRlx7bbwk4z1TaP6S9xba6j1G0=;
	b=cks3WT/jA5m7rgdgyh8JJUWofG/lxSfwYHCGyWbl6Y3fVR2LKmtV31gjxwqa/Svbstw5
	 GfGh51OGJFidZNGpCaCrHSH31Lih/MC47iqg5PCD/nqXcnkNmvRFsLZOwNJMmV485q85S
	 l+50Z71BdfXPdsmLPhnYPatrIVKPHP8gJos+T+zCKfXL6e8kMzlk1zCCujnQnYYQeiaqx
	 0O8z6KFU/JQaybqGoWArTY8TEmbEmHFVBfw8SdhFuWt46ocHcwKkhMinZeuN3/C/wddIO
	 nffkjXjGDka+OGOeAHEMhGd6xnBW535sxxrOHcvu+F1xB8vrtuRNshTzcUaXerbJQUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=asHWLUHh;
	arc=none smtp.remote-ip=209.85.221.52
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96752606A8A4
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 08:35:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96752606A8A4
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=asHWLUHh
Received: by mail-wr1-f52.google.com with SMTP id ffacd0b85a97d-490c3ae81d3so2440152f8f.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 00:35:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794904510; x=1795509310; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=+cVfVc99Mj9JzDjRqkRlx7bbwk4z1TaP6S9xba6j1G0=;
        b=asHWLUHh9Osx9c7ISjHVvBK+jrwM+bEKiKQ5ZLUG8jHeL8cbDrdmay7aq+azwtlrvN
         q7YkHw224WJQO7TnM1AyMygFYXrlY29jKpq3C9XROr0oTqsA+UK4p+WS5GMy+xx9DTRb
         nuDA+OEO8+ykjkDq/RDjAwEfWgenycj+snq2KkG6mulygb6NKchr6plM71+t8W0/+aGL
         LigMC+giRqQ92TsunABClmE52NWQSdRqhQeez7lH76lemvGh63Ic8nud3Qte/9KpQmbQ
         YrdviXjfG5hlS64KIE7Iq0kMRVYmtZMNK2hkMRb6Cz1tihRk5N+J71aJKPK+K5E0SOED
         KbHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794904510; x=1795509310;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=+cVfVc99Mj9JzDjRqkRlx7bbwk4z1TaP6S9xba6j1G0=;
        b=pQbrHDFbqTCUbrLgZU5+cFVsYbSkauJ/xWAytHRk9HwM6IidYeiWbKDkQcRVLBWNGF
         G6q8nKXU28KQ1oxEE5BEMz5jdh7Ur+Ej/PARh5CAIAinWj7Zyvr96H4pKK0hC1MGrzXE
         OYxEbkYGuwo5wcu9dISQ8ZOpfh8+yUjz6x2Kfsz5qPP15Cm0ivmpreR0f8S/hSUdphhS
         KqD0Io8rUrAYy+sc54EtbDb28mCAawDT2yuWIddTOqEILZnOyNhibKZxnhGHzWec6a17
         OsnxtQNNPRim2OKdn2QJjFDh9oeBALa1AQhtObhjBTM+E/uf5mb+wHHj3JiM4ucvxQbT
         bxGg==
X-Forwarded-Encrypted: i=1; AL+hErFTjngjwKjKXGXZrZ8b0gPuEPfuxFPGS6WvOPhBkPW87mmZVbdG/ydd/vFD467YMvF6OYH6piEpZUM=@vger.kernel.org
X-Gm-Message-State: APuU4Z8jIcN0EDDQrsXPdjRAn8Wv18Qkc3V/U5D4K9BmT8/xxJpzSGff
	szJIvhfmaSrLLPG4tL155NWmOs0cdDaLlkKXDBe5ghCV/et/kTE8sEVktPLICAHTFi9q
X-Gm-Gg: AZFdTZdIUcwH7FZ7kPoyS0+0Mn5fWggLS2L38Lj93jRGXi8Tfzv/AXA5sYWwBbPSb7x
	ZgrgedTs25dLPQU0sfbZfFjoksICg2cVjgSlhgBxbLtlw8UMxOR5W6jAAfVAHFFHiE38rMqvuKX
	5nrKU6v21OIYwvndMfZsN1FKyya6WJmLMJInxng/jajyQvcyJ6lEnqdHsuKOImlBfs8K7bTuwWV
	njiDcqiJ8uiIAX92bHKn6QvxCsVjeEkzTaELEkZbSRnFSs1rp0ees67DjJCWoMBeGtzwYp4zp8l
	ShafugH81KSuzvy6itCr3o4QLmTlCtyNSX0WTXiFlRxe1Cfqd3/PXtBE6u69SgL8mYO8uTjTXGd
	cnomTfuKixakj+7Z3knY3j48h5uFU4niKvql/QsHnDCk7ay1atYDSdjEN8UFYs0RQa3Mz6eUsPx
	ileUD0x8mbT9CO8k/9AM+i+lp/Z1z7zhFPaZRQ+qbMkh0ho3SOuDTALwfSyPuLBo9ypRNLXmDHg
	J38jzk8FRyWOdlkEUC8l0Tw2noWvCcRMPaJyrtuARJ2KYUFmzoTzeO9e6Ox644nXbjvYvqeAXC4
	PR9E2XSKYSXUwZGKs1Oy5HfyYLH9iEscCAjhF7DhOkUzH94icepdcoKg4MvINpVRewgu/EEdN0Y
	P2G2aBw28H4PCKVzSXhQWaWewKUqrW2U3bNwxAjp+o51UvyxQD9eITLMa
X-Received: by 2002:adf:e193:0:b0:48c:7306:18e9 with SMTP id ffacd0b85a97d-49c728c6e6amr26569239f8f.43.1794904509932;
        Tue, 17 Nov 2026 00:35:09 -0800 (PST)
Received: from ?IPv6:2003:cf:572c:2800:de4c:6789:33ce:97c2? (p200300cf572c2800de4c678933ce97c2.dip0.t-ipconnect.de. [2003:cf:572c:2800:de4c:6789:33ce:97c2])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c603f4e2esm26338505f8f.36.2026.11.17.00.35.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 00:35:09 -0800 (PST)
Message-ID: <b0ec2cd8f9b7a6a2e4a54c6df2fa897bce068cbd.camel@amutable.com>
Subject: Re: [PATCH RFC v3 28/44] ocfs2: use fc_init_pseudo() for dlmfs
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
Date: Tue, 17 Nov 2026 09:35:07 +0100
In-Reply-To: <20261116-work-loop-pseudo-v3-28-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
	 <20261116-work-loop-pseudo-v3-28-8cbbea1cf34f@kernel.org>
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
> Initialize dlmfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. dlmfs never holds executables or
> device nodes.
>=20
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Chris Down <chris@chrisdown.name>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
> =C2=A0fs/ocfs2/dlmfs/dlmfs.c | 2 ++
> =C2=A01 file changed, 2 insertions(+)
>=20
> diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
> index d3bfcada3e3bf..1789ec96dc130 100644
> --- a/fs/ocfs2/dlmfs/dlmfs.c
> +++ b/fs/ocfs2/dlmfs/dlmfs.c
> @@ -21,6 +21,7 @@
> =C2=A0#include <linux/module.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/pagemap.h>
> =C2=A0#include <linux/types.h>
> =C2=A0#include <linux/slab.h>
> @@ -563,6 +564,7 @@ static const struct fs_context_operations
> dlmfs_context_ops =3D {
> =C2=A0
> =C2=A0static int dlmfs_init_fs_context(struct fs_context *fc)
> =C2=A0{
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &dlmfs_context_ops;
> =C2=A0
> =C2=A0	return 0;
