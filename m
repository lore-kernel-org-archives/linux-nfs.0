Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13067 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab1DLMrR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 08:47:17 -0400
Message-ID: <4DA449D3.9060100@netapp.com>
Date: Tue, 12 Apr 2011 08:47:15 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Remove unused argument from nfs_find_best_sec()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The inode was used in an earlier version of the code, but it isn't 
used anymore.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

---
 fs/nfs/namespace.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 89fc160..1f063ba 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -119,7 +119,7 @@ Elong:
 }
 
 #ifdef CONFIG_NFS_V4
-static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors, struct inode *inode)
+static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
 	struct xdr_netobj oid;
@@ -166,7 +166,7 @@ static int nfs_negotiate_security(const struct dentry *parent,
 		}
 		flavors = page_address(page);
 		ret = secinfo(parent->d_inode, &dentry->d_name, flavors);
-		*flavor = nfs_find_best_sec(flavors, dentry->d_inode);
+		*flavor = nfs_find_best_sec(flavors);
 		put_page(page);
 	}
 
-- 
1.7.4.4

