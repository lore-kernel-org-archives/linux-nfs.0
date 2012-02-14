Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58267 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760886Ab2BNVlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 16:41:13 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 add a session statistics file to /proc/fs/nfsfs
Date: Tue, 14 Feb 2012 16:40:38 -0500
Message-Id: <1329255638-2353-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Session statistics are needed for performance characterisation and debugging
session recovery and migration.

Only gather forechannel statistics as the backchannel has one session slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |  120 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |    5 ++
 include/linux/nfs_fs_sb.h |    3 +
 3 files changed, 128 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 31778f7..9d8c479 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1815,6 +1815,118 @@ static const struct file_operations nfs_volume_list_fops = {
 	.owner		= THIS_MODULE,
 };
 
+#ifdef CONFIG_NFS_V4_1
+static int nfs_session_list_open(struct inode *inode, struct file *file);
+static void *nfs_session_list_start(struct seq_file *p, loff_t *pos);
+static void *nfs_session_list_next(struct seq_file *p, void *v, loff_t *pos);
+static void nfs_session_list_stop(struct seq_file *p, void *v);
+static int nfs_session_list_show(struct seq_file *m, void *v);
+
+static const struct seq_operations nfs_session_list_ops = {
+	.start	= nfs_session_list_start,
+	.next	= nfs_session_list_next,
+	.stop	= nfs_session_list_stop,
+	.show	= nfs_session_list_show,
+};
+
+static const struct file_operations nfs_session_list_fops = {
+	.open		= nfs_session_list_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+	.owner		= THIS_MODULE,
+};
+
+/*
+ * open "/proc/fs/nfsfs/sessions" which provides a summary of sessions with
+ * which we're dealing
+ */
+static int nfs_session_list_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *m;
+	int ret;
+
+	ret = seq_open(file, &nfs_session_list_ops);
+	if (ret < 0)
+		return ret;
+
+	m = file->private_data;
+	m->private = PDE(inode)->data;
+
+	return 0;
+}
+
+/*
+ * set up the iterator to start reading from the nfs_client list and return
+ * the first item
+ */
+static void *nfs_session_list_start(struct seq_file *m, loff_t *_pos)
+{
+	/* lock the list against modification */
+	spin_lock(&nfs_client_lock);
+	return seq_list_start_head(&nfs_client_list, *_pos);
+}
+
+/*
+ * move to next nfs_client
+ */
+static void *nfs_session_list_next(struct seq_file *p, void *v, loff_t *pos)
+{
+	return seq_list_next(v, &nfs_client_list, pos);
+}
+
+/*
+ * clean up after reading from the nfs_client list
+ */
+static void nfs_session_list_stop(struct seq_file *p, void *v)
+{
+	spin_unlock(&nfs_client_lock);
+}
+
+/*
+ * display a header line followed by a load of call lines
+ */
+static int nfs_session_list_show(struct seq_file *m, void *v)
+{
+	struct nfs_client *clp;
+	struct nfs4_slot_table *tbl;
+	char sessionid[16];
+
+	/* display header on line 1 */
+	if (v == &nfs_client_list) {
+		seq_puts(m, "HOSTNAME          SESSIONID       WAITQ:MAX,CUR"
+			"     SLOTID:MAX,TARGET,HIGHEST \n");
+		return 0;
+	}
+
+	/* display one session per line on subsequent lines */
+	clp = list_entry(v, struct nfs_client, cl_share_link);
+
+	/* Check if the nfs_client has a session and is initialized */
+	if (!clp->cl_session || clp->cl_cons_state != NFS_CS_READY)
+		return 0;
+
+	snprintf(sessionid, 16, "%x:%x:%x:%x",
+		((u32 *)&clp->cl_session->sess_id.data)[0],
+		((u32 *)&clp->cl_session->sess_id.data)[1],
+		((u32 *)&clp->cl_session->sess_id.data)[2],
+		((u32 *)&clp->cl_session->sess_id.data)[3]);
+
+	tbl = &clp->cl_session->fc_slot_table;
+	spin_lock(&tbl->slot_tbl_lock);
+	seq_printf(m, "%s  %-16s         %u,  %u               %d,  %d,  %d\n",
+		   clp->cl_hostname,
+		   sessionid,
+		   tbl->max_qlen,
+		   tbl->qlen,
+		   tbl->max_slots = 1,
+		   tbl->target_max_slots,
+		   tbl->highest_used_slotid);
+	spin_unlock(&tbl->slot_tbl_lock);
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * open "/proc/fs/nfsfs/servers" which provides a summary of servers with which
  * we're dealing
@@ -1992,6 +2104,14 @@ int __init nfs_fs_proc_init(void)
 			proc_fs_nfs, &nfs_volume_list_fops);
 	if (!p)
 		goto error_2;
+
+#ifdef CONFIG_NFS_V4_1
+	/* a file of sessions that we are using */
+	p = proc_create("sessions", S_IFREG|S_IRUGO,
+			proc_fs_nfs, &nfs_session_list_fops);
+	if (!p)
+		goto error_2;
+#endif /* CONFIG_NFS_V4_1 */
 	return 0;
 
 error_2:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 17b3d0b..1419e1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -692,6 +692,11 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	tbl = &session->fc_slot_table;
 
 	spin_lock(&tbl->slot_tbl_lock);
+
+	/* Gather stats */
+	tbl->max_qlen = max(tbl->max_qlen, tbl->slot_tbl_waitq.qlen);
+	tbl->qlen = tbl->slot_tbl_waitq.qlen;
+
 	if (test_bit(NFS4_SESSION_DRAINING, &session->session_state) &&
 	    !rpc_task_has_priority(task, RPC_PRIORITY_PRIVILEGED)) {
 		/* The state manager will wait until the slot table is empty */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a091dc1..5c04d42 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -207,6 +207,9 @@ struct nfs4_slot_table {
 	int		target_max_slots;	/* Set by CB_RECALL_SLOT as
 						 * the new max_slots */
 	struct completion complete;
+	/* For session statistics */
+	unsigned short  max_qlen;		/* max waitq qlen */
+	unsigned short  qlen;			/* current waitq qlen */
 };
 
 /*
-- 
1.7.6.4

