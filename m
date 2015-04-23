Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:61841 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966283AbbDWQRo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 12:17:44 -0400
From: Andre Przywara <andre.przywara@arm.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] fs/nfs: fix new compiler warning about boolean in switch
Date: Thu, 23 Apr 2015 17:17:40 +0100
Message-Id: <1429805860-19893-1-git-send-email-andre.przywara@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The brand new GCC 5.1.0 warns by default on using a boolean in the
switch condition. This results in the following warning:

fs/nfs/nfs4proc.c: In function 'nfs4_proc_get_rootfh':
fs/nfs/nfs4proc.c:3100:10: warning: switch condition has boolean value [-Wswitch-bool]
  switch (auth_probe) {
          ^

This code was obviously using switch to make use of the fall-through
semantics (without the usual comment, though).
Rewrite that code using if statements to avoid the warning and make
the code a bit more readable on the way.

Signed-off-by: Andre Przywara <andre.przywara@arm.com>
---
 fs/nfs/nfs4proc.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 627f37c..f7acfb6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3095,16 +3095,13 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 			 struct nfs_fsinfo *info,
 			 bool auth_probe)
 {
-	int status;
+	int status = 0;
 
-	switch (auth_probe) {
-	case false:
+	if (!auth_probe)
 		status = nfs4_lookup_root(server, fhandle, info);
-		if (status != -NFS4ERR_WRONGSEC)
-			break;
-	default:
+
+	if (auth_probe || status == NFS4ERR_WRONGSEC)
 		status = nfs4_do_find_root_sec(server, fhandle, info);
-	}
 
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
-- 
1.7.10.4

