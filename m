Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795781098;
	b=stLtWPFjy1lIaMEU0UL1R4Cao+vH4czJdBsGWm+91KMPNWryWsVFmXtUs/n1o+Wux2+c
	 ViV55dFK2z5s+IexbvhvklFNAq/j975ZMaUVylSywxo8w2oZdmNZGfQzpFKwDWWVIjVvO
	 zwmPQn2pW6f2ajusgB/HpbEc4b+r8NKGbIyaC28C+PbdzZ6dD/H4sidi6eGF5w2W9izqF
	 Y1yd/cpWJX5SvTAvlb2aiIlFeqqE7WfcXqdu3+8Olv/qHxZ/5Dgebvsjt17Rqx+dW0r2w
	 w8yKgNuZVbdyG8Rtag3Ed1h115ngHKhd6ZBnNtB2nT9PEShorHFnY9KY+WXMuIj21Rg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795781098;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ftbPRsCQ0aqf0DRrrjwD4Al8a/o+mRVmt2zUH0Y6zDA=;
	b=BLGX/Qce9q3Cz79iyQNdHvaCXhfeye8G8G4Qk6zTabgvBnX6xmQzm8cZQ2wn42J4cHfh
	 3hWp1BvhEcpie6PA1YVciKyF0FUlC71a3RcFvQt5FjKZbe9X5sdaAZofhQYBbscHDASRa
	 jxK+D5nj6JzMxtXtORNxvHBzVbXUyDY8dfr+dkRnATDarc6Cv47OVPc1QwBtFEcOJPEh0
	 +06Rfer4wTDhgDG7CM+QmCn1P0lqPUY10yc76dru5AYczUET2ueK67keB2NTLEB7z1IYM
	 t+RISQsvSjC5hzNmDXsGPKugqU0FuwVLmystu5gd/qj748xBMriPPvJLlAjh6Vfiyhw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="a/faIOem";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C149606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 12:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0C149606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=a/faIOem
Received: by mail-ed1-f54.google.com with SMTP id 4fb4d7f45d1cf-6b8a52db5f9so9787033a12.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 04:04:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795781096; cv=none;
        d=google.com; s=arc-20260327;
        b=BjqJLLL+br56WVInD/URAne8E9umoNnyQlldmHD+bNSw5xGlzJ9TQoyqRoA0lzARz5
         j2zYUOrZ5Fr5KsG36lpqsxyiPyxB4ndEM6SBj/hfBrDAIvY93mourXnFBiogfAXos6l2
         S0RCSramoMwPw3f3Q7MgN/ygCItpLRSpuXOygJ10bdusRdchxbUsxwFQu7CaVZ+rWXvs
         VtAiPjlYJRCdMgGQpmsfBS5hNRg3nwXYlXvNQpWP2S9h4CKZeup4eXgJlLJXrX94H64Y
         /bOaDo8lWDC0ol46803HhaFBUkMumsj0ZcHWc3mYfk/gf2YyDIJMYYHhmqouXxPCjwK0
         9ntg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ftbPRsCQ0aqf0DRrrjwD4Al8a/o+mRVmt2zUH0Y6zDA=;
        fh=V+2Jsb8h0zFhmR17oXlYDyF56HuEEj8McEtUv76lWwI=;
        b=KmVMFFDGL3pDBrA2IiJ1xlKMwtNQJ/v3NPw4N/nD4gtODAwOCtHuEAAJlr0JEu4N6T
         7EyMjOMCDTfIzfaT+OUyDp+ZPxrjrSXc2Cianc0cQkoJRWNB9ck16a5+1Ecq1Z0hDS6I
         VH2j5tdKC1V6S5n0PKXUK4E8L1iug9HpdvwKjssnGgyusTrDdnUNXii5SxQPqBfk8oiV
         udAI1fiezzo2BpWAkkNnxjwX/fVo79reeoQOVpk/ysg7iRf+36Zbd3YCbgv51BKqM4Re
         kULEbd8r5UIYAkR0Q60W87gL9rfZVqD4JmMO08tRz0IahU6BBPyjXgg1zFbhAMEzMvtH
         6jrA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795781096; x=1796385896; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ftbPRsCQ0aqf0DRrrjwD4Al8a/o+mRVmt2zUH0Y6zDA=;
        b=a/faIOemKG9XP9oN9nHZ0RXKAJGUuULcrj5tlG5oW/VxoETGk/czdvSllhhNf3cLZ9
         QZfgoKUPAO+lxAeT39SzbkiTrobrvkwTRilpOiRfynBTw3Dq4mQQOsaPpO2q3L/eNCw6
         75tG8Way+N5Y7kNdc374kxwLxPpgXrf4M3aS8Tkoc7ZPyjzg6Rzr+n+Pscq1n8ZXh53X
         8gOnoWD+dlS10yDPmY1W05uiGKpWUmd1Zb6pGB8AYpx6o/RFlMqxj59WZhRkFmmQMlzf
         d6R5FFbL3Np6vQDGcBL5tFUkX4TUGEgF/3bqMPd6LQvhH05HX1jyMVN8C3RNkqypH2BI
         RiQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795781096; x=1796385896;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ftbPRsCQ0aqf0DRrrjwD4Al8a/o+mRVmt2zUH0Y6zDA=;
        b=GW1jmCdzY9sXJxHy023W1s/EpatC9hzMbTyuFk2AT+fIzJpIhiWbfUuwMQR0p0DboE
         345rHd1tHgxDr1OX9jVtYPmp+7lAtoguNIFButuvHim/WoFpJh9nPVbjKkkNKyEvpVTq
         /IOrDplxOPZgLxk2DmZM7GJduG2WyVpo6W9ldKjO8epWfQc1dvcwyYnWVx2mq3NCT+wd
         ocFg6CjuUpUjsQKVbrCW6wxFxY4qIUrrA7md1J4sapwq2W7bTgmAMRTUJL9/PeWvUiI7
         bTSk64MOje8EeD1/XfcLQ3wrKB9dt09ezjihBJRN6j/IgACN1PlZMe9bqBzLrhY5wiky
         kbag==
X-Forwarded-Encrypted: i=1; AL+hErE+EuW6+tE3HIr/154G1Taxl3/5T/q6lKSvV9HGR5mYIGgO3EysymCqmoQ8Wihqz1wnahxq0RyoJfM=@vger.kernel.org
X-Gm-Message-State: APuU4Z9e52BG6REHSUZKGGf4txnQ8+MKqhqkyGKA+9hZrsOqqzhwmeVL
	YWjfSx7BRSbpWF1fNaKHLMSFNlUmxsUb4NPyffu5/T6lcUbNVj2+mMV0hzju3SPXN8TmpO3ySBb
	sGoWWkTzzR/qe7rLe8KAqk0ndeyAKUc4=
X-Gm-Gg: AZFdTZeje7W2nGGL4PBjAJ+Tqe+xRaCMlBDU9+RcN0WoaN/npt/SbKPIU1vZp8Xa7pz
	QS9xJaCpUrH556oz3fxVK/FIulazTvYigDcjRybtWnom+L+aYPSA1smDcMGSoihXSn5wBZX5r2A
	32vJ/8O/3u/3296NP9ZVdWg7FW7bJ9cPIJiROdg+78nWmdTKYUkEYTcreisL+02Gwv1IVJ6aoyT
	uP0Bdele4KIsXbGGcRJERiQ61BxGjmdloqVEnapd7IXRrXwaturWfAfTBO4kXTvhtwUaHay8nSA
	+p8ghpGUbKLJA4LZTG65PKm9eCwr7IGReHo8kw7HvJyNORtqCUHR4gH8/jPJ+MIqPaKySSzyOW7
	AyvKzIlWjKeZulR7s4wsEvcTkopytt1mpqS+4KK6bCZbrTGY6SE7gF7Y=
X-Received: by 2002:a05:6402:320f:b0:6b4:59d0:7294 with SMTP id
 4fb4d7f45d1cf-6ba37e9ec85mr20367582a12.31.1795781096175; Fri, 27 Nov 2026
 04:04:56 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261126163114.403846-1-koray.fra@gmail.com> <20261126163114.403846-5-koray.fra@gmail.com>
In-Reply-To: <20261126163114.403846-5-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 27 Nov 2026 13:04:44 +0100
X-Gm-Features: Aa3M54qEfB_iTiJNZjGRc3XRinkgqc1ntuigIkhA7BS94_VSwwZ4uoMmp26Q3TQ
Message-ID: <CAOQ4uxgJjy3TaORBkMOdef-JvzX2uA5K2sbMDEcLqmpkedsESw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] ntfs: switch to the new xflags fileattr API
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
> Switch ntfs_fileattr_[gs]et() from the legacy FS_*_FL flags to the
> modern xflags (FS_XFLAG_*) fileattr API with masks.
>

This is where the commit ends doing what its subject is saying.

> Introduce FS_XFLAG_COMPR and FS_XFLAG_ENCRYPT to be used in this API
> upgrade.
>
> Following the FS_XFLAG_VERITY example, put FS_XFLAG_ENCRYPT in
> FS_XFLAG_RDONLY_MASK and in FS_XFLAG_COMMON, since it's read-only for
> all filesystems.
>
> Following the FS_XFLAG_CASEFOLD example, put FS_XFLAG_COMPR in
> FS_XFLAG_RDONLY_MASK but not in FS_XFLAG_COMMON, since it's read-write
> for some filesystems and read-only for others, to avoid breaking
> existing filesystems.
>
> Also update vfs fileattr_fill_* helpers to include these two flags as
> well.

All of those non trivial bits deserve a patch of their own.

Not only are they independent vfs changes, but they also have
implications outside
of ntfs which need to be spelled out.

With current patches, I think this change now advertizes COMPR|ENCRYPT
in fxs_xflags for all filesystems that have them set even with the old VER0=
 API.
That may be ok, but it needs to be spelled out.

Do we also allow to set COMPR via VER0 API? Do we want to?
These are questions to be asked on a standalone patch.

Thanks,
Amir.
