Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042Ab1DMSbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 14:31:32 -0400
Message-ID: <4DA5EC00.3010703@netapp.com>
Date: Wed, 13 Apr 2011 14:31:28 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/6] NFS: Fix infinite loop in gss_create_upcall()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


There can be an infinite loop if gss_create_upcall() is called without
the userspace program running.  To prevent this, we return -EACCES if
we notice that pipe_version hasn't changed (indicating that the pipe
has not been opened).

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

---
 fs/nfs/nfs4proc.c              |    5 +++--
 net/sunrpc/auth_gss/auth_gss.c |    8 +++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bf41ea..8a03ee0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2224,8 +2224,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status != -EPERM)
-			break;
+		if (status == -EPERM || status == -EACCES)
+			continue;
+		break;
 	}
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index f3914d0..339ba64 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -520,7 +520,7 @@ gss_refresh_upcall(struct rpc_task *task)
 		warn_gssd();
 		task->tk_timeout = 15*HZ;
 		rpc_sleep_on(&pipe_version_rpc_waitqueue, task, NULL);
-		return 0;
+		return -EAGAIN;
 	}
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -563,10 +563,12 @@ retry:
 	if (PTR_ERR(gss_msg) == -EAGAIN) {
 		err = wait_event_interruptible_timeout(pipe_version_waitqueue,
 				pipe_version >= 0, 15*HZ);
+		if (pipe_version < 0) {
+			warn_gssd();
+			err = -EACCES;
+		}
 		if (err)
 			goto out;
-		if (pipe_version < 0)
-			warn_gssd();
 		goto retry;
 	}
 	if (IS_ERR(gss_msg)) {
-- 
1.7.4.4

