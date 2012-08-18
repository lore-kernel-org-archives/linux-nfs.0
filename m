Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ns.pmeerw.net ([87.118.82.44]:42623 "EHLO pmeerw.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755036Ab2HRPi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Aug 2012 11:38:58 -0400
From: Peter Meerwald <pmeerw@pmeerw.net>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, trivial@kernel.org,
        Peter Meerwald <pmeerw@pmeerw.net>
Subject: [PATCH] nfs: fix spelling of families in comment
Date: Sat, 18 Aug 2012 17:38:54 +0200
Message-Id: <1345304334-4789-1-git-send-email-pmeerw@pmeerw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peter Meerwald <pmeerw@pmeerw.net>
---
 fs/nfs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac6a3c5..99777c1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1502,7 +1502,7 @@ static int nfs_parse_mount_options(char *raw,
 
 	/*
 	 * verify that any proto=/mountproto= options match the address
-	 * familiies in the addr=/mountaddr= options.
+	 * families in the addr=/mountaddr= options.
 	 */
 	if (protofamily != AF_UNSPEC &&
 	    protofamily != mnt->nfs_server.address.ss_family)
-- 
1.7.9.5

