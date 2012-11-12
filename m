Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:6718 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab2KLTNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 14:13:16 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Remove _nfs_call_sync_session
Date: Mon, 12 Nov 2012 14:13:13 -0500
Message-Id: <1352747593-29297-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

All it does is pass its arguments through to another function.  Let's
cut out the middleman...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a75df39..30350a2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -733,16 +733,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	return ret;
 }
 
-static
-int _nfs4_call_sync_session(struct rpc_clnt *clnt,
-			    struct nfs_server *server,
-			    struct rpc_message *msg,
-			    struct nfs4_sequence_args *args,
-			    struct nfs4_sequence_res *res)
-{
-	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
-}
-
 #else
 static
 void nfs41_init_sequence(struct nfs4_sequence_args *args,
@@ -6979,7 +6969,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
-	.call_sync = _nfs4_call_sync_session,
+	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
-- 
1.8.0

