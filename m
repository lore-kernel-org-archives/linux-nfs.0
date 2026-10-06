Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5662425B0BD;
	Tue,  6 Oct 2026 19:47:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791316024; cv=none; b=nLwPhTVGhNKUJPVNht9gzObNnPOBEqfdVuXpt7PqzzMfbIxBxx8/zZ2X3gBrPnEUgVyR5NtLW8e06+UJ2KClzWRz+oQ4Nf3dVkzxsv9zxIlxQ4Sj648ZhZDhpt63HA8jnGXTfauplPpMASRgOh+DP1+ZvN6txl8/PbTT5jpxjm0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791316024; c=relaxed/simple;
	bh=cc02fnmYhMjNRJWWWxau3VBTEXG6tctMMlcyXxw5sY8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ILzVuEOMTR75G00Ep6iiWbo7J0W8ES0H1AKayG7fhOygvAppe3WtJnRbW7uqcnu/HHnWnKhQJzXSrHPN2qStWaD8xIm+p8vEx5u5F9F2PByrbTRS4hxRKV+xGMj6hfTqMoCab2mNmhs+9axzq09tyKd68pn+6DGoixdjgYhuFQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UMPfo23I; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UMPfo23I"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 871371F0089B;
	Tue,  6 Oct 2026 19:47:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791316022;
	bh=il44b6d7cnwVrTLbw9qIi3axa5za+JetazdEyV26FB0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=UMPfo23Iqlg+mkZk6I8hpY8Chl5olQ5z2wbFLHgAJSSrEfm0p/jyI3W5e4MukZGna
	 0O78MSqS3kJGi4DzP6nnBQTKcj3bbD1wBzvV08pPk1NniHG0ewGrOT5K8QUSclngnZ
	 rNRbiOAIic/f32wuNPxdNGCHZaDE+4uVQLi2FuhPdPDHVCafdL8gs5IuHEEwauIZ/o
	 LYgQczwFI8YkaxWxxIXW6IB8BHdPdZXWOdRkGc1M9MCbjw8CUj+dGNvGHKwjfVbrgY
	 0VNfzbI5XhW3z39C7MNYM36qlpNS+xLPJ9n0QajOedKX1m+Bs1RySibx4Lfn3QanFB
	 T3mozd25BdoHQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AE6A9F40066;
	Tue,  6 Oct 2026 15:47:01 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 06 Oct 2026 15:47:01 -0400
X-ME-Sender: <xms:NVDFavucvuQxgIfG4ki3mGGkLGHE0tX3AFiC6Eeq7X1D2YThsowG_A>
    <xme:NVDFarQsJeMNpvmfBp3nM1KdnecLNczSpovqNM-cNMNgWuYhnaU5biJK-StzU_3rl
    cpRY8zvNKm3FJwbfz6RybS-bNCEUhh8y4ojDZd2k8JjaKhpQRzCdO4>
X-ME-Proxy-Cause: dmFkZTGMaBQSnK4GQOosuurIVpy8Drfw5aCO1d0DH4zlmvk4m2MxBgpN5UCJCqYeJTtpDf
    qQb8bWp3kjU1t7j3hNzwVQt9+y4ubuscA8oFFNN0ZwS3ZsxE/JebV4Rj5/f1017LrIDkor
    pBrOImDtuj+vTJMm8pmRvHKKGB3Amek7I/YuWcHiNxv1lSYJ7DzMldOnAsDTa/tSfcz2l8
    ZV3ZhnCkFFfNEYNSDmiKebvstRFh8xQfDutt19oSBABskEDbrl1gJhMvn3KU2gfpcCJDHa
    lCYKMxGzwWHjR88dlqaEIkkDzv8PK1dhXmmDjWyU2q+RkdERUXxcZzIDIJUEUBAgtJ4rsS
    xhKmXis1Xri1BxQriZTvFRfQ0IyEXulJ9ksBjHfH8sHK0CzSk52USFxbybTtqZj2JLz8kZ
    +xyFY6xtJ0f50qUloToWLefwd2J79saxTVaMlxqE143zHkKM4D5tvp/Y0XgEiNmWsyEpoH
    q9OT842iLixMDR2LvE/abfgIQovHkuXrSg2tkkCovh1oG1FIoFYGRzSLyja/E2wgfpcKK8
    aqiQ5E8Df7LyiRyBLP3c5AZza/C8xXb9S4NH8/cofM8vUIisf6yTxBu5NKtoXpdKFQVtLK
    MqUCPyo3+hnaFkL/Fsw4e8S6BCBLSDA0BcipeiLccOxIYLGgJyl3flDwjcoQ
X-ME-Proxy: <xmx:NVDFamEtnIQ2JZncPbBBkMn39vGXhHU95yBMxRMdi_bs_tXqJNf-JQ>
    <xmx:NVDFavdJr-Uw7Nj3aeJVoSNPSb7IgZw20Kk3wvG2EZZsk00seBHM1Q>
    <xmx:NVDFavp1Y3Nd4hZFkkVOmLfHwAnFvFdh1HAQ0qVZulzN2e-pXI44aQ>
    <xmx:NVDFagBWOl7H9_uaPr8wVdjw-5rWQfmv0PiPwt7D0nIGsXR-UYIQ3A>
    <xmx:NVDFaoe_Ck0PrU3Tt2A_Fa6eLPt_yg7bkwOeXKiAIjDqKRXK0Ompqqd0>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 86E40780070; Tue,  6 Oct 2026 15:47:01 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A9t8TiIcTZy-
Date: Tue, 06 Oct 2026 15:46:40 -0400
From: "Chuck Lever" <cel@kernel.org>
To: daejun7.park@samsung.com
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Benjamin Coddington" <bcodding@redhat.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <63ef8d7c-086f-4cc8-84bb-72c1b23bf596@slotpi15m67>
In-Reply-To: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
References: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
Subject: Re: [PATCH 0/6] nfsd: layout recall and lease break fixes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Daejun,

An nfsd thread must not block for more than a few milliseconds, and
never on something a client controls. A client can tie up thread
after thread until the server has no more threads to respond to
LAYOUTRETURN or DELEGRETURN, and then the server deadlocks.

For delegations we are safe. nfsd_open_break_lease() passes
O_NONBLOCK and the operation returns NFS4ERR_DELAY.

For layouts we are not. A WRITE or SETATTR goes into XFS,
xfs_break_leased_layouts() calls break_layout() blocking, and the
nfsd thread sleeps in __break_lease() until the lease is dropped or
the breaker times out. That dates from f52792f484ba, but it was
bounded by fs.lease-break-time, and a Linux client from v6.8 on
rarely hit it. It responded OLD_STATEID, the callback failed, the
lease was dropped, and the thread was back within a round trip.

This series makes that wait the common case and then unbounded.

- Patch 3 polls on OLD_STATEID, so the thread sleeps for as long as
  the client takes to drain its I/O, up to lease-break-time.

- Patch 2 waits on the fence script with UMH_WAIT_PROC while
  lm_breaker_timedout() keeps returning false, so the thread waits
  lease-break-time plus however long the script takes to reach the
  client.

- Patch 5 extends the wait of patch 3 to a client past the seqid.

I think the fix has to come first. Before the WRITE or SETATTR, call
break_layout() non-blocking to start the recall, and return
NFS4ERR_DELAY on -EWOULDBLOCK, as we do for delegations. Then the
fence worker and the poll loop can take as long as they need and no
nfsd thread waits on them.

Give that a try and let me know if that works or needs improvement.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
