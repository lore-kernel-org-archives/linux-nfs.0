Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624Ab3FENwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 09:52:04 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r55Dq3uJ032677
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Jun 2013 09:52:03 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com
Subject: [PATCH RFC 1/2] NFS: Make nfs_attribute_cache_expired() non-static
Date: Wed,  5 Jun 2013 09:52:00 -0400
Message-Id: <1370440321-56488-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1370440321-56488-1-git-send-email-smayhew@redhat.com>
References: <1370440321-56488-1-git-send-email-smayhew@redhat.com>
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
index 1f94167..e49b16b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -845,7 +845,7 @@ int nfs_attribute_timeout(struct inode *inode)
 	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
-static int nfs_attribute_cache_expired(struct inode *inode)
+int nfs_attribute_cache_expired(struct inode *inode)
 {
 	if (nfs_have_delegated_attributes(inode))
 		return 0;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1cc2568..086927f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -339,6 +339,7 @@ extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
+extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
-- 
1.7.11.7

