Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38716 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094Ab0FJUwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 16:52:43 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] nfs4 use mandatory attribute file type in nfs4_get_root
Date: Thu, 10 Jun 2010 16:52:23 -0400
Message-Id: <1276203143-2118-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

decode_attr_type sets fattr->mode.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/getroot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 7428f7d..a70e446 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -146,7 +146,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
 		goto out;
 	}
 
-	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_MODE)
+	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
 			|| !S_ISDIR(fsinfo.fattr->mode)) {
 		printk(KERN_ERR "nfs4_get_rootfh:"
 		       " getroot encountered non-directory\n");
-- 
1.6.6

