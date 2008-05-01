From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 3/4] gssd: add a function to retrieve the current verbosity
	level
Date: Thu, 01 May 2008 09:35:10 -0400
Message-ID: <20080501133510.28884.94379.stgit@jazz.citi.umich.edu>
References: <20080501133455.28884.4768.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:29456 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbYEANfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 09:35:11 -0400
In-Reply-To: <20080501133455.28884.4768.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

