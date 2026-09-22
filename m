Received: from fout-a5-smtp.messagingengine.com (fout-a5-smtp.messagingengine.com [103.168.172.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDA42481238
	for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 06:55:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790060123; cv=none; b=dleZvSezCGMnrgVSOAGvGjw2XDnbgQ4AzSQbUqGxNJ4shg1FHaDiuDvwu9P6oIO9eBz8zbV78DAdfjp8/TdCtCQbqIFwe3C4jibSOM+Sj7NRczABw89RR4CZ32iL7yCCdd/+ePGvv5vYM4jTDDvrNJRseySqzOrGUVMNOqHgQkc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790060123; c=relaxed/simple;
	bh=OcmGMyu/7xdr5fEkRpcp3RLPsoJSJw+OysBWNM4uIoI=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=KhER5Z+FjqmkRvWB1E0IXt62c0iinT5b6g4edOQ/0mGWvvl+GR9V0rzTK9y5yBEvStk8yyRx4vGhFi6Wf5IaKnJfxmh7h9t4TX+BIfCngRVUs+PFgcdLQGw8LGRyRWzOgjrGE/D8dtdpSeYBSz90r30AZmLNA6XVUB12fOHr6is=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bu1bmJ/4; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=A1vSoP04; arc=none smtp.client-ip=103.168.172.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bu1bmJ/4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="A1vSoP04"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 1853CEC0181;
	Tue, 22 Sep 2026 02:55:15 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Tue, 22 Sep 2026 02:55:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790060115; x=1790146515; bh=hPdoJ0br1yr8XeH5cwuWwDKHaEgxnk7Hcwn
	vbf8dFfE=; b=bu1bmJ/4UoeKB/yROHyQoYTZKzSmND8ByMi+/cCo1hbW8JDMUEH
	Qo2rM/mFHv2oiGUs6z22gsXWNBZAGRsOSOrQ4vaD9oKZebRxnKkizEvA+hz2Gq25
	fhIJaq1pMRik9Kz8ipo+ujT937lTnOxvt1ZS2/qKe5Yr/qTtFjFc4yKiOHMgsazN
	Cu6huTrZdKU/cbgWdZAfjY0SgvKjknhXRE2nStPocgbIft1yReUs+Q5Zv0aUTleB
	aWJlwJfZ2bgqRZIpf1KAmUOuy2OSVwXRpl0kix+DjyBmqiQ7qCmZDy9oAM+wAcPH
	JCaMz3P6YNPmmJskRqq+KEjjXKBof0ZtcxQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790060115; x=
	1790146515; bh=hPdoJ0br1yr8XeH5cwuWwDKHaEgxnk7Hcwnvbf8dFfE=; b=A
	1vSoP04YJndbnlfGvGqmTJCkFzglc3YYMFZCLh0kgpwqFZv03zl4X8o9/ot+b3ZK
	TQeAyW8GBi1L1GH5i5fFiUlhL2O650X9udJ2els5bo5pLl2vNTDcdqFKr8c/YUN0
	yjRr3DkAspKdN7AxXuZax3/ND+uP4IwqnxkNSCFJ62ftS/99ta454xo26BTCV6YX
	VLLfXHULZ6i8C8p75BXt1C2wdn2XYV9BI5Is0Z08XwtUxqsiqI0+ymAo10JRAu7u
	oR4XH4uGIUH8LYAlt5nZEFkUU7mSjmzUNQHSIMW9sb+Oao3HLsM5UwJXADJO6Z2l
	1cFDcR+XMmlEZ55bLpaQg==
X-ME-Sender: <xms:UiayaruyuKT1R-uJwCNdWbInrgtTm7ERdkDmNXK15ZnU6haVGXNTgg>
    <xme:UiayausfagAQ6izU9m8SzrO554OhmfZOM1OfE1pzWhfONhx5SRbq1aQBu1RsAHN3g
    q_63Jlt25GqODL2DhZAINd--ATFF_Jwaj5ZDDTob4Ftym9lWA>
X-ME-Received: <xmr:UiayahCVxKd0Z_gXEosaTa3GqZhzorZ0kpowq1vRePs6m2D9R7HVLkewu5nXWFtYWPFoSlPwqjeyC5yKrL2xwtoFJ3RpgiM>
X-ME-Proxy-Cause: dmFkZTF3EUutTaGhfEtD1/7WtJcHwlZCtnsQDhe3roPMKWG1x29AlWrpJT06z1QNu4T2NG
    BvbCq0K/fFhhWfZ7riVCs2OKsb++MWYzH5bgSAEBQ17yK3Z0nYvaHX0VjPcxs5ViP/GnS9
    TM0x3STwiY3HaasL8xX+JBE0jGb2weOZLIU74QAKLlTDoO9Zij1fp4yTALFZajFdLXfiIu
    KIFDNoxU+VxByCT+voVw3d+aBRU8mazfaHKnPf/3DizuoKSI9EwD2txQzQfJd2XXiLLWHE
    c/rZNIvcMVgbzDi2eVcfDkFPGw6HJSrCcv6BG7NIP8DBuRPag4YnrxGPUYhmVh3zHJREEr
    rV9zMOG68M+JKIcRGQwcthSldaTost7Fq7aSr3A2Z1wFki5oUug5QXPxGI/4EQAuLHSMGP
    mCdeCSNTnU0yEcSyJjAxvRTnbG+cgch7fgpmfHSmjW5kDVq+nZg2wzXZ6Wh7rVqnPOGDU/
    GUzsXEeYRiUFzxg+snKms2lMvyZITmJQEAJ3UzVtG38R6Hv5ZjEOD039/HxwXua/qV1OwD
    Mm66W1DR8i6MrctLplS0TOYmR5xQ3Xy7OHX8ifxUcXw6USFQ9DbB6gVbf6qCuzIi81/fWB
    xwjMRsrDww3ECtWHFjT8O/C25kM9ptT+BnMC9g2t+5vLHUyOvq+37oE+UrlA
X-ME-Proxy: <xmx:UiayagNGD-awQ_3Ql6M8Xf7c3FoI77e9hsgllpUfynEmgDzY5VQDow>
    <xmx:UiayaqxV4Bnl99USTwfsMLkWgBftDJFHRumUYWCemFppWhoom8VOlw>
    <xmx:UiayagViWgZs0XVlKJ0Sf4eFEIepDQD42XFHW-gFgiai1SZqfLkSBA>
    <xmx:UiayasOVAg9OgdHmnkz1ALPfEJUtL1rcOPkNb_BkllU8TRWfGVuS1Q>
    <xmx:Uyayat4UIYOmlyiVOa_uYjyvh_yKXq8rnsD9Yo8jUHGWi-L2fFdA-LLb>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 02:55:12 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org, "Chuck Lever" <cel@kernel.org>
Subject: Re: [PATCH v6 00/12] Improve the scalability of NFSD's classic DRC
In-reply-to: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
Date: Tue, 22 Sep 2026 16:55:10 +1000
Message-id: <179006011019.37859.3256483489236921115@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 21 Sep 2026, Chuck Lever wrote:
> On a server with more than 64 GB of low memory, the cap, and not
> RC_EXPIRE, governs retention of DRC entries, so entries are evicted
> before a retransmit can hit them. RC_EXPIRE is 120 seconds, shorter
> than the default retransmit timeout for connected transport. This
> means entries are frequently dropped from the DRC before a client
> might retransmit.
>=20
> After this series, the DRC retires an entry once the server transport
> has seen the client peer acknowledge its reply.
>=20
> Each network connection publishes two positions: the reply it has
> just sent and the point up to which the peer has acknowledged, and
> the DRC compares only the two. Nothing else about transport state is
> exposed to fs/nfsd. UDP entries and replies sent over a TLS session
> keep the current time-based eviction.
>=20
> RC_EXPIRE itself is unchanged for every transport. A longer lifetime
> for connected transports is follow-on work.
>=20
> The hash bucket walk still stops at the first entry that has neither
> expired nor been acknowledged, so an acknowledged entry behind one
> from another transport stays until it expires.
>=20
> ---
> Changes in v6:
> - Make the DRC size limit independent of page size (Neil)
> - Drop same-connection retransmits (Neil)
> - Link to v5: https://patch.msgid.link/20260918-duplicate-reply-cache-v5-0-=
b6aba9ebf2f4@kernel.org
>=20
> Changes in v5:
> - Actually make xpt_id 64 bits wide (per Neil's review).
> - Move the DRC cap removal first (per Neil's review).
> - Rewrite the cap removal's description to stand on its own.
> - Drop the 4x visit bound from the prune walk (per Neil's review).
> - Evict acknowledged entries only where the prune walk reaches them.
> - Restore the shrinker's unlimited per-bucket scan.
> - Link to v4: https://patch.msgid.link/20260914-duplicate-reply-cache-v4-0-=
bcf9d2628a94@kernel.org
>=20
> Changes in v4:
> - Track reply positions instead of ack cookies (per Neil's review).
> - Make xpt_id a 64-bit counter and drop the xarray (per Neil's review).
> - Drop implied ACK and the last-request timestamp (per Neil's review).
> - Keep an unsent reply until RC_EXPIRE (per Neil's review).
> - Pin a DRC entry against eviction until its reply has been sent.
> - svcrdma: Serialize Send posting so positions match completion order.
> - Drop the nfsd_drc_reply_acked tracepoint.
> - Link to v3: https://patch.msgid.link/20260910-duplicate-reply-cache-v3-0-=
31532a4c7449@kernel.org
>=20
> Changes in v3:
> - Add the reply-acknowledged callback and its TCP and RDMA reporters
>   ahead of implied ACK, which now defers to a pending report.
> - Split the prune-loop restructure into its own patch.
> - Move the eviction tracepoints ahead of the ack patches; the
>   implied-ACK event now lands with implied ACK.
> - Keep err local to the pmap_register block in svc_setup_socket()
>   (per Jeff's review).
> - Never move xpt_last_recv backwards when nfsd threads race.
> - Fold the XPT_ORDERED patch into its consumer (per Jeff's review).
> - State the re-execution exposure of implied-ACK eviction instead of
>   calling the DRC advisory (per Jeff's review).
> - New patch: remove the DRC request checksum and payload_misses stat.
> - New patch: remove the 256k-entry cap on the DRC size.
> - Link to v2: https://patch.msgid.link/20260828-duplicate-reply-cache-v2-0-=
25069e660a7b@kernel.org
>=20
> Changes in v2:
> - Print the DRC eviction tracepoints' age field as unsigned.
> - Link to v1: https://patch.msgid.link/20260826-duplicate-reply-cache-v1-0-=
b1d51e1af5c7@kernel.org
>=20
> ---
> Chuck Lever (12):
>       NFSD: Make the DRC size limit independent of page size
>       NFSD: Remove hard cap on duplicate reply cache size
>       SUNRPC: Assign a unique identifier to each svc_xprt
>       NFSD: Track transport in DRC entries
>       NFSD: Prepare bucket pruning for additional eviction reasons
>       NFSD: Add tracepoints for DRC entry eviction
>       NFSD: Record DRC population in lookup tracepoints
>       SUNRPC: Publish reply positions for upper-layer consumers
>       SUNRPC: Publish TCP reply positions
>       svcrdma: Publish RDMA reply positions
>       NFSD: Evict acknowledged DRC entries
>       NFSD: Remove DRC checksum and payload_misses stat
>=20
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
>  fs/nfsd/cache.h                                    |  16 +-
>  fs/nfsd/netns.h                                    |   2 -
>  fs/nfsd/nfscache.c                                 | 206 +++++++++++------=
----
>  fs/nfsd/nfsd.h                                     |   3 +
>  fs/nfsd/nfssvc.c                                   |  11 +-
>  fs/nfsd/stats.h                                    |   5 -
>  fs/nfsd/trace.h                                    |  47 +++--
>  include/linux/sunrpc/svc.h                         |  16 ++
>  include/linux/sunrpc/svc_rdma.h                    |   5 +-
>  include/linux/sunrpc/svc_xprt.h                    |   3 +
>  include/linux/sunrpc/svcsock.h                     |   3 +
>  include/trace/events/sunrpc.h                      |   8 +-
>  net/sunrpc/svc.c                                   |   3 +
>  net/sunrpc/svc_xprt.c                              |  19 +-
>  net/sunrpc/svcsock.c                               |  29 +++
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |   2 +-
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  27 ++-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c           |   1 +
>  19 files changed, 263 insertions(+), 154 deletions(-)
> ---
> base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
> change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c
>=20
> Best regards,
> -- =20
> Chuck Lever <cel@kernel.org>
>=20
>=20

This all looks good to me - thanks.
Apart from path 10:
Reviewed-by: NeilBrown <neil@brown.name>

I don't know enough about rdma interfaces to properly review 10/12.

Thanks,
NeilBrown
