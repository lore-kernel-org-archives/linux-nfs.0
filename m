From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 7/8] nfsv4: Implement getfacl
Date: Wed,  2 Sep 2009 17:54:27 +0530
Message-ID: <1251894268-1555-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:53380 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbZIBMZP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:15 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CPH0O029671
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:17 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CPGQb1687720
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:16 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82CPFnl001945
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:16 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/nfs4pacl.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4pacl.c b/fs/nfs/nfs4pacl.c
index 162f4c5..a13a833 100644
--- a/fs/nfs/nfs4pacl.c
+++ b/fs/nfs/nfs4pacl.c
@@ -138,7 +138,22 @@ static size_t nfs4_xattr_list_pacl_default(struct inode *inode, char *list,
 static int nfs4_xattr_get_pacl_default(struct inode *inode, const char *key,
 				void *buf, size_t buflen)
 {
-	return -EOPNOTSUPP;
+	int error = 0;
+	struct posix_acl *acl;
+
+	acl = nfs4_proc_getacl(inode, ACL_TYPE_DEFAULT);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	else if (acl) {
+		if (acl->a_count == 0)
+			error = -ENODATA;
+		else
+			error = posix_acl_to_xattr(acl, buf, buflen);
+		posix_acl_release(acl);
+	} else
+		error = -ENODATA;
+
+	return error;
 }
 
 static int nfs4_xattr_set_pacl_default(struct inode *inode, const char *key,
@@ -179,7 +194,19 @@ static size_t nfs4_xattr_list_pacl_access(struct inode *inode, char *list,
 static int nfs4_xattr_get_pacl_access(struct inode *inode, const char *key,
 				void *buf, size_t buflen)
 {
-	return -EOPNOTSUPP;
+	int error = 0;
+	struct posix_acl *acl;
+
+	acl = nfs4_proc_getacl(inode, ACL_TYPE_ACCESS);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	else if (acl) {
+		error = posix_acl_to_xattr(acl, buf, buflen);
+		posix_acl_release(acl);
+	} else
+		error = -ENODATA;
+
+	return error;
 }
 
 static int nfs4_xattr_set_pacl_access(struct inode *inode, const char *key,
-- 
1.6.4.2.253.g0b1fac

