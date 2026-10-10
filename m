Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9A263515CB
	for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 22:19:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791670756; cv=none; b=isDFXHDeKk49o5InoCTrrq+H3g55N5E3GJTHuJf7FlENm8QhyNnTseFbnCSfSVe8qKXNmHtBpibuRwB10BTkDiKJabbucK6uldY4/9SpJByv4r8vgLlrPyIzOBDR20NSdwHOIOB7WZII22gfsBEmUjI5GtGVFxqyMksjVZOsXg4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791670756; c=relaxed/simple;
	bh=dw7ym7mdaqCxjp3Eixqyc2K2ivZJBKji8p1Jr4hvM6A=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nLHgyeua7h1OPXHGZgdhLyIjZ0PasqTPbnYgsnhMpVtzg2Bc3SdF6htYw5M2wPdvfb4lfw73oIgusMKJuo4Q0Lqr7j+SeKWAGSh7LSVGKQMd7PH4ENcVaGjCbRahfy0P8rCYyp7rX3Bbw9wLMEsk5S+SUfClR1Wr/UW+sXbMIQg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=lBvg+6O5; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="lBvg+6O5"
Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	by smtp-o-3.desy.de (Postfix) with ESMTP id CACBE11F8AF
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 00:19:04 +0200 (CEST)
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
	by smtp-o-1.desy.de (Postfix) with ESMTP id EF03B11F746
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de EF03B11F746
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1791670737; bh=ISyMa15ksc57BOiMelyTCIjUswj4ilbV7S9bGWUxNV8=;
	h=From:To:Cc:Subject:Date:From;
	b=lBvg+6O5eufjLYV6IotFCTl5oPnGOFRMSpOvcNkfKmM9ShAur0SYEMqgbtO12oi6+
	 n23DnM1SxTZVjQ7WY75ljgq9CPEY4rP4EHB3x6UzKIMNrDqHDbwLX3CwGi9Tw04UKy
	 x+6MkezoYlob6ro8JuFY1n3hG+LVtgKpijW7NSQo=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-2.desy.de (Postfix) with ESMTP id DC19B120043;
	Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [194.95.235.47])
	by smtp-m-2.desy.de (Postfix) with ESMTP id D27B216004A;
	Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [131.169.56.82])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id 3695A160059;
	Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from z-prx-2.desy.de (z-prx-2.desy.de [131.169.10.29])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 22F5D80053;
	Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-2.desy.de (Postfix) with ESMTP id 184E56053A;
	Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from z-prx-2.desy.de ([IPv6:::1])
 by localhost (z-prx-2.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id OrsNIhNVSbpL; Sun, 11 Oct 2026 00:18:56 +0200 (CEST)
Received: from nairi.desy.de (VPN0276.desy.de [131.169.254.21])
	by z-prx-2.desy.de (Postfix) with ESMTPSA id 433BF60005;
	Sun, 11 Oct 2026 00:18:53 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	snitzer@kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 0/2] pnfs/flexfiles: make DS connect application interrupt resistent
Date: Sun, 11 Oct 2026 00:18:37 +0200
Message-ID: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.56.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In our testing we hit a situation where the pNFS flexfiles client
goes into an infinite loop. The application spawns one reader process
per CPU core to read multiple files in parallel, and kills the readers
once a fixed time budget expires. The killed processes never exit.

We have identified three issues:

- Concurrent connections to data servers are serialized in
  nfs4_discover_server_trunking() (not addressed yet).

- Regardless of the configured security flavor, the client always
  tries krb5i first, addressed in a separate patch:
  https://lore.kernel.org/linux-nfs/20261009155802.540179-1-tigran.mkrtchyan@desy.de/T/#u

- ff_layout_pg_init_read() and ff_layout_pg_init_write() retry in a
  loop with ssleep() when no data server is available. Since ssleep()
  is uninterruptible and the loop does not check for fatal signals,
  a task with SIGKILL pending never leaves the loop.

These two patches address the last issue.

The patches tested on 7.3-rc3 and RHEL 5.14.0-757 kernels (with
backport).

Tigranve  Mkrtchyan (2):
  pNFS/flexfiles: make pg_init retry loops killable
  pNFS/flexfiles: don't report an interrupted DS connect as a DS error

 fs/nfs/flexfilelayout/flexfilelayout.c    | 23 ++++++++++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  5 +++++
 2 files changed, 25 insertions(+), 3 deletions(-)

-- 
2.56.0

