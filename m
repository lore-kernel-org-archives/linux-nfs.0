Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:45339 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751694AbaE1TNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 15:13:53 -0400
Date: Wed, 28 May 2014 21:13:51 +0200
From: Fabian Frederick <fabf@skynet.be>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 1/1] fs/nfs_common/nfsacl.c: move EXPORT symbol after
 functions
Message-Id: <20140528211351.6ceadfbab991206edc53bcbc@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fix checkpatch warnings:

"WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable"

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfs_common/nfsacl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index ed628f7..538f142 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -30,9 +30,6 @@
 
 MODULE_LICENSE("GPL");
 
-EXPORT_SYMBOL_GPL(nfsacl_encode);
-EXPORT_SYMBOL_GPL(nfsacl_decode);
-
 struct nfsacl_encode_desc {
 	struct xdr_array2_desc desc;
 	unsigned int count;
@@ -136,6 +133,7 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 			  nfsacl_desc.desc.array_len;
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfsacl_encode);
 
 struct nfsacl_decode_desc {
 	struct xdr_array2_desc desc;
@@ -295,3 +293,4 @@ int nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 	return 8 + nfsacl_desc.desc.elem_size *
 		   nfsacl_desc.desc.array_len;
 }
+EXPORT_SYMBOL_GPL(nfsacl_decode);
-- 
1.9.1
