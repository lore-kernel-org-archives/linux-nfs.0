Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5E303A6F04;
	Wed,  2 Sep 2026 19:29:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377360; cv=none; b=nmQkQVouav8YNXt7Gr4LSwM6DBb73Tg7dh2C/ymkubczi/zx6fkYhIeSHtjf4cpJRGWvbaiFmGCMAlzhDbDAd+CfKSEiCrHz0JAU9FCXJdKzM2awN+3tjWj9+FDqPTSdnwdpIQwFVEz+oLcpP7VEnLJo8hZYkd8xkldUIogbG24=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377360; c=relaxed/simple;
	bh=3Jw7o41F/A1SDrtWghxIVFeAWgYLWjA00RvC+YvDL10=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RaS/JOjqFQ6odh2MZadbc5cW/CmeNtKgbqI8rt6atp7oy42vMw8c891U8fDaQDUYbLPf/yHkJ6Bvf61hIkMTxX6WYefrGr32kTQR+H1V1n1l77uDLFoEg5rTT+nCOI7OYRp5vK9igMJ3XmbHzTu42+nnKNbLXITu568Sb3p1Ie8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iDxGrzBh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iDxGrzBh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 432A41F00ACF;
	Wed,  2 Sep 2026 19:29:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377351;
	bh=8D76IdjG5RCkGqgJJYSjBkybiBKnaTAZ9CnZKgv9Dfk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iDxGrzBhrtV3et7EFjOYAdajuSriWFxS7fdB/ThScSmJINVacHODWrQO6PdntvRby
	 BwVqsgq9oHUiNgfryrdSC60lKgl7dui+/u/4bp0dcB7vR6ozSlm/qVdG/zFAsxE5c4
	 ve6r2uGpC1irh3X//5MoncbGaVvrct6Fi2Zm2R1d23YqNY5g4/JOsreBytaHMKMecO
	 fI5LSPS417iSE62PAPSjGxsQmXHSlEMQs4zaCFAQnbLTCcpNwaSODueO1//xGMIoPZ
	 jtwE7DTWL9gC/ECk722IYEIeKnzZ2aGEZo4MNd0QfnUtvzc+Z4T4DHngW3ST0knOFk
	 RSFaqHdON1RNQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:53 -0400
Subject: [PATCH RFC v2 8/8] SUNRPC: Reduce xprtiod workqueue contention
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-8-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=875; i=cel@kernel.org;
 h=from:subject:message-id; bh=3Jw7o41F/A1SDrtWghxIVFeAWgYLWjA00RvC+YvDL10=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkATSl09RG7ifjXrwhFtzjpVY+n9p9D2pRqE
 lTPq/TDJcyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l9a0D/9V2sEgivDgG9qZnZXwL0oQXVmyPPsI03zXmS220U97QgMiQ0CDOtcfazyHqWeuDH66w3/
 zxrVOgpFBu2vAlCcyBj1VdbAFAIEksXOO4FMf7pLmklI/7QYJCt1fHWWa3ifcutzVM2Run/le+9
 eduY+7oNmaQvOnyf9u1aLLsfv2K4nNYWek6P98/OdXfqaLJPAHAvEbNro6vSbqEAAZ6/LV3tnPD
 gG2hf+eqx07grSqRUjuMu6Bf2Lay6GoiKeAVjU54PmX5tEgf6X+HPEF2mCcyalnAnBNr9nwCwlj
 hAaqel94xPeIDApHu8uNePP+zh1jvomKjj032zY1FDuc9IksvkWD9fM58fViM0M6k07UW9IP2YN
 C09UITnuk53n7VB7DSiJ8Izvf0qvyywkwoOJF7HX0boGmVsKp0Vn2hr4FgcZ6P5rO3vbam8ERVV
 TSlktofh3YHfFW5Hd9CwkgrcPKmKhJ/o/3tKLda6zq2GydM6FTySlvVrwijXikXvzJhRxk1p6VI
 2++rNclefqVBreuhjb/t6bKIZ8jZCa9YX9KS2zBna0JVK+Z4O5dHhDQOOPL2md3wsRNFSCRhhji
 K6OHo/i0Szbnu2GEhh6YnI2APqZJFRFMizUmmIPsq9AjNU/fNSKvtFqRNacjJa9ylmAOJZy8Afo
 vnOcWpg6D4+Fs/A==
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
index 2a1938b9e41e..e678326e6b0d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1298,6 +1298,7 @@ static int rpciod_start(void)
 	wq = alloc_workqueue("xprtiod", wq_flags, 0);
 	if (!wq)
 		goto free_rpciod;
+	rpc_set_wq_smt_affinity(wq, "xprtiod");
 	xprtiod_workqueue = wq;
 	return 1;
 free_rpciod:

-- 
2.55.0

