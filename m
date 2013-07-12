Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932919Ab3GLVkX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jul 2013 17:40:23 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1Uxl4g-00031C-T7
	for linux-nfs@vger.kernel.org; Fri, 12 Jul 2013 17:40:23 -0400
Date: Fri, 12 Jul 2013 17:40:22 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix minorversion support interface
Message-ID: <20130712214022.GC10562@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

You can turn on or off support for minorversions using e.g.

	echo "-4.2" >/proc/fs/nfsd/versions

However, the current implementation is a little wonky.  For example, the
above will turn off 4.2 support, but it will also turn *on* 4.1 support.

This didn't matter as long as we only had 2 minorversions, which was
true till very recently.

And do a little cleanup here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfsd.h     |    1 -
 fs/nfsd/nfssvc.c   |   13 +++++++------
 3 files changed, 8 insertions(+), 8 deletions(-)

For 3.11.

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a7cee86..0d4c410 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1293,7 +1293,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	 * According to RFC3010, this takes precedence over all other errors.
 	 */
 	status = nfserr_minor_vers_mismatch;
-	if (args->minorversion > nfsd_supported_minorversion)
+	if (nfsd_minorversion(args->minorversion, NFSD_TEST) <= 0)
 		goto out;
 
 	status = nfs41_check_op_ordering(args);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 2bbd94e..30f34ab 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -53,7 +53,6 @@ struct readdir_cd {
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
-extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern spinlock_t		nfsd_drc_lock;
 extern unsigned long		nfsd_drc_max_mem;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6b9f48c..760c85a 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -116,7 +116,10 @@ struct svc_program		nfsd_program = {
 
 };
 
-u32 nfsd_supported_minorversion = 1;
+static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
+	[0] = 1,
+	[1] = 1,
+};
 
 int nfsd_vers(int vers, enum vers_op change)
 {
@@ -151,15 +154,13 @@ int nfsd_minorversion(u32 minorversion, enum vers_op change)
 		return -1;
 	switch(change) {
 	case NFSD_SET:
-		nfsd_supported_minorversion = minorversion;
+		nfsd_supported_minorversions[minorversion] = true;
 		break;
 	case NFSD_CLEAR:
-		if (minorversion == 0)
-			return -1;
-		nfsd_supported_minorversion = minorversion - 1;
+		nfsd_supported_minorversions[minorversion] = false;
 		break;
 	case NFSD_TEST:
-		return minorversion <= nfsd_supported_minorversion;
+		return nfsd_supported_minorversions[minorversion];
 	case NFSD_AVAIL:
 		return minorversion <= NFSD_SUPPORTED_MINOR_VERSION;
 	}
-- 
1.7.9.5

