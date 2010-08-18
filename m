Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54693 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751576Ab0HRILH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 04:11:07 -0400
Message-ID: <4C6B9538.2020608@cn.fujitsu.com>
Date: Wed, 18 Aug 2010 16:09:28 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] Server should allow offset larger than LLONG_MAX at commit
 procedure
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When offset larger than LLONG_MAX, it's better to sync all the data of file
than return nfserr_inval.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/nfsd/vfs.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 96360a8..f67fe31 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1174,20 +1174,23 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct file	*file;
 	loff_t		end = LLONG_MAX;
-	__be32		err = nfserr_inval;
+	__be32		err;
+
+	if ((u64)count > ~(u64)offset)
+		return nfserr_inval;
 
 	if (offset < 0)
-		goto out;
-	if (count != 0) {
+		offset = 0;
+	else if (count != 0) {
 		end = offset + (loff_t)count - 1;
 		if (end < offset)
-			goto out;
+			end = LLONG_MAX;
 	}
 
 	err = nfsd_open(rqstp, fhp, S_IFREG,
 			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &file);
 	if (err)
-		goto out;
+		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		int err2 = vfs_fsync_range(file, offset, end, 0);
 
@@ -1198,7 +1201,6 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	nfsd_close(file);
-out:
 	return err;
 }
 #endif /* CONFIG_NFSD_V3 */
-- 
1.6.5.2




-- 
Regards
Bian Naimeng

