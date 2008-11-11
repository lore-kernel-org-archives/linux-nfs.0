From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [pnfs] [RFC 43/85] nfs41: use rpc prepare call state for sessionreset
Date: Tue, 11 Nov 2008 03:01:39 -0500
Message-ID: <7225594ED4A1304C9E43D030A886D2215523C5@daytona.int.panasas.com>
References: <4918920E.3030301@panasas.com> <1226348745-8661-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Benny Halevy" <bhalevy@panasas.com>, <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:32781 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750982AbYKKIHN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2008 03:07:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

http://linux-nfs.org/pipermail/pnfs/2008-November/005264.html
from Andy should probably be squashed into this patch.
 
Benny

________________________________

From: pnfs-bounces@linux-nfs.org on behalf of Benny Halevy
Sent: Mon 2008-11-10 22:25
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
Subject: [pnfs] [RFC 43/85] nfs41: use rpc prepare call state for sessionreset



From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |    4 ++++
 fs/nfs/nfs4proc.c |   22 +++++++++++++++++-----
 fs/nfs/read.c     |    2 +-
 fs/nfs/unlink.c   |    2 +-
 fs/nfs/write.c    |    2 +-
 5 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f78720b..133ad76 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -130,6 +130,10 @@ extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
 extern struct rpc_procinfo nfs3_procedures[];
 extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);

+/* nfs4proc.c */
+extern void nfs4_restart_rpc(struct rpc_task *task,
+                            const struct nfs_server *server);
+
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f6107b0..917d630 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -593,6 +593,18 @@ static void nfs4_sequence_done(const struct nfs_server *server,
 #endif /* CONFIG_NFS_V4_1 */
 }

+void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_server *server)
+{
+#ifdef CONFIG_NFS_V4_1
+       if (server->nfs_client->cl_minorversion &&
+           nfs41_test_session_reset(server->nfs_client->cl_session)) {
+               rpc_restart_call_prepare(task);
+               return;
+       }
+#endif /* CONFIG_NFS_V4_1 */
+       rpc_restart_call(task);
+}
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
        struct nfs_inode *nfsi = NFS_I(dir);
@@ -1638,7 +1650,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
                        break;
                default:
                        if (nfs4_async_handle_error(task, server) == -EAGAIN) {
-                               rpc_restart_call(task);
+                               nfs4_restart_rpc(task, server);
                                return;
                        }
        }
@@ -2871,7 +2883,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
        /* nfs4_sequence_free_slot called in the read rpc_call_done */
        nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
        if (nfs4_async_handle_error(task, server) == -EAGAIN) {
-               rpc_restart_call(task);
+               nfs4_restart_rpc(task, server);
                dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
                return -EAGAIN;
        }
@@ -2899,7 +2911,7 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
        /* slot is freed in nfs_writeback_done */
        nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
        if (nfs4_async_handle_error(task, server) == -EAGAIN) {
-               rpc_restart_call(task);
+               nfs4_restart_rpc(task, server);
                return -EAGAIN;
        }
        if (task->tk_status >= 0) {
@@ -2927,7 +2939,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)

        nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
        if (nfs4_async_handle_error(task, server) == -EAGAIN) {
-               rpc_restart_call(task);
+               nfs4_restart_rpc(task, server);
                return -EAGAIN;
        }
        nfs4_sequence_free_slot(server, &data->res.seq_res);
@@ -3701,7 +3713,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
                        break;
                default:
                        if (nfs4_async_handle_error(task, server) == -EAGAIN)
-                               rpc_restart_call(task);
+                               nfs4_restart_rpc(task, server);
        }
        nfs4_sequence_free_slot(server, &calldata->res.seq_res);
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3c77b26..5b8db19 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -367,7 +367,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
        argp->offset += resp->count;
        argp->pgbase += resp->count;
        argp->count -= resp->count;
-       rpc_restart_call(task);
+       nfs4_restart_rpc(task, NFS_SERVER(data->inode));
        return;
 out:
        nfs4_sequence_free_slot(NFS_SERVER(data->inode), &data->res.seq_res);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3df3794..2ac5dd5 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -83,7 +83,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
        struct inode *dir = data->dir;

        if (!NFS_PROTO(dir)->unlink_done(task, dir))
-               rpc_restart_call(task);
+               nfs4_restart_rpc(task, NFS_SERVER(dir));
 }

 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7d3fdc8..86573f7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1179,7 +1179,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
                                 */
                                argp->stable = NFS_FILE_SYNC;
                        }
-                       rpc_restart_call(task);
+                       nfs4_restart_rpc(task, NFS_SERVER(data->inode));
                        return -EAGAIN;
                }
                if (time_before(complain, jiffies)) {
--
1.6.0.2

_______________________________________________
pNFS mailing list
pNFS@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs


