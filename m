From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 013/100] NFSD: Path name length signage in nfsd request argument structures
Date: Fri, 25 Jan 2008 18:15:53 -0500
Message-ID: <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47334 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762073AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: For consistency, store the length of path name strings in nfsd
argument structures as unsigned integers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/nfsd/xdr.h  |    2 +-
 include/linux/nfsd/xdr3.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
index 49ddf79..a0132ef 100644
--- a/include/linux/nfsd/xdr.h
+++ b/include/linux/nfsd/xdr.h
@@ -73,7 +73,7 @@ struct nfsd_symlinkargs {
 	char *			fname;
 	unsigned int		flen;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 	struct iattr		attrs;
 };
 
diff --git a/include/linux/nfsd/xdr3.h b/include/linux/nfsd/xdr3.h
index 6fdb958..421eddd 100644
--- a/include/linux/nfsd/xdr3.h
+++ b/include/linux/nfsd/xdr3.h
@@ -89,7 +89,7 @@ struct nfsd3_symlinkargs {
 	char *			fname;
 	unsigned int		flen;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 	struct iattr		attrs;
 };
 
-- 
1.5.4.rc2.60.gb2e62

