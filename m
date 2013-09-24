Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53615 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543Ab3IXRgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 13:36:09 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <schumaker.anna@gmail.com>, <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4.1: try SECINFO_NO_NAME flavs until one works
Date: Tue, 24 Sep 2013 13:36:04 -0400
Message-ID: <1380044164-4486-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call nfs4_lookup_root_sec for each flavor returned by SECINFO_NO_NAME until
one works.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 989bb9d..9043a02 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7566,6 +7566,8 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	struct page *page;
 	rpc_authflavor_t flavor;
 	struct nfs4_secinfo_flavors *flavors;
+	struct nfs4_secinfo4 *secinfo;
+	int i;
 
 	page = alloc_page(GFP_KERNEL);
 	if (!page) {
@@ -7587,9 +7589,26 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	if (err)
 		goto out_freepage;
 
-	flavor = nfs_find_best_sec(flavors);
-	if (err == 0)
-		err = nfs4_lookup_root_sec(server, fhandle, info, flavor);
+	for (i = 0; i < flavors->num_flavors; i++) {
+		secinfo = &flavors->flavors[i];
+
+		switch (secinfo->flavor) {
+		case RPC_AUTH_NULL:
+		case RPC_AUTH_UNIX:
+		case RPC_AUTH_GSS:
+			flavor = rpcauth_get_pseudoflavor(secinfo->flavor,
+					&secinfo->flavor_info);
+			break;
+		}
+
+		if (flavor != RPC_AUTH_MAXFLAVOR) {
+			err = nfs4_lookup_root_sec(server, fhandle,
+						   info, flavor);
+
+			if (!err)
+				break;
+		}
+	}
 
 out_freepage:
 	put_page(page);
-- 
1.7.12.4 (Apple Git-37)

