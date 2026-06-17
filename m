Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C98F3A1C9
	for <linux-nfs@vger.kernel.org>; Wed, 17 Jun 2026 00:57:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781657856; cv=none; b=IuPkNnisLz85zV6a1a8lmUFa6t8ST9NOOA+7JxTSbQetv8fh6jZsCKWpMMNAjpL+h28G72YkW7g1A4lLcwFA4N89288QFF7gumfR929o1ZqsfzI5uX5+gWtyiDkaQIx5iPReAfM0qaGz3MezgTV9A49n972M3kVTL3Dfv9lzcWw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781657856; c=relaxed/simple;
	bh=cOW79HXT2FMy7QzCo9jGvJRCz6UAzJxItjXS4qQLDp8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=LlYcW+kqheWBNGfj8iHvQiuOsTR4cKZfIX4yB+sHtIj+pOF0wqRkpmacXkJWWhaUuH92iHC2DmMdfgRZA7/LP48GaL3k3FzTqEKWLHFNYz2YQUfksFJd4DVnNMuTjw7EMsp6oBCsuohpPehbDHJWkRQLm6HmH4wmbHJ/IfuL+Ag=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kyP+l1oH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kyP+l1oH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D5201F000E9;
	Wed, 17 Jun 2026 00:57:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781657854;
	bh=onAv6oeGsXFirqVncIWEGYbS3jxWXQ+5Udq7o+XbzS4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=kyP+l1oHnCruWiaMKH5hCIpBRdQpeqQbCqXRVg0YOAAW1FLbZufSfq+p9YqaOZ0WS
	 n3uXHCD2I0K3+J33iBBllPnnX07ZMVOMvTbUQyo0ZWo4vUm80yHzIrAHG2u1CDR8TG
	 F/0MUa4uoo9Knb10lQ4kpwYzdimP5pQ46GLffIZCT+GW5H3p5PnsUWEBhnu4QcvOgf
	 nGS9CFp/1USyarpK3ptzHm42m95aFQfnBGVBCH4dwznuQqW71FJSuMFpmE3iWBzQOB
	 J2TN3uWPBjVpxk1rRj+f3HL3XRdA24Bgp+j/ZHRXyMKzKFM4cFbcPGTZx/aIkCP0dw
	 d1YNpTrmh/+UQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A198DF40080;
	Tue, 16 Jun 2026 20:57:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 16 Jun 2026 20:57:33 -0400
X-ME-Sender: <xms:_fAxal9Pf3ituOlH3-PRePL_FCNGYmLuKAnLeoayjf3qcTJjZhG8aQ>
    <xme:_fAxakj5phiQQRuhSI9Pdp6J3rOXMamdSWyGY6bGNTNSNiNtX74tiBr99WqdDSjLN
    iiCIxNyGYU_e6BTBM3BzQwD97Qf975G3LgH6JGU37IMT3urBS0pzUc>
X-ME-Proxy-Cause: dmFkZTGJ67i6wSod1mqKb4eTbnDgAoX/U7P7rw8OK60OyHg0EVLVMp5WSmvGe8CKnrzpyB
    pPy9TG6poLHjpx5vItOmopuap+iJfi6qhLDpUgKSMTYAnHR79LCJ1+mRHHKHUS2IwrUM2F
    w+HVEilUovpZ4wTDCfc2ttpCuS+z36sNNNrLsI3SB/fZUqJgMKa6ZeI6mu7O3uVYpYRLTK
    NyoSn/TIi8pL0sRfJSTZd/RV7N1NZXHDglOXQBy5vP0KE8T4nK2VOHshsKH2TH5Ge+awVu
    mf/ofu3gaU9PStxvHfpuVMN00fXH3+0CyslrTyVaQXt0s/+9mKkZ1hcUfZ7q07PPohvkSx
    um9YerzAKsRmH73WgB7VWwyb19pTPJeYqJ0W9DB04g8UT453YXdAD+X8/6VpxF7SFgBgn0
    a24hZKRkjgQjpWoHUmtwvyRW3E8tdjedx73aDc4P9/ndSSfAGMvPqo6HN3iCiJ4rNnWe13
    EGVrX3XAlieJuYJMW/EJhr+Z8JyaKGA1JGHReDSLnMX3kDCUUH4fiH4QonE+d5QdpkNA1r
    JVR92wgokgc7BZHUK3BkfBp4nrDb/9XNuJnJ1D9wS/1kcAzCOd1mi/V7YkgAfZnsqobsSE
    T3DtaA8uz7tIxSzWbZJOHPeyFwzZn6OVw9lZdz6QtGsbLYKx69GdvAM1PeHA
X-ME-Proxy: <xmx:_fAxalLK3hP5GqoVDzQm-EePkdoMp_983Z_xDF8ceG9QKfOR958Hfg>
    <xmx:_fAxanJIPBjbmgLfwQs_8jdYpa5jfxJBaNr0tCT2nOrCKJzLkpmnWQ>
    <xmx:_fAxaoitmbOU8iqufwTJ84pREGKW0xClLpUt7XX-r7QB34yYFWuocg>
    <xmx:_fAxapMjKTbaJnnUk0bA5S9SSDl-CPgKSP_ETGCNylbTc5Nw-izWPQ>
    <xmx:_fAxarr5eNRNwRXcrfGvGamD1lqkDnaWIAvQWfO3UHdztr4X_TOTLaRs>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7A201780070; Tue, 16 Jun 2026 20:57:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 16 Jun 2026 20:57:12 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <e55738ec-80a5-4e74-85e3-29c17d4f67c9@app.fastmail.com>
In-Reply-To: <20260616-exportd-netlink-v4-3-03505aee3883@kernel.org>
References: <20260616-exportd-netlink-v4-0-03505aee3883@kernel.org>
 <20260616-exportd-netlink-v4-3-03505aee3883@kernel.org>
Subject: Re: [PATCH v4 3/4] nfsd: implement server-stats-get netlink handler
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hey Jeff -

On Tue, Jun 16, 2026, at 8:45 AM, Jeff Layton wrote:
> Implement nfsd_nl_server_stats_get_dumpit() which exposes the
> NFS server statistics currently available via /proc/net/rpc/nfsd
> through the nfsd generic netlink family.
>
> The handler uses a dump operation to stream statistics across
> multiple netlink messages:
>
>   - First message: all scalar stats (reply cache, filehandle,
>     IO, network, RPC) plus per-version procedure counts
>     (proc2/3/4-ops) using per-netns vs_count arrays.
>
>   - Subsequent messages: NFSv4 per-operation counts
>     (proc4ops-ops), one entry per message, using cb->args[0]
>     to track the current operation index across dump calls.
>
> This allows nfsstat to retrieve server statistics via netlink
> with a procfs fallback for older kernels.
>
> Assisted-by: Claude:claude-opus-4-6
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  Documentation/netlink/specs/nfsd.yaml | 105 +++++++++++++++++
>  fs/nfsd/netlink.c                     |   5 +
>  fs/nfsd/netlink.h                     |   2 +
>  fs/nfsd/nfsctl.c                      | 206 ++++++++++++++++++++++++++++++++++
>  include/uapi/linux/nfsd_netlink.h     |  35 ++++++
>  5 files changed, 353 insertions(+)

The procfs output in nfsd_show() emits one more counter that this dump
handler drops: wdeleg_getattr (NFSD_STATS_WDELEG_GETATTR), printed at
the end of the CONFIG_NFSD_V4 block in fs/nfsd/stats.c, right after
proc4ops. The netlink dump stops after proc4ops-ops and sets
cb->args[0] = -1, so the write-delegation GETATTR-conflict counter never
goes out on the wire.

There's no schema slot for it either: the server-stats attribute-set
ends at proc4ops-ops, so a consumer that prefers netlink and only falls
back to procfs on an old kernel loses this counter on every kernel new
enough to support server-stats-get.

I Suggest:

- add a wdeleg-getattr (u64) attribute to the server-stats
  attribute-set in nfsd.yaml and list it under the dump reply
  attributes;

- add NFSD_A_SERVER_STATS_WDELEG_GETATTR to the uapi enum, after
  PROC4OPS_OPS and before __NFSD_A_SERVER_STATS_MAX so existing
  values don't shift;

- emit it as a single scalar in the start == 0 message, wrapped in
  CONFIG_NFSD_V4 to match the procfs side.


-- 
Chuck Lever
