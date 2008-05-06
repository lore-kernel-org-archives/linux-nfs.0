From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: reorder printk in do_probe_callback to avoid
	use-after-free
Date: Mon, 5 May 2008 20:12:40 -0400
Message-ID: <20080506001240.GN12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755814AbYEFAMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 20:12:41 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1JtAnQ-0005Yu-GS
	for linux-nfs@vger.kernel.org; Mon, 05 May 2008 20:12:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We're currently dereferencing the client after we drop our reference
count to it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

I intend to submit this for 2.6.26.

--b.

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 562abf3..fadf423 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -419,9 +419,9 @@ static int do_probe_callback(void *data)
 out_release_client:
 	rpc_shutdown_client(client);
 out_err:
-	put_nfs4_client(clp);
 	dprintk("NFSD: warning: no callback path to client %.*s\n",
 		(int)clp->cl_name.len, clp->cl_name.data);
+	put_nfs4_client(clp);
 	return status;
 }
 
-- 
1.5.5.rc1

