Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbaGKVQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 17:16:09 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1X5iAr-0003a3-DX
	for linux-nfs@vger.kernel.org; Fri, 11 Jul 2014 17:16:09 -0400
Date: Fri, 11 Jul 2014 17:16:09 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: handle failure to find backchannel
Message-ID: <20140711211609.GA13656@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The local variable "ses" will be left NULL here in the case we fail to
find a connection.  Spotted by a coverity scan.
    
Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2c73cae9899d..fe22cd5c42d3 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1001,14 +1001,18 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	}
 	spin_unlock(&clp->cl_lock);
 
+	if (!c)
+		goto out_no_connection;
 	err = setup_callback_client(clp, &conn, ses);
-	if (err) {
-		nfsd4_mark_cb_down(clp, err);
-		return;
-	}
+	if (err)
+		goto out_no_connection;
 	/* Yay, the callback channel's back! Restart any callbacks: */
 	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
 		run_nfsd4_cb(cb);
+	return;
+out_no_connection:
+	nfsd4_mark_cb_down(clp, err);
+	return;
 }
 
 static void nfsd4_do_callback_rpc(struct work_struct *w)
