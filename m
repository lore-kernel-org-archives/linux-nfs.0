Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:5691 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdFGGnI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jun 2017 02:43:08 -0400
From: Tuo Chen Peng <tpeng@nvidia.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Tuo Chen Peng <tpeng@nvidia.com>
Subject: [PATCH] nfs: Fix fscache stat printing in nfs_show_stats()
Date: Tue, 6 Jun 2017 23:42:44 -0700
Message-ID: <1496817764-3641-1-git-send-email-tpeng@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_show_stats() was incorrectly reading statistics for bytes when printing that
for fsc. It caused files like /proc/self/mountstats to report incorrect fsc
statistics for NFS mounts.

Signed-off-by: Tuo Chen Peng <tpeng@nvidia.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eceb4ea..b417639 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -879,7 +879,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 	if (nfss->options & NFS_OPTION_FSCACHE) {
 		seq_printf(m, "\n\tfsc:\t");
 		for (i = 0; i < __NFSIOS_FSCACHEMAX; i++)
-			seq_printf(m, "%Lu ", totals.bytes[i]);
+			seq_printf(m, "%Lu ", totals.fscache[i]);
 	}
 #endif
 	seq_printf(m, "\n");
-- 
2.7.4

