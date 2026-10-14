Received: from mail-dy1-f174.google.com (mail-dy1-f174.google.com [74.125.82.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6662C5632B7
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 16:52:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.82.174
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791996752; cv=pass; b=Azj6vfvOjL0EDAUS1zY5xdyWhNuXchmMKXTwbqFyr74WipjTCkrT2Ad7P+IrCkSZIdAx+TkL/HhavDPuF5u7ldlOhE7oU3i2JD124a0/cBgHrXKiM1ogsqgNmbm7iZx+zEJfkCLm8Ybydpb2k36HW4jwlxaUnoR6M6D4VYv5iGY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791996752; c=relaxed/simple;
	bh=fQ50eGlFnjMQI2C3GaRdlcFw09nmY23Q11yUL7SlD5I=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=AaAwBXV5/amnnNKHgTsNgUfUhLZMB5xXwY8GxqEXynk4vZSGuZAW2hNfVNeNLwZ8FonNPprSLSWzA5Gf1wASZrOeGHh3izfsiqHLX6pVzUDnWiz42UBDNvgajWIOivtLvd3rChD+BFdk6tESwtUQVbrAGntkmY6L1yjBZXXKnPU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com; spf=pass smtp.mailfrom=toxicpanda.com; dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b=cIqhkAJt; arc=pass smtp.client-ip=74.125.82.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b="cIqhkAJt"
Received: by mail-dy1-f174.google.com with SMTP id 5a478bee46e88-33e6279a1d7so1243450eec.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 09:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791996749; cv=none;
        d=google.com; s=arc-20260327;
        b=e300Oql1t6AcBcJoa8neYSt9aF7T+RGn2rxYw7/BMtQ6RJp0dnPeuaPgtfDkXehm+Y
         pMp8VhA8raRH7cV4DG9QHoHcWsIYopp6/PP36VlaoLhnlTm1qqUFFHvnrcyW662kAeB0
         EPKA0r8E33EP/gcN1AdaHoeWpyT4TdnmaUGRRVaxiq9c7d0SXfIlBgt3HviaINvrjypC
         Wc4n6FYcXjBMiTyTNRhWT7KRUU278dNnc9FHrufqjubOCARx3W/2R5/+KwSbOxxQwQPq
         qhykMfPSIWtXDfQTGt596t7VSMIoYMektAiq6tfErx5xLrBh7OQ+SUnHxOqorksHT3a8
         rxZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=SWLwZ/p70zDk5tHBhgiTHN/1ZMG5p4KgHwoBBSKxoBM=;
        fh=QZcSu2/W7FOBPA3EPjuN4iFC6TKeVixHdBNuZAYSxYI=;
        b=CgS6TLleKA197aPM5oFA1jG2xG8hxZPWTptlFoiJTOMhLxqf+27yrErjvQmhfvxstY
         j0DM78EP5DFmXhc7KXyUM658SXaJhjQ8Ph8/i+rYabj0coyBlz9d7aOBJK6CSxB0LfmR
         4lTj+RYZjy1K2BKdPpXN3n198Fk2qkWZ31NIXNduvpZPM9AO1F+vB2R+1IbcXcZ3b4VN
         ik2vNBLp2NHIQ6zvwVkRcegidMg5wI/55WHygWjb2/IjG+MWN4qI5V1KE7wv5lMUf3Lv
         fFtGYo4wmEi8H8BD/M60bSxI+cLa/Nl19enEeSIW/z3R8JmE9Bk1nGJw4l22G/iGQxtz
         kMYw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda.com; s=google; t=1791996749; x=1792601549; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=SWLwZ/p70zDk5tHBhgiTHN/1ZMG5p4KgHwoBBSKxoBM=;
        b=cIqhkAJtHmT03n2ZEgG8w4wzPyqXgS0tO+5FPE0Ijiuk5wj2XwI84XFWd0i4Vc7TXg
         kFDiRMoW3XYsxxKDS5EjN84s4sc1+2cceZ1KakpWldZFyeRMMfzl/gV6uTka0p/ks7gI
         H2hGLpArpHVzQrPUuBnAPvsjQJOHIS2HgT8d/fqOLKEnaKfYQb6yaQsCEnAERJSdIDqB
         3uTklSzvtA0WwbMzDPeMUTbDt8c7NVVUqdch7WFB+AhRJP0/3pEKvK4dpT/lDM+0bEPA
         zQ6a5NS2siQjSjLHvhxtR1xI24TbhiHMwCI5s05O8LFtnksRrNU7sRcMgCwksiRPLoMV
         KoQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791996749; x=1792601549;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SWLwZ/p70zDk5tHBhgiTHN/1ZMG5p4KgHwoBBSKxoBM=;
        b=qAifAuKU1tiM9x0+A6vGu+34Aa9xWDp9YBHtQD9OPpT3PAn+UDyVeHHgVEfVoARrHR
         vhhO8EuiZ1hivhFl9AeNPQe+aNGPV0uJuJoEkyCN+D8YjQI0zE0bhIvM5NhMrlOfcTux
         L7T9MeyUFaz8RErwoEOeabNF+yz3J8gK18qJzfPksliJiAIi/WZSLz+NOajzDzXU2N58
         CI/xjGR1e8F5Mucw9JQFr/wbLB6qsUaKnhsQzgwU4yiWDFgFUbif1KD2GSHYtwwwpdVf
         FOhQMxtQcBpBu+npzBZJHvz6jijjHY2GeCkj2jgFudKIKc+ba3SDyudlr89CnB5E/Vzg
         sDwA==
X-Forwarded-Encrypted: i=1; AKwUvBwzFgsRu+d8rgp1AJ7Q+H3xtOcv6+NnUvYAlocP3AfqaSdf8adTMmttbenD5UsYQTGdAoQiYefnysQ=@vger.kernel.org
X-Gm-Message-State: AFq9FYIljow7WY5+y65eBn2HdHFjd5fDSASyAhjviQ9agEAyPja7F/K+
	ibSppU/VGEBYLyoQo2sB2jRyO0nxzyWaCWOQrgGo/JRI34N4QtRsIWYGnSQJoUY6tohIf/sPOvT
	ZOdaQ1FmR52y2oYYQv7OR6ye3y/BZIFCCz8/9+gBrCA==
X-Gm-Gg: AYBFou2Gc/LH85Ac2dqJ1vQ/QqzqRLZHV9V42A8hgKMrJIUWLutg911TMjKjzYGtUX7
	wwEvsIyPh8d2kzCH08MSbJ8FZERASPmqGc4Z8rlO10Bj1yFEr3x7pmp6pIX7dqtJQ/URjuytegU
	bFJdwzm6BM0yChbfYCETDwOashrjk9XHbN+nxwE8+chtfDXaNBHnFBDzHlQX0g2gzEzAIVT80lV
	yCGqsgYfX4SiRwwXOVNO9IfXEnzz6FTniggSycHX5lnTmM8oFRi/oZ9HRjk9JP1+OwQ9IC/lU8j
	hXy86KbxyStOVssNZ7/Y7iRfYKB83/tMfep0xPBRUj1vJsSi4vpx+ZELDvRjACBUbaVt5znm9DS
	Kkkqz1yoeGAKDag==
X-Received: by 2002:a05:693c:87c7:20b0:351:516f:7576 with SMTP id
 5a478bee46e88-3537e01e8a0mr23272919eec.10.1791996749365; Wed, 14 Oct 2026
 09:52:29 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
 <20261014135154.05de968e@pumpkin> <179198668564919.2.10323410751655182155@toxicpanda.com>
 <20261014173042.0a74a25d@pumpkin>
In-Reply-To: <20261014173042.0a74a25d@pumpkin>
From: Josef Bacik <josef@toxicpanda.com>
Date: Wed, 14 Oct 2026 12:52:17 -0400
X-Gm-Features: AclHuK-GYay-AQwoTupL5qC9wZ92QZPzmV0dk65w2lPnhQBw10ayUmM8aY0IhLk
Message-ID: <CAEzrpqd9Pna32K8i5Ug3tP+ZiRa7-0GmyX+sn=OwbZ_3osEAsQ@mail.gmail.com>
Subject: Re: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits() report
 unreadable frags
To: David Laight <david.laight.linux@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	Andrew Lunn <andrew+netdev@lunn.ch>, David Ahern <dsahern@kernel.org>, 
	Ido Schimmel <idosch@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Mina Almasry <almasrymina@google.com>, Kaiyuan Zhang <kaiyuanz@google.com>, 
	Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 14, 2026 at 12:30=E2=80=AFPM David Laight
<david.laight.linux@gmail.com> wrote:
>
> On Wed, 14 Oct 2026 14:04:45 +0000
> Josef Bacik <josef@toxicpanda.com> wrote:
>
> > On Wed, Oct 14, 2026 at 01:51:54PM +0100, David Laight wrote:
> > > Can't you use that fact that the csum function should only return
> > > either 0 or ~0 and use the other value to indicate an error.
> > >
> > > ISTR this coming up before with the 'copy_to/from_user_and_csum' code=
.
> >
> > skb_copy_and_csum_bits() returns an unfolded __wsum starting from 0, so
> > 0 is a valid result today.  It would work if it started from ~0 the way
> > csum_and_copy_from_user() does, since that doesn't change the folded
> > result and the sum can never come out as 0.
>
> The result can only be 0 if either the length is zero or all the bytes
> are zero.
> You can probably prove that is never required.
> It is likely better to initialise the csum to either 0xffff or ~0.
>
> IIRC both IPv4 and IPv6 complement the checksum before sending it.
> For IPv6 a zero is invalid (it means checksum not calculated for IPv4),
> I think the best was to achieve that is to initialise the csum to 1
> and then add 1 after inverting it.
>
> > But this is one of those "you have to know the behavior of the function
> > to use it properly." Explicit errors are always better, it removes
> > ambiguity and creates cleaner and less error prone code. I'm happy to
> > change it to start with ~0 as well to add the extra protection, but
> > explicit errors are always best. Thanks,
>
> Look at all the places ERR_PTR() gets used.
> An in-band error indication gives better code and is probably less buggy!
>

...ERR_PTR would be fine too? I'm arguing for explicit return values,
not "0 means failure". But I don't care enough to argue, I'm
respinning. Thanks,

Josef
