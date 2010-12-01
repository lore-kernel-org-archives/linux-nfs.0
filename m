Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:39816 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599Ab0LAKmZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 05:42:25 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB1AgNqh021238
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 21:42:23 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB1AgM8g2129974
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 21:42:23 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB1AgMPo031115
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 21:42:22 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: trond.myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] nfs: Discard ACL cache on mode update
Date: Wed,  1 Dec 2010 16:12:16 +0530
Message-Id: <1291200136-9982-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

An update of mode bits can result in ACL value being changed. We need
to mark the acl cache invalid when we update mode. Similarly we need
to update file attribute when we change ACL value

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 821d4c7..89fb751 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3356,6 +3356,8 @@ ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
 	ret = nfs_revalidate_inode(server, inode);
 	if (ret < 0)
 		return ret;
+	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
+		nfs_zap_acl_cache(inode);
 	ret = nfs4_read_cached_acl(inode, buf, buflen);
 	if (ret != -ENOENT)
 		return ret;
@@ -3384,6 +3386,13 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	/*
+	 * Acl update can result in inode attribute update.
+	 * so mark the attribute cache invalid.
+	 */
+	spin_lock(&inode->i_lock);
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
+	spin_unlock(&inode->i_lock);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
 	return ret;
-- 
1.7.1

