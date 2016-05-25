Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbcEYOgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 10:36:53 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] mount: use sec= that was specified on the command line
Date: Wed, 25 May 2016 10:36:50 -0400
Message-Id: <1464187010-9562-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When older servers return RPC_AUTH_NULL, it means the
rpc creds will be ignored. In that case use the sec=
that was specified instead of setting sec=null

Fixes Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1112983
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/super.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f126828..d410b90 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1680,6 +1680,7 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 {
 	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
 	unsigned int i;
+	int use_auth_null = false;
 
 	/*
 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
@@ -1687,14 +1688,21 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 	 *
 	 * AUTH_NULL has a special meaning when it's in the server list - it
 	 * means that the server will ignore the rpc creds, so any flavor
-	 * can be used.
+	 * can be used but still use the sec= that was specified.
 	 */
 	for (i = 0; i < count; i++) {
 		flavor = server_authlist[i];
 
-		if (nfs_auth_info_match(&args->auth_info, flavor) ||
-		    flavor == RPC_AUTH_NULL)
+		if (nfs_auth_info_match(&args->auth_info, flavor))
 			goto out;
+
+		if (flavor == RPC_AUTH_NULL)
+			use_auth_null = true;
+	}
+
+	if (use_auth_null) {
+		flavor = RPC_AUTH_NULL;
+		goto out;
 	}
 
 	dfprintk(MOUNT,
-- 
2.5.0

