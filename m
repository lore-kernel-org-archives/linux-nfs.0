Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792874042;
	b=PuPzNl0GPwrV7DCvy/yXFHKG+JDm7J1xj/Rq+fhzLrzKgF2+83NPegwAC0M2JJUojW02
	 x3VVOW4gwSbh92hvfDP2BJ7gBAdqt9QchFI0Py4HJctpnPU+j/+RUVJTphlw0XrLtuBMG
	 hxYvW4ev0ivTg6fjXpWdvfhj3NA5sFGI6k3NWdwSnouCAfkEPNor/L9nDNDdWqOV3TyaQ
	 26N4GJgNsZuz7JOwY/Dc6NavmKZNr0nJEneRyvcticRjjBHtMVZqwXvGGwxSvtx38dq7l
	 hm2dll7UfwnRgVw5avL/C+K5tEQBCEDtXoXTnkN3t9QK1xkx+7+1dMv2PeWEwuAxxMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792874042;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=O7nLcz1aNrpXPgG2U6sTiNfVNPhilwU8KCVwrhsEzN8=;
	b=wjXP6XNIHfhKQLJHrF7Sb4g8agzTA+pXqOkct/bBjRmjZgG4VEk69w/u84sdBarzgG6P
	 krD+NNzV7mUQPyFbOl5o1F8b/+/gPIqal1uz85MeOXCHzf9J3Xt45rL41Vgu1MWs1Wf6C
	 EErS5YgR1C23/Wh3Tf9CQo3vDWP6UWLE7GIuPKoOJymE/6ZrbeBRQr2b1zvIuvZ/ELJW/
	 C5UCTLX22YdKccq8/jxppiae4/TWKQBf6Km8dxVbjn5o/zrm2uXd+lyCofDZ+zTJFdntZ
	 mQ9bzALNXJ+LEuXZNh2EuQAJ6Y1epbMFgq9mgZPnz6Qjz0xvEypRxjt+tp29M4zu1yA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W42fxIhr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B263E606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 20:34:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W42fxIhr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DC3231F01825;
	Sat, 24 Oct 2026 20:34:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792874041;
	bh=O7nLcz1aNrpXPgG2U6sTiNfVNPhilwU8KCVwrhsEzN8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=W42fxIhr47saKJxDBN33os610d+2MnQ5JSI2dyujkrCTdEawMk7lXyc44u8SklQH+
	 +Tbit8mRRAylqLpSc8jW2LAbpXuaytqIUJzlT2+h0dNUi2ZxBQIiZdlgT9ptcEYhMc
	 SPxDkJDwsGDJiLICTI85ckgblt9K+3MqOge4K5Vwgzhalcbshr0Y4Mo5mRIfekaw+b
	 vGQs5xrSi1d6YzlOAFjNQF3RRqr9Nd5+gi0z9wGM1cqCjhJ5jdot2EUkC2Ectg/VWc
	 ZNLf3SdpltCR3Y5YpjeVOcnNd4G4BnxQHuSWzcNZ13DtK3MSIJElMoDtesgNLMf85M
	 NT1iPGMdYViEQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2195DF40066;
	Sat, 24 Oct 2026 16:34:00 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 24 Oct 2026 16:34:00 -0400
X-ME-Sender: <xms:OBbdasXBEhCYaJDoi2OQ5PyZnpcwt1OPFMvU0k-E7rOw_RXIPJd67A>
    <xme:OBbdarZSPgUiGJlQuli88OHf8tpkGCNi0_4-FjQnEs8uvkh5jcQBZlzeU6jcN2dAM
    Cucnm4lEJ2Ni4HGLyikQ5_xaN2JVIN7PgJlW6k6Se_H7GPQLHqg3Ts>
X-ME-Proxy-Cause: dmFkZTGwYMEl2mCs5p0brRKIzGlpOKhwc72KvvComrstgAtMrp12ajk54Uqe+lvmteVFnf
    34La8X6kvH3cXXDZOOLPfNz9eDYrh/9S5eWAZaKsFWHMiMmQ5qUdRjGg2GXKKkaYwh0IMc
    +ke0nNVyPplZh8Kly+JouQykSlFnMktvutSC5N6iFWKDfCFzeyr4MAlmw8v7vi76jRe103
    D1A9/ntlJvnEtUCsLvjHLuDsUUcx1xKqiMODWBwe5saWkWvHtN83QW4/nfDwzFDqcxV06F
    3+nIz1pM2tcr+PuU8rjsJuu+g4v2KBJasjZPkloN1i4QUtnCn5H3kqf37Ghmd4CwRK/Oam
    POPk5SmDjdb189/NFqCF+teQi0uD4O31YQvhGxTtjeyfUgAbjmJg55223Bc+qlGaVSs0hA
    avFRHFT7RfqKFXPl29hSt76dJexKr1R4xWyprSVBQcj9CManwLfNVLxWgwwTWDu2VzpxTp
    dd0LQ2BNJ4m1mIaj5VVfChducw3tBC04kXDVulBUvSB3OoJk/8gORWOM0r5IQAFAHkCr9M
    C+5pgU5maFnCnaOjlJ5DiUnA4PZdpi/kGshfeDDrPjTM0pEoJRwuKFxCaNcBxKIoxTjHKb
    t+8MpC2M3Lwf9zAYOhjZz5PUmcvmKeJDgoJAXjxW6ozi0VFpZJ7lnOCLSgZw
X-ME-Proxy: <xmx:OBbdakuvXevDTGn70BgYkmc5JtPv7AzrTx1ahJ7K1J8MDYrhjKK9Ww>
    <xmx:OBbdaiJzNJSeXTZyDLmuh6-qoq_rNDWurxlLPnLtiZzP9s2N9CBwqg>
    <xmx:OBbdat9l0iB8d6qkpom6613gf9_M0CU0eoqXwvbn2UkTO5QpR_Sucw>
    <xmx:OBbdarwZ_Z42G_7bQxG-uRygCtil3ktTV6alrYrRTy_alRSVVw7v5w>
    <xmx:OBbdaq44DUxC7Xhdco_RPdtcduM15fsYsUe8gIW74bZrqBHQwBWEQQYt>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id EEDB9782738; Sat, 24 Oct 2026 16:33:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A4vVj0r1ngN7
Date: Sat, 24 Oct 2026 16:33:39 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jorge Mora" <jmora1300@gmail.com>
Cc: linux-nfs@vger.kernel.org, trondmy@kernel.org, anna@kernel.org,
 Rakesh.Bhargava@netapp.com, Mohit.Kumar@netapp.com, mora@netapp.com
Message-Id: <425e2489-72a0-49c6-8a69-21069a878aa4@slotpi15m67>
In-Reply-To: <20261024164633.256458-1-mora@netapp.com>
References: <20261024164633.256458-1-mora@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and transport
 disconnect
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, Oct 24, 2026, at 12:46 PM, Jorge Mora wrote:
> Other consequences of the same race are a use of ep after
> rpcrdma_ep_put() frees it, and rpcrdma_flush_disconnect() dereferencing
> r_xprt->rx_ep after disconnect cleared it.

...

>  - rpcrdma_xprt_disconnect() sets rb_closing after rdma_disconnect(),
>    waits for rb_unmap_users to reach zero after draining the QP and
>    before releasing reps, reqs and MRs, and clears rx_ep and rb_closing
>    under rb_lock before dropping the ep reference.
>  - rpcrdma_flush_disconnect() tolerates a NULL rx_ep.

Let's drop the reorder and the rpcrdma_flush_disconnect() hunk.

The only new reader of rx_ep that runs without the transport send
lock is frwr_unmap_sync(), and rb_closing already gates it. It
returns before touching the ep whenever rb_closing is set, and
rb_closing stays set until the locked section that clears rx_ep. So
keep the ep put where it is today, and clear rx_ep and rb_closing
together under rb_lock after the put. A late frwr_unmap_sync() caller
then bails on rb_closing before it can see a stale pointer.

So the rpcrdma_flush_disconnect() change addresses a problem the
patch itself introduces, not a pre-existing one. Removing both keeps
the fix to just two pieces: claiming a req's MRs under rb_lock, and
waiting for claimants before disconnect releases the MRs and the ep.
The sentence in the patch description about rpcrdma_flush_disconnect()
dereferencing a cleared rx_ep can be removed too.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
