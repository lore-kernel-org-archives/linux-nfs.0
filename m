From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] NFS: Save the values of the "mount*=" mount options
Date: Thu, 31 Jan 2008 15:00:42 -0500
Message-ID: <20080131200042.17975.51747.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: miklos@szeredi.hu, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:54579 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759511AbYAaUBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2008 15:01:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save the value of the mountproto= mountport= mountvers= and mountaddr=
options so that these values can be displayed later via
nfs_show_options().

This preserves the intent of the original mount options, should the file
system need to be remounted based on what's displayed in /proc/mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
---

 fs/nfs/client.c           |   10 ++++++++++
 include/linux/nfs_fs_sb.h |    7 +++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2fed191..d4ceb56 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -690,6 +690,16 @@ static int nfs_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
+	/* Preserve the values of mount_server-related mount options */
+	if (data->mount_server.addrlen) {
+		memcpy(&server->mountd_address, &data->mount_server.address,
+			data->mount_server.addrlen);
+		server->mountd_addrlen = data->mount_server.addrlen;
+	}
+	server->mountd_version = data->mount_server.version;
+	server->mountd_port = data->mount_server.port;
+	server->mountd_protocol = data->mount_server.protocol;
+
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 670e5c7..ac7e4fb 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -118,6 +118,13 @@ struct nfs_server {
 
 	atomic_t active; /* Keep trace of any activity to this server */
 	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
+
+	/* mountd-related mount options */
+	struct sockaddr_storage	mountd_address;
+	size_t			mountd_addrlen;
+	u32			mountd_version;
+	unsigned short		mountd_port;
+	unsigned short		mountd_protocol;
 };
 
 /* Server capabilities */

