From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 8/9] Remove old logging implementation for idmapd and
	rework	gssd and idmapd to use the new xlog logging infrastructure.
Date: Fri, 12 Oct 2007 16:35:20 -0400
Message-ID: <20071012203520.24796.89645.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRE5-0008GM-HD
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:17 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRE9-0002q3-4t
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:22 -0700
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

This patch removes all of the old idmap_* logging functions and replaced them
with the corresponding xlog functions. In addition that that it also reworks
the gssd logging wrappers to use the new xlog_backend. Finally it makes
necessary changes to the build files to get the project compiling again.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/Makefile.am |    3 +
 utils/gssd/err_util.c  |   43 ++-------------
 utils/idmapd/idmapd.c  |  142 +++++++++++++-----------------------------------
 3 files changed, 46 insertions(+), 142 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index c0ca8be..e42b339 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -38,7 +38,8 @@ gssd_SOURCES = \
 	krb5_util.h \
 	write_bytes.h
 
-gssd_LDADD = $(RPCSECGSS_LIBS) $(KRBLIBS)
+gssd_LDADD =	../../support/nfs/libnfs.a \
+		$(RPCSECGSS_LIBS) $(KRBLIBS)
 gssd_LDFLAGS = $(KRBLDFLAGS)
 
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
diff --git a/utils/gssd/err_util.c b/utils/gssd/err_util.c
index f331432..5644db6 100644
--- a/utils/gssd/err_util.c
+++ b/utils/gssd/err_util.c
@@ -30,64 +30,33 @@
 
 #include <stdio.h>
 #include <stdarg.h>
-#include <syslog.h>
 #include <string.h>
-#include "err_util.h"
+#include "xlog.h"
 
 static int verbosity = 0;
 static int fg = 0;
 
-static char message_buf[500];
-
 void initerr(char *progname, int set_verbosity, int set_fg)
 {
 	verbosity = set_verbosity;
 	fg = set_fg;
 	if (!fg)
-		openlog(progname, LOG_PID, LOG_DAEMON);
+		xlog_open(progname);
 }
 
 
 void printerr(int priority, char *format, ...)
 {
 	va_list args;
-	int ret;
-	int buf_used, buf_available;
-	char *buf;
 
 	/* Don't bother formatting a message we're never going to print! */
 	if (priority > verbosity)
 		return;
 
-	buf_used = strlen(message_buf);
-	/* subtract 4 to leave room for "...\n" if necessary */
-	buf_available = sizeof(message_buf) - buf_used - 4;
-	buf = message_buf + buf_used;
-
-	/*
-	 * Aggregate lines: only print buffer when we get to the
-	 * end of a line or run out of space
-	 */
 	va_start(args, format);
-	ret = vsnprintf(buf, buf_available, format, args);
+	if (fg)
+		vfprintf(stderr, format, args);
+	else
+		xlog_backend(L_ERROR, format, args);
 	va_end(args);
-
-	if (ret < 0)
-		goto printit;
-	if (ret >= buf_available) {
-		/* Indicate we're truncating */
-		strcat(message_buf, "...\n");
-		goto printit;
-	}
-	if (message_buf[strlen(message_buf) - 1] == '\n')
-		goto printit;
-	return;
-printit:
-	if (fg) {
-		fprintf(stderr, "%s", message_buf);
-	} else {
-		syslog(LOG_ERR, "%s", message_buf);
-	}
-	/* reset the buffer */
-	memset(message_buf, 0, sizeof(message_buf));
 }
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index a82cd0b..355c6e1 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -55,7 +55,6 @@
 #include <stdlib.h>
 #include <string.h>
 #include <stdarg.h>
-#include <syslog.h>
 #include <pwd.h>
 #include <grp.h>
 #include <limits.h>
@@ -66,6 +65,7 @@
 #include "config.h"
 #endif /* HAVE_CONFIG_H */
 
+#include "xlog.h"
 #include "cfg.h"
 #include "queue.h"
 #include "nfslib.h"
@@ -187,71 +187,6 @@ flush_nfsd_idmap_cache(void)
 	return ret;
 }
 
-static void
-msg_format(char *rtnbuff, int rtnbuffsize, int errval,
-	   const char *fmt, va_list args)
-{
-	char buff[1024];
-	int n;
-
-	vsnprintf(buff, sizeof(buff), fmt, args);
-
-	if ((n = strlen(buff)) > 0 && buff[n-1] == '\n')
-		buff[--n] = '\0';
-
-	snprintf(rtnbuff, rtnbuffsize, "%s: %s", buff, strerror(errval));
-}
-
-static void
-idmapd_warn(const char *fmt, ...)
-{
-	int errval = errno;	/* save this! */
-	char buff[1024];
-	va_list args;
-
-	va_start(args, fmt);
-	msg_format(buff, sizeof(buff), errval, fmt, args);
-	va_end(args);
-
-	syslog(LOG_WARNING, "%s", buff);
-}
-
-static void
-idmapd_warnx(const char *fmt, ...)
-{
-	va_list args;
-
-	va_start(args, fmt);
-	vsyslog(LOG_WARNING, fmt, args);
-	va_end(args);
-}
-
-static void
-idmapd_err(int eval, const char *fmt, ...)
-{
-	int errval = errno;	/* save this! */
-	char buff[1024];
-	va_list args;
-
-	va_start(args, fmt);
-	msg_format(buff, sizeof(buff), errval, fmt, args);
-	va_end(args);
-
-	syslog(LOG_ERR, "%s", buff);
-	exit(eval);
-}
-
-static void
-idmapd_errx(int eval, const char *fmt, ...)
-{
-	va_list args;
-
-	va_start(args, fmt);
-	vsyslog(LOG_ERR, fmt, args);
-	va_end(args);
-	exit(eval);
-}
-
 int
 main(int argc, char **argv)
 {
@@ -276,7 +211,7 @@ main(int argc, char **argv)
 		progname++;
 	else
 		progname = argv[0];
-	openlog(progname, LOG_PID, LOG_DAEMON);
+	xlog_open(progname);
 
 #define GETOPTSTR "vfd:p:U:G:c:CS"
 	opterr=0; /* Turn off error messages */
@@ -347,7 +282,7 @@ main(int argc, char **argv)
 	nobodygid = gr->gr_gid;
 
 #ifdef HAVE_NFS4_SET_DEBUG
-	nfs4_set_debug(verbose, idmapd_warnx);
+	nfs4_set_debug(verbose, xlog_warn);
 #endif
 	if (conf_path == NULL)
 		conf_path = _PATH_IDMAPDCONF;
@@ -360,15 +295,14 @@ main(int argc, char **argv)
 	event_init();
 
 	if (verbose > 0)
-		idmapd_warnx("Expiration time is %d seconds.",
+		xlog_warn("Expiration time is %d seconds.",
 			     cache_entry_expiration);
 	if (serverstart) {
 		nfsdret = nfsdopen();
 		if (nfsdret == 0) {
 			ret = flush_nfsd_idmap_cache();
 			if (ret)
-				idmapd_errx(1,
-					"main: Failed to flush nfsd idmap cache\n");
+				xlog_err("main: Failed to flush nfsd idmap cache\n: %s", strerror(errno));
 		}
 	}
 
@@ -383,7 +317,7 @@ main(int argc, char **argv)
 			char timeout_buf[12];
 			if ((timeout_fd = open(CLIENT_CACHE_TIMEOUT_FILE,
 					       O_RDWR)) == -1) {
-				idmapd_warnx("Unable to open '%s' to set "
+				xlog_warn("Unable to open '%s' to set "
 					     "client cache expiration time "
 					     "to %d seconds\n",
 					     CLIENT_CACHE_TIMEOUT_FILE,
@@ -392,7 +326,7 @@ main(int argc, char **argv)
 				len = snprintf(timeout_buf, sizeof(timeout_buf),
 					       "%d", cache_entry_expiration);
 				if ((write(timeout_fd, timeout_buf, len)) != len)
-					idmapd_warnx("Error writing '%s' to "
+					xlog_warn("Error writing '%s' to "
 						     "'%s' to set client "
 						     "cache expiration time\n",
 						     timeout_buf,
@@ -402,14 +336,14 @@ main(int argc, char **argv)
 		}
 
 		if ((fd = open(pipefsdir, O_RDONLY)) == -1)
-			idmapd_err(1, "main: open(%s)", pipefsdir);
+			xlog_err("main: open(%s): %s", pipefsdir, strerror(errno));
 
 		if (fcntl(fd, F_SETSIG, SIGUSR1) == -1)
-			idmapd_err(1, "main: fcntl(%s)", pipefsdir);
+			xlog_err("main: fcntl(%s): %s", pipefsdir, strerror(errno));
 
 		if (fcntl(fd, F_NOTIFY,
 			DN_CREATE | DN_DELETE | DN_MODIFY | DN_MULTISHOT) == -1)
-			idmapd_err(1, "main: fcntl(%s)", pipefsdir);
+			xlog_err("main: fcntl(%s): %s", pipefsdir, strerror(errno));
 
 		TAILQ_INIT(&icq);
 
@@ -429,12 +363,12 @@ main(int argc, char **argv)
 	}
 
 	if (nfsdret != 0 && fd == 0)
-		idmapd_errx(1, "main: Neither NFS client nor NFSd found");
+		xlog_err("main: Neither NFS client nor NFSd found");
 
 	release_parent();
 
 	if (event_dispatch() < 0)
-		idmapd_errx(1, "main: event_dispatch returns errno %d (%s)",
+		xlog_err("main: event_dispatch returns errno %d (%s)",
 			    errno, strerror(errno));
 	/* NOTREACHED */
 	return 1;
@@ -451,7 +385,7 @@ dirscancb(int fd, short which, void *data)
 
 	nent = scandir(pipefsdir, &ents, NULL, alphasort);
 	if (nent == -1) {
-		idmapd_warn("dirscancb: scandir(%s)", pipefsdir);
+		xlog_warn("dirscancb: scandir(%s): %s", pipefsdir, strerror(errno));
 		return;
 	}
 
@@ -473,7 +407,7 @@ dirscancb(int fd, short which, void *data)
 			    pipefsdir, ents[i]->d_name);
 
 			if ((ic->ic_dirfd = open(path, O_RDONLY, 0)) == -1) {
-				idmapd_warn("dirscancb: open(%s)", path);
+				xlog_warn("dirscancb: open(%s): %s", path, strerror(errno));
 				free(ic);
 				goto out;
 			}
@@ -482,7 +416,7 @@ dirscancb(int fd, short which, void *data)
 			strlcpy(ic->ic_path, path, sizeof(ic->ic_path));
 
 			if (verbose > 0)
-				idmapd_warnx("New client: %s", ic->ic_clid);
+				xlog_warn("New client: %s", ic->ic_clid);
 
 			if (nfsopen(ic) == -1) {
 				close(ic->ic_dirfd);
@@ -508,8 +442,8 @@ dirscancb(int fd, short which, void *data)
 			close(ic->ic_dirfd);
 			TAILQ_REMOVE(icq, ic, ic_next);
 			if (verbose > 0) {
-				idmapd_warnx("Stale client: %s", ic->ic_clid);
-				idmapd_warnx("\t-> closed %s", ic->ic_path);
+				xlog_warn("Stale client: %s", ic->ic_clid);
+				xlog_warn("\t-> closed %s", ic->ic_path);
 			}
 			free(ic);
 		} else
@@ -560,7 +494,7 @@ nfsdcb(int fd, short which, void *data)
 		goto out;
 
 	if ((len = read(ic->ic_fd, buf, sizeof(buf))) <= 0) {
-		idmapd_warnx("nfsdcb: read(%s) failed: errno %d (%s)",
+		xlog_warn("nfsdcb: read(%s) failed: errno %d (%s)",
 			     ic->ic_path, len?errno:0, 
 			     len?strerror(errno):"End of File");
 		goto out;
@@ -574,15 +508,15 @@ nfsdcb(int fd, short which, void *data)
 
 	/* Authentication name -- ignored for now*/
 	if (getfield(&bp, authbuf, sizeof(authbuf)) == -1) {
-		idmapd_warnx("nfsdcb: bad authentication name in upcall\n");
+		xlog_warn("nfsdcb: bad authentication name in upcall\n");
 		return;
 	}
 	if (getfield(&bp, typebuf, sizeof(typebuf)) == -1) {
-		idmapd_warnx("nfsdcb: bad type in upcall\n");
+		xlog_warn("nfsdcb: bad type in upcall\n");
 		return;
 	}
 	if (verbose > 0)
-		idmapd_warnx("nfsdcb: authbuf=%s authtype=%s",
+		xlog_warn("nfsdcb: authbuf=%s authtype=%s",
 			     authbuf, typebuf);
 
 	im.im_type = strcmp(typebuf, "user") == 0 ?
@@ -592,26 +526,26 @@ nfsdcb(int fd, short which, void *data)
 	case IC_NAMEID:
 		im.im_conv = IDMAP_CONV_NAMETOID;
 		if (getfield(&bp, im.im_name, sizeof(im.im_name)) == -1) {
-			idmapd_warnx("nfsdcb: bad name in upcall\n");
+			xlog_warn("nfsdcb: bad name in upcall\n");
 			return;
 		}
 		break;
 	case IC_IDNAME:
 		im.im_conv = IDMAP_CONV_IDTONAME;
 		if (getfield(&bp, buf1, sizeof(buf1)) == -1) {
-			idmapd_warnx("nfsdcb: bad id in upcall\n");
+			xlog_warn("nfsdcb: bad id in upcall\n");
 			return;
 		}
 		tmp = strtoul(buf1, (char **)NULL, 10);
 		im.im_id = (u_int32_t)tmp;
 		if ((tmp == ULONG_MAX && errno == ERANGE)
 				|| (unsigned long)im.im_id != tmp) {
-			idmapd_warnx("nfsdcb: id '%s' too big!\n", buf1);
+			xlog_warn("nfsdcb: id '%s' too big!\n", buf1);
 			return;
 		}
 		break;
 	default:
-		idmapd_warnx("nfsdcb: Unknown which type %d", ic->ic_which);
+		xlog_warn("nfsdcb: Unknown which type %d", ic->ic_which);
 		return;
 	}
 
@@ -672,14 +606,14 @@ nfsdcb(int fd, short which, void *data)
 
 		break;
 	default:
-		idmapd_warnx("nfsdcb: Unknown which type %d", ic->ic_which);
+		xlog_warn("nfsdcb: Unknown which type %d", ic->ic_which);
 		return;
 	}
 
 	bsiz = sizeof(buf) - bsiz;
 
 	if (atomicio((void*)write, ic->ic_fd, buf, bsiz) != bsiz)
-		idmapd_warnx("nfsdcb: write(%s) failed: errno %d (%s)",
+		xlog_warn("nfsdcb: write(%s) failed: errno %d (%s)",
 			     ic->ic_path, errno, strerror(errno));
 
 out:
@@ -693,7 +627,7 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
 	case IDMAP_CONV_IDTONAME:
 		idtonameres(im);
 		if (verbose > 1)
-			idmapd_warnx("%s %s: (%s) id \"%d\" -> name \"%s\"",
+			xlog_warn("%s %s: (%s) id \"%d\" -> name \"%s\"",
 			    ic->ic_id, ic->ic_clid,
 			    im->im_type == IDMAP_TYPE_USER ? "user" : "group",
 			    im->im_id, im->im_name);
@@ -705,13 +639,13 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
 		}
 		nametoidres(im);
 		if (verbose > 1)
-			idmapd_warnx("%s %s: (%s) name \"%s\" -> id \"%d\"",
+			xlog_warn("%s %s: (%s) name \"%s\" -> id \"%d\"",
 			    ic->ic_id, ic->ic_clid,
 			    im->im_type == IDMAP_TYPE_USER ? "user" : "group",
 			    im->im_name, im->im_id);
 		break;
 	default:
-		idmapd_warnx("imconv: Invalid conversion type (%d) in message",
+		xlog_warn("imconv: Invalid conversion type (%d) in message",
 			     im->im_conv);
 		im->im_status |= IDMAP_STATUS_INVALIDMSG;
 		break;
@@ -729,7 +663,7 @@ nfscb(int fd, short which, void *data)
 
 	if (atomicio(read, ic->ic_fd, &im, sizeof(im)) != sizeof(im)) {
 		if (verbose > 0)
-			idmapd_warn("nfscb: read(%s)", ic->ic_path);
+			xlog_warn("nfscb: read(%s): %s", ic->ic_path, strerror(errno));
 		if (errno == EPIPE)
 			return;
 		goto out;
@@ -745,7 +679,7 @@ nfscb(int fd, short which, void *data)
 		im.im_status = IDMAP_STATUS_SUCCESS;
 
 	if (atomicio((void*)write, ic->ic_fd, &im, sizeof(im)) != sizeof(im))
-		idmapd_warn("nfscb: write(%s)", ic->ic_path);
+		xlog_warn("nfscb: write(%s): %s", ic->ic_path, strerror(errno));
 out:
 	event_add(&ic->ic_event, NULL);
 }
@@ -756,7 +690,7 @@ nfsdreopen_one(struct idmap_client *ic)
 	int fd;
 
 	if (verbose > 0)
-		idmapd_warnx("ReOpening %s", ic->ic_path);
+		xlog_warn("ReOpening %s", ic->ic_path);
 
 	if ((fd = open(ic->ic_path, O_RDWR, 0)) != -1) {
 		if ((ic->ic_event.ev_flags & EVLIST_INIT))
@@ -768,7 +702,7 @@ nfsdreopen_one(struct idmap_client *ic)
 		event_set(&ic->ic_event, ic->ic_fd, EV_READ, nfsdcb, ic);
 		event_add(&ic->ic_event, NULL);
 	} else {
-		idmapd_warnx("nfsdreopen: Opening '%s' failed: errno %d (%s)",
+		xlog_warn("nfsdreopen: Opening '%s' failed: errno %d (%s)",
 			ic->ic_path, errno, strerror(errno));
 	}
 }
@@ -793,7 +727,7 @@ nfsdopenone(struct idmap_client *ic)
 {
 	if ((ic->ic_fd = open(ic->ic_path, O_RDWR, 0)) == -1) {
 		if (verbose > 0)
-			idmapd_warnx("nfsdopenone: Opening %s failed: "
+			xlog_warn("nfsdopenone: Opening %s failed: "
 				"errno %d (%s)",
 				ic->ic_path, errno, strerror(errno));
 		return (-1);
@@ -803,7 +737,7 @@ nfsdopenone(struct idmap_client *ic)
 	event_add(&ic->ic_event, NULL);
 
 	if (verbose > 0)
-		idmapd_warnx("Opened %s", ic->ic_path);
+		xlog_warn("Opened %s", ic->ic_path);
 
 	return (0);
 }
@@ -819,7 +753,7 @@ nfsopen(struct idmap_client *ic)
 			    DN_CREATE | DN_DELETE | DN_MULTISHOT);
 			break;
 		default:
-			idmapd_warn("nfsopen: open(%s)", ic->ic_path);
+			xlog_warn("nfsopen: open(%s): %s", ic->ic_path, strerror(errno));
 			return (-1);
 		}
 	} else {
@@ -828,7 +762,7 @@ nfsopen(struct idmap_client *ic)
 		fcntl(ic->ic_dirfd, F_SETSIG, 0);
 		fcntl(ic->ic_dirfd, F_NOTIFY, 0);
 		if (verbose > 0)
-			idmapd_warnx("Opened %s", ic->ic_path);
+			xlog_warn("Opened %s", ic->ic_path);
 	}
 
 	return (0);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
