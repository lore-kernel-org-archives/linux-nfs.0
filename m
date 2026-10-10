Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [131.169.56.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D42C32142B
	for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 22:19:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791670755; cv=none; b=Rz20bE30a3rDoT8RbZ6DWLLE6bcoF54Ne/oTHrx9QqbfRkyMMMx4yyUPv5DPDHD8o46kplXE+Vw7kWnmBk4DJxIjXS6cCHIjmV+xGOP0iMJLpEkG9VQQQ1+u2VMXyn1SKKKPYMtLQFQ+CVkwiX69a7DF0V+xpzXpj6wuHsVNfoo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791670755; c=relaxed/simple;
	bh=o5C6kfC2OeRMuL57hdfv5YlcP1YKKIh9rWEpux+NbEU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kluArFsc7nhtFuExhT4oK2Wq8dz3X0UMYON75pWGYwMPnXufQeMfox2OUHCgRVX7ym/MMm9+0zhHP10In1aqJ62K61Wc2ojnxyGmWJCQpDVqi6847TLgnQq3RkSmocPfOj7PeAl+JwgccCQJpLvoxBR03HqNBMwFdRKODadShKk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=VzJXLdvV; arc=none smtp.client-ip=131.169.56.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="VzJXLdvV"
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 5A66613F647
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 00:19:04 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 5A66613F647
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1791670744; bh=yjPEAWe2G7T7fXrrXsJkLJ3XkNf3ertiTtExgZ6z80I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VzJXLdvVNNeIkcdv3act4I2QAu91VDidX2+dnLu8wjeaFR/yQGkoYXgoPTfuvRUrd
	 Wk7gkIcyXQ1SERihPkC/qLe6NrYLBdeeFdqGa5AZp4vKfjTyAxilkdY2qReJBagA8C
	 KlP1CnvF39eChSHvPJH7/FrPtvPT9xjjbAhbfq+M=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [IPv6:2001:638:700:1038::1:82])
	by smtp-buf-3.desy.de (Postfix) with ESMTP id 4B5F0C0040;
	Sun, 11 Oct 2026 00:19:04 +0200 (CEST)
Received: from a1722.mx.srv.dfn.de (a1722.mx.srv.dfn.de [194.95.233.47])
	by smtp-m-2.desy.de (Postfix) with ESMTP id 39696160043;
	Sun, 11 Oct 2026 00:19:04 +0200 (CEST)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [131.169.56.82])
	by a1722.mx.srv.dfn.de (Postfix) with ESMTP id 82D7B3200A2;
	Sun, 11 Oct 2026 00:19:03 +0200 (CEST)
Received: from z-prx-2.desy.de (z-prx-2.desy.de [131.169.10.29])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 74CAE80046;
	Sun, 11 Oct 2026 00:19:03 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-2.desy.de (Postfix) with ESMTP id 68DDD6053A;
	Sun, 11 Oct 2026 00:19:02 +0200 (CEST)
Received: from z-prx-2.desy.de ([IPv6:::1])
 by localhost (z-prx-2.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id cG8ZKLlnv-1Q; Sun, 11 Oct 2026 00:19:02 +0200 (CEST)
Received: from nairi.desy.de (VPN0276.desy.de [131.169.254.21])
	by z-prx-2.desy.de (Postfix) with ESMTPSA id BB00160005;
	Sun, 11 Oct 2026 00:19:00 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	snitzer@kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/2] pNFS/flexfiles: make pg_init retry loops killable
Date: Sun, 11 Oct 2026 00:18:38 +0200
Message-ID: <20261010221839.42172-2-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
References: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a task is killed while the pNFS client connects to a data server,
nfs4_pnfs_ds_connect() fails with -ERESTARTSYS. If the layout has
FF_FLAGS_NO_IO_THRU_MDS set, ff_layout_pg_init_read() cannot fall back
to the MDS and retries after an uninterruptible ssleep. As the fatal
signal stays pending, every new connect attempt is aborted the same
way and the task loops forever without returning to user space:

  # grep -E 'SigPnd|ShdPnd' /proc/156021/status
  SigPnd: 0000000000000100
  ShdPnd: 0000000000000100

  # cat /proc/156021/stack
  msleep+0x2e/0x50
  ff_layout_pg_init_read+0x267/0x310 [nfs_layout_flexfiles]
  __nfs_pageio_add_request+0x1c1/0x480 [nfs]
  nfs_pageio_add_request+0x21d/0x2c0 [nfs]
  nfs_read_add_folio+0x143/0x200 [nfs]
  nfs_readahead+0x204/0x290 [nfs]
  read_pages+0x62/0x230
  page_cache_ra_unbounded+0x136/0x180
  filemap_get_pages+0xf2/0x350
  filemap_read+0xd5/0x320
  nfs_file_read+0x6d/0xc0 [nfs]
  vfs_read+0x24f/0x3a0
  __x64_sys_pread64+0x90/0xc0
  do_syscall_64+0x5f/0xe0

Previous attempt propagates the error from nfs4_ff_layout_prepare_ds(), but
only ff_layout_{read,write}_pagelist() look at it. The pg_init functions
test IS_ERR() and retry on any error.

Check for a fatal signal or an exiting task before sleeping in
ff_layout_pg_init_read() and ff_layout_pg_init_write() and fail the I/O
instead of retrying.

Fixes: f06bedfa62d5 ("pNFS/flexfiles: don't attempt pnfs on fatal DS errors")
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..c636983f1e12 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -961,6 +961,20 @@ ff_layout_get_ds_for_read(struct nfs_pageio_descriptor *pgio,
 						 offset, dss_id);
 }
 
+/*
+ * Wait before retrying pg_init. Returns false, with pgio->pg_error set,
+ * if the task was killed or is exiting and must not retry.
+ */
+static bool ff_layout_pg_retry_wait(struct nfs_pageio_descriptor *pgio)
+{
+	if (fatal_signal_pending(current) || nfs_current_task_exiting()) {
+		pgio->pg_error = -ERESTARTSYS;
+		return false;
+	}
+	ssleep(1);
+	return true;
+}
+
 static void
 ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 		      struct nfs_page *req,
@@ -1062,7 +1076,8 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			goto out_mds;
 		pnfs_generic_pg_cleanup(pgio);
 		/* Sleep for 1 second before retrying */
-		ssleep(1);
+		if (!ff_layout_pg_retry_wait(pgio))
+			return;
 		goto retry;
 	}
 
@@ -1086,7 +1101,8 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 		}
 		pgio->pg_error = 0;
 		/* Sleep for 1 second before retrying */
-		ssleep(1);
+		if (!ff_layout_pg_retry_wait(pgio))
+			return;
 		goto retry;
 	}
 out_mds:
@@ -1141,7 +1157,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 				goto out_mds;
 			pnfs_generic_pg_cleanup(pgio);
 			/* Sleep for 1 second before retrying */
-			ssleep(1);
+			if (!ff_layout_pg_retry_wait(pgio))
+				return;
 			goto retry;
 		}
 		pgm = &pgio->pg_mirrors[i];
-- 
2.56.0

