Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:48598 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbbBKNHn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 08:07:43 -0500
Date: Wed, 11 Feb 2015 16:08:32 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfsd: fix comparison in fh_fsid_match()
Message-ID: <20150211130832.GA25573@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're supposed to be testing that the fh_fsid's match but because the
parenthesis are in the wrong place, then we only check the first
byte.

Fixes: 9558f2500a20 ('nfsd: add fh_fsid_match helper')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 84cae20..f229204 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -200,7 +200,7 @@ static inline bool fh_fsid_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
 {
 	if (fh1->fh_fsid_type != fh2->fh_fsid_type)
 		return false;
-	if (memcmp(fh1->fh_fsid, fh2->fh_fsid, key_len(fh1->fh_fsid_type) != 0))
+	if (memcmp(fh1->fh_fsid, fh2->fh_fsid, key_len(fh1->fh_fsid_type)) != 0)
 		return false;
 	return true;
 }
