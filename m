Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab3GEVte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 17:49:34 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r65LnWhX022577
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:33 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r65LnWZl019624
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:32 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r65LnW5C012299
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:32 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r65LnWYd012298
	for linux-nfs@vger.kernel.org; Fri, 5 Jul 2013 17:49:32 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Make nfs_attribute_cache_expired() non-static
Date: Fri,  5 Jul 2013 17:49:30 -0400
Message-Id: <1373060971-12260-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1373060971-12260-1-git-send-email-smayhew@redhat.com>
References: <1373060971-12260-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS: Make nfs_attribute_cache_expired() non-static so we can call it from
nfs_readdir().

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/inode.c         | 2 +-
 include/linux/nfs_fs.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ce72704..b4e3432 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -847,7 +847,7 @@ int nfs_attribute_timeout(struct inode *inode)
 	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
-static int nfs_attribute_cache_expired(struct inode *inode)
+int nfs_attribute_cache_expired(struct inode *inode)
 {
 	if (nfs_have_delegated_attributes(inode))
 		return 0;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fc01d5c..990d6e3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -347,6 +347,7 @@ extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
+extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
-- 
1.7.11.7

