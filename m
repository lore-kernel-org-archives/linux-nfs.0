Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52099 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:52 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 5/8] NFS: teach nfs_do_access to understand MAY_NOT_BLOCK
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.27775.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If MAY_NOT_BLOCK is set we return -ECHILD in preference to making a
network call.
This allows nfs_permission to call it in RCU-walk mode.

Now nfs_permission() can often complete in RCU-walk mode with no error.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 36e12f545fd7..f3895325ac6a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2232,6 +2232,10 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	if (status == 0)
 		goto out_cached;
 
+	status = -ECHILD;
+	if (mask & MAY_NOT_BLOCK)
+		goto out;
+
 	/* Be clever: ask server to check for all possible rights */
 	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
 	cache.cred = cred;
@@ -2311,10 +2315,9 @@ force_lookup:
 
 	cred = rpc_lookup_cred(mask & MAY_NOT_BLOCK);
 	if (!IS_ERR(cred)) {
-		if (mask & MAY_NOT_BLOCK)
-			return -ECHILD;
 		res = nfs_do_access(inode, cred, mask);
-		put_rpccred(cred);
+		if (!(mask & MAY_NOT_BLOCK))
+			put_rpccred(cred);
 	} else
 		res = PTR_ERR(cred);
 out:


