From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/2] gssd: add a function to retrieve the current verbosity
	level
Date: Tue, 08 Apr 2008 14:33:25 -0400
Message-ID: <20080408183322.11839.46964.stgit@RoCK.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:15727 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbYDHSd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 14:33:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add a new function to retrieve the current verbosity level
so that some messages that would otherwise always print may
be silenced.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/err_util.c |    5 +++++
 utils/gssd/err_util.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)


diff --git a/utils/gssd/err_util.c b/utils/gssd/err_util.c
index 5644db6..2583e06 100644
--- a/utils/gssd/err_util.c
+++ b/utils/gssd/err_util.c
@@ -60,3 +60,8 @@ void printerr(int priority, char *format, ...)
 		xlog_backend(L_ERROR, format, args);
 	va_end(args);
 }
+
+int get_verbosity(void)
+{
+	return verbosity;
+}
diff --git a/utils/gssd/err_util.h b/utils/gssd/err_util.h
index 5e5af48..c4df32d 100644
--- a/utils/gssd/err_util.h
+++ b/utils/gssd/err_util.h
@@ -33,5 +33,6 @@
 
 void initerr(char *progname, int verbosity, int fg);
 void printerr(int priority, char *format, ...);
+int get_verbosity(void);
 
 #endif /* _ERR_UTIL_H_ */

