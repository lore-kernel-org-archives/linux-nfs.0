Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:53443 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab3F0PuR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:50:17 -0400
Received: by mail-yh0-f52.google.com with SMTP id f10so489284yha.39
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 08:50:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston.Adamson@netapp.com
Subject: [PATCH v3 2/3] nfs: move server_authlist into nfs_try_mount_request
Date: Thu, 27 Jun 2013 11:50:06 -0400
Message-Id: <1372348207-26388-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
References: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch we're going to want to cycle over this list and attempt
to call ->create_server for each different flavor until one succeeds.
Move the list allocation to the stack of nfs_try_mount_request() and
pass a pointer to it and its length to nfs_request_mount().

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index afeee81..a0949f5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1701,10 +1701,10 @@ out_err:
  * corresponding to the provided path.
  */
 static int nfs_request_mount(struct nfs_parsed_mount_data *args,
-			     struct nfs_fh *root_fh)
+			     struct nfs_fh *root_fh,
+			     rpc_authflavor_t *server_authlist,
+			     unsigned int *server_authlist_len)
 {
-	rpc_authflavor_t server_authlist[NFS_MAX_SECFLAVORS];
-	unsigned int server_authlist_len = ARRAY_SIZE(server_authlist);
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
@@ -1712,7 +1712,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
 		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
-		.auth_flav_len	= &server_authlist_len,
+		.auth_flav_len	= server_authlist_len,
 		.auth_flavs	= server_authlist,
 		.net		= args->net,
 	};
@@ -1763,8 +1763,12 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 					struct nfs_subversion *nfs_mod)
 {
 	int status;
+	struct nfs_parsed_mount_data *args = mount_info->parsed;
+	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
+	unsigned int authlist_len = ARRAY_SIZE(authlist);
 
-	status = nfs_request_mount(mount_info->parsed, mount_info->mntfh);
+	status = nfs_request_mount(args, mount_info->mntfh, authlist,
+					&authlist_len);
 	if (status)
 		return ERR_PTR(status);
 
-- 
1.8.1.4

