Received: from mail-qv1-f42.google.com (mail-qv1-f42.google.com [209.85.219.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9517629B216
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 18:19:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792001969; cv=none; b=EZpjHUNrfI8rXmiXh7aV+buP6wH4WUmx03MT/28v48ZoOJLrw4qo2kPnu7nSd8/WvGPUswfdAfkqxSdUv8ro1p/11BlVraOgB+c8rkmPZ+B0SDFfT6A57Segq9HxrRzMtjfBrbS9Mx9y5FjZ9N9kWl8LkeJmal6R8E6DBeCLacc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792001969; c=relaxed/simple;
	bh=xLy4bwJA3p4oGwSxkOP7algz00ABvvlb2hL7FQ0tbXw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=sEBZ0uZaSVDZLFQCA6NsBV5FD051X9JZenj4E8lptBQpdEZjkBHjcl4lMySK3bA1wtTtYotkjDi47fP3MvC1wqQXeJr9GLpnvLBlDtRhTcB7+9IqkTrWRWb1RwnGyzjFqwAbF6gEisPe85fj4YFKGTesiB0JE8KtQ55w+FAtL40=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com; spf=pass smtp.mailfrom=toxicpanda.com; dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b=mcxCiTw4; arc=none smtp.client-ip=209.85.219.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda.com header.i=@toxicpanda.com header.b="mcxCiTw4"
Received: by mail-qv1-f42.google.com with SMTP id 6a1803df08f44-91b64fb6010so53055616d6.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 11:19:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda.com; s=google; t=1792001967; x=1792606767; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=d7wsO3zLWdRB4GlI02kHERXU64Q1Nav35BL5ro5gRHk=;
        b=mcxCiTw4lZJIh8U/OXoB6J70gl5U4J2msmzGl7f4VpgSa4sFZb2o+FzALZjjUAC0Ng
         Dy8VvO5LTI32n46fuv1RfgQ9Zkv2rv3SFX3o/m9O7OhKnePyftas/KdC7zytsgpJh4xJ
         ci2OI8Gy0Jwz4wExAWokrjz3PXfDwTsHdAEmDHpDBmheddrni//eLjLBHY1lPVDvnh4N
         TtsKzcF/WE7VMKVA7tdwO//4VSaNqC4GTlIl/tjOBX/uOzsTbanWVGX6iSrQ3JZ/0OsZ
         495mYKhcx45g8VLDctwl3rnIkhbi2Qb3JON5fBw9wllPBl2J2XWDlmVaIgMVD1V8KsiP
         YkNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792001967; x=1792606767;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=d7wsO3zLWdRB4GlI02kHERXU64Q1Nav35BL5ro5gRHk=;
        b=tkUIcwFj2BKmEz/Sfw6Ea4C2WUq2sdFCgWL9P54cIFRw93ctgqXcYt5k/vV8HIyO0d
         nY13NKSMxYE6IyPLUHsoVQnAHCBEsw85CfU4gpfZQpAT8a2UNCgH/rn8Tko4JQkXWldX
         LzPrja/s7dhpngcizumpS8XaRa3I9QfXhNt1gz1gjrGWJVBIdFFb+3tUo0QZadhZBLJE
         nT9sg0bAmR8LciItY+34dPcD3u8kMXlKiNoyfntFVyJo4juwPO1sg+vi6qdG/gQkiECT
         oJ/6zkOUAlMfDa0udPx4tk/XiI3D7cpvRDrbwWpcbRn9n3zhTddCwlPs3ASdrofPuIrU
         RPPg==
X-Forwarded-Encrypted: i=1; AKwUvBxbrTtfezRgQKfIlJb/y/OeA1sMSxXQ53m82tXqW6lg9gLnaoHf5p7fMRc1UX9SeEoHEyLwrrzPBwA=@vger.kernel.org
X-Gm-Message-State: AFq9FYItwdLeuGFrd/TKaj3lvFLSFUfa3ZAA/rV0oIjWVgoCwkdhfjdj
	d+b4BvjeGeo0fl1RVq4dzz+2y4K4Ix494OIERYFpvDsr5uYhVRH9O7NahH8akG1cQXU=
X-Gm-Gg: AYBFou2wGPo9UhpLct8lowsPgqYw9hJQJKttyGXxevScPnAlVHqyUC4mJiH3g4V9y7T
	kISYev1wNSWZz+O1jwiEt2J89UxlkrBGk88p36mxNzfpMzwIgGZotYjbvncoYkhvG8+dZFZfzZo
	Pv7oTkfyDL3XDjJm/TcreXET9I0LiYPEbtE1fwH47QEIOxJy31yeJOfoymPtjqtjbjXGKfIec8x
	LtH9iywJp7uoHmJ2IbQKtSPaMXmd3/wkwVKeyYg0rGNdjK6g1wPmpHOMz9Skq3GvbWPmibODt8H
	z3mBpZsG8I2xRZRof8Usrz0wzi1wol9gvs6gVsw2zQeNGt+bsgApPoJ+U38btsb5/4vSwc4ff95
	e/Fro5ZgPB3yaIJj7T+gfetmWHqBgeubOBi9jpzzyhzc/For22X3A34n+2/giRwtU3MYZpHh4vA
	1SPh+UDG/O9vXE9cJGfJsuyBA2ysH26bfHHKZycFlr2fxQaFxgySHPXBw8kKbcJmUCY7j8myTGl
	p7z9zxte32y5yI=
X-Received: by 2002:a05:620a:2728:b0:93d:23d5:32fd with SMTP id af79cd13be357-93ec1499888mr2303090585a.27.1792001967385;
        Wed, 14 Oct 2026 11:19:27 -0700 (PDT)
Received: from toxicpanda.com ([153.61.196.244])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93ef508205csm553393285a.35.2026.10.14.11.19.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Oct 2026 11:19:26 -0700 (PDT)
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
Date: Wed, 14 Oct 2026 18:17:01 +0000
Message-ID: <179200182107330.2.7762063370688204320@toxicpanda.com>
In-Reply-To: <179199883858343.2.17884063473154560573@toxicpanda.com>
References: <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
 <20261014135154.05de968e@pumpkin>
 <179198668564919.2.10323410751655182155@toxicpanda.com>
 <20261014173042.0a74a25d@pumpkin>
 <CAEzrpqd9Pna32K8i5Ug3tP+ZiRa7-0GmyX+sn=OwbZ_3osEAsQ@mail.gmail.com>
 <179199883858343.2.17884063473154560573@toxicpanda.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

On Wed, Oct 14, 2026 at 05:27:18PM +0000, Josef Bacik wrote:
> So 0 can't mean failure here without changing checksums, and v3 will
> keep the explicit error return from v2.

Scratch the v3.  With the code staying the same, all it would add is the
reproduction details from my reply to netdev-bot, and v2 still applies
cleanly to net.  So v2 is the version to take as is.

Thanks,
Josef
