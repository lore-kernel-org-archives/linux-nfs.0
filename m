Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47783 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409Ab1ADUnm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 15:43:42 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V7 06/12] NFS do not clear minor version at nfs_client free
Date: Tue,  4 Jan 2011 15:42:40 -0500
Message-Id: <1294173766-5573-7-git-send-email-andros@netapp.com>
In-Reply-To: <1294173766-5573-6-git-send-email-andros@netapp.com>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
 <1294173766-5573-2-git-send-email-andros@netapp.com>
 <1294173766-5573-3-git-send-email-andros@netapp.com>
 <1294173766-5573-4-git-send-email-andros@netapp.com>
 <1294173766-5573-5-git-send-email-andros@netapp.com>
 <1294173766-5573-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Resetting the client minor version operations causes nfs4_destroy_callback
to fail to shutdown the NFSv4.1 callback service.

There is no reason to reset the client minorversion operations when the
nfs_client struct is being freed.

Remove the minorverion reset and rename the function.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0870d0d..855add6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -170,21 +170,17 @@ error_0:
 }
 
 #ifdef CONFIG_NFS_V4
-/*
- * Clears/puts all minor version specific parts from an nfs_client struct
- * reverting it to minorversion 0.
- */
-static void nfs4_clear_client_minor_version(struct nfs_client *clp)
-{
 #ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp)) {
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp))
 		nfs4_destroy_session(clp->cl_session);
-		clp->cl_session = NULL;
-	}
-
-	clp->cl_mvops = nfs_v4_minor_ops[0];
-#endif /* CONFIG_NFS_V4_1 */
 }
+#else /* CONFIG_NFS_V4_1 */
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+}
+#endif /* CONFIG_NFS_V4_1 */
 
 /*
  * Destroy the NFS4 callback service
@@ -199,7 +195,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
 		nfs4_kill_renewd(clp);
-	nfs4_clear_client_minor_version(clp);
+	nfs4_shutdown_session(clp);
 	nfs4_destroy_callback(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
 		nfs_idmap_delete(clp);
-- 
1.6.6

