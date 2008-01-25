From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 044/100] nfsd4: clean up access_valid, deny_valid checks.
Date: Fri, 25 Jan 2008 18:16:24 -0500
Message-ID: <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
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
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Neil Brown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932069AbYAYXRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:41 -0500
In-Reply-To: <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Document these checks a little better and inline, as suggested by Neil
Brown (note both functions have two callers).  Remove an obviously bogus
check while we're there (checking whether unsigned value is negative).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Neil Brown <neilb@suse.de>
---
 fs/nfsd/nfs4state.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9320b7f..663bb35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1157,14 +1157,19 @@ find_file(struct inode *ino)
 	return NULL;
 }
 
-static int access_valid(u32 x)
+static inline int access_valid(u32 x)
 {
-	return (x > 0 && x < 4);
+	if (x < NFS4_SHARE_ACCESS_READ)
+		return 0;
+	if (x > NFS4_SHARE_ACCESS_BOTH)
+		return 0;
+	return 1;
 }
 
-static int deny_valid(u32 x)
+static inline int deny_valid(u32 x)
 {
-	return (x >= 0 && x < 5);
+	/* Note: unlike access bits, deny bits may be zero. */
+	return x <= NFS4_SHARE_DENY_BOTH;
 }
 
 static void
-- 
1.5.4.rc2.60.gb2e62

