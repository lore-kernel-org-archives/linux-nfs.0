Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35986 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751266AbdBSCI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 18 Feb 2017 21:08:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Sat, 18 Feb 2017 21:07:46 -0500
Message-Id: <1487470070-32358-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1487470070-32358-1-git-send-email-bfields@redhat.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@netapp.com>

We're not taking into account that the space needed for the (variable
length) attr bitmap, with the result that we'd sometimes get a spurious
ERANGE when the ACL data got close to the end of a page.

Just add in an extra page to make sure.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a0eaecf9676..60501e10625d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5069,7 +5069,7 @@ static void nfs4_write_cached_acl(struct inode *inode, struct page **pages, size
  */
 static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
 {
-	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
+	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
 	struct nfs_getaclargs args = {
 		.fh = NFS_FH(inode),
 		.acl_pages = pages,
@@ -5083,13 +5083,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
+	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
 	int ret = -ENOMEM, i;
 
-	/* As long as we're doing a round trip to the server anyway,
-	 * let's be prepared for a page of acl data. */
-	if (npages == 0)
-		npages = 1;
 	if (npages > ARRAY_SIZE(pages))
 		return -ERANGE;
 
-- 
2.9.3

