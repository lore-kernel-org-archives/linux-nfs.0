Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34768 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbcCGKKN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Mar 2016 05:10:13 -0500
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] nfsd: recover: fix memory leak
Date: Mon,  7 Mar 2016 15:40:03 +0530
Message-Id: <1457345403-7195-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_cltrack_grace_start() will allocate the memory for grace_start but
when we returned due to error we missed freeing it.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 fs/nfsd/nfs4recover.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 195fe26..66eaeb1 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1266,6 +1266,7 @@ nfsd4_umh_cltrack_init(struct net *net)
 	/* XXX: The usermode helper s not working in container yet. */
 	if (net != &init_net) {
 		pr_warn("NFSD: attempt to initialize umh client tracking in a container ignored.\n");
+		kfree(grace_start);
 		return -EINVAL;
 	}
 
-- 
1.9.1

