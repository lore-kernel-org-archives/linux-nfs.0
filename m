From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] sanitize logging subsystem
Date: Fri, 11 Mar 2005 15:18:29 +0200
Message-ID: <200503111518.29792.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_lqZMCVmvEXN8rQ5"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9k2N-0000Bb-EV
	for nfs@lists.sourceforge.net; Fri, 11 Mar 2005 05:18:43 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1D9k2K-0006Qw-Rf
	for nfs@lists.sourceforge.net; Fri, 11 Mar 2005 05:18:43 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Boundary-00=_lqZMCVmvEXN8rQ5
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

It seems like there are several ways to log messages or
display them on std{out,err} in nfs utils, more or less
similar to each other. Let's try to untangle them.

I'll start from cleaning up xlog.c:

* There is no external API to log to arbitrary FILE*,
  we can drop code which supports this internally.
  Patch converts xlog.c to directly use stderr.
* Print date/time in ISO (YYYY-MM-DD HH:MM:SS) format.
* Add support for disabling logging to syslog.

Patch does not introduce behavioral changes except for
making foregrounded mountd to really use stderr.
There was a bug which prevented this.

Patch is tested. Please comment/apply.
--
vda

--Boundary-00=_lqZMCVmvEXN8rQ5
Content-Type: text/x-diff;
  charset="koi8-r";
  name="nfs-utils-1.0.7_log1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.7_log1.diff"

diff -urpN nfs-utils-1.0.7.orig/support/include/xlog.h nfs-utils-1.0.7.logging1/support/include/xlog.h
--- nfs-utils-1.0.7.orig/support/include/xlog.h	Tue Oct 19 02:21:12 1999
+++ nfs-utils-1.0.7.logging1/support/include/xlog.h	Fri Mar 11 15:12:00 2005
@@ -7,12 +7,15 @@
 #ifndef XLOG_H
 #define XLOG_H
 
+/* These are logged always. L_FATAL also does exit(1) */
 #define L_FATAL		0x0100
 #define L_ERROR		0x0200
 #define L_WARNING	0x0400
 #define L_NOTICE	0x0800
 #define L_ALL		0xFF00
 
+/* These are logged if enabled with xlog_[s]config */
+/* NB: code does not expect ORing together D_ and L_ */
 #define D_GENERAL	0x0001		/* general debug info */
 #define D_CALL		0x0002
 #define D_AUTH		0x0004
@@ -31,7 +34,8 @@ struct xlog_debugfac {
 };
 
 void			xlog_open(char *progname);
-void			xlog_background(void);
+void			xlog_stderr(int on);
+void			xlog_syslog(int on);
 void			xlog_config(int fac, int on);
 void			xlog_sconfig(char *, int on);
 int			xlog_enabled(int fac);
diff -urpN nfs-utils-1.0.7.orig/support/nfs/xlog.c nfs-utils-1.0.7.logging1/support/nfs/xlog.c
--- nfs-utils-1.0.7.orig/support/nfs/xlog.c	Fri Jul 25 04:53:59 2003
+++ nfs-utils-1.0.7.logging1/support/nfs/xlog.c	Fri Mar 11 15:11:17 2005
@@ -29,12 +29,12 @@
 
 #undef	VERBOSE_PRINTF
 
-static int  foreground = 1;		/* not a daemon initially	*/
+static int  log_stderr = 1;
+static int  log_syslog = 1;
 static int  logging = 0;		/* enable/disable DEBUG logs	*/
 static int  logmask = 0;		/* What will be logged		*/
 static char log_name[256];		/* name of this program		*/
 static int  log_pid = -1;		/* PID of this program		*/
-static FILE *log_fp = (FILE *)NULL;	/* fp for the log file		*/
 
 static void	xlog_toggle(int sig);
 static struct xlog_debugfac	debugnames[] = {
@@ -50,11 +50,6 @@ void
 xlog_open(char *progname)
 {
 	openlog(progname, LOG_PID, LOG_DAEMON);
-	if (foreground) {
-		log_fp = stderr;
-		if (log_fp != NULL)
-			setbuf(log_fp, NULL);
-	}
 
 	strncpy(log_name, progname, sizeof (log_name) - 1);
 	log_name [sizeof (log_name) - 1] = '\0';
@@ -65,9 +60,15 @@ xlog_open(char *progname)
 }
 
 void
-xlog_background(void)
+xlog_stderr(int on)
+{
+	log_stderr = on;
+}
+
+void
+xlog_syslog(int on)
 {
-	foreground = 0;
+	log_syslog = on;
 }
 
 static void
@@ -126,17 +127,13 @@ xlog_enabled(int fac)
 }
 
 
-/* Write something to the system logfile. */
+/* Write something to the system logfile and/or stderr */
 void
 xlog(int kind, const char *fmt, ...)
 {
 	char		buff[1024];
 	va_list		args;
-	int		logged = 1, n;
-#ifdef VERBOSE_PRINTF
-	time_t		now;
-	struct tm	*tm;
-#endif
+	int		n;
 
 	if (!(kind & (L_ALL)) && !(logging && (kind & logmask)))
 		return;
@@ -148,40 +145,44 @@ xlog(int kind, const char *fmt, ...)
 	if ((n = strlen(buff)) > 0 && buff[n-1] == '\n')
 		buff[--n] = '\0';
 
-	switch (kind) {
-	case L_FATAL:
-		syslog(LOG_ERR, "%s", buff);
-		break;
-	case L_ERROR:
-		syslog(LOG_ERR, "%s", buff);
-		break;
-	case L_WARNING:
-		syslog(LOG_WARNING, "%s", buff);
-		break;
-	case L_NOTICE:
-		syslog(LOG_NOTICE, "%s", buff);
-		break;
-	default:
-		logged = 0;
-		break;
+	if (log_syslog) {
+		switch (kind) {
+		case L_FATAL:
+			syslog(LOG_ERR, "%s", buff);
+			break;
+		case L_ERROR:
+			syslog(LOG_ERR, "%s", buff);
+			break;
+		case L_WARNING:
+			syslog(LOG_WARNING, "%s", buff);
+			break;
+		case L_NOTICE:
+			syslog(LOG_NOTICE, "%s", buff);
+			break;
+		default:
+			if (!log_stderr)
+				syslog(LOG_DEBUG, "%s", buff);
+			break;
+		}
 	}
-	if (!logged || foreground) {
-		if (!logged && log_fp == NULL) {
-			syslog(LOG_DEBUG, "%s", buff);
-		} else if (log_fp != NULL) {
+
+	if (log_stderr) {
 #ifdef VERBOSE_PRINTF
-			time(&now);
-			tm = localtime(&now);
-			fprintf(log_fp, "%s[%d] %02d/%02d/%02d %02d:%02d %s\n",
-					log_name, log_pid,
-					tm->tm_mon + 1, tm->tm_mday,
-					tm->tm_year, tm->tm_hour, tm->tm_min,
-					buff);
+		time_t		now;
+		struct tm	*tm;
+
+		time(&now);
+		tm = localtime(&now);
+		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d %s\n",
+				log_name, log_pid,
+				tm->tm_year, tm->tm_mon + 1, tm->tm_mday,
+				tm->tm_hour, tm->tm_min, tm->tm_sec,
+				buff);
 #else
-			fprintf(log_fp, "%s: %s\n", log_name, buff);
+		fprintf(stderr, "%s: %s\n", log_name, buff);
 #endif
-		}
 	}
+
 	if (kind == L_FATAL)
 		exit(1);
 }
diff -urpN nfs-utils-1.0.7.orig/utils/mountd/mountd.c nfs-utils-1.0.7.logging1/utils/mountd/mountd.c
--- nfs-utils-1.0.7.orig/utils/mountd/mountd.c	Mon Sep  6 05:15:50 2004
+++ nfs-utils-1.0.7.logging1/utils/mountd/mountd.c	Fri Mar 11 15:11:36 2005
@@ -531,7 +531,8 @@ main(int argc, char **argv)
 		}
 	}
 	/* Initialize logging. */
-/*	xlog_open("mountd"); */
+	if (!foreground) xlog_stderr(0);
+	xlog_open("mountd");
 
 	sa.sa_handler = SIG_IGN;
 	sa.sa_flags = 0;
@@ -589,7 +590,6 @@ main(int argc, char **argv)
 			if (fd > 2) (void) close(fd);
 		}
 		setsid();
-		xlog_background();
 	}
 
 	my_svc_run();

--Boundary-00=_lqZMCVmvEXN8rQ5--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
