Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35186 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbcLCU6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Dec 2016 15:58:08 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so6821785ioe.2
        for <linux-nfs@vger.kernel.org>; Sat, 03 Dec 2016 12:57:30 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] pNFS/flexfiles: Only send layoutstats updates for mirrors that were updated
Date: Sat,  3 Dec 2016 15:57:17 -0500
Message-Id: <20161203205725.12961-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161203205725.12961-2-trond.myklebust@primarydata.com>
References: <20161203205725.12961-1-trond.myklebust@primarydata.com>
 <20161203205725.12961-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there have been no reads or writes to a given mirror since the last
layoutstats update, then don't resend the same data.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++++++
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 +++
 2 files changed, 9 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index a6264d6836dc..540813c30b00 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -705,6 +705,7 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 	spin_lock(&mirror->lock);
 	report = nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat, now);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
+	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 	spin_unlock(&mirror->lock);
 
 	if (report)
@@ -721,6 +722,7 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	nfs4_ff_layout_stat_io_update_completed(&mirror->read_stat,
 			requested, completed,
 			ktime_get(), task->tk_start);
+	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 	spin_unlock(&mirror->lock);
 }
 
@@ -734,6 +736,7 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	spin_lock(&mirror->lock);
 	report = nfs4_ff_layoutstat_start_io(mirror , &mirror->write_stat, now);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
+	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 	spin_unlock(&mirror->lock);
 
 	if (report)
@@ -753,6 +756,7 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 	spin_lock(&mirror->lock);
 	nfs4_ff_layout_stat_io_update_completed(&mirror->write_stat,
 			requested, completed, ktime_get(), task->tk_start);
+	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 	spin_unlock(&mirror->lock);
 }
 
@@ -2201,6 +2205,8 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 			break;
 		if (!mirror->mirror_ds)
 			continue;
+		if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags))
+			continue;
 		/* mirror refcount put in cleanup_layoutstats */
 		if (!atomic_inc_not_zero(&mirror->ref))
 			continue;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 3ee0c9fcea76..09f292e3a4ad 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -81,12 +81,15 @@ struct nfs4_ff_layout_mirror {
 	struct rpc_cred	__rcu		*rw_cred;
 	atomic_t			ref;
 	spinlock_t			lock;
+	unsigned long			flags;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
 	u32				report_interval;
 };
 
+#define NFS4_FF_MIRROR_STAT_AVAIL	(0)
+
 struct nfs4_ff_layout_segment {
 	struct pnfs_layout_segment	generic_hdr;
 	u64				stripe_unit;
-- 
2.9.3

