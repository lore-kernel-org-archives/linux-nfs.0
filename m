Received: from mail-qk1-f170.google.com (mail-qk1-f170.google.com [209.85.222.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CA5F53A8B2
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 17:53:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792000383; cv=none; b=uDMQempmtGeJ+abbXI7hy1QZ/CAbYgseO110NBb33C5cA1trJbKlcDs9FiBW5f1IBstQ2cdb0WfUxqClJUdwjcW/avitkMSfirOBhdaF7jl6XuoplmORPRQeNdmDzQ3adZm+CJcrR+5AZ3boVh4vmaMPQCk2h9eKAVbBsrCX8NQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792000383; c=relaxed/simple;
	bh=+xRfdEstPEoB/0nLtXWtVVOiZOJPtIXTR+WV6k2Yt1g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Oom4A+MxKTX/EoP81jrm3s4sQQ0EZdTJ3FqlOmRk0iTbZKteej5I6W2DIYrf+eleSb7fv7XmW0Kys+E9aC3nzYARIewEyObYHaS/AKU8j4OuTy+hFJljMd9HvaYea+XdmNVuDCby/iPMvfRC/6MTQi+nSp8W1ES6r671dhnVNLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com; spf=pass smtp.mailfrom=toxicpanda.com; dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b=IHdhk+8T; arc=none smtp.client-ip=209.85.222.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b="IHdhk+8T"
Received: by mail-qk1-f170.google.com with SMTP id af79cd13be357-93ef9803765so237592185a.2
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 10:53:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda.com; s=google; t=1792000381; x=1792605181; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zsq92fxVdxK45zQgeZwO9L+7uNriDQM/IAKXxnDi/WI=;
        b=IHdhk+8TbZ9+MHOja1L3hCQI5WRVs8ODzT+XBsVN9WxfTbjQjv6YviNSZuKqOunIGh
         b8550FvIYq2uokyw0bE+b7UM2gbjiwN3Zu9N4Em4VUZVwIBOYsr7+NKj4ja5KJTd/aZW
         gajfntqizqiRuWOw4AB56z7IlQg6IXBIHUplTjUu4NiGXuxmm4cOIpKmdHS0ZIJBqTYz
         a0iYz22yw3JmaP2GXxtveI46YtDHYsK/VNZWDLd6Pz9VSj6rH8kCuS+aM8ywi4CeDs0C
         Z1uqImcdTHDtAr/vLEqE64o0Y74XQlHATveWFoecArb+zLr9KVIezzhleSXxEff7iSf8
         nwaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792000381; x=1792605181;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zsq92fxVdxK45zQgeZwO9L+7uNriDQM/IAKXxnDi/WI=;
        b=FgLyKiSSBDDWnBKhX6ROLboBtiIQwQkPvre9Tb1qT4Kyy0Ua5PgWdkzP0LR601Jybw
         HQPHV7SkVzSe45oh9FrFcdlHARRvmKkVUhoDNYgKxcIYA8Nwsh3HyzfGKbg2Fq1G0g6/
         KKhCaUWYSRUQ/XNH1XSl25pNNq7c/BkkFmFPzkvivN/vMC2z2M/Kjqg5vUWYUihBGkOc
         loEL9ITKjiUT4SOZRD+w6AY8Tm78IM3zSAIi2CiZuTsJhx2cA10D+zSlcH1sen6wgazW
         1/mDVa46kPHvdFWGbzwsWjElx5AaAA288QbOzJCWdPC/3gFeXcTfRGFlfhka9GWMdsgr
         VGeg==
X-Forwarded-Encrypted: i=1; AKwUvBzXii0Dh02ebcIWY4hAll8Hd5X1SHVHio4nc8VQgUq7Vq5bWaWGClBE3WUtZUY8VVmQ8Ur90xTP4XQ=@vger.kernel.org
X-Gm-Message-State: AFq9FYKLa+mDt1vMGEcfobeAoe9oyoBeATWrhwq6YzrsAzaa/ujt3Gg3
	LZShRdMaVgHztLs3av/vcicl/RkUAaPkaNP71oX45/SkGm5Ca0io5yESk3RRUz7Lhmg=
X-Gm-Gg: AYBFou0CSDLTn71DjCcmNpiz/OJ9YFx7rAQoN2+ALm6gUGULZ3nzO9nmpad5ZzYOG+b
	AaF7inmfhOzgTdGY2FyAKx8X4C6+ebgvzoqO5hrgsQ6K9s92GcmAUQB9U3ZDHMARJ3BU2ZAeytI
	vhXKlqBynj1mnlzznPvjUdqroOLFM3BhW1spNpkWqUGTGgz1o/s8q4KAZusnsjXbb4pi1ZQaMRf
	BQbjTqhe02zLnLOFJlJvtl6vyQeIZw+psvfSEKvDyXLo5IayPFhzyTl1YQC0aMpZiQ4324C5RcP
	9TxCxGZYvH1h+B8GIOaUS+r3cziV86r6w0/UTlcZTSr7o1ua8jR9ZMeAq5IIcXmtuQSpiWSyC4L
	gg6AvxThDNttg7d5q4CgHTses9w/aCdbXebH1WdCOravpwLdReghujIK2y/LjCniFqtQOwVYn+G
	0Zje3SQczVhFzc4Ai0tS4Fo6Uyry2IJk5fVuUFal+5U8BJyCkKJRnoRvufdOjiNmJFHJR/Un+3f
	1TjS4qW9/U1i6pN
X-Received: by 2002:a05:620a:17a0:b0:93e:c12c:f13b with SMTP id af79cd13be357-93ec12d085amr2683326985a.69.1792000381143;
        Wed, 14 Oct 2026 10:53:01 -0700 (PDT)
Received: from toxicpanda.com ([153.61.196.254])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91b97b387e0sm58301296d6.12.2026.10.14.10.53.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Oct 2026 10:53:00 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
To: David Laight <david.laight.linux@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@kernel.org>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, Andrew Lunn <andrew+netdev@lunn.ch>,
 David Ahern <dsahern@kernel.org>, Ido Schimmel <idosch@nvidia.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Mina Almasry <almasrymina@google.com>, Kaiyuan Zhang <kaiyuanz@google.com>,
 Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 stable@vger.kernel.org
Subject: Re: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits() report
 unreadable frags
Date: Wed, 14 Oct 2026 17:27:18 +0000
Message-ID: <179199883858343.2.17884063473154560573@toxicpanda.com>
In-Reply-To: <CAEzrpqd9Pna32K8i5Ug3tP+ZiRa7-0GmyX+sn=OwbZ_3osEAsQ@mail.gmail.com>
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
 <20261014135154.05de968e@pumpkin>
 <179198668564919.2.10323410751655182155@toxicpanda.com>
 <20261014173042.0a74a25d@pumpkin>
 <CAEzrpqd9Pna32K8i5Ug3tP+ZiRa7-0GmyX+sn=OwbZ_3osEAsQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

On Wed, Oct 14, 2026 at 12:52 PM Josef Bacik <josef@toxicpanda.com> wrote:
> ...ERR_PTR would be fine too? I'm arguing for explicit return values,
> not "0 means failure". But I don't care enough to argue, I'm
> respinning. Thanks,

I respun it with the sum starting from ~0, and it changes what goes on
the wire, so I was wrong above about ~0 not changing the folded result.

csum_add(~0, 0) stays ~0, and csum_fold(~0) is 0x0000 where
csum_fold(0) is 0xffff.  No other 32 bit value folds to 0xffff, so
there's no non-zero value that can stand in for a zero sum.  ICMPv4
folds the raw sum with no pseudo-header, so an echo request with id 0,
seq 0 and an all-zero payload gets a reply with a checksum of 0x0000
instead of 0xffff, and the sender drops it.  I checked that on
loopback: the reply has 0xffff with v2 and 0x0000 with the ~0 seed.

So 0 can't mean failure here without changing checksums, and v3 will
keep the explicit error return from v2.

Thanks,
Josef
