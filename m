Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2138 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932902AbbIDRaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:07 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH Version 2 15/16] NFS always use openstateid in COPY_NOTIFY
Date: Fri, 4 Sep 2015 13:29:37 -0400
Message-ID: <1441387778-16465-16-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 14 ++++++++++----
 fs/nfs/nfs4_fs.h   |  2 +-
 fs/nfs/nfs4state.c |  2 +-
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index e33734d..1a46f2a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -39,6 +39,15 @@ static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 	return ret;
 }
 
+static void nfs42_set_open_stateid(nfs4_stateid *dst, struct file *file)
+{
+	struct nfs_open_context *open;
+
+	open = get_nfs_open_context(nfs_file_open_context(file));
+	nfs4_copy_open_stateid(dst, open->state);
+	put_nfs_open_context(open);
+}
+
 static void nfs42_set_netaddr(struct file *file_out,
 				      struct nfs42_netaddr *naddr)
 {
@@ -272,10 +281,7 @@ static int nfs42_proc_copy_notify(struct file *src, struct file *dst,
 	args->cna_src_fh  = NFS_FH(file_inode(src)),
 	args->cna_dst.nl4_type = NL4_NETADDR;
 	nfs42_set_netaddr(src, &args->cna_dst.u.nl4_addr);
-
-	status = nfs42_set_rw_stateid(&args->cna_src_stateid, src, FMODE_READ);
-	if (status)
-		return status;
+	nfs42_set_open_stateid(&args->cna_src_stateid, src);
 
 	msg.rpc_argp = args;
 	status = nfs4_call_sync(src_server->client, src_server, &msg,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 408c637..2d436d1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -447,7 +447,7 @@ extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern int nfs4_select_rw_stateid(nfs4_stateid *, struct nfs4_state *,
 		fmode_t, const struct nfs_lockowner *);
-
+extern void nfs4_copy_open_stateid(nfs4_stateid *, struct nfs4_state *);
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
 extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f2e2ad8..22498c0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -967,7 +967,7 @@ out:
 	return ret;
 }
 
-static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	const nfs4_stateid *src;
 	int seq;
-- 
1.8.3.1

