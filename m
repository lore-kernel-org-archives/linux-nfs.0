Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 067A42820AC
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 23:02:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789081365; cv=none; b=qBuStrARqVj4TM0uc46OeL0AvihAwmhbu+rZ4a1WHn0nW1Uzasx7M+35BfdYTbz3pFodnVWrrYFS2bb78l2ADDJAuGVpcbHTq6i1rLDf2U1mP1Bdmpls/Y9g0xOkJx4NV0e1bdnf3HmY+gMsXo6eeHqlAfsXcMUbFbcT25ZzCls=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789081365; c=relaxed/simple;
	bh=faca2oce78Be9yaFIedVYb4JhhZuKU22YD7E3w4J/Ww=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=V0Qq2eqLppdXLvIJSFpo89VvRGZDzh2LB9m0umUpG1gScUgqj4v1ft9OxSzI0YkhFChxL/22e+NKm/xJB53LihvPwr5o1wL9Pm7fhICC3qzUFgv/DuzLqsy3DidwTM5KXq0SAbh/vaXkJUhcfCwLTVPhkUqzerH3x7UN0weJ6xQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ABOfCRRb; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=nto/giKJ; arc=none smtp.client-ip=103.168.172.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ABOfCRRb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nto/giKJ"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.phl.internal (Postfix) with ESMTP id 23447EC01C7;
	Thu, 10 Sep 2026 19:02:42 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Thu, 10 Sep 2026 19:02:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789081362; x=1789167762; bh=ZYO1EMYxBDjgOacebyLep1hhSME3Hf9e0n1
	0vYwKTAc=; b=ABOfCRRb76VBYH2hSI/pH40kTPaoDIdxGwI9zEgU3DOek4oxDJW
	f5AMCxFgdxbv7vFcrjRNV7kR0MdQWtVhUoocFEtBqfZiKPcRqqlNSlQfTCHLozhj
	RTkHykTY9iSUzrAy55stTXx42oY34TV+6AfvFSgkmk+pkNzdwXZcDB6VsV4KftsV
	xVgyaA42q7oqvouOowaBSP9UKVnyx3TbqoIBQEyEGIy5npBZQC889pbX3ILtiEP3
	/zGjtTynLF1tgeDIwrPznW1WJFVMcigdnOkSKyu8OB4LIwFxc0xcdY5TOT2i1k+t
	TIla3n8Rt/Ev+sG9/DCIEAOr2m/52eup4zA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789081362; x=
	1789167762; bh=ZYO1EMYxBDjgOacebyLep1hhSME3Hf9e0n10vYwKTAc=; b=n
	to/giKJJckkmlJhq5LJN2/t0qxY41Z6sJbwMmkS4Dmqq6ksGLNYMsYGTBabuCTfs
	ZnYZtp4UjppPT9I78ywnv/VIMJoi986Kj+diyCODmnIK4zY8OW5XAULSPxS83lga
	Q/tpzcNG+6Ujf1Cg8BVWMUM+VPqG+eUcLx9mP2XAMF0cWKE4HNLR2JsTjvIsoHqF
	EWZz7Gi1P9G/eVpLhlRTCnDkwA3GBB+qD5GxzOU4kVjd9yzY3hZ9dDUemoCH7Mvt
	zIY85j5hDUYGGhIvrZyyUlmbTODc0nnBgdXDHN2vtw4Oc7C7xatE88iFfFQx6RYa
	E3NeollhoE3URfqMGLXhw==
X-ME-Sender: <xms:ETejaul2QM_gKeNu-1Insj9knio-h3vjlZiBx9mjqJVn2JP4mH1HsA>
    <xme:ETejaoH74dRq-_jVQAi6ob7V1eM1KyTmE1h0a0LzB3GIi-tPpKt2s-w_5366vm_F0
    hdzYTkthN425T4dKofYpio8IB3atyBId3a1tTDrHfUH8KtDsw>
X-ME-Received: <xmr:ETejau7XXVCWiEniooQpoFaWreNBa7jcKHFnrdsHuXh32epmdSA32MCrjdc_6pAQig>
X-ME-Proxy-Cause: dmFkZTEh+z74Lo0VXni+hp8ydLGMlWrRr8Aq2KTkYFw4T0N0UTXVEWC4Kz2WPqXZLP/e8m
    z1DK9stEzIES1opyRopaA1N5oWjrl33z475bO0bfVglWjPosJ4q5gbXmTkz135UZnCdxoV
    OsK1zVtU6VWIlbnZgAlLvreRsmh5qIMqiS8Nv79DWLh8z0GF7TJPEDMXONYzi1imz8smAC
    sM4PaGC4h5qhHNJ8srpZ5SH+E0e1ivhCS7PVxqNmYIrX+5F9EeCYvEWT6Jv0iqQIgeYMSC
    v2uGuFVYfp33xwwjwFWU2SUBoWF4a3uf5s+52rO4M6gAtuk3n87J6vSQ1vyH5cYpUuPmZj
    mG+6yo4DCtCLkBzzSZ0wpK7lsbkdFIyKRX4nlD9eEKspUZpMFhGiAcEVUqBHkgcFnVxumE
    9LEI/BQhtmkXz+ZO7w9NPYsH0M0gldb8b3Ekc9xzpc6nSvsFE5r4n8690QS6av2lzDeoMK
    vuK2B0O/sqaoVl1MkR3NDyzkJ/BffqchKyULBKhaH06cwaawJ+5aQ+Qg0nC4mYiidul1Iy
    pfTE/HkWK+NhRygK62EnL+hvZIbVj7t4LkYRghe/TA+bCdX8/Mkr6xjqYKqPvUSHHETNnl
    bpcghVVhf+3iu/EHpIQEQq2QozyUn6JA3eJo42BnfEJGr5H71JDrxxPnuZhA
X-ME-Proxy: <xmx:EjejaokyDIpo0MK9MDZZJ0l0jAbMCSS0sJ4-9-8dYRJArIZe9vNfog>
    <xmx:EjejarpumWirzQsES3z-DJTio4pI0-01J1dSqrg607euNFv2aS7WMQ>
    <xmx:EjejavuglBTlf4jiTLv6WHhPMCaFntnKxMZedGR6Ugep16S9Vjc8_g>
    <xmx:EjejaoFoKNHIZxRbYXJDy48A5qxq4EGnc4HJH2ZFZX2GsvkX3GrHFw>
    <xmx:EjejaqRfDsgTIgZuyaBolcAlc0pmJn9GtL4NCalRN2aQ9rhPcENcKYFZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 10 Sep 2026 19:02:39 -0400 (EDT)
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
Subject: Re: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
In-reply-to: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
Date: Fri, 11 Sep 2026 09:02:35 +1000
Message-id: <178908135551.207413.11072935643340240963@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 10 Sep 2026, Chuck Lever wrote:
> A completed DRC entry currently stays in its bucket for 120 seconds
> whether or not the client already holds the reply. On a busy server
> those entries lengthen every bucket walk, and under pressure they
> crowd out entries a retransmit could still hit.
>=20
> This series modifies the DRC to retire an entry once there is reason
> to believe its reply was delivered.
>=20
> 1. The transport reports delivery outright where it can. TCP now
>    reports when snd_una passes the reply's sequence number, and RDMA
>    reports on each Send completion.

As you note in the relevant patch, the TCP ack can arrive before the NFS
client has seen the reply.  But I don't think you drop the cached reply
immediately, so that probably don't matter.
The risk is that the second non-idempotent request might fail (mkdir,
but dir already exists), not that it will produce a different positive
result (technically possible, but vanishingly so).  Once we see the TCP
ACK we can be confident the client *will* see that reply (network fault
won't cause it not to) so it will mostly likely act on the first reply
and ignore the second.

> 2. Where no report will come, a later request on the same connection
>    stands in as an implied ACK, since a client on a live TCP or RDMA
>    connection does not retransmit within it (RFC 1813 Section 4.5).

I don't follow this.  Why would no report come?  TCP will always send
and ACK.
And I don't read RFC 1813 4.5 as saying a client does NOT retransmit on
a live connection, only that it DOES on a re-opened connection.
I believe that when an NFS client gets a timeout (6 minutes on TCP?) it
will resend without re-opening the TCP connection.

And as you say it is possible (I would say "likely") that a client will
have multiple requests outstanding.  Even multiple non-idempotent
requests.  So I cannot see that a later request tells us anything about
receiving an earlier reply.

A non-idempotent request often returns a new filehandle, and using the
presentation of that filehandle as evidence that the earlier reply was
seen would be sound, but I cannot see much other opportunity to draw a
connection from later requests to earlier replies.

So I'm perplexed as to why point 2 is needed, or how it is justified.

Thanks,
NeilBrown



>=20
> UDP continues to use a traditional time-based eviction mechanism.
>=20
> The first mechanism is the more reliable of the two, and the backup
> mechanism is more of an informed guess. A pipelined client sends its
> next request before the previous reply lands, and an entry evicted
> in that window is lost if the connection then drops and the client
> retransmits. In the current NFSD code, memory pressure and RC_EXPIRE
> already open this same window. For instance, on a server with fast
> networking and storage, pressure eviction already evicts entries far
> younger than 120 seconds.
>=20
> Two DRC capacity guards that were sized for a cache full of stale
> replies can be removed, now that reply delivery reports keep the DRC
> small. The commit messages for those patches explain the rationale
> in detail.
>=20
> v2 of this series (implied ACK only) was profiled with "perf record
> -e cycles -e cpu-clock -e LLC-load-misses -e branch-misses" during
> an NFSv3/RDMA 4KB random-write workload. v3 has not been re-profiled.
> nfsd_cache_lookup overhead dropped from 1.53% to 0.76% of CPU
> cycles during this test. The rb-tree operations (rb_erase,
> rb_insert_color) that dominated LLC cache misses fell from a
> combined 13.2% to 1.1% of all LLC-load-misses, because shorter-lived
> entries keep the per-bucket trees small.
>=20
> ---
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
>       SUNRPC: Assign a unique identifier to each svc_xprt
>       NFSD: Track transport in DRC entries
>       NFSD: Prepare bucket pruning for out-of-order eviction
>       NFSD: Add tracepoints for DRC entry eviction
>       NFSD: Record DRC population in lookup tracepoints
>       NFSD: Add reply-acknowledged callback infrastructure
>       SUNRPC: Add TCP sequence-number ACK tracking for reply delivery
>       svcrdma: Fire reply-acknowledged callback on Send completion
>       SUNRPC: Record last-request timestamp on svc_xprt
>       NFSD: Evict unacknowledged DRC entries via implied ACK
>       NFSD: Remove DRC checksum and payload_misses stat
>       NFSD: Remove hard cap on duplicate reply cache size
>=20
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
>  fs/nfsd/cache.h                                    |  20 +-
>  fs/nfsd/netns.h                                    |   2 -
>  fs/nfsd/nfscache.c                                 | 310 +++++++++++++----=
----
>  fs/nfsd/nfssvc.c                                   |  20 +-
>  fs/nfsd/stats.h                                    |   5 -
>  fs/nfsd/trace.h                                    |  81 +++++-
>  include/linux/sunrpc/svc.h                         |  51 ++++
>  include/linux/sunrpc/svc_rdma.h                    |   1 +
>  include/linux/sunrpc/svc_xprt.h                    |   6 +-
>  include/linux/sunrpc/svcsock.h                     |  10 +
>  include/trace/events/sunrpc.h                      |  10 +-
>  net/sunrpc/netns.h                                 |   4 +
>  net/sunrpc/sunrpc_syms.c                           |   2 +
>  net/sunrpc/svc.c                                   |   1 +
>  net/sunrpc/svc_xprt.c                              |  53 +++-
>  net/sunrpc/svcsock.c                               | 119 +++++++-
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  14 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c           |   7 +-
>  19 files changed, 541 insertions(+), 186 deletions(-)
> ---
> base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
> change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c
>=20
> Best regards,
> -- =20
> Chuck Lever <cel@kernel.org>
>=20
>=20

