Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.217.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793109903;
	b=3gZ0ihDM9kUt6jF9gS/LbGEWTCmVf717+aMRRUg/rA7jPsyMBhMJ7WNy+ARVKgGiiwDv
	 MRG3yRmujWDZausVvLeOV/P94RUjtdfHMrcs09lo/IEaMQtBWnU6v7TOXcc4py4ggG2yq
	 MtR3y63SO9IZrKX0GvIm1L51esIZ/fMxKlwqnCJ5FTjxX3e3MdpJoPLsBwQ5RbxPDeY9R
	 on8wlqYFjvfB4OWkGb+P94zcNSFq/2vVoTMe9Ac93z7zmDZqQLtxTPrb+sAWaMg7WIlHK
	 i2Ey0+h1IUI7RigmXFB8gQfg7DksIRCGQZAkjklifCYVNhHC6i1nrbkVPyd5Wz3oyQw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793109903;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=W7qpgLW06+QZrv93vDvbBbOUt30oIfC1Mu6jHbXPALI=;
	b=pEAG2zFeNkDuhC56QL9WFWe+OamFjIoBBMdQh/PmDcVgSFHqu+XefN8PxCuL809fCJDJ
	 aqUMIO49lNiXOgGpzxZo/FXLvxdnz+Dfma5LgGglX9JHsHEoDV4hpojHw8sAHVWbtvUOa
	 yiUDG7OwEAJs2xxWZlOb42u1w/yHCNMn7TxfrJW9DSxiZpsKNi/oc0gqGnH24MsLvwxOv
	 qN8HxgtWoqx8JV2+CmQ78szneLr0O1bbBFzIIYYk+qbVcF+OE4lVPmjuQqfPRxa+3G3go
	 CQCyEzSQuUo2tCMSHUFtkSo0vdazotg5h8EONTWZpQP3lseHtpD7GozjCmiBV+ULBhQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=f4CKSjku;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.217.44
Received: from mail-vs1-f44.google.com (mail-vs1-f44.google.com [209.85.217.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC750606A31B
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 14:05:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC750606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=f4CKSjku
Received: by mail-vs1-f44.google.com with SMTP id ada2fe7eead31-7c2f48f3a96so1422424137.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 07:05:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793109902; cv=none;
        d=google.com; s=arc-20260327;
        b=DPahNU2qiiI/g1Ro9TaAM/d3hgy3VBxzyTnfHlIcTbuNFgU9I4bzQja/AEV3dE9r/K
         6DXvM3a2pvBJczj6CKT9WY5TIDmnAgnc2jnbAmcvpo+a0IR5sUB8h2JkcpvlvIYrCvq9
         F6MEr5vtb/2A9GCb4vltgx9N7m0oR5UVHuhKJ1oovJai3rkL5HzEPk8vc/wTlQOZ/9vc
         lz9gZ6E8NNjmTN0Pi6f5sUhvjqghwP3E+lzRpkdcOmZn7nUed1UWMVU1o9bXewUMBh/y
         dp/9AeKtYQK23RCHYCpm1oino2jsQ7HqPd51+oAbQn19C+LHo2gMNaa9i9GRtre//PWz
         I9aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=W7qpgLW06+QZrv93vDvbBbOUt30oIfC1Mu6jHbXPALI=;
        fh=JgrymsDLGBpsqEER4KoLHJmU9UidvuYhLQ5WJYtbmHc=;
        b=gULg3yoG5PKVnw/cUQWC/vXHYDa0s1zisSSGUfpzbUccUklxIlsOJDC+UR9vd1gflY
         ruy0FytwJwInjTK6E3+mIb6rIeizheF+qq/kCnSmgGPP8lCdntcWlx+6pIHBoK11wnzc
         mucitWNKBTxzjXyZsTWmDe493NMU83aonvy5NhH3Ykr2Jm+rdrNDa0K3CAbCeLWoUfGo
         PcyRkJkuv56Sgw5w306mDhkabzGFXJU9cFwFPxhAGyH+YX99nuv7YgTPHZPrssJzCF5n
         7Sk6BGXGOYKPB9ZIkfIwNNZer2qQi7V/SznRPjoM1Uj/ZrUedc+xU8laoMjEN+L6+XAv
         YOEQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793109902; x=1793714702; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=W7qpgLW06+QZrv93vDvbBbOUt30oIfC1Mu6jHbXPALI=;
        b=f4CKSjku6gUhocCowGjqd8WSenkgeuJb5RsCcPvqoahEPcMOi8Ba4l72MvO/FVe1oZ
         AAJ+J2pDTco6WxfDjEJW5eGVZgxq0k0JaGF8ku8MuKrvKSEVVIXCfU16ix1Zf/NdyWhO
         8b4dbTsRpXqiILHVmpdb7M3wJLbMZd097wjwzoArfFSPGldtQ3kpM6d6rgLspTXbXPNm
         ufkvzR1c1+ONm1gOcHPQ6sMd+tSLzZ5tGJoCUS77b7vR1PJQSxx7kwoPsyOzJsn2tQBu
         gOMPd2I1m4rnMLlCKgXdqEFXeMcdTxpmxq4FFPJ/r4tBJfl85fxXzCJPZjnX5VJtyBLF
         mc4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793109902; x=1793714702;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=W7qpgLW06+QZrv93vDvbBbOUt30oIfC1Mu6jHbXPALI=;
        b=J/QKbfLl2aE1I2SRsnV6cJL/2ootOTrwbPCu/oWVRTmSPn3NMcepgBNA81NhPy62N2
         OhwIEoLAjqxNqE+DIDPgtVA/mkPIMvV+wkgJCYsF7YwHbdVTW+MnPItdFZXpG2PC821N
         3q9EmvrPdNa8JATn3wg2udQtbXYFqcOyAZQn5IiSfyK59VzNcsIVSggu9LdjkehyMmMz
         BUdmdGMjV7D89aHG2ZQhzOQQQ8zZhy8jOtM0hzgUSq/+g3cTyqmlUmJk4309uIb8NEb/
         tgENJUsFIWk3K83L35JQu2WaGpWxnrmQQL6OUuzNkxK80teoKuRfjQ+TkqXS+2DysOrE
         vIDQ==
X-Forwarded-Encrypted: i=1; AKwUvBzW5IGj4H2kjBK47oe48sGO1jIHe3YexTQ4yKKvIaWPXiHKKHpa0aA7aFdjTCuHPFpbOSCVSfOO0c8=@vger.kernel.org
X-Gm-Message-State: AFq9FYL+5+m4ptaiviHaQB5VI1gO8+p9I9UQAlaZJLlHC2gm7HrI/GU8
	wuLLGw0BS6/HUp3m1kk9NqII2uSsCSjxjxjh/3W/ZAQf5DrWmiBz15MFKrtNAATrXLMJG/vtxZO
	jRcht0x4E8vVR0HyOc3oC62HhHCVdQcCDF1t2
X-Gm-Gg: AYBFou3NKWiwFT4JLGw8wZKvWSVj1TR1oX7mHWsfdc9gl/JSBJi99KEs5mrIXvwLQ7q
	lHJGKA0XzSePJ+ER74VCp7hY0DrZU0WWfBSYzRfBy8KakPLgWqzluOhYTyT32u7qlGYx8bXuXr6
	qtWHMNFvvW6tAZkRTVzvgjm9Br87NxfzXxNLA6E0nw5mcW0ZfY5RyacIFu3bP17cxrZGkiWjo8/
	DxrkUScubP971bmKHWNS2wmnXMoVUbaP2QOvC0H3uRmpeNLwopjpD2/Xvp+kHlULA2gw2clSdnE
	H/3ZdfgYDOuvi+Yz3hm8vdcv21huUTs9MUbl+sXVIg2Z+uwpYdoETGWRQ2sz/Nvv2mPI/sF6Vm6
	amwMMD0ZhqDJ+TffSIvIE/CFHSxpgqozaxgH5
X-Received: by 2002:a05:6102:3309:b0:7ca:e2c1:9a0f with SMTP id
 ada2fe7eead31-7ce5cd20f82mr2802725137.17.1793109901915; Tue, 27 Oct 2026
 07:05:01 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20260802195328.175328-1-f3lix.dev@gmx.de>
In-Reply-To: <20260802195328.175328-1-f3lix.dev@gmx.de>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Tue, 27 Oct 2026 15:04:25 +0100
X-Gm-Features: AclHuK_UpWvnj9vrPaA3gM9vlPqsDL7lIYE2q4KB2vEFQmM7Zny2Xldd1i_stCA
Message-ID: <CALXu0UcEbcHbb4F+pKG1vM5XmgTcuHiLn8Y6y_hQJAYjMdZeMg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.2: request mode after CLONE
To: Felix Hoffmann <f3lix.dev@gmx.de>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Sun, 2 Aug 2026 at 21:58, Felix Hoffmann <f3lix.dev@gmx.de> wrote:
>
> The NFS server can clear setuid and setgid bits when CLONE modifies the
> destination.  The client currently omits mode from the post-operation
> attributes, so the cached mode can retain setid bits after the server has
> removed them.  A local process can then execute the file using those stale
> privilege bits.
>
> Request mode in the CLONE compound's GETATTR.  This lets the ordered
> post-operation update install the server's mode before CLONE returns.
>
> Fixes: e5341f3a5762 ("nfs42: add CLONE proc functions")
> Cc: stable@vger.kernel.org
> Assisted-by: Codex:gpt-5
> Signed-off-by: Felix Hoffmann <f3lix.dev@gmx.de>
> ---
> Tested on x86-64 using an NFSv4.2 loopback mount with Linux NFSD and a
> Btrfs export:
>
>   - before this change, the client retained mode 04775 while the server
>     stored mode 0775, and the privilege transition reproduced in 10/10
>     non-debug runs
>   - with this change, both client and server reported mode 0775 and no
>     privilege transition occurred in 10/10 non-debug runs or 3/3 KASAN
>     runs
>
> The reproducer requires write authorization to the destination; NFSD
> rejected the same operation against a non-writable 04755 file with EACCES.
> A working reproducer is available privately on request.
>
>  fs/nfs/nfs42proc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index ab86246fc364..35a4909d51b7 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -1302,7 +1302,8 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
>                 return -ENOMEM;
>
>         nfs4_bitmask_set(dst_bitmask, server->cache_consistency_bitmask,
> -                        dst_inode, NFS_INO_INVALID_BLOCKS);
> +                        dst_inode,
> +                        NFS_INO_INVALID_BLOCKS | NFS_INO_INVALID_MODE);
>
>         status = nfs4_call_sync(server->client, server, msg,
>                                 &args.seq_args, &res.seq_res, 0);

Felix, did you report this issue to other NFS client implementations,
like FreeBSD or libnfs?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
