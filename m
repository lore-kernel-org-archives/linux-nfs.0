From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 66/67] nfs41: fail mount on EXCHANGE_ID, CREATE_SESSION failure
Date: Thu,  2 Apr 2009 17:00:22 +0300
Message-ID: <1238680822-15467-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31353 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757012AbZDBOA3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 10:00:29 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs4_recover_expired_lease() call schedules the state manager thread and
waits for it to complete. A negative cl_cons_state indicates that either the
EXCHANGE_ID or the CREATE_SESSION failed. In this case return -EPROTONOSUPPORT
which will be returned to the caller (mount).

Note that session setup either succeeds or fails prior to calling
a SEQUENCE operation, so unlike the session_reclaimer NFS41_SESSION_ALLOC
state, there is no need to test for session alloc (setup) in
nfs4_setup_sequence.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c   |   16 ++++++++++++++++
 fs/nfs/internal.h |    1 +
 fs/nfs/nfs4proc.c |    2 ++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8a3aa9a..0c18a18 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -528,6 +528,22 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 }
 
 /*
+ * With sessions, the client is not marked ready until after a
+ * successful EXCHANGE_ID and CREATE_SESSION.
+ *
+ * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
+ * other versions of NFS can be tried.
+ */
+int nfs4_check_client_ready(struct nfs_client *clp)
+{
+	if (!nfs4_has_session(clp))
+		return 0;
+	if (clp->cl_cons_state < NFS_CS_READY)
+		return -EPROTONOSUPPORT;
+	return 0;
+}
+
+/*
  * Session has been established, and the client marked ready.
  * Set the mount rsize and wsize with negotiated fore channel
  * attributes which will be bound checked in nfs_server_set_fsinfo.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dc92be7..7b5cb33 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -101,6 +101,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
+extern int nfs4_check_client_ready(struct nfs_client *clp);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e0d8698..f6db7a5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2041,6 +2041,8 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	nfs_fattr_init(info->fattr);
 	status = nfs4_recover_expired_lease(server);
 	if (!status)
+		status = nfs4_check_client_ready(server->nfs_client);
+	if (!status)
 		status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	return status;
 }
-- 
1.6.2.1

