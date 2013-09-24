Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:57815 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747Ab3IXR6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 13:58:07 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <schumaker.anna@gmail.com>, <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4.1: try SECINFO_NO_NAME flavs until one works
Date: Tue, 24 Sep 2013 13:58:02 -0400
Message-ID: <1380045482-4895-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call nfs4_lookup_root_sec for each flavor returned by SECINFO_NO_NAME until
one works.

One example of a situation this fixes:

 - server configured for krb5
 - server principal somehow gets deleted from KDC
 - server still thinking krb is good, sends krb5 as first entry in
    SECINFO_NO_NAME response
 - client tries krb5, but this fails without even sending an RPC because
    gssd's requests to the KDC can't find the server's principal

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

This is version 2 of the patch.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 989bb9d..a288f15 100644
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
@@ -7587,9 +7589,31 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
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
+		default:
+			flavor = RPC_AUTH_MAXFLAVOR;
+			break;
+		}
+
+		if (flavor != RPC_AUTH_MAXFLAVOR) {
+			err = nfs4_lookup_root_sec(server, fhandle,
+						   info, flavor);
+			if (!err)
+				break;
+		}
+	}
+
+	if (flavor == RPC_AUTH_MAXFLAVOR)
+		err = -EPERM;
 
 out_freepage:
 	put_page(page);
-- 
1.7.12.4 (Apple Git-37)

