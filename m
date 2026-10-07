Received: from mail-oo1-f44.google.com (mail-oo1-f44.google.com [209.85.161.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80C5749A3B7
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 14:30:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791383427; cv=none; b=sO57464dcI5EY6g6CTm7nxgK49T7ftcbi3Fnl+YYqHpRbclhhlCDPg5y8JWf46O0HEqnys6iBNIDRlWIAIGc17F3A64vWn5HDGbnelshbJaegSK9ZO0dS8yrYntcxcVBJiRBRCCQhAdsdJmDSxtfqcKyP3P+DyDX8I50WKwe8UQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791383427; c=relaxed/simple;
	bh=j7fHCKUtZAFtMsUJvIlpfeKa34CQ9vSZ1Qx3b8xDpF4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Pjpigfrh2YUty8aqV6Q1ZBMKyq2JUx0RO5zKNYGmz0R34Gj7MS7seM67MIpWicLffkR+/nzlzXyGV0Yt3XDxy1PR4ac7JR5G67fn6GZM/mMJ4E+eM3b1tTLUdLzXVzE4u1pjb7yjXEvGMQ4ol4QbDcwu1DSTeJl7116zuEZ4ShI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=kDCCeQ8a; arc=none smtp.client-ip=209.85.161.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="kDCCeQ8a"
Received: by mail-oo1-f44.google.com with SMTP id 006d021491bc7-6deb848ddd7so2936367eaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 07:30:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791383421; x=1791988221; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=GqeuWAMdkI6p4xxEB4eWiNajU/+xBbTF6Jz0X/6uAyk=;
        b=kDCCeQ8afVF7Q8oVqhGM72P+9l2sdswIYyka28stw2HFY4AjPg8FLv5ImDXDYQDFrX
         rwuNn5Y/lgbPs8n6gyO7nNuqC4n0lQDutNitzAkJ8kIqxzZYN3DbY//vwCuxEq60Ek7O
         h+ksdLAGbD96cL+SopdQN1WLa76eKDe9xRQYxd4emPwgmWB4Kfs5UjTGgSo/0EiYO/VS
         3Gb5V5To7O2q3X3BVKGFB4r8leHlcZ2Zlz9CnBP6IfVwt68MLypZ7O/sL8RxfD3RSo8U
         rpP56Y0Z9KEqRyxoqwbG0bRTmmZYjf+jU314GNfuoBkyQU9uuM7+yeRwcIG9nklRQl3Y
         iSeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791383421; x=1791988221;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=GqeuWAMdkI6p4xxEB4eWiNajU/+xBbTF6Jz0X/6uAyk=;
        b=oY2+8lqIfV7q62ugL9K1AIWQYwaV/0+u5gl2MF0uZV+CV2gV7yhJcpN2NHGHUDJ0eP
         4g3w9dRBaaL5HifCKddYkdLMAt/SHHFhtgHOspmz/2ai3DxB/aiMtm5KSlIj6C8UssLV
         U9QPJGN9wB1VkM4r4lPTlghU18SXzZ3iWRaCksjRcGRpGZtMfxImgsqNkrbzTDhjf8Eo
         pS7t+PyMcG5jZW8uuZ06GBG+iDNIir8ylSzZq2DRWuFOKASoWu3X6F1wNqIqRAfVInIc
         P2ZLd6xFz44FqDJc9r6NLU6YWM1zuPdJ2nTb4XJ7wqqiCm81iuMm4np4PdRRRA+e4t42
         BwqA==
X-Forwarded-Encrypted: i=1; AKwUvBzlneU8XyxocUIcABD4d3dkipLmjDprY0hNvto/6Ho2wzE0wL5W4BWDZUZ4Gklx3cBKY5AVVTxLwks=@vger.kernel.org
X-Gm-Message-State: AFuF++kJhHTl1oB1iypxsDt/IALHP8OmblWZjjw25Bgzk9094EcpLj08
	H34YW8YuYFQ3TRJGy/eocLDDF29aOb8q/LaR+5JV/x3owJ4hGNF0hMWrQaV516vEbqiNFDynxq9
	HGpz8
X-Gm-Gg: AYBFou3c5s5MJv2dc7Sw1sXo57DlhP5SbQ7ThvmspTdGclKZlu9LGRjHOja06TRxPdd
	xkPYjlFddzrwD5rjpOBESIgi+NobLcbQkeQtPeEmWFtVRoVQLVSKH8uMP4cdOE0ysIIPH1fNTz5
	bsmyVM9xpBqaQfipJBd8MrDPVzhLY4hjbmtbRE2JpYmL0L125hyS2CzNJi1Ab735jx5dO/xK2nw
	g+BNXev/YVkcuw2uTHcBJ8OCELTXAH5CQ74j/7q0t9fZXE0Y3J0vTYPNBvAV66d/7qEAQZfMgCD
	btub7P4CmxROL1GtvaPUN0zWv5PmxDCCfNWHDEVbi+iUIuOTIl5EfMmF4YHoEhc5IjQAoYHBXp/
	tOGHd/WNKFQpowl5eqc75DV6xVbX2iWKuf+7A/WamW+ImiEWXzfNglPpd3NbDgKtmF/LCfgZGKc
	jknVnSjRlLG73tZHiViq7DlyTftmeUAyo06XUljJlaVa8akO/RJB6DPqNcYWLlTXnsD5rWmvwoA
	iEvsLZoDOvpLEJWtA==
X-Received: by 2002:a05:6820:8108:b0:6cd:3ffc:e32d with SMTP id 006d021491bc7-6e7a7b047eamr2282676eaf.75.1791383420930;
        Wed, 07 Oct 2026 07:30:20 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6e79341b8f3sm2189403eaf.5.2026.10.07.07.30.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 07:30:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin
 across clients
Date: Wed, 07 Oct 2026 10:30:19 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <C19236C7-4988-407A-A1AA-B55FB59DFC0E@hammerspace.com>
In-Reply-To: <0d2ca4ec-d7b5-419e-8284-2ed134302f91@app.fastmail.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
 <7840A427-7BD2-4C87-95FC-2E5325130CAB@hammerspace.com>
 <0d2ca4ec-d7b5-419e-8284-2ed134302f91@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 7 Oct 2026, at 10:15, Chuck Lever wrote:

> The extra good numbers redacted for brevity ...
>
> Also, thanks Daire for your user stories, those details are interesting.
>
>
> On Tue, Oct 6, 2026, at 2:07 PM, Benjamin Coddington wrote:
>> On the question in your second mail, an admin setting one table for
>> more than one fairness behavior: the posted kernel keys on source
>> address, so I can emulate "all movers are one class" today by giving
>> the movers one address.
>
> OK, that helps me understand the motivation for your earlier question
> regarding whether I would accept such an approach. You were referring,
> in particular, to the proposal to introduce a new netlink API for
> creating tables that configure server fairness, after Neil, Jeff, and
> I all rejected tuneables in June.
>
> The design requirements have evolved to need some kind of configuration,
> because a single NFS server is frequently deployed in environments
> where several different workloads are active at once. The requirement
> to protect fairness between NFSv3, NFSv4, and presumably LOCALIO
> client workloads makes this challenging.
>
> I'm not terribly excited at adding this configuration to exports.
> Today, netgroups are defined separately, for instance, and exportfs
> is just a consumer of those groups. Making it more like iptables,
> controlled via nfsdctl, resonates with me more.
>
> We also have the problem of using raw IP addresses, which is a)
> not user interface-friendly (hostnames might be nicer); and b)
> not entirely secure.

I've been working through all the various ways I could think of to allow
admins to classify; heres a list with the reasons why I ruled them out
(except for the last):

  - tc / nftables packet marks: tc classes exist only on egress, and the
    only tag that reaches the accepted socket is the mark.  RDMA has
    neither packets nor a socket.

  - Listener or local server address: the client chooses which address it
    mounts, so the client would choose its own class.

  - DSCP / traffic class: on RDMA it's whatever the client declared, and
    the NFS client has no knob to set it.

  - IPv4 route realms: no IPv6 equivalent, and the realm code has seen
    only fixes since 2015.  Clients on the server's own subnet would also
    need tag-only routes.

  - nft sets or ipset as the address table: the kernel API tests a
    packet, not an address, so it would need new netfilter API.

  - /etc/exports and the mountd upcall: export lines get duplicated, which
    is complicated and brittle.  The class is also only known after the
    first request, which needs the transport move.

  - Module parameter: too global, as you said in June.

  - Address-prefix table through nfsd netlink (what I floated on 10-05):
    workable, but it needs a new kernel table and matching code, a new
    netlink interface, and nfs-utils work.

  - Classify-only BPF struct_ops at accept: It runs once per connection on
    the accept path shared by TCP and RDMA, and covers IPv6.  With no
    program loaded, dispatch is unchanged.  The prefix table becomes an LPM
    map the admin updates live, with no new kernel table or netlink.

So I now have a pending RFC v2 which, while complicated, has the distinct
advantage that it has near-zero performance overhead if unconfigured, and
successfully punts the classification problem to a sysadmin that cares.  I
hope to post it today, but it will need review over in bpf@vger as well.

Ben
