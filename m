Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B08AF4FECC4
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 12:51:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791982372; cv=none; b=EYoZDXPPV86kYpjdCTK5Lprdy9PXcVHW9LpaHBOUFy7c1+VfnAh9EB1xbsNDmp1K/V5TXTUThohqujMyG6SLMgo3nti0+anS8w05M8snNyFZrnPOwIirxDHTtyqfoPi9k7m6Y20Nb4iikMyQMCMSNePstBUTv59Dmjw4ufOVkR4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791982372; c=relaxed/simple;
	bh=JHVx4PXMqJYlp8lW2UAdemmaCWI7bWUZI1+Vxrjerj0=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LvCrI9PjRO1svyUJpFh4FapWj4YhUwqUzD0T31CgndEsR5jsS4BEr0R+EetyODP+THIWs9xyBDue5/wJfaQSEEuGpX2fKzuN5Mu0sMBPc+r9vIW+Tk3/eaoBwVGbSDMbAw2eUZCm0oSdT/wFW6Ul1xKbJ68+FPgJ/EROz/0dhtw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=sRcyrkL1; arc=none smtp.client-ip=209.85.128.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sRcyrkL1"
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4a161d9b8c7so28662105e9.3
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 05:51:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791982317; x=1792587117; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=h2lXGRufG/CkzlVDEuwvfDVQ2gYthCpgB+y1GvWyU9A=;
        b=sRcyrkL1QvMCxpmrkoJxmjZrfWjWnmwTp/swz4YF5AxP1FZmlxobb1aVwq2ipFaAAe
         kVbje50RcdNSBXfUzbLDdtMaadvFz/G7KjFSZIOH3jkJR7VLX2aieA56FdJm2yQwGMhF
         5sl04lHWb4Nsh0LTHBmfjklx3grdRew1CVwv8RcsSs9ySYiDzBShO7j+FgMKAPXw6IbD
         oYSXHKv+KNAGpuszTYmtKIID7xdeZ/m6jNhLr5iiSuTU0h6Lc9yes7YgN3cYDMuwZ8xE
         6Q2+O5AER1C+S7NHEADtk5dCySAf1NWqPFsAPCCVQ0g/NjJkd/BvghIEmH92JOHhwHAZ
         +Y+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791982317; x=1792587117;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=h2lXGRufG/CkzlVDEuwvfDVQ2gYthCpgB+y1GvWyU9A=;
        b=vpx6fu4w2rVP5ev1vP41dyaYQ1m7JGO5GBJRL0RZ3o87tJiJ7I74yArPhFeUEHZaMQ
         /gSSAJogckd5aQX+OVamPOngY3LK3LcFs1iPleK1tuQTytyaZkJSHA/dTKgdU3AwPcmQ
         +o2yNqKI67htvoxxXMscH11bvfJeslXOFxEBn9bWhpm70+GDEk8aF4IigvAVa9JnwvSm
         ZeH7mxmdAmUZO2Sp0mpbGpRi6TkqDgyboG8x7n9NKIzkPN3EKdlpFLdFImSDZdTs+p/Q
         ocBfqAOagtIfHEark6vy2fZxm8sBolV2Guk66afWl83A4VOfr0g8Uks4/EV2lMdhUhjb
         qz4g==
X-Forwarded-Encrypted: i=1; AKwUvBxm8WURhMeoI4ObbkCWwYTABBTiZulhYO+EFLiceYm8b213mb6NTqm7pWul/a2u9n+ydLKZ3jHU3Sg=@vger.kernel.org
X-Gm-Message-State: AFq9FYIrh7OQBb30SlJff8qfdbxCsNRWSuKOD9K2vrQ+5vHkl+ORKKfB
	sFIY/M5opdB66J82jHosKw4DkUU0uACsZubFCZCDBo//1cfArBRSKyo7
X-Gm-Gg: AYBFou0S4ETPAwO5cg9vP8COXrRy330cqenyMEMhuyC9xOGMDGEccY1uWFh8SLwLiAm
	8CGs6VhsjlX8YUbr70uwEFYUqxyG98s9JQfy/Ux/IeJJx1pl6o0pIDHmFrKtlw3Kp58CKVG7w3C
	D1Hc74A2DnYZ8nqfsUH0NBa8+GzGwyQ0rZcdJchW2v6lIKr329zWDk0rbT4B7XHRGcZATqq8CTb
	beIs6TceMKFemiMC1e49eB14urIFjeYpo/pDWBkiAspKGwuffmNOSKSBHpcIZEw2nuVp67lFfA/
	SHzNkZID6WbkcEwN+oJX8aMpXddt/PL0e9Z+9SrSy3HYX/+kd6HJHJYTFiqGyT5bl6ydxjjkLAN
	2Qt/fJInvcR5uvsJSW3jcatjDudi/i6HivHZUBF8qPcE6aVi5jonoi6aWxB6d14dD971QyTvnKM
	/rwPAk4xOpSjeglr/V7qbIff0bFGkwKllyL4KyyF+e1QcfZTxDvIl5fALxk/vgUh48HNTt8iEmj
	sfemZQRCKexSBMbi2geb1MhI484syCdM9I=
X-Received: by 2002:a05:600c:3e16:b0:4a1:992f:d0e7 with SMTP id 5b1f17b1804b1-4a1992fd259mr236072475e9.16.1791982316612;
        Wed, 14 Oct 2026 05:51:56 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a18bf35930sm435944885e9.13.2026.10.14.05.51.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Oct 2026 05:51:56 -0700 (PDT)
Date: Wed, 14 Oct 2026 13:51:54 +0100
From: David Laight <david.laight.linux@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Andrew Lunn <andrew+netdev@lunn.ch>, "David S. Miller"
 <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski
 <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman
 <horms@kernel.org>, David Ahern <dsahern@kernel.org>, Ido Schimmel
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
Message-ID: <20261014135154.05de968e@pumpkin>
In-Reply-To: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 13 Oct 2026 18:02:44 +0000
Josef Bacik <josef@toxicpanda.com> wrote:

> Subject: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits() report  unreadable frags
> Date: Tue, 13 Oct 2026 18:02:44 +0000
> 
> skb_copy_and_csum_bits() has no way to fail.  When it reaches
> unreadable frags it zero-fills the rest of the buffer and returns 0,
> and since commit ab9414ed70bd ("net: skbuff: don't leave stale bytes in
> skb_copy_and_csum_bits()") that 0 is the correct checksum for what's in
> the buffer.  Its callers can't tell the copy didn't happen.

Can't you use that fact that the csum function should only return
either 0 or ~0 and use the other value to indicate an error.

ISTR this coming up before with the 'copy_to/from_user_and_csum' code.

David
