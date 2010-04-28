From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: fix filehandle comment
Date: Wed, 28 Apr 2010 17:31:07 -0400
Message-ID: <20100428213107.GA23474@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44741 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab0D1VbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:31:07 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1O7EqZ-0006Dr-Ce
	for linux-nfs@vger.kernel.org; Wed, 28 Apr 2010 17:31:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Minor typos.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/nfsd/nfsfh.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 65e333a..45bb5a8 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -40,8 +40,8 @@ struct nfs_fhbase_old {
  * This is the new flexible, extensible style NFSv2/v3 file handle.
  * by Neil Brown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> - March 2000
  *
- * The file handle is seens as a list of 4byte words.
- * The first word contains a version number (1) and four descriptor bytes
+ * The file handle is seens as a list of four-byte words.
+ * The first word contains a version number (1) and three descriptor bytes
  * that tell how the remaining 3 variable length fields should be handled.
  * These three bytes are auth_type, fsid_type and fileid_type.
  *
-- 
1.6.3.3

