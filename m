Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD59055D882
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 16:30:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791995450; cv=none; b=YgfiZsPZ5ZjVtJ3een4CKoQ/3uz2YP6KUnBLYBGTB9tPHKe30FyiW5rjNR4TzE75hxRa7I5y2RppY4IhV4ciDa+hQ6aO2t+H+KRCC9RzhJuyhhKA8hCFhU6tXAq/SxG0JGf3pgPSXS5vu4RZfrHzgLhECy+otBLrywLKEGXc3bE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791995450; c=relaxed/simple;
	bh=BrjkRWhyANEzvU2G8fYFBH01XWMhW7Vpygjf58bbTgA=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=f+lQ/TdexS3qSGkklSt4KI8F0itQ68t1Vp8Gp6eoMSOedav1dwQLbrDdUPkg/FzepB4JUonKU5nT1FJdEzcxjwJlBcXwFyHtqfB1JWGcJZvyOU3KOYnY24i22eWQO8lFPEYPkiIxdtm9lQE1H55UYOYqvLMHn7dGvzrUjYBJ/w0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=I86KcNay; arc=none smtp.client-ip=209.85.128.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I86KcNay"
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-4a1635f7c89so12136235e9.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 09:30:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791995446; x=1792600246; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=jlhZ2D8PVaX0+/HQ1rv8ogSvRZujgAeRl9LWjz1EazE=;
        b=I86KcNayWRCZftozOOWWxK91poIAkB5vFmgIEJV7louwmGtzLv2/UGs6AaJ//tcT2+
         nKCEe/p2aWiFkRTRK6r+W4ppgLnG2mv2LdkDIDnkt1zqUBxiYNtmJl9xzzz3jDkdF5eC
         Esl5dunQWf1ZWJfrOkCG3U35nS7NtZ3IIif5JqK5yhn4/QBmJC6puAsbqJWnnJsOMu77
         Q3Cmo66B4stsYqUmw+GSm6Alc6JjbB6g9Os9db56nlsTu1avF3A87TN5E6SU6ycjX9UY
         rmvHw2YEDL+T4lvUX81U0Sd1sN6XsXpcIMmQWO1aDQq8EbyjcBXabohOqNS82/ZlMdzS
         iHpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791995446; x=1792600246;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=jlhZ2D8PVaX0+/HQ1rv8ogSvRZujgAeRl9LWjz1EazE=;
        b=H8MgA3L/ghRw/1RRICGXoo+lAs21cnYWtTpASgnGg06GW6gQmK2rHGsCPjpHoADuOy
         hRnmqyRSKUErpwwJHEfwNK4r6z+QuY0WEK1/o8LgARAiDYU95sMxIXhqrdYw9kCq1oBP
         GYbbO4Xn4S9vDWoPh3+Rlx9hrdQmvf8ivvHcU9CFZnqAYMmW3aP5tFqmYcxJtJGpYoBP
         zy11GAKlByTfFHEq/cr7JRNMfRdI76BNLYhbaSECiSWiNIOSkPuapd7Dq395prJcXpkv
         yMRGUJ5t3UmQNtvIFKxTiEmnC+OhDJQfBCLbnq8P2SBgjiOd1HAUGN6hZqh1C9A5U4UF
         Uc8A==
X-Forwarded-Encrypted: i=1; AKwUvByiOoIqdz81QpfrKi4TwJyfOLmxbcDs7NnWKLeZd/etFnoxxS3Z3oZUzaoW8WiDvh0G4LFFS9KKLnk=@vger.kernel.org
X-Gm-Message-State: AFq9FYLt+H+mzgk8L5hNvq8RWo9HeGyhwZaGGU7iZLapnrpO5bwJ+oZU
	SXbEQmkK1vk9Ob2a6SAZsWnRTEYqBCz/JCCrV3ozyKf3DVj5Q2Ft+zvt
X-Gm-Gg: AYBFou3DEvJXHedJEGMR/W2TK5Hx2LVaFGvxdmbWJXdyxCaaRJnG5BdHNEqEfSvNMUf
	HQySKaAJmy9NIjzQkjud822yKnaPjSy3ZwHY/Tq6/xNoq2jqDXNM+ceHscCRvZUbmsvs/R0GyzG
	P+RDDYIXkwlDUiNJ29R/aFK52dMC1TBCT09ZKPKGvytzPzJ39pXaoMu9G3K6lrJgBPUBLLApmg9
	koHWLmQGja0Or7CMbwfoyPQQbgzicoNSKyX4FJV+kJy8dtKG8RyI3aPWCC5tFYsiZvLCOt/tyLY
	0kJZa/aZGuEOG7iGzgNMINPmIA3Pk3E/VdufYrAnhkML7Hg2P45YXplZjD4Vhq2aovn4Lsz2BBL
	BR0cS3teLZkC2/uBa5sIJPgBmtu4sVzOZdQInCWkYH6V3yvWxkRlQHcL9DdUAjxF0zEKsYTptaW
	cBZ7qZLkvYSZ+ubvHmXjXSsWQ7EGpVZtH4jw2ZBLMNuxdLr1+Iuek7Zqn8cTir57aNx7kLKCq+2
	I4i8LACaggA3iKknWFMWD8xhV6vOCy+tbQ=
X-Received: by 2002:a05:600c:a00c:b0:49f:fe90:de63 with SMTP id 5b1f17b1804b1-4a18e4e0a3emr341491645e9.28.1791995445684;
        Wed, 14 Oct 2026 09:30:45 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48de0967affsm11644556f8f.1.2026.10.14.09.30.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Oct 2026 09:30:44 -0700 (PDT)
Date: Wed, 14 Oct 2026 17:30:42 +0100
From: David Laight <david.laight.linux@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: "David S. Miller" <davem@davemloft.net>, Eric Dumazet
 <edumazet@kernel.org>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni
 <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, Andrew Lunn
 <andrew+netdev@lunn.ch>, David Ahern <dsahern@kernel.org>, Ido Schimmel
 <idosch@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
 <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, Mina Almasry <almasrymina@google.com>, Kaiyuan Zhang
 <kaiyuanz@google.com>, Willem de Bruijn <willemb@google.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits()
 report unreadable frags
Message-ID: <20261014173042.0a74a25d@pumpkin>
In-Reply-To: <179198668564919.2.10323410751655182155@toxicpanda.com>
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
	<20261014135154.05de968e@pumpkin>
	<179198668564919.2.10323410751655182155@toxicpanda.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 14 Oct 2026 14:04:45 +0000
Josef Bacik <josef@toxicpanda.com> wrote:

> On Wed, Oct 14, 2026 at 01:51:54PM +0100, David Laight wrote:
> > Can't you use that fact that the csum function should only return
> > either 0 or ~0 and use the other value to indicate an error.
> >
> > ISTR this coming up before with the 'copy_to/from_user_and_csum' code.  
> 
> skb_copy_and_csum_bits() returns an unfolded __wsum starting from 0, so
> 0 is a valid result today.  It would work if it started from ~0 the way
> csum_and_copy_from_user() does, since that doesn't change the folded
> result and the sum can never come out as 0.

The result can only be 0 if either the length is zero or all the bytes
are zero.
You can probably prove that is never required.
It is likely better to initialise the csum to either 0xffff or ~0.

IIRC both IPv4 and IPv6 complement the checksum before sending it.
For IPv6 a zero is invalid (it means checksum not calculated for IPv4),
I think the best was to achieve that is to initialise the csum to 1
and then add 1 after inverting it.

> But this is one of those "you have to know the behavior of the function
> to use it properly." Explicit errors are always better, it removes
> ambiguity and creates cleaner and less error prone code. I'm happy to
> change it to start with ~0 as well to add the extra protection, but
> explicit errors are always best. Thanks,

Look at all the places ERR_PTR() gets used.
An in-band error indication gives better code and is probably less buggy!

David

> 
> Josef

