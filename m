Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55217 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbbAFQ3i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:38 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 05/18] nfsd: add fh_fsid_match helper
Date: Tue,  6 Jan 2015 17:28:28 +0100
Message-Id: <1420561721-9150-6-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper to check that the fsid parts of two file handles match.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfsfh.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index e24d954..84cae20 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -196,6 +196,15 @@ static inline bool fh_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
 	return true;
 }
 
+static inline bool fh_fsid_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
+{
+	if (fh1->fh_fsid_type != fh2->fh_fsid_type)
+		return false;
+	if (memcmp(fh1->fh_fsid, fh2->fh_fsid, key_len(fh1->fh_fsid_type) != 0))
+		return false;
+	return true;
+}
+
 #ifdef CONFIG_NFSD_V3
 /*
  * The wcc data stored in current_fh should be cleared
-- 
1.9.1

