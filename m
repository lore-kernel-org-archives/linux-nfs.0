Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f44.google.com ([209.85.213.44]:50715 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab3F0Tyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 15:54:51 -0400
Received: by mail-yh0-f44.google.com with SMTP id t59so646298yho.31
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 12:54:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston.Adamson@netapp.com
Subject: [PATCH v4 3/4] nfs: have nfs_mount fake up a auth_flavs list when the server didn't provide it
Date: Thu, 27 Jun 2013 15:54:40 -0400
Message-Id: <1372362881-32282-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372362881-32282-1-git-send-email-jlayton@redhat.com>
References: <1372362881-32282-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of handling this as a special case in the auth-selection code,
we can simply fake up an auth_flavs list when the server doesn't
provide it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/mount_clnt.c | 18 +++++++++++++++++-
 fs/nfs/super.c      | 13 -------------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 91a6faf..0f925f3 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -139,7 +139,10 @@ struct mnt_fhstatus {
  * nfs_mount - Obtain an NFS file handle for the given host and path
  * @info: pointer to mount request arguments
  *
- * Uses default timeout parameters specified by underlying transport.
+ * Uses default timeout parameters specified by underlying transport. On
+ * successful return, the auth_flavs list and auth_flav_len will be populated
+ * with the list from the server or a faked-up list if the server didn't
+ * provide one.
  */
 int nfs_mount(struct nfs_mount_request *info)
 {
@@ -195,6 +198,19 @@ int nfs_mount(struct nfs_mount_request *info)
 	dprintk("NFS: MNT request succeeded\n");
 	status = 0;
 
+	/*
+	 * The NFSv2 MNT operation does not return a flavor list. Also, some
+	 * NFSv3 servers (older Linux servers in particular) return an empty
+	 * list.
+	 *
+	 * In that event fake up a list that just has RPC_AUTH_NULL in it since
+	 * we have no way to know what the server actually supports.
+	 */
+	if (info->version != NFS_MNT3_VERSION || *info->auth_flav_len == 0) {
+		dprintk("NFS: Faking up auth_flavs list\n");
+		info->auth_flavs[0] = RPC_AUTH_NULL;
+		*info->auth_flav_len = 1;
+	}
 out:
 	return status;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a0949f5..ceb60c7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1620,19 +1620,6 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	rpc_authflavor_t flavor;
 
 	/*
-	 * The NFSv2 MNT operation does not return a flavor list.
-	 */
-	if (args->mount_server.version != NFS_MNT3_VERSION)
-		goto out_default;
-
-	/*
-	 * Certain releases of Linux's mountd return an empty
-	 * flavor list in some cases.
-	 */
-	if (count == 0)
-		goto out_default;
-
-	/*
 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
 	 * must be in the list returned by the server.
 	 *
-- 
1.8.1.4

