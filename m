Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:44405 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbaA0VbO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 16:31:14 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 27 Jan 2014 14:31:14 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7B1EE6E8048
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 16:31:06 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0RLVAnI10027474
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 21:31:10 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0RLVA4C004976
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 16:31:10 -0500
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s0RLVAK2004955
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 16:31:10 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: initialize the ACL support bits to zero.
Date: Mon, 27 Jan 2014 15:31:09 -0600
Message-Id: <1390858269-12378-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid returning incorrect acl mask attributes when the server doesn't
support ACLs.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868..a132710 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3435,7 +3435,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 {
 	__be32 *p;
 
-	*res = ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL;
+	*res = 0;
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACLSUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
-- 
1.8.3.1

