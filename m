Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36698 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbG3Nwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:52:39 -0400
Received: by pdjr16 with SMTP id r16so25513704pdj.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:52:39 -0700 (PDT)
Message-ID: <55BA2BFA.2060809@gmail.com>
Date: Thu, 30 Jul 2015 21:51:54 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 1/5] NFSD: Store parent's stat in a sperate value
References: <55BA2B46.90204@gmail.com>
In-Reply-To: <55BA2B46.90204@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit ae7095a7c4 (nfsd4: helper function for getting mounted_on ino)
don't process the return value from get_parent_attributes().

Also, the following FATTR4_WORD2_LAYOUT_BLKSIZE will using stat.blksize,
using an independent value for parent's attributes.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5463385..f11003c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2674,6 +2674,9 @@ out_acl:
 		*p++ = cpu_to_be32(stat.mtime.tv_nsec);
 	}
 	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
+		struct kstat parent_stat;
+		u64 ino = stat.ino;
+
 		p = xdr_reserve_space(xdr, 8);
 		if (!p)
                 	goto out_resource;
@@ -2682,9 +2685,13 @@ out_acl:
 		 * and this is the root of a cross-mounted filesystem.
 		 */
 		if (ignore_crossmnt == 0 &&
-		    dentry == exp->ex_path.mnt->mnt_root)
-			get_parent_attributes(exp, &stat);
-		p = xdr_encode_hyper(p, stat.ino);
+		    dentry == exp->ex_path.mnt->mnt_root) {
+			err = get_parent_attributes(exp, &parent_stat);
+			if (err)
+				goto out_nfserr;
+			ino = parent_stat.ino;
+		}
+		p = xdr_encode_hyper(p, ino);
 	}
 #ifdef CONFIG_NFSD_PNFS
 	if ((bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) ||
-- 
2.4.3

