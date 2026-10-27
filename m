Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793108317;
	b=OdctFWER5fB2Uy5kBqAHomxu/fcO9DuF4Wy+IFGT2ohrnzoFtxzgbIOfowpUDG2x2xUl
	 rQEAja+vc6+XpXq8rhje02a2BieTnlhAx6U5YErt6L7qEhldtBqh888tMZru2+zJrZWNH
	 y3vbFzenbjREj3AXRcRwoRZ4BBsSQOjnayGaVuGOijAz3vWwLwCrrFkuTMrwYSTQrY+Ab
	 pwHPkOKnf7TlWNB2zOq+GXz7WjwbpUkA3sI/TbbgHziJYq/1zW9OyDBeHNFNB5nGs7z6J
	 bkTmxWP1sgsAvj2v8YSAu0KBiXx78T57RATLp4JqGfjm+LFR8QS37rw0heGRS9Q29tw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793108317;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=4wgyAUtxoYsHUq2vOhTXGeF7hsURu9DbNvr2JxybX0U=;
	b=SUH3GN5flSfSv2Iht7BhbnzvJdh3qp2EusvcxqjgR9nceExF1Hnhz0ILw3CAivbljX//
	 FK16OEsFvhN1o+v8NhWKO8fAuk5sHduuro7Lj//OHd4e8v5IaumQHqWiMH8AYKgZc9ay+
	 MT3mR6rM8ftC17HlTk7Jdm9qmnEGXVk5gkU63bsuPgfvOTy0IZWhr0JQ5s3eyrOpzm0/Q
	 g7YFHAGpfFVmFeVWVWnCeKYnLeJO2TVRhv6ii46aptP7w4GHGLxs1aX+d61SU2gxccFxk
	 cYEZH6FTnnF5HDbwUeFSy6WbjcN2JM8rfokbpm3Ff0vBESXQKiZ/0S90KHj3eowEjuQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kO0iEAQP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EBF2606A325
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:38:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kO0iEAQP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0E131F01825
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:38:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793108316;
	bh=4wgyAUtxoYsHUq2vOhTXGeF7hsURu9DbNvr2JxybX0U=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=kO0iEAQPsTt/cp1YGtMUaYFz3lLjWMxQuBw4L/9zF67BzrPyDDctfpcvezBpLBbV1
	 bGYa8GZfFYqTR8C6aikcybgnkogcZgWFpNplbI9LJK3y3RGz8pHQhbkgF1mKEsG6q7
	 9Xbj8lVab83zdRvZcLY36+8CKckJuZJFjxWX/ZllRkdUl9fqDU1nR10hfPV3H9Gx/E
	 uLagTX6hHtc7WiM48LETEQVY+Prro4f5bg3ecTcbnkh/cbgJCMgax0cFn725hbPJ5y
	 AYdrm2TsSPw2pFUjV2Yg0IgUNaVkeDGMpHgTCeJ8ioWl0bp3GQmwtzWd4uq3x/7s14
	 avmwaUATXvFXQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0EB37F40066;
	Tue, 27 Oct 2026 09:38:36 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 27 Oct 2026 09:38:36 -0400
X-ME-Sender: <xms:W6ngagsCdM8wggJU5eEqw23mkTSHnR5VimuP5CbvzaKjN3oqkm_Cig>
    <xme:W6ngaoSU7dW4mVPF59dOMvLr1U4beRggSDPvIcAlg8pAN5pw65LruEWurlg9FMAZq
    dDHF91D0I-ODuWxun9o3L65H4eBNzR-5FGRUAor2G79y6DWk0NRPB-K>
X-ME-Proxy-Cause: dmFkZTGZxu4SiG05ueDQEZeu+6fWxwmYtcso3/rWUUsricWFIQPIRp+cXnTf9MUKOQ39eG
    7IRalJBKNW2RcTxBqwgtPhH82bDVZBrEwtsGaJl29X6DsOuB7dee+NnxD2B0/hocz7Zwjf
    LJFO0dauFX3JLKyvo+0ohP3loERyH6y9LxqDOZTN+adCqummkoCeMpDbc99/cU9tRQMNR7
    X7Gm2bd7Lg+V/bK28HsQ3Vjk63oXVi31kCkl3PJ+z2AnZmjtzp69af+70YIIqcZTJYQwP9
    4x1kNSIhYVAUsfSvKmKUmcBJKxHDrEfWqaoJpL4WdSE6rt+mWJqfkt9hOsIMBOHKKcozY/
    7ncGFTJhFOWjm+D4bhvitSTpy3CzoN9UiZ6j1JagrcUPBl2i7wHxY5GtRvl0nET6mGBKJ5
    ++SXBLN6uPWsHN5NiVOxFANpRV7cOBzqJcGBK5TE2BDFS+nBIlALLhrA5PH2smzUsJpzZO
    5G3pQjPXhyVSCmDzq5FXoT85bD9LM2Vj4oOZiNUWY4BboyPIoz/ARqPA6UiqEFsuiUOFcB
    NpNY5b6z1EvfNJQr6lz3SjhqFUVncCn+mbbOAD+W8SbKU30p3jnpkSQKDYSNOeAVJhdZWF
    kXYBc6c3xPzpGO4clYKAoWrBczmrswZIUf0yFFH4okrOdZwvUv6r0OuljoPQ
X-ME-Proxy: <xmx:W6ngavSqpIKKirkF3A-T0g2pu-fWP0AygY50ju8nPJSDOZSxlifyWA>
    <xmx:XKngao8SFoUVv1wzyDKKA7k-KuqVs08b9AeXXdB-T7QLS9dS1001aw>
    <xmx:XKngagYjYSYDDt_GXvYQJqcKNeSUOC8PSL96AHi0xJbCShI1boXXPg>
    <xmx:XKngaprT03yc_kMFvhWAgnKhX3k51q-eB2dukGEBSNlNL2yDSYyulw>
    <xmx:XKngakS4kws4ZvHWWDp_C_A-Rukk3QK3IkB5VyGeM0Ltbmmg76D1ICvP>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D861A78273B; Tue, 27 Oct 2026 09:38:35 -0400 (EDT)
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
X-ThreadId: AhcSeGgFL0jV
Date: Tue, 27 Oct 2026 09:38:15 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tristan Madani" <tristmd@gmail.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 tristan@talencesecurity.com
Message-Id: <cc343ef0-1277-4c57-8db7-bd9d80e1429f@slotpi15m67>
In-Reply-To: <20261026230151.2474608-1-tristan@talencesecurity.com>
References: <20261026230151.2474608-1-tristan@talencesecurity.com>
Subject: Re: [PATCH] nfsd: pin client reference across async copy reaper cleanup
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/26/26 7:01 PM, Tristan Madani wrote:
> nfsd4_async_copy_reaper() detaches completed async copies from the
> client list and later calls cleanup_async_copy(), which eventually
> drops the stid reference via nfs4_put_stid().  That path accesses
> stid->sc_client unconditionally, but the client is not pinned during
> the cleanup phase.

Thanks for the report. The same bug is already fixed here:

  0941ff1cda56 ("nfsd: hold client reference while reaping async copies")
  https://lore.kernel.org/linux-nfs/20260928083050.642664-1-bint4b13@gmail.com/

For future NFSD submissions, please base on the nfsd-testing
branch at

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git

per Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
