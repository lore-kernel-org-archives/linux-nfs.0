Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795443551;
	b=4HvmDKi4Ys9CFT7UzvJFvfrpQmnhH5XrUZBsicRvs3MaanIw9ghrMKeHHtbzls/tXICH
	 w892cUvq0dy/usw1yoEuoJaPHG9AgVUvp8XBGhtSXBJ+3tML2ELQ0SmBj2k9FNW9Nt/tU
	 RcnQL3A33dmYDvfsM9Tt6G/ra0MjXbzgU8r6Yjem605s5b1f8ihAG7nWvj70Z2ZtKL1da
	 iyA1pjol5Ujon77Qidj9QSM1dgPjK5zVhZWyKS19GMtb5F8Hcym4r3/JDNHFsqrfknfbc
	 lMpXpkRDpzYCakNq0XkTHfkjrT1SuyDA90gxjJ/uBE5tGVeaelNRF9fiat3AmfZH4lw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443551;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=SGqpzMMXOxhLnysXHPX7ervAuuBOMpPxjnvIFfmSlbo=;
	b=uzh/qut2avCaGySMfX0li76eW5UvnSa7vo2PjMaDB7IqbDfJCAC3Uw03ibk1zJI7YXAK
	 wjWc5G+GgxSiu5TJ/WjFQ+Hg/UR5xuuYaB+OyNa9auqG9ED/ULDZcV3F/M3z2oRB2MvIz
	 ZVRGvBCiBpsG1qY3MbvdXbTSKDWMFkrTIwrTNyvdIEEADFC51rGX+OVGfx14aijhbdx6k
	 EOIx0D0HLT4XIf+kZp19c/UoAzsc66E0NH9zEKbuusEIDVhAuJkQJ0Aw1LNTECSqPIDcI
	 XYxQ9GbHY1VUvHBa33acx84gJg2cEI08698sARhJT7aihpN3hjBpXUrOiWLLwI3Z+TQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="ia/9bOu8";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.43
Received: from mail-ed1-f43.google.com (mail-ed1-f43.google.com [209.85.208.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 924C7606A331
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:19:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 924C7606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ia/9bOu8
Received: by mail-ed1-f43.google.com with SMTP id 4fb4d7f45d1cf-6b7ddb99db4so4332529a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 06:19:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795443550; cv=none;
        d=google.com; s=arc-20260327;
        b=bOTzupl1XgjQvkoFqwaOZqGLdkCjaWv9pkbRRN3IR1LEyvN08zrnNLlVY2gntCn1g5
         BK427guALp9/07apY8XNCmJ1hAgAxGQuyfVzOApdrXkW7JE/hFNq5w28ORunfqSThQto
         zmyFqPZAYK8dYmiCkIREkS1tcA5FjEPd7mRhULPgK6fpBOVJEAO3YySOzcLwT+YtP89+
         pMPaKLe8AHfCdXfbIQ3u46/3S+CGgFcQXDPNphML8z8pfgnYKDUZfeb+uNacLytIUc4I
         CMR59+wbELBcqa0OP066GU5ZctCCf1a0+JG42/JLoi1/NVkRdKXPjXwPNDR3SeJ7h4NX
         hgIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=SGqpzMMXOxhLnysXHPX7ervAuuBOMpPxjnvIFfmSlbo=;
        fh=IwLxXuB1QduS2pKpbDHY/rcdzEo1ZffkgqYAWrpwah8=;
        b=XPx/Fh9Bfm1ROCFol5UfR02/xhBXWip8K8oqCJjKsccIkRyM2DhqPmpY5fIJCV2cAM
         gjwlULNCEF+bf7U6qz3iIO1wBO60a0dgAKv6rGD2oIs0fUWFswBU8q5ycla7cGDNHd+U
         0yA5w8xCvRFNymTQ1WbkI4ofDZeGK2hAngSWZMbBLCjQ3amDmXrkLGi6yO/9k6YKoQ6L
         KkGB4czHA3McgIMEIGm72vzVVwCjLgAj+KvjVqMA5+rsQHAz7PoKfpH5CbGedcQvR8WY
         l2F/s2MD98zM7Y5tEzXC1cEefv7CPeFkwhLUOZtbcAR66tP9XFoPJKiR3LUEdcfpLQIn
         I2dA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795443550; x=1796048350; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=SGqpzMMXOxhLnysXHPX7ervAuuBOMpPxjnvIFfmSlbo=;
        b=ia/9bOu8jSdEcdklu7sre/wKzZoFdki81W2YJr5dws7NTbMa6eVh8vfd8h7EZAJ14D
         zJ0mFNzTG9vSV7EDC7ZzObA4FfyyFHJFmlg2OfQnE1GzlKJYEiaPGS+81TXDzscV3Lmf
         e1X/UPfaxn/OuM29vOeBkbikjniBtlasyUheiBxZBmZndMWZEYV/NoVgu4CKY5knEIJ4
         FHLmL5+7Zqnk0SKhO1f5Rpk1eEaOfaYiP0nRtrE5LwUEhOM5CmVruhmq/q9f3TExFydB
         fjuNhxX5EXWG9T9dmW5z9mMjNIKUvdWzXZN1cU45mM7c3rZLJkxX3+ShE2gwYEV7l3VB
         J4+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795443550; x=1796048350;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SGqpzMMXOxhLnysXHPX7ervAuuBOMpPxjnvIFfmSlbo=;
        b=zPlFwoObrTsf1b9jz17cfJjQGuCMPJHnv8gmzrH6rbyRljg3NW4xd/NkA8SJqPIauS
         tOgZtXEOBLhr8h+vc7XnIzGvvEFy7AIj2cRHw+2FaDkhHWWqS3jxcaXn7kL3pSNsHk9g
         QwMvjTJ76TDP48RxBergIHjj+ohIAVnZcwBjj6y9wJGFQh8HeRQ70+l8Qfktl8EqaIO1
         39VYOKNjdAOvRZtMT005zf99SX5K60IS7bZS+ghiiHLaunviRvReYqv+ZZKPphZgTXEy
         23BSA6+Z9+hqBQ9BnCloaJy3/5RRAqtGLlHCLaMSc04ZS0DhzxEhL4r3+rHH6EMK3EW/
         Ymrg==
X-Forwarded-Encrypted: i=1; AL+hErGW890YN145EYeYRKkOIk0OBh/zIxw2Onkvcr+K/nM1PTJKUiVGMrpitXALGUzbOxvMaiTa0xblih0=@vger.kernel.org
X-Gm-Message-State: APuU4Z/YPb0H21LGuUffcJ/kiDkmK761QJAJyohDWoaxJLPGthQKyIfz
	TbE4vMJQcQqHOwKIuZhPCTbv8QiacfJL0Z+H0z+MEDgF1Z1MppNRTB6jwEqF7/ZEllFqWiI/ztJ
	1cC1t3B9t5ew2L3tA0Jm817Ei/sDIKNw=
X-Gm-Gg: AZFdTZfvIskKufgz8T+25vUw5KBJBLWw8PQao+O786x/mYGo4P71vGcEHa6cJkWRltp
	IDe2bQVIneCoJ3E58FBiIiH4lUnq3HgVCHVC5R006FhjvWmeuJum4FTn0zkWUXJ0fx4Rj8Ys20r
	DH/nKzkLZgD19bFbT/GDwOz41ZM5L1TGE/Lptd4CR9V4hJ9pyNfPFU7icGi/drqvFIXM13pa7il
	bs/q35v1TZtXWHIxWt1Kg6GRaT99GPZw3cGRT+qDs3GuXFDJa4uFhm5umaS1Bn7NqnOKvOaKQLs
	PAAEXR2KJSsiKRTPJh7uEFvNlAfJ+UNPkVsdAMsUcMD2VKtGR2zbnR45VMGprCmLLvrj9QQk4tr
	CXXribOUedSrgEClqF1kvjc1YR3xcbFFX8fkkvSF+DLh3y6IO9go05ZrSEGanJhu4XwVlMg==
X-Received: by 2002:aa7:c61a:0:b0:6b9:86d:bb5e with SMTP id
 4fb4d7f45d1cf-6ba37e91e14mr6755202a12.41.1795443549130; Mon, 23 Nov 2026
 06:19:09 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com> <20261122000856.536902-2-koray.fra@gmail.com>
 <awP8S5KF9v-nqWVY@aalbersh-thinkpadx1carbongen13.rmtcz.csb> <DN2NJH234CC4.2LSWRSOO4TX5I@gmail.com>
In-Reply-To: <DN2NJH234CC4.2LSWRSOO4TX5I@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 15:18:57 +0100
X-Gm-Features: Aa3M54qCw9X0Tb0EaHQOCg1GMA-OBfzeB1bXtwNxs39Fn8cRfeeS4nOAW1KHDXc
Message-ID: <CAOQ4uxiREfVU-WKiUVRZLb-uzMXzDEsmG13FVMW7YBoyq10=Nw@mail.gmail.com>
Subject: Re: [PATCH 1/3] vfs: use goto out on error in vfs_fileattr_set()
To: koraynilay <koray.fra@gmail.com>
Cc: Andrey Albershteyn <aalbersh@kernel.org>, Namjae Jeon <linkinjeon@kernel.org>, 
	Hyunchul Lee <hyc.lee@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Jan Kara <jack@suse.cz>, "Darrick J . Wong" <djwong@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 3:15=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> On Mon Nov 23, 2026 at 9:42 AM CET, Andrey Albershteyn wrote:
> > On 2026-11-22 01:08:54, koraynilay wrote:
> >> Switch from using if (!err) { ... } to the cleaner if (err) goto out;
> >> in the main body of vfs_fileattr_set().
> >>
> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
> >
> > Looks good to me
> > Reviewed-by: Andrey Albershteyn <aalbersh@kernel.org>
>
> Thank you, can I add this tag to the v2 version of this patch (since it
> won't be changed, and link to this thread in the comment section of the
> patch)?

You should always keep RVB when re-posting without meaningful
changes to a patch.

That's how reviewing works.

Thanks,
Amir.
