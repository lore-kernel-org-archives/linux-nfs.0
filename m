Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34941 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbbC0Qwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:40 -0400
Received: by igcau2 with SMTP id au2so25601921igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 09:52:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Return delegations synchronously in evict_inode
Date: Fri, 27 Mar 2015 12:52:37 -0400
Message-Id: <1427475157-13904-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kinglong Mee reports that asynchronous delegations are being killed
by the call to rpc_shutdown_client() when unmounting. This can lead
to state leakage on the server until the client lease expires.

Reported-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index a6ad68865880..08c624448750 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -514,7 +514,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 
 	delegation = nfs_inode_detach_delegation(inode);
 	if (delegation != NULL)
-		nfs_do_return_delegation(inode, delegation, 0);
+		nfs_do_return_delegation(inode, delegation, 1);
 }
 
 /**
-- 
2.1.0

