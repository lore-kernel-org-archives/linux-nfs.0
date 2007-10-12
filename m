From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 7/9] Cleanup xlog logging code to be safe and usable
	for all
Date: Fri, 12 Oct 2007 16:35:15 -0400
Message-ID: <20071012203515.24796.44562.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRE4-0008G7-4M
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:16 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRE4-0007dJ-1T
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:16 -0700
In-Reply-To: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

This patch reworks the xlog logging code to avoid rebuilding the message into a
fixed size buffer. It also adds two new logging functions xlog_warn and
xlog_err which are replacements for idmap_warn and idmap_err. There use to be
two different variates of these functions with the only difference being that
one flavor tacked on the error string to the end of the message. This
responsibility has been pushed to the called of the function since it
needlessly complicated the function and required us to rebuild the message
strings.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 support/include/xlog.h |    5 ++++
 support/nfs/xlog.c     |   64 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/support/include/xlog.h b/support/include/xlog.h
index cf9bc91..fd1a3f4 100644
--- a/support/include/xlog.h
+++ b/support/include/xlog.h
@@ -7,6 +7,8 @@
 #ifndef XLOG_H
 #define XLOG_H
 
+#include <stdarg.h>
+
 /* These are logged always. L_FATAL also does exit(1) */
 #define L_FATAL		0x0100
 #define L_ERROR		0x0200
@@ -40,5 +42,8 @@ void			xlog_config(int fac, int on);
 void			xlog_sconfig(char *, int on);
 int			xlog_enabled(int fac);
 void			xlog(int fac, const char *fmt, ...);
+void			xlog_warn(const char *fmt, ...);
+void			xlog_err(const char *fmt, ...);
+void			xlog_backend(int fac, const char *fmt, va_list args);
 
 #endif /* XLOG_H */
diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
index 1bbfd19..26123c5 100644
--- a/support/nfs/xlog.c
+++ b/support/nfs/xlog.c
@@ -131,39 +131,28 @@ xlog_enabled(int fac)
 
 /* Write something to the system logfile and/or stderr */
 void
-xlog(int kind, const char *fmt, ...)
+xlog_backend(int kind, const char *fmt, va_list args)
 {
-	char		buff[1024];
-	va_list		args;
-	int		n;
-
 	if (!(kind & (L_ALL)) && !(logging && (kind & logmask)))
 		return;
 
-	va_start(args, fmt);
-	vsnprintf(buff, sizeof (buff), fmt, args);
-	va_end(args);
-
-	if ((n = strlen(buff)) > 0 && buff[n-1] == '\n')
-		buff[--n] = '\0';
-
 	if (log_syslog) {
 		switch (kind) {
 		case L_FATAL:
-			syslog(LOG_ERR, "%s", buff);
+			vsyslog(LOG_ERR, fmt, args);
 			break;
 		case L_ERROR:
-			syslog(LOG_ERR, "%s", buff);
+			vsyslog(LOG_ERR, fmt, args);
 			break;
 		case L_WARNING:
-			syslog(LOG_WARNING, "%s", buff);
+			vsyslog(LOG_WARNING, fmt, args);
 			break;
 		case L_NOTICE:
-			syslog(LOG_NOTICE, "%s", buff);
+			vsyslog(LOG_NOTICE, fmt, args);
 			break;
 		default:
 			if (!log_stderr)
-				syslog(LOG_INFO, "%s", buff);
+				vsyslog(LOG_INFO, fmt, args);
 			break;
 		}
 	}
@@ -175,16 +164,49 @@ xlog(int kind, const char *fmt, ...)
 
 		time(&now);
 		tm = localtime(&now);
-		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d %s\n",
+		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d ",
 				log_name, log_pid,
 				tm->tm_year+1900, tm->tm_mon + 1, tm->tm_mday,
-				tm->tm_hour, tm->tm_min, tm->tm_sec,
-				buff);
+				tm->tm_hour, tm->tm_min, tm->tm_sec);
 #else
-		fprintf(stderr, "%s: %s\n", log_name, buff);
+		fprintf(stderr, "%s: ", log_name);
 #endif
+
+		vfprintf(stderr, fmt, args);
+		fprintf(stderr, "\n");
 	}
 
 	if (kind == L_FATAL)
 		exit(1);
 }
+
+void
+xlog(int kind, const char* fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	xlog_backend(kind, fmt, args);
+	va_end(args);
+}
+
+void
+xlog_warn(const char* fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	xlog_backend(L_WARNING, fmt, args);
+	va_end(args);
+}
+
+
+void
+xlog_err(const char* fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	xlog_backend(L_FATAL, fmt, args);
+	va_end(args);
+}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
