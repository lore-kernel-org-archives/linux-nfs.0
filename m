Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f173.google.com ([209.85.214.173]:57362 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3FZOgJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 10:36:09 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so13578796obb.18
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 07:36:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: make nfs_select_flavor take a list of authflavors and a length
Date: Wed, 26 Jun 2013 10:36:02 -0400
Message-Id: <1372257363-28148-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
References: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't actually need a nfs_mount_request structure here, and by
doing this we can call this function outside of nfs_request_mount().

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2d7525f..5538bcc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1614,9 +1614,9 @@ out_security_failure:
  * Returns 0 on success, -EACCES on failure.
  */
 static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
-			      struct nfs_mount_request *request)
+			unsigned int count, rpc_authflavor_t *server_authlist)
 {
-	unsigned int i, count = *(request->auth_flav_len);
+	unsigned int i;
 	rpc_authflavor_t flavor;
 
 	/*
@@ -1642,8 +1642,8 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	 */
 	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
 		for (i = 0; i < count; i++) {
-			if (args->auth_flavors[0] == request->auth_flavs[i] ||
-			    request->auth_flavs[i] == RPC_AUTH_NULL)
+			if (args->auth_flavors[0] == server_authlist[i] ||
+			    server_authlist[i] == RPC_AUTH_NULL)
 				goto out;
 		}
 		dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
@@ -1659,7 +1659,7 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	for (i = 0; i < count; i++) {
 		struct rpcsec_gss_info info;
 
-		flavor = request->auth_flavs[i];
+		flavor = server_authlist[i];
 		switch (flavor) {
 		case RPC_AUTH_UNIX:
 			goto out_set;
@@ -1676,7 +1676,7 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
 	 * if it does, use the default flavor.
 	 */
 	for (i = 0; i < count; i++) {
-		if (request->auth_flavs[i] == RPC_AUTH_NULL)
+		if (server_authlist[i] == RPC_AUTH_NULL)
 			goto out_default;
 	}
 
@@ -1756,7 +1756,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 		return status;
 	}
 
-	return nfs_select_flavor(args, &request);
+	return nfs_select_flavor(args, server_authlist_len, server_authlist);
 }
 
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
-- 
1.8.1.4

