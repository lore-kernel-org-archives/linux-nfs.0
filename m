Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759994Ab3CIAdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 19:33:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: fix use-after-free of 4.1 client on connection loss
Date: Fri,  8 Mar 2013 19:33:40 -0500
Message-Id: <1362789221-4246-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1362789221-4246-1-git-send-email-bfields@redhat.com>
References: <1362789221-4246-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we drop the lock here there's nothing keeping the client around:
the only lock still held is the xpt_lock on this socket, but this socket
no longer has any connection with the client so there's no way for other
code to know we're still using the client.

The solution is simple: all nfsd4_probe_callback does is set a few
variables and queue some work, so there's no reason we can't just keep
it under the lock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa928b0..b52b32e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -793,8 +793,8 @@ static void nfsd4_conn_lost(struct svc_xpt_user *u)
 		list_del(&c->cn_persession);
 		free_conn(c);
 	}
-	spin_unlock(&clp->cl_lock);
 	nfsd4_probe_callback(clp);
+	spin_unlock(&clp->cl_lock);
 }
 
 static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp, u32 flags)
-- 
1.7.9.5

