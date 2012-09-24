Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38107 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102Ab2IXT5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:57:54 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/28] NFSv4.1: Retry pNFS after a 2 minute timeout
Date: Mon, 24 Sep 2012 15:56:25 -0400
Message-Id: <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we had to fall back to read/write through MDS, then assume that we should
retry pNFS after a suitable timeout period.
The following patch sets a timeout of 2 minutes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 15 ++++++++++++++-
 fs/nfs/pnfs.h |  1 +
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d6fa244..0b5387b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -35,6 +35,7 @@
 #include "iostat.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
+#define PNFS_LAYOUTGET_RETRY_TIMEOUT (120*HZ)
 
 /* Locking:
  *
@@ -248,6 +249,7 @@ pnfs_iomode_to_fail_bit(u32 iomode)
 static void
 pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 {
+	lo->plh_retry_timestamp = jiffies;
 	set_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
 			iomode == IOMODE_RW ?  "RW" : "READ");
@@ -256,7 +258,18 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 static bool
 pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 {
-	return test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) != 0;
+	unsigned long start, end;
+	if (test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags) == 0)
+		return false;
+	end = jiffies;
+	start = end - PNFS_LAYOUTGET_RETRY_TIMEOUT;
+	if (!time_in_range(lo->plh_retry_timestamp, start, end)) {
+		/* It is time to retry the failed layoutgets */
+		clear_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
+		clear_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
+		return false;
+	}
+	return true;
 }
 
 static void
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e3eb7d1..bc8e500 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -140,6 +140,7 @@ struct pnfs_layout_hdr {
 	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
+	unsigned long		plh_retry_timestamp;
 	unsigned long		plh_flags;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
-- 
1.7.11.4

