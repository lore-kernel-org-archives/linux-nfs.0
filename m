Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE6DCEEC3
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 00:02:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789516949; cv=none; b=tMlfQlQcC892ljiZxFFlZg1julxyFi3oGwAnECGa9ZtRYrbylTgGtJjoEFU6TG+tPOw8LWqphNGANWGfN4JskVRjiFhq9+X+zlrI1b7c/JkzSfqhXsF8GyRrn7frTVQWpMt0Inex7owlng6zTIrjLRgbxZIRE8bzmQbzBpnR0bI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789516949; c=relaxed/simple;
	bh=EkU+ci8zyBzNMUCzWj0epCOjsYwUIEXt9LM1D33MMkk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=pmUH5V4HdhkUFRPq4QY4ON9K0uuSlnX//M4VV0O4ujJhlirGERY/OFEnj2PY6AwmnwyWcShvFut5EHOXy6/aWgKGYEFv/RW/Y6THfbluMThP2a6KMR/MjV4sOTo/jX2aRs7ebcP+mUKrWe+tPhDPAjp5SmOIh59eRcpPkmnJPCI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J0KQg5c+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J0KQg5c+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E3411F00893;
	Wed, 16 Sep 2026 00:02:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789516948;
	bh=ZaQt56J8NwF6ljF7rHaT6qP5cEIXIwyyCJidmSbBtAM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=J0KQg5c+AgREST6gm0s3ASOowR3di6B74lpIjm8OTUEvnttgZS0LyhiMaiaAxrEI6
	 LpBFR2miUbeAus6pPHocIkxLgcRef61i6n7YOr+Yz6wn692ZCiPKd1PKIjMBqPV1we
	 JbgXqBaBUTFRMZ0f0OSPipPc2NS6IiW5fLbr7AGdSkbPKrdwlIXbQhbbbVpuLJlZ7U
	 ngN8mDlEdLt0mGn+tPGGc9GEwG+bHSi0jaHFQV+2oM7A4xjZGookW0GZILunkAFhLq
	 Xk7eYASKNPQXpt6pHM/OIB1M96jSd0OizB+3aLePyMjofIPmRCaaXxdkT7YEfSEgE4
	 Z+0NUGKdmG6+Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 58A63F40066;
	Tue, 15 Sep 2026 20:02:27 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 15 Sep 2026 20:02:27 -0400
X-ME-Sender: <xms:k9ypahlGwZsOMSjpUVNuCVusVzpBmKF_4tvPkV2DE0oYOi3gfLaq4w>
    <xme:k9ypanoi4B7CAfQU-NsZpaAvFfBlMJJTU7UWpBeXK7jYzOSsUIsgm3FVYMTEKjOdk
    awkCLjOTGj31RWovQZZ9XIS3m-3KKPmUMQHi6ZuiryayONywiTLpeCW>
X-ME-Proxy-Cause: dmFkZTEpDvytN2T29wTM+0Dj9RK9uhaGWqIOIcEtpH3EseJJ0UIZlJIgDptvGehe47Tc7N
    nwANd/MXz3o8eR792OtF9k337iv0MSoKp02LAPS6TPS7xnDLVJID6Lq13o5gXJKGSjuYg2
    ejMvf7wHO5qmg0oaSu+mUC3H65db1h+jogjgH3IPgYiSEfafNv/I2QLIa2WVVQF6THMQzt
    0noyQlm6xFYZ+jQ5AdZxOq+IKr6J/eZLy4OmuGgYEzry1e9RxSE9SY9RrqNxLb2+6PaEat
    FM2CWLSjMHT7Y0RVFwiXQPjql++S2aXzwpf2LWQzDhcCnSLMK2SdFkAylx7pp0t8nzlEIV
    p23r1wMRcCYMKwI1f2nGV0tUwxMPNPWJ3RABxpj1IHzIGLAbEwsNnWEecOewTNeAF5eH2g
    vQE8qP0UWORdANON9CazmwviI3ND8VX7Zjfq0MVkTEIU0jGp4r/N3dBplS3lEi5wCxtsc9
    dAVqAt6jk0gz8lMgo0zaVkaod97LoJxd+05Wc1Ufl+o5YVzQ7O1VPS/0orEOZWosbca9Xg
    PcPKhJZAymHPYAPDxCJW/ulHNd0+A43zNpdm+Nhgb/Wj1QjymuSvv0QkcCz2xOz2mDZ5bu
    i8nMv5v4A8L/JqAclJnT9UYcXNsCxHhRuuW72CeXWPHgG8GQXCvXACsIRnjQ
X-ME-Proxy: <xmx:k9ypan9dYDqQBv1SJNclqz5MTUBNoi2jRsas2Z8_9tSMdh26peEpeQ>
    <xmx:k9ypakZXy1BV5ONdpgR6rgC-7Ggs9GCoZLxYcsreeyYYR1WxjzAy5g>
    <xmx:k9ypajPhOYce-od3P6_JYMFZy32E97SvVdqt3dQQICYtGTke3fA6Ow>
    <xmx:k9ypaoAUSrtO8ALz7valDzeFBksO5u7DO9jK3JFAIw5BmebsbJ2REQ>
    <xmx:k9ypaiIW0KYRHu1B2FeUUEZX_g7NCcdSZ7AGql_eejW8fgdsMenEiMBJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4139D780075; Tue, 15 Sep 2026 20:02:27 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 15 Sep 2026 20:02:07 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <038f948f-64d7-434d-ae51-2e692c3b71b9@slotpi15m67>
In-Reply-To: <178945353329.207413.1555757673936041397@noble.neil.brown.name>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
 <178945353329.207413.1555757673936041397@noble.neil.brown.name>
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 15 Sep 2026, NeilBrown wrote:
> In any case, There is zero chance an NFS server will get a
> retransmission of an NFS request over TCP within 120 seconds unless the
> admin has significantly reduced the timeo / retrans options.
> So maybe there is no point caching these at all???

Agreed that 120 seconds serves nobody on TCP. But the retransmit that
matters arrives on a new connection, after a partition or a client
timeout, and by then the old connection's send buffer is gone. The
DRC is the only mechanism that can handle it.


> Or maybe once we get this more efficient pruning working, we can extend
> the lifetime for cached TCP replies to something potentially useful,
> like 15 minutes.  Or more.

That's the direction I would prefer to take. We spent a lot of effort
on the courteous server so NFSv4 state survives partitions that might
last hours. The DRC should cover the same window for NFSv3, if that is
at all feasible.

With acknowledged entries retired, that costs only the entries whose
reply the peer never acknowledged, which is the set a retransmit can
still hit, and the shrinker still bounds the total. UDP, being
unconnected, would keep the short timer, since nothing else constrains
it.

TLS will need some attention, since a TLS session does not publish
an acknowledged receive position. That will have to be follow-on work.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
