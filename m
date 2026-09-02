Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BF3F39EF12;
	Wed,  2 Sep 2026 19:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377364; cv=none; b=NTEA7xTFmNA4VILp0CLz1VSFGm1no7FSbylBrC5X+9JPCsVPoLzqMTSLP4KSQrYa6/5Ubc+WovgPl/K/Dt2Fz/wxIh0v2Mo54A3T43cNp757SCAhTYX3rLMu2D9mqWHjB8W/7Yny9OKor5C1A7IJ2P6j7Q/Cwq4CkyT3GZgwu3Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377364; c=relaxed/simple;
	bh=8U0XBPRVxSfOU0obQjD1fxaP88zM2TcU5L4hYzBluvY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=M2o9aYjyMmxEssCmGBBls/ebmKS7h6QdpCbVn7zTNyldsbsXugKNxXwEQfHxn2dbriQDUX2NjBaiqip6X8uYyAvdnblEcUYtXLOpqlN3u2uw3h3N5/X+OZK1LLWhDgDZA9wwhmBNsEkHjzp05t6x0B7fX1Q/yyFcuJNUKTR5TBo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jsz9pgy4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jsz9pgy4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 576AE1F00ADB;
	Wed,  2 Sep 2026 19:29:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377347;
	bh=Oqjf36SDCKS8VzDfnH6ImhAmZ1KHIl0D7LfeOiVeArU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jsz9pgy44s5jK9Y2y4/YAXiy5MO8jxZYQYPRwjI2g0AevKdQQX7deLJJXFaizYAUU
	 yWODiwzzbsd/sxEtLnIXex3eyseuT3+720gfoJAdXv1pqpCl6UtzlEztAKskzy/eaD
	 TWX35QTRdwddwnQUQEt69VzOpfdvZRm2Uuj/RtzHIGeXMr+rB/JzpzjK/GCeykJ1M/
	 fuRm+sY/vr7WmdqLorobbf0UJ/sI1Z+Qjni2K8crOfAOw6f8mQcZKzrnPTe6IyAUhP
	 S5cfrgmID7zMN7zd96J7rkJmgKKTqQcVA1WW9aDNYE9broJ6E7vKnz+W9/2ECra3a1
	 s5l1ao363lMdQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:48 -0400
Subject: [PATCH RFC v2 3/8] SUNRPC: Set WQ_SYSFS on rpciod and xprtiod
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-3-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1248; i=cel@kernel.org;
 h=from:subject:message-id; bh=8U0XBPRVxSfOU0obQjD1fxaP88zM2TcU5L4hYzBluvY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkAhBl6UAuyLi+KpB+/ch9lI+aI4JqgbZp0X
 KBAopwQNamJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l/R4D/42tBmmj06EEIB22lTVPWqgLgbbtgF8+INJsb2G/+x7ezyxQUbuGbDGqV3br5hvaSAaIMb
 ZCc/G1MdvrGZ1BS209jCQA9OoKR5vju8lHHVNUJtuMKKwyl5H2kCjVRJmpsKcgpc9TbSie+fiF+
 efOdJKU4ysZc9QF9Imd4fen8qVurJiUh7FEhwYBebOPikL7KaPYuQ5fzJErPrloL8OFK/cSOSFu
 r/f5F5PJ+yGfd1GeV76YG4li04SiijtJmJ4TzAPODI+hu9fSts7PabFXlQBmOpov3QAq58qJYS1
 i92VQjtlwscjOV9E82RLfjx2UzROiAloylYpZMT52FtLaMSCr6d/yjL6yBohj4zA6JBpzytyJBc
 Q8R98wTfY+z0xhzGDdSz86MO3XQ55juFdqnradvNzhDSM3HOv7DCD4ueI42RcMr2pUc/IMiozpV
 MoTjaUIFgIRW3/dwjtEsZEVDMeIWIbgamS3VYr5skZWbMxwFcb2ntvDONVyFuqf5NHunIeX8B6G
 mP1rp5NE/uqedhCHXerYPCikyAqZDByDO6X6EtO/uJ/1dgFJrfEcoVKK7WDpfXmEu6COa9nc6ie
 efV8zw0CQqHrjpgJ8nwBPcClsVILZG3BLNmNCdmICXcnif9W7GHKTMvgDJRuYxk4RBSHU55n9sY
 ncELwmij1zstWtg==
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
2.55.0

