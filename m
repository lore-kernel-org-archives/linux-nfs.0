Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35990 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751214AbdBSCI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 18 Feb 2017 21:08:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] NFSv4: minor acl caching policy documentation
Date: Sat, 18 Feb 2017 21:07:47 -0500
Message-Id: <1487470070-32358-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1487470070-32358-1-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 60501e10625d..a4e33e519f6e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5035,12 +5035,18 @@ static inline ssize_t nfs4_read_cached_acl(struct inode *inode, char *buf, size_
 	return ret;
 }
 
+/*
+ * We don't cache ACLs over a certain size.  I don't know if we have any
+ * real reason for this policy:
+ */
+#define NFS4_MAX_CACHED_ACL PAGE_SIZE
+
 static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size_t pgbase, size_t acl_len)
 {
 	struct nfs4_cached_acl *acl;
 	size_t buflen = sizeof(*acl) + acl_len;
 
-	if (buflen <= PAGE_SIZE) {
+	if (buflen <= NFS4_MAX_CACHED_ACL) {
 		acl = kmalloc(buflen, GFP_KERNEL);
 		if (acl == NULL)
 			goto out;
-- 
2.9.3

