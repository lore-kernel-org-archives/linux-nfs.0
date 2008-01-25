From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 003/100] Fix incorrect assignment
Date: Fri, 25 Jan 2008 18:15:43 -0500
Message-ID: <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
Cc: Prasad P <pvp@us.ibm.com>, Steve French <smfltc@us.ibm.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761990AbYAYXR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:28 -0500
In-Reply-To: <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Prasad P <pvp@us.ibm.com>

Dereferenced pointer "dentry" without checking and assigned to inode
in the declaration.

(We could just delete the NULL checks that follow instead, as we never
get to the encode function in this particular case.  But it takes a
little detective work to verify that fact, so it's probably safer to
leave the checks in place.)

Cc: Steve French <smfltc@us.ibm.com>
Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs2acl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 0e5fa11..d5fca59 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_getaclres *resp)
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode;
 	struct kvec *head = rqstp->rq_res.head;
 	unsigned int base;
 	int n;
-- 
1.5.4.rc2.60.gb2e62

