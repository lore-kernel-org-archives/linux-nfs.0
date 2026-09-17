Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97BF94E0B73
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 18:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789671211; cv=none; b=u5OkM6JPqb4jOZSTqpEWS5u3vmp6hPDaeupJrqwsk3M2Y2+QeVuC3TTPcqvhE3Wgk88EsGnASGxHbrTspNRKTa7+IM2kMG0J8QNZ9kcYliAfvcMcdC+wV/nS+GHIZgg+iB+iI0yNPgUb5hO8FbZfRVRXuI5WtPVRPlXkZEkxb+0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789671211; c=relaxed/simple;
	bh=l+9a0Yu3e3A7RCJWRbjWYWfjNvQgggzTHcXCHttqXDk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Ez5isjjr4m+gqPHp/fTicP6wh+RIp2mISlDv9AgNgoNH0yt7u9Vt7p7J8pHglMyzAhMiqDgKl17aPhxDoK4NS/XD3dmy+07oPOHHas43qzhb2euHLCbKB9dTiP7jnRhSVM961FaHx5GfHjsBM07wU69ovrmbfWZgU7ERAHZWibc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mKpg3nwt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mKpg3nwt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 01C651F00898;
	Thu, 17 Sep 2026 18:53:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789671210;
	bh=Lb4kqWeQRdjb4zE8LxwgGJIxhNABEaxfnXr3Nu6Ek1w=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mKpg3nwtfEDSuFz1mD1dFfM3+BcUbAtXtsn8j4iHYD6w2Rzv7SlVpMbhI7ltQIiPh
	 jliJNi5VbFqa5u6yPcHCBpKzhji1mZI/QUR70Nq40Nu47sEM/A3IITgEzoWczyeMZ8
	 2Khtk7T1SOqJfNWJR8iBqMZ5gYwyE+CAnpOcrb8uzgJvzGjRsJrAPva2IeBFqiKXBd
	 G1KXYB9tyB3/+UTJ57b4XeJqwrxcBWetjUi6rfN8sM/vhzJgzcPKKyi9gOK6yze5Wb
	 BbRoKv6xl7gDEs4kEhsM42XNlVXK6zT5TVv4eqP3W0fuTQt+VoR9SwdXrGGn36TtCM
	 rP9qMKN6Ff7jA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B0D46F40066;
	Thu, 17 Sep 2026 14:53:28 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 17 Sep 2026 14:53:28 -0400
X-ME-Sender: <xms:KDesaklddvElvZDBxZRijDCPgAKfOIKp_pP7_UY4W74twLI5CCpjzA>
    <xme:KDesauohEFD_9F4ntKb8fqxmrd7u6siu-on-MZwmAgLKfBUfn85sI2d_wLZCsPXiz
    sG8PNOEJwiONYGlgwF8bQTw-utXKSKoZHi_2v0DIPidF9RMnBMaOji0>
X-ME-Proxy-Cause: dmFkZTFU68yxpAWHjlSNcpsx/sdWPttVe6nqg4sevMl5pQQU/Mmb/uPNOhYdVpUOBugiea
    fPhfm4n+v0lG6GKZPC7j1a83nRqt5oBajknPg6/QVgwafBdE6y7U3uPcfExQ2u2x4bgeUD
    KQfwfUgFgXL2HDr6uX/iLe6fblhVJbjGBZ+vkCkX2LiWJHPD1FHsZ+8D0ob5nAyHdaD5TD
    zZ8YfhuB3mJm/0I5IbAqf2pElAsnsZUn+uAjpo/q9csiTxWCU+XtgB30WgihzDcajiepIq
    XnjvLei7+cKtduraHGezudW/LghupZUt1xwf6tagrrL/0mHacRTKMbYi8EX2zEuD9BFCC4
    ajpqIAiIEXsiClzQ6Uwq++FagVBMzqCOz3SKYc91sSpRcdpKIHqCZqwW0axW0/sMw4Lxzp
    Gs9Sqv7HNTxHm5La38y3Peb60F1YdDpLcpg51T2TpTZ+P3sRwNTpt/o1q6cE2BoUeovNnR
    lhB/VGdE33VNa9ZJuspzkb/mdFKRi1yNTqRdBf+wqqzttXw122DYzNTyPa50OWfX1OHi7S
    PJj58/D6eDKtGlJR4M9M6N8ZZX+ZrPz/TyLoec2SjEAtb/Pm7Pji+GXwvh0NmZfZRXNOtK
    /h+lDE1tvLGdK4BiGT2HVkYQEZHdwvgtMNuotSqYLwVTL8ZSlctUyosONoZQ
X-ME-Proxy: <xmx:KDesahtP8aszEx_VMrRlMyv8XUdyPjrYUn97r765wCZYdwgCxVYRng>
    <xmx:KDesav-GP6ASQ0wfi6jhyhLt6dujYRI6fWSDu-FM_7zw8BFO6Qn02A>
    <xmx:KDesaj1maA43naF6Z12hgkzbgWqw_hN1czn8plTy6EQyQkwbrgj3UQ>
    <xmx:KDesashjI94EV3kBUKgxOuDdeM5h-WBkc-WPQl6iibEjGdptKI0YBQ>
    <xmx:KDesaraqgR-1PlZ7u6ENjGjk9bnxZAd5N2YRJQWTXmVrKLzMmlJG1fMd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 91269780070; Thu, 17 Sep 2026 14:53:28 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AqpWOXCroG7V
Date: Thu, 17 Sep 2026 14:53:02 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Wentao Liang" <vulab@iscas.ac.cn>, Dai.Ngo@oracle.com, akpm@osdl.org,
 chuck.lever@oracle.com, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
 tom@talpey.com, stable@vger.kernel.org
Message-Id: <9cc180f6-f408-42f2-b143-e155df6f542a@slotpi15m67>
In-Reply-To: <f0ce5336a4062ff88775f81ba26726085dcb95a2.camel@kernel.org>
References: <20260917163154.2162438-1-vulab@iscas.ac.cn>
 <f0ce5336a4062ff88775f81ba26726085dcb95a2.camel@kernel.org>
Subject: Re: [PATCH] nfsd: Fix id-to-name cache entry leak in idtoname_parse()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2026-09-17 at 14:10 -0400, Jeff Layton wrote:
> Looks like we have the same bug later if idtoname_update() fails too?

I don't think so: when sunrpc_cache_update() fails to allocate the
replacement entry, it drops the reference on the old entry itself:

	tmp = detail->alloc();
	if (!tmp) {
		cache_put(old, detail);
		return NULL;
	}

So that exit is already balanced.

> +out_put:
> +       cache_put(&res->h, cd);
>  out:

On the update failure path, res is NULL here, and cache_put()
dereferences it. A shared label would need the "if (res)" guard that
expkey_parse() uses.

A shared put label might be a reasonable clean-up, but for a fix
headed to stable, the two-line version Wentao posted looks OK
to me.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
