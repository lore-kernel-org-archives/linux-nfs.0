Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44869 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760495Ab1F1SZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 14:25:44 -0400
Received: by mail-iy0-f174.google.com with SMTP id 12so373005iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 11:25:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: Allow sec=none mounts in certain cases
To: linux-nfs@vger.kernel.org
Date: Tue, 28 Jun 2011 14:25:41 -0400
Message-ID: <20110628182540.2866.42553.stgit@seurat.1015granger.net>
In-Reply-To: <20110628181324.2866.98154.stgit@seurat.1015granger.net>
References: <20110628181324.2866.98154.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There is an undocumented convention (verified by reviewing network
traces from a NetApp filer and a Solaris NFS server) where a server
that returns a mount authflavor list containing an AUTH_NULL entry
is actually indicating it will accept any security flavor for the
export being mounted.

This might be used when the server maps all security flavors into the
same security mode.  For example, the server treats all accessors as,
say, UID 17.

Essentially, AUTH_NULL is treated as a wildcard that matches the
flavor the mounter requested.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4625a4c..543cf9f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1570,13 +1570,20 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
 	 * the first flavor in the list that it supports, on the
 	 * assumption that the best access is provided by the first
 	 * flavor."
+	 *
+	 * By convention we treat AUTH_NULL in the returned list as
+	 * a wild card.  The server will map our requested flavor to
+	 * something else.
 	 */
-	for (i = 0; i < args->auth_flavor_len; i++)
-		for (j = 0; j < server_authlist_len; j++)
-			if (args->auth_flavors[i] == server->auth_flavs[j]) {
-				args->auth_flavors[0] = server->auth_flavs[j];
+	for (i = 0; i < server_authlist_len; i++) {
+		if (server->auth_flavs[i] == RPC_AUTH_NULL)
+			goto out;
+		for (j = 0; j < args->auth_flavor_len; j++)
+			if (server->auth_flavs[i] == args->auth_flavors[j]) {
+				args->auth_flavors[0] = server->auth_flavs[i];
 				goto out;
 			}
+	}
 
 	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
 	nfs_umount(server);

