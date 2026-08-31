Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A56F54A4414;
	Mon, 31 Aug 2026 18:22:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200536; cv=none; b=heSNNznIhA11UokJup3LEK6MQzdinPITd/YISVU/8jzyAoc+9bPTcAnUF2JXsMfe//t8DFwGB2v09A+49cC4q7wUjEAHtLR9F9F9zajjAuJyhCaZILGKyubOc7r7aHp3C5POPmY/VpvgiiV9eIa4awUPvnQmw4elJuGoZ/D4f8M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200536; c=relaxed/simple;
	bh=xT7HizUrknGMjf/pPX9I2cRTBh8bgQVEBDDV51nL1X0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Zo1M4OVMhvHd/duZEQzMikz5hvHUfJjqzbTH4p9ARtJJEooUf02K2xMPWhVBRG/XMR90KDvqhqAZQN8Z6l7c2qy7m9NiDTI61WD+GCMCvb1RD1F5MXn3STnJzHTmmIanw0JTdgdn9mRCvkN1cnaHTCTgw8dSEHCDJhE5EUfeD4s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BLN5ppeS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BLN5ppeS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0E55B1F000E9;
	Mon, 31 Aug 2026 18:22:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200534;
	bh=NFZHnOZfgrGz8mBkIoJ8Uq/DZjW0+VctiqeMxOFdM9Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BLN5ppeS7uHIJGvwBLObqcmTRLLiJCrgy5huyttjTZ7nSa0cWAQvUC79rG0EHcgbc
	 tdsD/ykZZH0N6NmO8DmS+yufqykwHJC5WAVbxlokhxn0Q2k8Lc5QyPTJeXiau5HuKY
	 dWx/l9X4esOtVmFzmUDz2Re0KMdAFu7QTC7jKi/1Idk/KRZcq7ZTF5ojeVPZo9IQWU
	 wOCgh244yCksso/pT+D5V10SQit0m+n7zmXCr4elWYwBRZ9a73OdtGVgnROUDqMqJh
	 jamfU16ZmaDazmmkNEuQbCD2YOpMD59ftUEZdtahCWH9MKEs2vNm/dayIlEuElNMWR
	 EAQ0tsDFGwTlQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:22:04 -0400
Subject: [PATCH RFC 8/8] SUNRPC: Reduce xprtiod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-8-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=875; i=cel@kernel.org;
 h=from:subject:message-id; bh=xT7HizUrknGMjf/pPX9I2cRTBh8bgQVEBDDV51nL1X0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZP5nKqeYag30AG0GTN1esiHQX73ffO8sLq5
 +TNUUk2dcmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 l/gzD/wPbRSVBV0PBWuiS4P+BZ8p0IcfWe90a7g9R5eWpeunnk25H9hv5KpIJa0mAy81necntm0
 RmLJNM1ETHohLRq18VSkHGOAbm0GHg1DMV8y1y7vBhhMs0qy8tVILrw4cl/bXWmGDEq7qHQfxyB
 dRMWvqTaKFzE2L4QC/k2jkA1fKlg3III6fD78hcdynguog69aFMpw4514mkvBOuBFXf29APnnGy
 AodrIMN0N09fhPpXzSK+S/Z6oYhl2FYWx6Z15O2B+M1wTEOp27bZC/5zC9qVmy6opNrKa0+qqGf
 8K10a1E7QqsGTbF2xam4glfAqyOfqyixoM6S7BanYnWUFtO6XIEkQ9X6Vgm3t/bAWA3WX1y73/E
 yJynqGLbfR4RZw6Q7MrE3Mcbi8Eu5crORIQk3Zqa4pypvD/IPK3Wyrzc0HhXsWRjZ6pvCAO0V9m
 Z0joktucneaNVgde7Cc98xWw+daRQLIzOf1E8yZr0v7VD5Fggl/8fNhEgJ8GiL56ojhJt/AqRK3
 2no4w+l7yQ0BnfHx96pmGDhxxk+N+Nunw600cHQuJ+rh3ZljeohZNiLvFhHkXgLREQahds/n4+r
 AejBhizsaTudlHD2np4sZmk8d+bXI9f3p6/FxvH7XhK3bXZ9gTOax4dba4IqEJVj83pjymEvmMl
 BJatB6Ulltj65Dw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xprtiod handles transport-level operations: socket receive
processing, error recovery, and connection lifecycle. On systems
driving heavy NFS traffic, these operations contend on the UNBOUND
worker pool lock just as rpciod does.

Set WQ_AFFN_SMT on the xprtiod workqueue to give each SMT group its
own pool and lock.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sched.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b84af2c0b104..3236dfdb4096 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1304,6 +1304,7 @@ static int rpciod_start(void)
 	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)
 		goto free_rpciod;
+	rpc_set_wq_smt_affinity(wq, "xprtiod");
 	xprtiod_workqueue = wq;
 	return 1;
 free_rpciod:

-- 
2.55.0

