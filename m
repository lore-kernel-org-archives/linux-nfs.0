Received: from mail-pz2-f40.google.com (mail-pz2-f40.google.com [74.125.228.40])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2FD42F8EBB
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 00:37:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.40
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790123876; cv=none; b=feVM3DdUzo3r24J6yLSxWaEf9ZgjnPSYskcar5wvZ95uDT8J/2f6M4Lm/6FaUTKCO1KSxgTex1rZ4U2fGc00Z6ZhDgjO8ZfsD41pW8pFrp80gwIvcJ+qeVlJC1OWlkjCde5n4fitw97OhzaX7l+6F5Z8/BSlefJHo3WmDAFox1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790123876; c=relaxed/simple;
	bh=mLB37Exj08/433G+3BazeafnfFxR6CqGB3+a9cQSS5g=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=YpEwsDphprTdLbrZ1TbVn8iFeMCI2pfyCWecsdBZfNYP7Xa3klr5OFkdQSz2/MEkE59xZhVNJHJ7F0+kj9BX/JunvlN8PB7LcihhGDujqx5rUJIy6XNW9v4byWMxchHtfiulshhoI2iADRXZ5fx8ZjMAYBR22IrXhtUl/XUony4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=kzfhNqVr; arc=none smtp.client-ip=74.125.228.40
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kzfhNqVr"
Received: by mail-pz2-f40.google.com with SMTP id 41be03b00d2f7-cc5121bcf1aso402724a12.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 17:37:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790123874; x=1790728674; darn=vger.kernel.org;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:content-type:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=IwcZc6dV/wJdORGfLDctznTgTbvt9ax2XJYGP2ZitOo=;
        b=kzfhNqVrrobPRdQM8WhVaBsRcdEmk5WmiapAxAXfiiXVwJ8Lt90vavG/0JT3wnIu8Y
         cnEPsMMo0ylXmuyRusSJyEGyaQ0OybkbQpxDjtt4wsEvqS1mnm4RrD5R2v9aUGA6boHL
         Pb5v1haeofXhPZ7svjFUsGLRayw2Jon4UOkzWZI+scCqmQO7+LTxT0Ibh8CdggLTB3jy
         2kLYHg6boHTHMV4ApithnA3o3FGrRwivI/uBr0wPQOm3etzp5QtsUMw9qMSVwVFWZM+3
         dAG+mdQhJM45zRdVqzbJehBwkzHmaTt2OKBgNGVaY8HkRribkZeDEsLvycrVL+ZXlTj8
         amvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790123874; x=1790728674;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:content-type:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IwcZc6dV/wJdORGfLDctznTgTbvt9ax2XJYGP2ZitOo=;
        b=MZUhVQI1m8d9HWxBe89RUiDgfl3NPDUjWflkeghv5cPW2SlX7B2FlT2DQZOIH9aBfa
         Kb/Dw500lWQ8M2+bytt8OKbRldRlHZZh8ucDtqQQPjAetloGcu/WvaKiujRC+kZ0Zl6T
         z+tUIPtr1JKiW+x+FN/uh79kEA4pq8L9Xm2Y78Dv5QAvC40h8EjJlUasdSdjfqyhF8uA
         bdNa3xYWTJ40retF775RShEXnapxQltNwFD2y6dZcoXk9tU70FpEb27k49RRkcMCWHhX
         sJwaXEhXwlS3oaVCh4S/6UOf+ShMwnuhc97yK7Lg224LLbJk5AU/qPQWKHr8Tq2FRbcC
         53gQ==
X-Forwarded-Encrypted: i=1; AKwUvBwLYMrQD3Tjf2/AsefK+bxog16yWQthkpllQJJnsEZ1RDuqwwCeUV3K2ZTix++TYYiH7zZyUCHxPbM=@vger.kernel.org
X-Gm-Message-State: AFuF++ljFcx/pvLoM1SnGgrwukP/qU55tNO20ui/qcHIr2LgVlfICQaW
	4gdplNT/prQ8I/1w6H0idAPTnWkpmu0hXvL2Ca2VfIygNHMqWaqhcthu
X-Gm-Gg: AYBFou2bauxupzFUb8w3kCV5C/GmWQCXROYqtCsE/QoFCD5DTbRRob0GG+ZOJbsAWmc
	FOLndiI3nBXzKeu1W4DZeof5h+O1cbcYu80JxLgBISce71P9FzMkbtex17NkjB9uZvNTLXo7gs/
	5+b8XMT/VJAFIir6cV44bnyj7kHrLBG9NgzgEej0mHOKvtA969EtY3/ziDzMupDObY5CFH5Lz5A
	G3cL6uRVAXvrIfdYXQTS10CbntgZiFkD5dp6uQH9Nk2Xl9NqWgR/sKILqyXngiAC5OTSd8jbf5m
	Mb6JBJzIkBYzp4Mn03d6Errh/fnlqRwgJbaTVklcRWCVOMEZhBbLR3CD6oiiub/hxi9bK/2FRNR
	5h8KuGPl+TQClyVlX/vnd4aIZitmkyf2Fyzm3/tJsvhuOLbXxAgNIVtayR6dQOiRZB3v+e8Si4T
	mXks2wEqI6Gw8Dm0MqDzki6wh90UdyxYushpxC+B35+uP0Ow+wreDLSxqkUk4AeWYVnvOt08Fgp
	fYCP34fGumXjnUxUBPK4KCNOIo4VEQ=
X-Received: by 2002:a05:6a20:748d:b0:3dd:a196:53a2 with SMTP id adf61e73a8af0-3ddf82f113fmr927824637.68.1790123873965;
        Tue, 22 Sep 2026 17:37:53 -0700 (PDT)
Received: from smtpclient.apple ([14.139.251.98])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-87d1cfc0843sm449618b3a.12.2026.09.22.17.37.50
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2026 17:37:53 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.700.51.1.1\))
Subject: Re: [PATCH] nfsd: prevent NFSv4.1 SEQUENCE reply-cache overflow
From: Mayank Jangid <mayank.jangid.moon@gmail.com>
In-Reply-To: <29830200-dcb0-452f-9e19-80a595b46fe7@slotpi15m67>
Date: Wed, 23 Sep 2026 06:07:38 +0530
Cc: jlayton@kernel.org,
 neil@brown.name,
 okorniev@redhat.com,
 Dai.Ngo@oracle.com,
 tom@talpey.com,
 linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 security@kernel.org,
 Kushal Khemka <kushalkhemka559@gmail.com>,
 Kkartik Aggarwal <aggarwalkkartik@gmail.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A0CE2B28-0875-43AE-95A2-18AA7FB758B4@gmail.com>
References: <20260922112608.1256363-1-mayank.jangid.moon@gmail.com>
 <29830200-dcb0-452f-9e19-80a595b46fe7@slotpi15m67>
To: Chuck Lever <cel@kernel.org>
X-Mailer: Apple Mail (2.3864.700.51.1.1)

Hi Chuck,

Thanks for pointing me to J=C3=A9r=C3=A9my's series.

I tested the queued fix against our reproducer, and it resolves the =
issue. I can no longer reproduce the reply buffer overflow with the two =
patches applied.

Please feel free to add:
Tested-by: Mayank Jangid (OpenSec Intelligence) =
mayank.jangid.moon@gmail.com <mailto:mayank.jangid.moon@gmail.com>

Thanks,
Mayank Jangid
OpenSec Intelligence

> On 22 Sep 2026, at 7:36=E2=80=AFPM, Chuck Lever <cel@kernel.org> =
wrote:
>=20
> On 9/22/26 7:26 AM, Mayank Jangid (OpenSec Intelligence) wrote:
>> nfsd4_sequence() narrows the reply buffer to the session =
cached-response
>> limit before accepting the slot sequence ID. A client can negotiate
>> ca_maxresponsesize_cached down to NFSD_MIN_HDR_SEQ_SZ, leaving no =
storage
>> in the slot trailing sl_data[] array.
>=20
> Thanks for the report and the patch. J=C3=A9r=C3=A9my Jean reported =
the same
> issue in August, and a fix for it is already queued in the =
nfsd-testing
> branch:
>=20
>  =
https://lore.kernel.org/linux-nfs/20260817-jean-v1-0-9e356596ab85@kernel.o=
rg/
>=20
> Patch 1/2 there adds the same pre-flight check of the SEQUENCE reply
> size before nfsd4_sequence() narrows the buffer and accepts the slot,
> and patch 2/2 sets op->status when an operation header cannot be
> encoded. Your patch does the same two things, so I won't apply it on
> top of that series.
>=20
> If you can test the queued fix against your reproducer and confirm it
> addresses the overflow you found, a Tested-by: on that thread would be
> welcome.
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

