From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 025/100] nfsd: minor fs/nfsd/auth.h cleanup
Date: Fri, 25 Jan 2008 18:16:05 -0500
Message-ID: <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
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
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47355 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762096AbYAYXR3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:29 -0500
In-Reply-To: <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While we're here, let's remove the redundant (and now wrong) pathname in
the comment, and the #ifdef __KERNEL__'s.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/auth.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/auth.h b/fs/nfsd/auth.h
index 0fb9f72..78b3c0e 100644
--- a/fs/nfsd/auth.h
+++ b/fs/nfsd/auth.h
@@ -1,6 +1,4 @@
 /*
- * include/linux/nfsd/auth.h
- *
  * nfsd-specific authentication stuff.
  * uid/gid mapping not yet implemented.
  *
@@ -10,8 +8,6 @@
 #ifndef LINUX_NFSD_AUTH_H
 #define LINUX_NFSD_AUTH_H
 
-#ifdef __KERNEL__
-
 #define nfsd_luid(rq, uid)	((u32)(uid))
 #define nfsd_lgid(rq, gid)	((u32)(gid))
 #define nfsd_ruid(rq, uid)	((u32)(uid))
@@ -23,5 +19,4 @@
  */
 int nfsd_setuser(struct svc_rqst *, struct svc_export *);
 
-#endif /* __KERNEL__ */
 #endif /* LINUX_NFSD_AUTH_H */
-- 
1.5.4.rc2.60.gb2e62

