Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794528973;
	b=PNh1Bg4vC5bk6Hhp1kZc/PCidu2qraEnRI19LOVs5OQEV1drZsf2ULsp00Rp5Eep2Q4M
	 FWipUZsI2gLjYnAq601kl7IrSC1SZXXrRhylIRVIIZmahybvQu3TKLZPCMuPL1RWbpmM8
	 cebEbMIcqVYqQJ8OQVae+gB/NATYRCbgAxFUPFXJ8is1df8qTPC+8gKOkQTO0/EUxh8l+
	 k3D+i9dudTZsYuVTGrjLxScmlmdqbgJbOnpsOJiDfQ0wLLdH+JlxR+BXYBm4fdwLunyvq
	 AGoRifCaNVigU8PDHS9DHjifQWaTRGZuqpHFqP2VbzOIz294T+jBfjfaBf9U+D4Oo7A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794528973;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=iHbmP7zoB+1WEqENELHktAxoCSEWIAxZ1TQyZrPuaW8=;
	b=kIb9pO9lbyO6WORhzI3rCCuu/skQOMjYXyeCToAPSm9p/hEzzqUv84dX3cWLV0RMBx0y
	 N2dsNmQqowadTBsxB/g9PXBSKnMBuestgn5nD5eX4u7CEZBg5Qdei+AWoH/BcadaILguC
	 UDkpLrvVkRHCsDfwx7gY+AxBwDNZENEZ74SQfAcyWAGScq8lWECOKzioJNiN1roLJSHxU
	 8cjjRCanmDuqT2Z0+4PeZhBU2tiQ4n0OOJCiu1g8VOq6DakdSOpY9m+owKTXU7GW5uzmI
	 WkV/YQMhW/Sm89t84UJiKzW5bjy6B7TSrXk7toJ3LCglb19D3Bx8UFG+2wYjYS2VFdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hSCnQ559;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 492BA606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 00:16:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hSCnQ559
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8782F1F000C4;
	Fri, 13 Nov 2026 00:16:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794528972;
	bh=iHbmP7zoB+1WEqENELHktAxoCSEWIAxZ1TQyZrPuaW8=;
	h=From:To:Cc:Subject:Date;
	b=hSCnQ559RTI63Hc/xXTg6dTVAUqF0KtCpSgxTFn2Eyyo2qujVd3fERjxip2ngWuUA
	 jEmo2VlV88UdIaza6HcvPkVWQkNagsjy+OMhq1lLZlygv6G4LXbYm6GwWnonwznXxm
	 oKSS8IK/utesWIC5yixcms8SDa8Eu/6uF5BJF8qASobKOI0kSf371JLQeIpbYfAJqj
	 XNfzkEqAmpzUfI9U9JfS4he/zQZfXHCS98gQzgjmxBB+YBQvsNnUOGdRr+vyAIxpcz
	 XrpAaSUYjUmZO4ESc/1A7haijBFDgn+Smwr96zP7RBL2tSgrBFFqEJ5xmJYbUn+7Zt
	 nqJjFLyusyTZg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna.schumaker@oracle.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] SUNRPC: keep the client's sends on their node, and stop copying them
Date: Thu, 12 Nov 2026 19:16:09 -0500
Message-ID: <20261113001611.90519-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Two changes to the RPC client's TCP send path, based on
anna-nfs/linux-next.

The first adds WQ_SYSFS to rpciod and xprtiod, so that an administrator
can make their affinity strict and keep their work off far NUMA nodes.
Nothing changes until the sysfs attributes are written.

The second sends a request's pages to the TCP socket with
MSG_SPLICE_PAGES on its first transmission, as the server already does,
instead of copying them.  A retransmission is still copied.

Mike Snitzer (2):
  SUNRPC: Make rpciod and xprtiod visible in sysfs
  SUNRPC: Splice a request's pages into the TCP socket

 net/sunrpc/sched.c    |  4 ++--
 net/sunrpc/socklib.c  | 26 ++++++++++++++++++++++----
 net/sunrpc/xprtsock.c |  9 +++++++++
 3 files changed, 33 insertions(+), 6 deletions(-)

-- 
2.52.0

