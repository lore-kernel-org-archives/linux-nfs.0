Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794528974;
	b=yEqADJxl/rfccw9dAL/haISqMYhdp7LH3ovswgYeDexOQgpEtZVlPszLwXJ8ObczBRGo
	 hZRumVYimu8Cp6qS42Lln352VuvYUcIOtFqUtKZRMYOXlUkFIEVNz4WeGpJFkQQXQ3DNj
	 Yhv3Y+G8Qu+BJpcEG2lvcirTG9fWK3uWi80lt+58eguLEI4Bf+SRaPLqfokW+uKBABJr1
	 IMJQCuk2XayxPGskQUWcemFQdnyyVJ1PDJRaMEC0CAWOFfBH7A2vCejEZk6e5A3Fit+Rg
	 Bm/gAOiKoUKy4SGSjmZ5K6rgSFAH1VKA4ygQPsPGT0dOzuKJWNz6arcGDpoT91LFy9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794528974;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=iEeNxFmmecro+W9JF3V46T1CQ2ddY5Cny3BjMT6qUgk=;
	b=iuuFKwiA6aLlCAnH7dYeeRBK722exDV/9gDHANXdVrV8D+V/FlMOxz4VADkogxEUjZTn
	 X/gHCl4OtDNzETqyKhs5liVisg48aODkBzSRNwCESvZjmGCNBhmw4KXCx1gY5IqwSa0Du
	 ErDvzFhkYbxkGj4Awb8Bz+gJv+k1LYQtL46G1AweL5Kasn39lL63xqgH+WtEyUuYJsx3+
	 tQTcnbYlurqv9FRja5o68r+XMMrqQ6d+Dluxz6kh1OR1xmjKEHrxkToxT8yCOapsg6FT8
	 UFcLFm4bGdlHjfZoGqEmzbNbKCWsLVHPsKwTLonuOM33ozQXzgB5Z/hsEAlrCp9MiaQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oem0SsVS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6534D606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 00:16:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oem0SsVS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0EE551F000C5;
	Fri, 13 Nov 2026 00:16:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794528974;
	bh=iEeNxFmmecro+W9JF3V46T1CQ2ddY5Cny3BjMT6qUgk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oem0SsVSujOrIFcH/gNkJkOlEqMqr797jxrveWTsvVsZvM0YYL44NGdxWpa+JoWDF
	 oIsmiZHFY40l7vAC50uK2Oc4/5g/Badj0x1AJj8QrIW4cWAFZxJVR4Vc2m3EoDNZ51
	 jX8jh1XLUiNXlMrvqdqZORyXFFKuzASDgMtLYjJwsdLBTD1G0aR1yNKC3duHGX7+ki
	 FmXst9+t3XDQthwZPbPh2YFvWHvxNKMTVBqChgrEDvTb1+p8HaA/ONQ6ZFhg83JYWx
	 gJtZvjG+EuZNb2H3IBUYQ161hTdA9BP1CYySgFfUKvJmaOozt6vlK/3ApB1N5MW8nL
	 F2ZfR5Zrh2MUQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna.schumaker@oracle.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Make rpciod and xprtiod visible in sysfs
Date: Thu, 12 Nov 2026 19:16:10 -0500
Message-ID: <20261113001611.90519-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261113001611.90519-1-snitzer@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
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

rpciod and xprtiod are unbound workqueues.  An async task's work is
queued to the affinity pod of the CPU that queues it, but an unbound
workqueue's affinity is not strict by default, so the scheduler is free
to run the worker on any CPU the workqueue allows.  On a two-node NFS
client whose writers are pinned to the node local to their NIC, with
the workqueues' affinity scope set to numa, 1.5% to 2.4% of the skbs
sent on each port were still handed to the driver from the other
node's CPUs: 97% of them from rpciod running rpc_async_schedule(), the
rest from xprtiod.

Neither workqueue can be made strict today, because neither is created
with WQ_SYSFS and so neither has affinity_scope, affinity_strict or
cpumask under /sys/devices/virtual/workqueue/.  Add WQ_SYSFS to both.
Nothing changes until an administrator writes those attributes.

With affinity_strict set to 1 on both, the same client sent nothing
from the other node and spent about 1.7 fewer CPUs at the same
throughput.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 net/sunrpc/sched.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca57799..83e2974a44d9f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1278,11 +1278,11 @@ static int rpciod_start(void)
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (!wq)
 		goto out_failed;
 	rpciod_workqueue = wq;
-	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
+	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM | WQ_SYSFS, 0);
 	if (!wq)
 		goto free_rpciod;
 	xprtiod_workqueue = wq;
-- 
2.52.0

