Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:59156 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753414Ab0JGTR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 15:17:58 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SQUASHME: pnfs: get_lseg in nfs4_layoutget_prepare rather than in pnfs_has_layout
Date: Thu,  7 Oct 2010 15:17:58 -0400
Message-Id: <1286479078-29072-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CAE16FA.9040606@panasas.com>
References: <4CAE16FA.9040606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

pnfs_has_layout does not get_lref on its return value anymore

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 25bc169..97cc539 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5442,12 +5442,12 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 		return;
 	}
 	if (!lseg->valid) {
-		put_lseg_locked(lseg);
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: invalid lseg found, waiting\n", __func__);
 		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
 		return;
 	}
+	get_lseg(lseg);
 	*lgp->lsegpp = lseg;
 	spin_unlock(&ino->i_lock);
 	dprintk("%s: valid lseg found, no rpc required\n", __func__);
-- 
1.7.2.3

