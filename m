Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55213 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbbAFQ3h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:37 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 04/18] nfsd: move nfsd_fh_match to nfsfh.h
Date: Tue,  6 Jan 2015 17:28:27 +0100
Message-Id: <1420561721-9150-5-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The pnfs code will need it too.  Also remove the nfsd_ prefix to match the
other filehandle helpers in that file.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 12 ++----------
 fs/nfsd/nfsfh.h     |  9 +++++++++
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2505b68..aaa3f8e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -408,14 +408,6 @@ static unsigned int file_hashval(struct knfsd_fh *fh)
 	return nfsd_fh_hashval(fh) & (FILE_HASH_SIZE - 1);
 }
 
-static bool nfsd_fh_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
-{
-	return fh1->fh_size == fh2->fh_size &&
-		!memcmp(fh1->fh_base.fh_pad,
-				fh2->fh_base.fh_pad,
-				fh1->fh_size);
-}
-
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
 static void
@@ -3300,7 +3292,7 @@ find_file_locked(struct knfsd_fh *fh, unsigned int hashval)
 	struct nfs4_file *fp;
 
 	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
-		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
+		if (fh_match(&fp->fi_fhandle, fh)) {
 			if (atomic_inc_not_zero(&fp->fi_ref))
 				return fp;
 		}
@@ -4294,7 +4286,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_stid.sc_file->fi_fhandle))
+	if (!fh_match(&fhp->fh_handle, &stp->st_stid.sc_file->fi_fhandle))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 08236d7..e24d954 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -187,6 +187,15 @@ fh_init(struct svc_fh *fhp, int maxsize)
 	return fhp;
 }
 
+static inline bool fh_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
+{
+	if (fh1->fh_size != fh2->fh_size)
+		return false;
+	if (memcmp(fh1->fh_base.fh_pad, fh2->fh_base.fh_pad, fh1->fh_size) != 0)
+		return false;
+	return true;
+}
+
 #ifdef CONFIG_NFSD_V3
 /*
  * The wcc data stored in current_fh should be cleared
-- 
1.9.1

