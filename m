Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:46057 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbaCJEwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 00:52:10 -0400
From: "Yan, Zheng" <zheng.z.yan@intel.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] nfsd4: fix memory leak in nfsd4_encode_fattr()
Date: Mon, 10 Mar 2014 12:52:07 +0800
Message-Id: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fh_put() does not free the temporary file handle.

Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
---
 fs/nfsd/nfs4xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 63f2395..8de4c9d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2499,8 +2499,10 @@ out:
 		security_release_secctx(context, contextlen);
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 	kfree(acl);
-	if (tempfh)
+	if (tempfh) {
 		fh_put(tempfh);
+		kfree(tempfh);
+	}
 	return status;
 out_nfserr:
 	status = nfserrno(err);
-- 
1.8.5.3

