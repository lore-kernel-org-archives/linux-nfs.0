Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59DAD3B0ADB;
	Tue, 15 Sep 2026 14:20:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789482060; cv=none; b=ez6MhQjODBatsdRO0YSBZPW2Llcpn1caCYPKSL5T2UL2Qc95cYce0WRdzVqVz50dKQ8lBy9IHe3Vo7R1l+Y0HExGxybthiJQW86n+/2vXCjgFgAP23ClrGlqUO90K83iWkKdaUjkpbZdXHYnDJuCNEg+WI93FG6r01TC3k+OfnU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789482060; c=relaxed/simple;
	bh=MVWfLseSKoY8UWv3qOWXRywa9v8PwRgqf50RtAy70fY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=F8gc07PaTjchX7/LT03gAucNed/KLtDqEiLQLOkwReX9fay1BH2pVjdLzrgr2VvBWwPJzGxFTxwIibVbnAaTNmr5CRbYvqRWiK0RlvUa1ds72PnFCAUvhr04Gopwf/pR/bHOpxQza3qY2CCDQPNZq2azphOcDCvxfCgps0KRfVI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JVLaOBuE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JVLaOBuE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 41B791F00899;
	Tue, 15 Sep 2026 14:20:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789482057;
	bh=uOoXR9XwKEVJv+80SOBDs9JGjW6p0beKPPbXNt3sOPw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JVLaOBuE4NG6yO/4lO3N0SIt4l+6VPByZD09YeJmDGeITHSNG56gmY82Q+BOUF0Lx
	 ioDcHcqedzzUz24Dge9TX9wP/NnGPIP6bqTQXZ6e7Cl+bZu8H8Ry7IjtNU88Od0hHY
	 DFnTdCBOGTIfK9DvmhjzSNwNNGit+q3N/by3p3/XvVlHJ8gy8iAf+Df6oCgtLX4hsn
	 nv8gDv6tue23MnFWSLyHWFyWyqQEdu9A8PiSbdxy1y+GYTyDyLqr+EOE00exOXlDPM
	 chWzl87Uw4F4CYlTyrKsSg9ryZ6/EXXh3g6NY0vnNuf/tZ2b081/BGt+drd7Jm5TXF
	 NahaGPvqLrEFw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 15 Sep 2026 10:20:43 -0400
Subject: [PATCH v3 3/4] SUNRPC: Set WQ_SYSFS on rpciod and xprtiod
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-performance-v3-3-ae26d460bfd3@kernel.org>
References: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
In-Reply-To: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Tim Menninger <tmenninger@purestorage.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1248; i=cel@kernel.org;
 h=from:subject:message-id; bh=MVWfLseSKoY8UWv3qOWXRywa9v8PwRgqf50RtAy70fY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqVRGyoM/WxhBmaluE0lgn0JDVdi/22fNoI1Fv
 gQy+82xgoOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqlURgAKCRAzarMzb2Z/
 lwy0D/wJOjFQvrvrrZ3zgcALTegBuuHkGLJ36p3E35kf1L8QuzfLSqnQGBfXI05PccRpoYK5cTJ
 xAJ4k1wIZ+xVrEtuTN6aOw2B7UjWbSIcQz1YBjFZG0YLdaAafDDCEooekm+2ir7zfr/d6SGaOA3
 vv+oQU5ADLc9KjrDhEZ/ilc4qseKEGi3zEqvSGi+glJlSecd6XI921/5bRJT1goyeVQ3AxYB6zg
 Faip7M56MPi6WXvxBrguDC/YiJo652iEBuhvbKmqTcsxh2h2w3rAnU3GcUSE6pXcmHooMgcbB1Z
 QKG9cW5xqLU28Bio5LOHvo0gq8ffo60KjD/1LULQ0TWB9MhfNFnOlYt30p87nDkGbURtiOzKzcU
 xfJfg82n66fkQX84wUAio1+EBHHfdi3+htXTNTgMAhsNZqQKLCs7h0ABjRBfT9pkQdG3S62JSRo
 jdUbsOq4eQI1W2mT+weyyHosfFYQERdr3S/0bLUEYwLe3+a8Sb87rsXnFJRzAG/sGMhi3X9pP4v
 AwxWeYQBDmhiR2I8iuTfW9nK4NtZxXgBSK4ML0Th8dhN41MH4v2fGQ7WgVh2Ae9C2hvpqO1MPPV
 XcgT9+/0MHQhzXh7j7tSv5Z+y2QjiNiJ+a3c38UNxmqevCUBlP3j4L5aBGM2SQLutE+zDKRGqyX
 Tf/wCSN5eHchGcg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An unbound workqueue's attributes can be changed at run time only
through /sys/devices/virtual/workqueue/, and a workqueue appears
there only when it is created with WQ_SYSFS. rpciod and xprtiod are
created without it, so their affinity scope cannot be tuned without
reloading the sunrpc module.

Create both with WQ_SYSFS.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sched.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca5779..e81419aa553c 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1273,16 +1273,17 @@ void rpciod_down(void)
  */
 static int rpciod_start(void)
 {
+	const unsigned int wq_flags = WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS;
 	struct workqueue_struct *wq;
 
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	wq = alloc_workqueue("rpciod", wq_flags, 0);
 	if (!wq)
 		goto out_failed;
 	rpciod_workqueue = wq;
-	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
+	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)
 		goto free_rpciod;
 	xprtiod_workqueue = wq;

-- 
2.54.0

