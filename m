Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33752 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbGAD7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:59:50 -0400
Received: by pacws9 with SMTP id ws9so16210869pac.0
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:59:49 -0700 (PDT)
Message-ID: <559365AE.4030702@gmail.com>
Date: Wed, 01 Jul 2015 11:59:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 7/8] nfs: Remove invalid NFS_ATTR_FATTR_V4_REFERRAL checking
 in nfs4_get_rootfh
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_ATTR_FATTR_V4_REFERRAL is only set in nfs4_proc_lookup_common.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4getroot.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
index c0b3a16..039b3eb 100644
--- a/fs/nfs/nfs4getroot.c
+++ b/fs/nfs/nfs4getroot.c
@@ -35,13 +35,6 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool auth_p
 		goto out;
 	}
 
-	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
-		printk(KERN_ERR "nfs4_get_rootfh:"
-		       " getroot obtained referral\n");
-		ret = -EREMOTE;
-		goto out;
-	}
-
 	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
 out:
 	nfs_free_fattr(fsinfo.fattr);
-- 
2.4.3

