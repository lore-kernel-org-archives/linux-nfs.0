From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 01/10] nfs41: adjust max_rqst_sz, max_resp_sz w.r.t to rsize, wsize
Date: Mon, 23 Nov 2009 13:54:38 -0800
Message-ID: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161AbZKWV7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The v4.1 client should take into account the desired rsize, wsize when
negotiating the max size in CREATE_SESSION. Accordingly, it should use
rsize, wsize that are smaller than the session negotiated values.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/client.c   |   14 ++++++++++----
 fs/nfs/internal.h |    4 ++++
 fs/nfs/nfs4proc.c |    7 +++++--
 fs/nfs/nfs4xdr.c  |   14 ++++++++++++++
 4 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 99ea196..f360739 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -911,8 +911,10 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 
 	server->maxfilesize = fsinfo->maxfilesize;
 
-	/* We're airborne Set socket buffersize */
-	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
+	/* We're airborne Set socket buffersize. */
+	if (!nfs4_has_session(server->nfs_client))
+		rpc_setbufsize(server->client, server->wsize + 100,
+			       server->rsize + 100);
 }
 
 /*
@@ -1260,10 +1262,14 @@ error:
 static void nfs4_session_set_rwsize(struct nfs_server *server)
 {
 #ifdef CONFIG_NFS_V4_1
+	struct nfs4_session *sess;
 	if (!nfs4_has_session(server->nfs_client))
 		return;
-	server->rsize = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	server->wsize = server->nfs_client->cl_session->fc_attrs.max_rqst_sz;
+	sess = server->nfs_client->cl_session;
+	server->rsize = sess->fc_attrs.max_resp_sz - nfs41_maxread_overhead;
+	server->wsize = sess->fc_attrs.max_rqst_sz - nfs41_maxwrite_overhead;
+	rpc_setbufsize(server->client, sess->fc_attrs.max_rqst_sz,
+		       sess->fc_attrs.max_resp_sz);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e21b1bb..d946936 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -195,6 +195,10 @@ static inline void nfs4_restart_rpc(struct rpc_task *task,
 #ifdef CONFIG_NFS_V4
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
 #endif
+#ifdef CONFIG_NFS_V4_1
+extern const u32 nfs41_maxread_overhead;
+extern const u32 nfs41_maxwrite_overhead;
+#endif
 
 /* nfs4proc.c */
 #ifdef CONFIG_NFS_V4
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff37454..ef77d40 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4827,13 +4827,16 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 int nfs4_init_session(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_session *session;
 	int ret;
 
 	if (!nfs4_has_session(clp))
 		return 0;
 
-	clp->cl_session->fc_attrs.max_rqst_sz = server->wsize;
-	clp->cl_session->fc_attrs.max_resp_sz = server->rsize;
+	session = clp->cl_session;
+	session->fc_attrs.max_rqst_sz = server->wsize + nfs41_maxwrite_overhead;
+	session->fc_attrs.max_resp_sz = server->rsize + nfs41_maxread_overhead;
+
 	ret = nfs4_recover_expired_lease(server);
 	if (!ret)
 		ret = nfs4_check_client_ready(clp);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 20b4e30..fc36af4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -46,6 +46,7 @@
 #include <linux/proc_fs.h>
 #include <linux/kdev_t.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/msg_prot.h>
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
@@ -676,6 +677,19 @@ static int nfs4_stat_to_errno(int);
 					 decode_sequence_maxsz + \
 					 decode_putrootfh_maxsz + \
 					 decode_fsinfo_maxsz)
+
+const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
+				      compound_encode_hdr_maxsz +
+				      encode_sequence_maxsz +
+				      encode_putfh_maxsz +
+				      encode_getattr_maxsz) *
+				     XDR_UNIT);
+
+const u32 nfs41_maxread_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
+				     compound_decode_hdr_maxsz +
+				     decode_sequence_maxsz +
+				     decode_putfh_maxsz) *
+				    XDR_UNIT);
 #endif /* CONFIG_NFS_V4_1 */
 
 static const umode_t nfs_type2fmt[] = {
-- 
1.6.2.5

