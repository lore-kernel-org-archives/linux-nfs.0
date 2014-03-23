Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47849 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbaCWBMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/50] nfsd4: use more generous NFS4_ACL_MAX
Date: Sat, 22 Mar 2014 21:11:36 -0400
Message-Id: <1395537141-10389-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/acl.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index a812fd1..b481e1f 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -39,9 +39,13 @@ struct nfs4_acl;
 struct svc_fh;
 struct svc_rqst;
 
-/* Maximum ACL we'll accept from client; chosen (somewhat arbitrarily) to
- * fit in a page: */
-#define NFS4_ACL_MAX 170
+/*
+ * Maximum ACL we'll accept from a client; chosen (somewhat
+ * arbitrarily) so that kmalloc'ing the ACL shouldn't require a
+ * high-order allocation.  This allows 204 ACEs on x86_64:
+ */
+#define NFS4_ACL_MAX ((PAGE_SIZE - sizeof(struct nfs4_acl)) \
+			/ sizeof(struct nfs4_ace))
 
 struct nfs4_acl *nfs4_acl_new(int);
 int nfs4_acl_get_whotype(char *, u32);
-- 
1.8.5.3

