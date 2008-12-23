From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/69] SUNRPC: nfsacl_encode/nfsacl_decode should be
 exported as GPL-only
Date: Tue, 23 Dec 2008 18:02:06 -0500
Message-ID: <20081223230206.13743.61545.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbYLWXXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:44 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFd006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again, this has never been intended as a public abi for out-of-tree
modules.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs_common/nfsacl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index c11f537..04133aa 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -29,8 +29,8 @@
 
 MODULE_LICENSE("GPL");
 
-EXPORT_SYMBOL(nfsacl_encode);
-EXPORT_SYMBOL(nfsacl_decode);
+EXPORT_SYMBOL_GPL(nfsacl_encode);
+EXPORT_SYMBOL_GPL(nfsacl_decode);
 
 struct nfsacl_encode_desc {
 	struct xdr_array2_desc desc;

