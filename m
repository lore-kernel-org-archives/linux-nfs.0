Received: from fout-b7-smtp.messagingengine.com (fout-b7-smtp.messagingengine.com [202.12.124.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7A523F9F28
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:13:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789449207; cv=none; b=Kivw7vsNEbUoM2bfk4ajyvZTE3xD/i+RS3shD2exxME6u1qVhCUdQGVioO7dSnFL2L43wtalxBnyiEdt4WLJv871TPazhEI3lKYtGvjgNC5knjDn8l3qkDzEF5lNTJR5MEm7eMTPe9twX/xAg6PjlqJUlz/xFGnwfVpLHwCNUBA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789449207; c=relaxed/simple;
	bh=j/HHidvu0B2UL7366P0wMsUpCcvNNdkz+Z/JB76A01M=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=dk21vi/OeVcpQHmUGYJ0r/cm5ENyNPNP4O/DZI93O2bZtmSuU8HOcOZ0pFcPg+mv2UcoHE5p++3/ym4409ITxJGkeEqTp5chaQsXE9JKtgHUpdFlLab8pU1fgxaIuOKhoX2GtO1tgo7qjknavIzgAysHM59dpDKoqcjmJj2HpUo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=HnYPdKvh; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=OMxtqHgX; arc=none smtp.client-ip=202.12.124.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="HnYPdKvh";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OMxtqHgX"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 88A961D00408;
	Tue, 15 Sep 2026 01:13:23 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Tue, 15 Sep 2026 01:13:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789449203; x=1789535603; bh=/Z1isgpwdbzrZY4s/K2w3kRE570WdDeRQWD
	0meg5DOE=; b=HnYPdKvhLNa6ylZllwt4GN+26ombAYsu6TylMBTPlTeogRVF6zi
	8KAZ4jGjC7nDPKvmTelOAAF8XedFoXXUE2RhmdazAkXDYVrPAvvfdpOaX0MyYjjF
	6Ah51b46+aek+iOXd2XUNFfyaxwrBuAmN1IMUHrbvWIA1giPMFinqNPpl6Xq/Fen
	mmfEcD4z4bTudoyVZMB0a3fxKn8T4b19ZS9c1BDhI17A/WrEGV3BOOR59iPhgO2H
	jhyn56OWmX1O5D03GjoydOoGlC9v7JK7YMPxOu1h6HRzEeaEeQDzWuhjkAmipBMD
	CqUgUzP56Q/VcPdGUUyULmm7lryVTpZL2xA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789449203; x=
	1789535603; bh=/Z1isgpwdbzrZY4s/K2w3kRE570WdDeRQWD0meg5DOE=; b=O
	MxtqHgXZ5iYzd+QyFipbwvuwFw/3B/ydmzL5p3jmZnhNNZdLllWQNdhMddRbwZVW
	EnHPqjWBsAnAQVsQ8+4L5mTCi+UeTzXTEEzam7H6j9YCiMvMwC3evcFEGbhGfTZt
	wa5fHacnxmOWZ+oEhqmtQouUQWrvXp40AvElrVlqjwaANjWl1FIM41fLy+oGqvHY
	OV3WdtPtFTm7OBRXUk+VKmteQAvL6zm6a88iJqNTN0GYugq9yDKXoPjdCgFmEvb1
	K5UNGmBCBq90Nu+bAtFVHoC46SCbi9762ah1SM9tcEGuUeYsDDU4lYHWbWXz9HKm
	hdULz5UYmG3NIG5FtBwCA==
X-ME-Sender: <xms:89Ooapau2bwwf876EAyfbWr-pgzhzYVJbTOGtLCeSil4zmQ4k0H2lw>
    <xme:89OoaioeoAA7EtjD9bSkOGqUh9tLE1YW9x0q4ZP79Zm-Qq89olnBvkTw_TSb7sVxB
    K6MDVbPPXmDRTDK--IBwAIuVo9cIPpHBYbpNX4ECQGrpUds5SI>
X-ME-Received: <xmr:89OoauNvQkVQddH5NT5SK97J2jt--Z5ikWUR9jyQyiIKdX7BP_hAZJlFrSBgP6lxhwkeBP1ZhtAHKiEs5GDbNl1iF5z0dsQ>
X-ME-Proxy-Cause: dmFkZTG0br20/WuEdj1Ujzzq8d1zfszGl/bBz0TqFqzLRqW663MwMz9MQiCWqqxs1OFGj6
    6mE7gXcMA9bSAGATWhp1i/RAdxTDXUv5+q5+bY0j+hAIb70P7iV8fdDXVFGPS5Z1raHHfr
    5PTYhWgi7f2GydPyNjjSj5zT5b4Z6HhuqCwlhgOwgRsCqjZ1qfb1xYFFHlHLMzXSMuuORT
    eHztHJrDaKxpzH1zpq6yq/xbvzwtnhYpnLqBbNDASip1DlsQCtbSbZ7F1jKxs4OO0V9rmK
    U4ukJrhYrOW13F6UxFwHp8RYV27YVf1PGDHFnnj9Ju6o03ybt6Qj3G5jbBgI1CofKIJNnY
    IzNit9eDaDRFFaJLa3SP7wt/tRZpClADVw49Eox4a2EDrm76ajCNJ95bvbIogmrWy2iJjA
    s2fB9Qbp7rJ+fdEodjLQsIBjSrbgbL/3MNj5Jg44ADhnSojcfpEYXqh4cHqhoSosNNsLtd
    6kEyiMCjrUHm8ttlukjmr8BA5agSCBSzitIAU+yeF+7O0UTfVWIKluJVWSULb2w3yn2PhY
    weQ0b8S3YxnsceIkHZ4M4w9CsMUHuAWu0hqt29Xfpgdt9ZYKqS/TZ642iNAOTSv8TSVHO3
    erMMrzfeIRVwPSsLhFbCpFING9Tm3Jbp+eWtkJa1U48/JtQnzf5pJOlupXrw
X-ME-Proxy: <xmx:89OoatoDw7txxpBXztnQKbL7Po_hrPIEcPQcz67lYYOElx8I1EdFrA>
    <xmx:89OoajdUKwgcrTNm8189FoYuGA_KrFs9SmABrkXFwLRmd4aD7WPbYw>
    <xmx:89OoajSlHQ_vAWFB6rQ0ELtonKsxBHcwVvhRwcypR81kDETzSZdZKg>
    <xmx:89OoasZq1ukZmfgKCsGvGhOWOh_CEAHtOzaXAmL6x7r7TPE8OtDsOQ>
    <xmx:89OoalXBX5_nNY_P1kUa2gbYHl_FHy7mvyJ2-MwAMdXJjNahyXQzQ-_x>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 15 Sep 2026 01:13:20 -0400 (EDT)
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
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
In-reply-to: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
Date: Tue, 15 Sep 2026 15:13:16 +1000
Message-id: <178944919634.207413.1627415312248503752@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 15 Sep 2026, Chuck Lever wrote:
> A completed DRC entry currently stays in its bucket for 120 seconds
> whether or not the client already holds the reply. On a busy server
> those entries lengthen every bucket walk, and under pressure they
> crowd out entries a retransmit could still hit.
>=20
> After this series, the DRC retires an entry once the server transport
> has seen the client peer acknowledge its reply. Each transport
> publishes two positions, the reply it has just sent and the point up
> to which the peer has acknowledged, and the DRC compares only the
> two (patch 6). Nothing else about transport state is exposed to
> fs/nfsd. UDP entries and replies sent over a TLS session keep the
> time-based eviction.
>=20
> Retention now ends at delivery rather than at consumption. A client
> whose RPC timer fires after the reply was acknowledged but before
> its RPC layer read it retransmits, and NFSD executes the call again.
> The client completes with the first reply and discards the second.
> Patch 9 works through the cases.
>=20
> The XID checksum and the 256k entry cap were both sized for a cache
> full of stale replies. With acknowledged entries retired, the
> checksum guards only entries that wait out RC_EXPIRE, and the cap
> starves the partition case it was never meant for (patches 10-11).
> The "payload misses" line disappears from reply_cache_stats.
>=20
> ---
> Changes in v4:
> - Track reply positions instead of ack cookies (per Neil's review).
> - Make xpt_id a 64-bit counter and drop the xarray (per Neil's review).

You actually made the xpt_id 32-bit and the reply-position 64 bit.
I would swap those, or at least make them 48bits each.

As a connection can exist for an arbitrarily long time, if the xpt_id
counter ever wraps you can get a collision.  The age of cache entries
isn't the important age - it is the age of the connection.
2^32 seconds is 136 years, so it probably won't wrap (connections tend
to last minutes to hours, not seconds).
2^48 milliseconds is nearly 9 millennia so that certainly won't wrap.

The reply position only needs to outlast the cache entry, not the
connection.  But it counts in bytes.
10Gbit is 1Gbyte/sec so 32 bits could cycle in 4 seconds :-)
(but that is what TCP uses!)
Your code doesn't depend on the underlying size, which is nice.
48 bits would only cycle after 3 days at 10Gbit, which is much longer
than the cache residency time.

(I haven't properly looked at the pruning algorithms yet, but I will).

Thanks,
NeilBrown


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
> Chuck Lever (11):
>       SUNRPC: Assign a unique identifier to each svc_xprt
>       NFSD: Track transport in DRC entries
>       NFSD: Prepare bucket pruning for out-of-order eviction
>       NFSD: Add tracepoints for DRC entry eviction
>       NFSD: Record DRC population in lookup tracepoints
>       SUNRPC: Publish reply positions for upper-layer consumers
>       SUNRPC: Publish TCP reply positions
>       svcrdma: Publish RDMA reply positions
>       NFSD: Evict acknowledged DRC entries
>       NFSD: Remove DRC checksum and payload_misses stat
>       NFSD: Remove hard cap on duplicate reply cache size
>=20
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
>  fs/nfsd/cache.h                                    |  16 +-
>  fs/nfsd/netns.h                                    |   2 -
>  fs/nfsd/nfscache.c                                 | 243 +++++++++++------=
----
>  fs/nfsd/nfsd.h                                     |   3 +
>  fs/nfsd/nfssvc.c                                   |  11 +-
>  fs/nfsd/stats.h                                    |   5 -
>  fs/nfsd/trace.h                                    |  47 ++--
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
>  19 files changed, 286 insertions(+), 168 deletions(-)
> ---
> base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
> change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c
>=20
> Best regards,
> -- =20
> Chuck Lever <cel@kernel.org>
>=20
>=20

