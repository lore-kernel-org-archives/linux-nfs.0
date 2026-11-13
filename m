Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=52.34.181.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794612166;
	b=37xJPlKrPa8dwU/TwyRRCMdOvW7+CwjJLfwyj/7tPcWAjJSCa4jJ9uwnUR/1fhC1JCrd
	 G+KeJB9dHwykFOEoN3XNN/oabYCY7mp5Lz9YH/vdLQ7KzM5yoCR0fxeY7ImpRBmw3v6KY
	 CrtQhFZvxNvqozgmsx6dqEV3euulXmjmy7F9GvFLinJVDiJKCKepV2a3F36+6O9vRpz/v
	 7abRHmvfEBffOcxRHbROQ7DrkAAJ+KwgLUilLQ3RjaeDeNctPO1kwSr+e6BPLO5yXZBqf
	 x2KaJMdGg2kuQ40liFAvVoQF4kIrQE2iPkurp5UZMXeBSC5A3lvthVNEbrI96MIh+sA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794612166;
	h=DMARC-Filter:DKIM-Signature:X-CSE-ConnectionGUID:X-CSE-MsgGUID:
	 X-IronPort-AV:Received:Received:X-Farcaster-Flow-ID:Received:Received:
	 From:To:CC:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=vVx+JMwtPBMuQydLLiSO1xhLyBxdv1a3EAkmeOR3hPM=;
	b=MGVJpBoPLGWR5QmKg1jkV+uxmxUerTllO3lJth3qBhonN87nFOkQ4pZcBO7kWJVpp3+x
	 UnOeJk2nMVBl/heEsgtGrhpMwAF9Qn4JFCtxam8cM3CY0RUE4fs1iCr7y5xxQ3Ty+hYCQ
	 +YK2lGtJdGnEHqWrhImWvg0HwcAvFE/Mzwv4TB7wtCWDM+d37grMjK17E0durtKoHs586
	 xcDeyQSP8wAph4Zm7kMGT3daSH74eX7ZCvWpwZA2e9Y4NFiYSlBo8G6fyeVoO29G7QZPp
	 IGOm/iEyzBlK1qOriJZSYDc4O+vgmKDItauz/wZzt0s4o9hx8tZN7ZRzoDESw1iUbbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=amazon.com;
	spf=pass smtp.mailfrom=amazon.com;
	dkim=pass header.d=amazon.com header.i=@amazon.com header.a=rsa-sha256 header.s=amazoncorp2 header.b=Mm7oaiMd;
	arc=none smtp.remote-ip=52.34.181.151
Received: from pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com (pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com [52.34.181.151])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C5D7606A88A;
	Fri, 13 Nov 2026 23:22:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4C5D7606A88A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amazon.com header.i=@amazon.com header.a=rsa-sha256 header.s=amazoncorp2 header.b=Mm7oaiMd
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
  t=1794612163; x=1826148163;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=vVx+JMwtPBMuQydLLiSO1xhLyBxdv1a3EAkmeOR3hPM=;
  b=Mm7oaiMdV2dj4S/NxRzVUkqYMWlAQBzqj5U+zlNCjcC5p1bl5NXBtTqG
   Y4udfLwC7mrWIZuei69z4tRbYUDEOk1BeToU9VuW6G3jfiMXlA2SgUVt7
   MZIuMauTy2l8UnlM9d0fzrEQ4+TKqqsqDN+bq44CTcOL+sKL/N85lwkzJ
   M4rXaXsWe7nvhtJ/4mREyBd5/uFaX5dkpmRNSGgVjmAYYZbT7xvhuF5c6
   W9yKE7bJOTR5MEjPe/FwqwBR7+qolH+Fhnp2QZrZBLmhvZ4S32wfcPr34
   LDVw3oo+f9t0f6RrhycEntuSJISumpJYeLLkGgpYcEOoxa4KL5O+EqAcx
   g==;
X-CSE-ConnectionGUID: XISuTTF9QB2og9aEfhXPBg==
X-CSE-MsgGUID: wsnROOv/RkCcqme1xi+Pgw==
X-IronPort-AV: E=Sophos;i="6.27,212,1787011200"; 
   d="scan'208";a="33959237"
Received: from ip-10-5-9-48.us-west-2.compute.internal (HELO smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.9.48])
  by internal-pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 13 Nov 2026 23:22:42 +0000
Received: from EX19MTAUWA001.ant.amazon.com [205.251.233.182:28231]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.31.142:2525] with esmtp (Farcaster)
 id 133f35c7-3562-4cd9-9745-97d73287f980; Fri, 13 Nov 2026 23:22:42 +0000 (UTC)
X-Farcaster-Flow-ID: 133f35c7-3562-4cd9-9745-97d73287f980
Received: from EX19D001UWA001.ant.amazon.com (10.13.138.214) by
 EX19MTAUWA001.ant.amazon.com (10.250.64.204) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.56;
 Fri, 13 Nov 2026 23:18:34 +0000
Received: from dev-dsk-wangnyue-1a-719890fd.us-east-1.amazon.com
 (10.169.101.180) by EX19D001UWA001.ant.amazon.com (10.13.138.214) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.56; Fri, 13 Nov 2026
 23:18:33 +0000
From: Yue Wang <wangnyue@amazon.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>
Subject: [PATCH] NFSv4: avoid an rpciod deadlock when an async RPC frees the nfs_client
Date: Fri, 13 Nov 2026 23:18:24 +0000
Message-ID: <20261113231826.21760-1-wangnyue@amazon.com>
X-Mailer: git-send-email 2.47.3
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
Content-Type: text/plain
X-ClientProxiedBy: EX19D031UWA004.ant.amazon.com (10.13.139.19) To
 EX19D001UWA001.ant.amazon.com (10.13.138.214)

Unmounting many NFSv4 mounts while their server is unreachable can hang
every NFS mount on the machine for good. The rpciod workers of one NUMA
node are stuck in:

  rpc_wait_bit_killable <- rpc_call_sync <- nfs4_proc_destroy_session
  <- nfs41_shutdown_client <- nfs4_free_client <- nfs41_sequence_release
  <- rpc_free_task <- __rpc_execute <- rpc_async_schedule

If an async lease renewal (SEQUENCE, or RENEW for NFSv4.0) or an async
FREE_STATEID holds the last reference to the nfs_client, its release
callback frees the client and sends DESTROY_SESSION and DESTROY_CLIENTID
with rpc_call_sync(). The release runs inline in the rpciod worker. With
the server unreachable, the RPC waits on the delay queue, whose timer has
been rpciod work since commit 7e0a0e38fcfe ("SUNRPC: Replace the queue
timer with a delayed work function"). Once one node's rpciod max_active
share is full of such workers (171 on a 384-CPU, 6-node machine), the
timer can no longer run, so none of them ever wakes up. The delay queue
is global, so retries and reconnects of all other mounts stop too.

Release these tasks from nfsiod, as other NFSv4 async operations with
sleeping release callbacks already do. Only the release callback moves;
the RPC and its wake-ups stay on rpciod.

The cost: nfsiod also completes READ, WRITE and COMMIT tasks. If enough
teardowns pile up to fill a node's nfsiod share, I/O completion on that
node waits until they time out, about 6 minutes with the default
timeouts, instead of hanging forever.

Tested with 1500 NFSv4.1 mounts unmounted while their renewals were
stalled, then made unreachable: without the patch, 1024 rpciod workers
stay blocked and 477 clients are never freed; with it, no rpciod worker
blocks and all clients are freed within 320 s.

Fixes: 7e0a0e38fcfe ("SUNRPC: Replace the queue timer with a delayed work function")
Cc: stable@vger.kernel.org
Signed-off-by: Yue Wang <wangnyue@amazon.com>
---
 fs/nfs/nfs40proc.c | 17 +++++++++++++++--
 fs/nfs/nfs4proc.c  |  4 ++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs40proc.c b/fs/nfs/nfs40proc.c
index b07f2d6ccde4..2c3ecd9289f4 100644
--- a/fs/nfs/nfs40proc.c
+++ b/fs/nfs/nfs40proc.c
@@ -116,7 +116,16 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, const struct cred *cred
 		.rpc_argp	= clp,
 		.rpc_cred	= cred,
 	};
+	/* The release may free @clp synchronously: keep it off rpciod. */
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clp->cl_rpcclient,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_renew_ops,
+		.workqueue = nfsiod_workqueue,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
+	};
 	struct nfs4_renewdata *data;
+	struct rpc_task *task;
 
 	if (renew_flags == 0)
 		return 0;
@@ -129,8 +138,12 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, const struct cred *cred
 	}
 	data->client = clp;
 	data->timestamp = jiffies;
-	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT,
-			&nfs4_renew_ops, data);
+	task_setup_data.callback_data = data;
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
 static int nfs4_proc_renew(struct nfs_client *clp, const struct cred *cred)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1018b03c1cb..302f891c7a55 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9459,6 +9459,8 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
 		.callback_ops = &nfs41_sequence_ops,
+		/* The release may free the nfs_client: keep it off rpciod. */
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT | RPC_TASK_MOVEABLE,
 	};
 	struct rpc_task *ret;
@@ -10468,6 +10470,8 @@ static int nfs41_free_stateid(struct nfs_server *server,
 		.rpc_client = server->client,
 		.rpc_message = &msg,
 		.callback_ops = &nfs41_free_stateid_ops,
+		/* The release may free the nfs_client: keep it off rpciod. */
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_MOVEABLE,
 	};
 	struct nfs_free_stateid_data *data;

base-commit: 7e1392a42ea288d70a266f6553fe06f57f8647ea
-- 
2.48.2

