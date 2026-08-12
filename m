Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64F05370AD7
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 06:26:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786515984; cv=pass; b=Q65s+ccgkNSYYmu/oZqim3a7PEiacasNQoqHZsqf6qcwJgEzeXWpEDUYe9U4ObytDBc+DUuPwP9y4Q9u3xsVQShv60BgYT4GLct/TLBKQwb7neXKJ8ZQaaUhrZTPsx9VJCb7P63d4XAvzTGmTT6lmDj+W+JtphvWZwfmkLZp6BE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786515984; c=relaxed/simple;
	bh=Qk+f7qUpisuefi5qZX0Yny7kz4qTIrW8Nup/wNmAHos=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=FZvNqcX6x28IAHq6XP15U3HvrRSJf+2RiWkgZcULF7zKEXT9MaW2NCz2/Lw7bl7TaEcQOezVk/IUFPJgElRFYlkDvJt5K2zvSPOZZkpszCE9ZrLsGKedwj4WcMNro1yJFa3XYQhapXdPXTYmngRu7yXfWWjRGqCKMHnf+hX26IU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nEU40JE5; arc=pass smtp.client-ip=209.85.160.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nEU40JE5"
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-448b69cfc6dso702051fac.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 23:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786515979; cv=none;
        d=google.com; s=arc-20260327;
        b=kb8gDewAQuKtgbOPrBRVGcIn9inTzFAVi6VcmFYudOEYwhD35WdJpCotsoidZuXWys
         0OXc6zvJ1kEVuUX7Q35MgVNOxlvU9K24xhFs56YFDhYg2Ie7zZAdk0uc1qvSzcVFjlK3
         hmaCXrAOXOtvcuERPhC0LfHee2DprfdLSA/4+Ucy4zPOZb4oplVcZ5ilHS4Bc56YHpVl
         DukmyYeh72sRXEphpoPSC8aHzEtxMR9RbybIM/qKzWAty1oFKOl/vqfSTtU2YtMktEJK
         yTXawvHoKUEvlJBUdALnMfJgKtPUhMXqE48PksDk6HODxQwjovJxQzHjkqjU16jIbj/0
         yOEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fFqugCRDKSBfvtZWDMDqD/M/4b3jiz9j7nvBE43yWwc=;
        fh=sNFcx3E5+MHIuF7+QDvApCYG39vFHPuxOJmf4rGcdEE=;
        b=g4O0W5d0Xe1JXPbooog1LKj9GB7oE2KIyEUheVv97BBDpjU5uiJcm8P4+5DT80p666
         sZ84J5+mF1P2S5afDoXovjMHdI2o5HYu9q6Lymv8Mv1y4sc8LCFlEs5pS13Kpot2ec3p
         tseLAI6BoI7sK3VRJSHK18Bw2FbBES3rZkPfrcuLirKx9ZceKdHhKer2ZHGYPjK2YPfh
         Ytkr6MGn+uaseotM5O/8UQ5wn/gcU/+osZwzOJt2L7LXW4IYRSz96X+LrOXanDmF/yv+
         uBsigY2hn8Uj5ynGd6jAtkD2Wxrv/4JgTusF1FDcVOTEolwJitpBAXlCC4EHbfbIAJso
         hnrg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786515979; x=1787120779; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fFqugCRDKSBfvtZWDMDqD/M/4b3jiz9j7nvBE43yWwc=;
        b=nEU40JE52EtkTGFf6QD0Dr4inqAlD/YzDxenFdLN3sDGUpTiLc7iq2LkGMRXlWR1K8
         /uQBM3YcE+yBYrboYFxzbcFFYihGXk9UVG2Eh1wNIW6rwQANK+b3TN8Tys22ObKcwwPP
         OxewT3TlP0ojGBOQlPIHDw/v1VgmArIEMIS0SY6IGNhjSosm4qajFUhHTHVrKISRzIIp
         f+aY0PNiOOs9mjutvs9i2UgwSEaSrhnTgIJqw+DhBDcA+64O2tDMMwuIGqyw4KkTzhYQ
         KxjfkPlSLtVhP47hk99pd21E2RlPDtz0tl+RWrFAERN3+j4XD0kOOvv3ki5uERznrl+t
         w8oQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786515979; x=1787120779;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=fFqugCRDKSBfvtZWDMDqD/M/4b3jiz9j7nvBE43yWwc=;
        b=fSax61G4H4aM+WhQjMapw0FS9re1Rh6ccuGIF4NX//EkTw+aAGv/73ikNlFL7QE8L4
         wrh4KKYLf9eQqTlM3OBvSRYAVfYRfxrNiMkshsdMGWT+r3gIJIR4H+NgDR5PODT2Yh1x
         JCLjirSGcbXE3MxU7W+xjGj2nr/oree1aNO6uJzPd5YBoCP8Sb/vUidEMV4TYbPBMik2
         /uk3uEF1XFlbvtnkgonBhv5vfgCa1pvwmkjIpFI6rYwHHSK0yH77zoZqdDQOIgNebVpT
         cec3aGWwAEKELaL917ma0P0DWdbqjZqeoKuXAUUPLfvHlhH0m6mrIqcGoLuqjDEjvCO3
         BxWQ==
X-Forwarded-Encrypted: i=1; AHgh+Rpw2kUx59vBWnM1U3SiODDvxAOc6mGF5ASzMmI0KM0kXa24dG2zjQBJCGZ4EiUUGVORiDwsGejHA1E=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw90SVEX5bcmu5hKDYQN+I2FzNT7CPggnoXtjHpjYMcF70IHnRE
	9X30sMCWmS1sq4nYV59zgKFfP4Muqfbb/HKkU6QRrNgWqAXWyMRiS5Qfih0xF91H2ZUnbnrsyaU
	rY7t5lw1yL3xH2ismGnVWfyMbpkAXykg=
X-Gm-Gg: AR+sD11kuZ57Ld7yxLUoYHHXjCzOW62+omReeFIBZua+s5+5jkxg0F/+jJGF+F6fZr/
	H6lzMqm7MIlSoGe9g+c4YCPqgEXE51+N3OT2npkrlJy0Hh41rVVB7dENPorChFaGfDkK/yNk6CX
	zhIBm/6H80yHoPIQAGV7Mda1tnHZfOW53+7YhXUBCFYQYKbk5ewmeLlVua+6mDBby5xtq8j65GM
	f+V+zYKBV3WQvud5ARYJsQiVF29RSoGv6hBllJzD6UdE7LDSd3y2Vkc5uIVV4KmbjgqHz8Xpv8R
	yOeJwLv8pr7dDNDjsFvr6yiT/t7lW5AuKNFZRCu5Z/y0bQ==
X-Received: by 2002:a05:6871:2313:b0:451:d946:1dbc with SMTP id
 586e51a60fabf-45e3e71ebc8mr2082014fac.7.1786515979221; Tue, 11 Aug 2026
 23:26:19 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260802195328.175328-1-f3lix.dev@gmx.de>
In-Reply-To: <20260802195328.175328-1-f3lix.dev@gmx.de>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Wed, 12 Aug 2026 08:25:00 +0200
X-Gm-Features: AUfX_mwnAxnwXmyL1JUGoqSQyh0wzY3M8rODdd-LpchdDuzABPnjW8H3WsJT1CM
Message-ID: <CALXu0UehYh4Kdjj3ioTy+c_9C5504ke18RufKZ0r79VfyPAEqw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.2: request mode after CLONE
To: Chuck Lever III <chuck.lever@oracle.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Peng Tao <tao.peng@primarydata.com>, Felix Hoffmann <f3lix.dev@gmx.de>, linux-nfs@vger.kernel.org, 
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

Chuck, what do you think? Does this apply only to NFS CLONE, or to NFS COPY too?

Ced

--
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
