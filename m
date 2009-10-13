From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/26] statd: Use the new nsm_ file.c calls in rpc.statd
Date: Tue, 13 Oct 2009 10:55:37 -0400
Message-ID: <20091013145537.2424.83629.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:42679 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbZJMO4r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:56:47 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEu5uP029885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:06 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEaKxk012723
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:41 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace open-coded accesses to on-disk NSM information in rpc.statd
with calls to the new API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/misc.c    |   24 --------
 utils/statd/monitor.c |  140 ++++++++++++++++---------------------------------
 utils/statd/statd.c   |  116 ++++-------------------------------------
 utils/statd/statd.h   |   23 --------
 4 files changed, 57 insertions(+), 246 deletions(-)

diff --git a/utils/statd/misc.c b/utils/statd/misc.c
index 44af30e..f2a086f 100644
--- a/utils/statd/misc.c
+++ b/utils/statd/misc.c
@@ -49,27 +49,3 @@ xstrdup (const char *string)
 
   return (result);
 }
-
-
-/*
- * Unlinking a file.
- */
-void
-xunlink (char *path, char *host)
-{
-	char *tozap;
-
-	tozap = malloc(strlen(path)+strlen(host)+2);
-	if (tozap == NULL) {
-		xlog(L_ERROR, "xunlink: malloc failed: errno %d (%m)", errno);
-		return;
-	}
-	sprintf (tozap, "%s/%s", path, host);
-
-	if (unlink (tozap) == -1)
-		xlog(L_ERROR, "unlink (%s): %m", tozap);
-	else
-		xlog(D_GENERAL, "Unlinked %s", tozap);
-
-	free(tozap);
-}
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 09f03da..8d9f663 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -23,14 +23,13 @@
 
 #include "rpcmisc.h"
 #include "misc.h"
+#include "nsm.h"
 #include "statd.h"
 #include "notlist.h"
 #include "ha-callout.h"
 
 notify_list *		rtnl = NULL;	/* Run-time notify list. */
 
-#define LINELEN (4*(8+1)+SM_PRIV_SIZE*2+1)
-
 /*
  * Reject requests from non-loopback addresses in order
  * to prevent attack described in CERT CA-99.05.
@@ -60,11 +59,12 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	char		*mon_name = argp->mon_id.mon_name,
 			*my_name  = argp->mon_id.my_id.my_name;
 	struct my_id	*id = &argp->mon_id.my_id;
-	char            *path;
 	char		*cp;
-	int             fd;
 	notify_list	*clnt;
-	struct in_addr	my_addr;
+	struct sockaddr_in my_addr = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
 	char		*dnsname;
 	struct hostent	*hostinfo = NULL;
 
@@ -80,7 +80,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 */
 	if (!caller_is_localhost(rqstp))
 		goto failure;
-	my_addr.s_addr = htonl(INADDR_LOOPBACK);
 
 	/* 2.	Reject any registrations for non-lockd services.
 	 *
@@ -172,7 +171,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		goto failure;
 	}
 
-	NL_ADDR(clnt) = my_addr;
+	NL_ADDR(clnt) = my_addr.sin_addr;
 	NL_MY_PROG(clnt) = id->my_prog;
 	NL_MY_VERS(clnt) = id->my_vers;
 	NL_MY_PROC(clnt) = id->my_proc;
@@ -182,39 +181,15 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	/*
 	 * Now, Create file on stable storage for host.
 	 */
-
-	path=xmalloc(strlen(SM_DIR)+strlen(dnsname)+2);
-	sprintf(path, "%s/%s", SM_DIR, dnsname);
-	if ((fd = open(path, O_WRONLY|O_SYNC|O_CREAT|O_APPEND,
-		       S_IRUSR|S_IWUSR)) < 0) {
-		/* Didn't fly.  We won't monitor. */
-		xlog(L_ERROR, "creat(%s) failed: %m", path);
+	if (!nsm_insert_monitored_host(dnsname,
+					(struct sockaddr *)&my_addr, argp)) {
 		nlist_free(NULL, clnt);
-		free(path);
 		goto failure;
 	}
-	{
-		char buf[LINELEN + 1 + SM_MAXSTRLEN*2 + 4];
-		char *e;
-		int i;
-		e = buf + sprintf(buf, "%08x %08x %08x %08x ",
-				  my_addr.s_addr, id->my_prog,
-				  id->my_vers, id->my_proc);
-		for (i=0; i<SM_PRIV_SIZE; i++)
-			e += sprintf(e, "%02x", 0xff & (argp->priv[i]));
-		if (e+1-buf != LINELEN) abort();
-		e += sprintf(e, " %s %s\n", mon_name, my_name);
-		if (write(fd, buf, e-buf) != (e-buf)) {
-			xlog_warn("writing to %s failed: errno %d (%s)",
-				path, errno, strerror(errno));
-		}
-	}
 
-	free(path);
 	/* PRC: do the HA callout: */
 	ha_callout("add-client", mon_name, my_name, -1);
 	nlist_insert(&rtnl, clnt);
-	close(fd);
 	xlog(D_GENERAL, "MONITORING %s for %s", mon_name, my_name);
  success:
 	result.res_stat = STAT_SUCC;
@@ -236,71 +211,46 @@ failure:
 	return (&result);
 }
 
-void load_state(void)
+static unsigned int
+load_one_host(const char *hostname, const struct sockaddr *sap,
+		const struct mon *mon,
+		__attribute__((unused)) const time_t timestamp)
 {
-	DIR *d;
-	struct dirent *de;
-	char buf[LINELEN + 1 + SM_MAXSTRLEN + 2];
-
-	d = opendir(SM_DIR);
-	if (!d)
-		return;
-	while ((de = readdir(d))) {
-		char *path;
-		FILE *f;
-		int p;
-
-		if (de->d_name[0] == '.')
-			continue;
-		path = xmalloc(strlen(SM_DIR)+strlen(de->d_name)+2);
-		sprintf(path, "%s/%s", SM_DIR, de->d_name);
-		f = fopen(path, "r");
-		free(path);
-		if (f == NULL)
-			continue;
-		while (fgets(buf, sizeof(buf), f) != NULL) {
-			int addr, proc, prog, vers;
-			char priv[SM_PRIV_SIZE];
-			char *monname, *myname;
-			char *b;
-			int i;
-			notify_list	*clnt;
-
-			buf[sizeof(buf)-1] = 0;
-			b = strchr(buf, '\n');
-			if (b) *b = 0;
-			sscanf(buf, "%x %x %x %x ",
-			       &addr, &prog, &vers, &proc);
-			b = buf+36;
-			for (i=0; i<SM_PRIV_SIZE; i++) {
-				sscanf(b, "%2x", &p);
-				priv[i] = p;
-				b += 2;
-			}
-			b++;
-			monname = b;
-			while (*b && *b != ' ') b++;
-			if (*b) *b++ = '\0';
-			while (*b == ' ') b++;
-			myname = b;
-			clnt = nlist_new(myname, monname, 0);
-			if (!clnt)
-				break;
-			NL_ADDR(clnt).s_addr = addr;
-			NL_MY_PROG(clnt) = prog;
-			NL_MY_VERS(clnt) = vers;
-			NL_MY_PROC(clnt) = proc;
-			clnt->dns_name = xstrdup(de->d_name);
-			memcpy(NL_PRIV(clnt), priv, SM_PRIV_SIZE);
-			nlist_insert(&rtnl, clnt);
-		}
-		fclose(f);
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	notify_list *clnt;
+
+	clnt = nlist_new(mon->mon_id.my_id.my_name,
+				mon->mon_id.mon_name, 0);
+	if (clnt == NULL)
+		return 0;
+
+	clnt->dns_name = strdup(hostname);
+	if (clnt->dns_name == NULL) {
+		nlist_free(NULL, clnt);
+		return 0;
 	}
-	closedir(d);
-}
 
+	xlog(D_GENERAL, "Adding record for %s to the monitor list...",
+			hostname);
+
+	NL_ADDR(clnt) = sin->sin_addr;
+	NL_MY_PROG(clnt) = mon->mon_id.my_id.my_prog;
+	NL_MY_VERS(clnt) = mon->mon_id.my_id.my_vers;
+	NL_MY_PROC(clnt) = mon->mon_id.my_id.my_proc;
+	memcpy(NL_PRIV(clnt), mon->priv, SM_PRIV_SIZE);
+
+	nlist_insert(&rtnl, clnt);
+	return 1;
+}
 
+void load_state(void)
+{
+	unsigned int count;
 
+	count = nsm_load_monitor_list(load_one_host);
+	if (count)
+		xlog(D_GENERAL, "Loaded %u previously monitored hosts");
+}
 
 /*
  * Services SM_UNMON requests.
@@ -359,7 +309,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
 
-			xunlink(SM_DIR, clnt->dns_name);
+			nsm_delete_monitored_host(clnt->dns_name);
 			nlist_free(&rtnl, clnt);
 
 			return (&result);
@@ -413,7 +363,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 			temp = NL_NEXT(clnt);
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
-			xunlink(SM_DIR, clnt->dns_name);
+			nsm_delete_monitored_host(clnt->dns_name);
 			nlist_free(&rtnl, clnt);
 			++count;
 			clnt = temp;
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 6148952..72c9b41 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -25,25 +25,15 @@
 #include <sys/resource.h>
 #include <sys/wait.h>
 #include <grp.h>
+
 #include "statd.h"
 #include "nfslib.h"
+#include "nsm.h"
 
 /* Socket operations */
 #include <sys/types.h>
 #include <sys/socket.h>
 
-/* Added to enable specification of state directory path at run-time
- * j_carlos_gomez@yahoo.com
- */
-
-char * DIR_BASE = DEFAULT_DIR_BASE;
-
-char *  SM_DIR = DEFAULT_SM_DIR;
-char *  SM_BAK_DIR =  DEFAULT_SM_BAK_DIR;
-char *  SM_STAT_PATH = DEFAULT_SM_STAT_PATH;
-
-/* ----- end of state directory path stuff ------- */
-
 int	run_mode = 0;		/* foreground logging mode */
 
 /* LH - I had these local to main, but it seemed silly to have 
@@ -73,7 +63,6 @@ static struct option longopts[] =
 };
 
 extern void sm_prog_1 (struct svc_req *, register SVCXPRT *);
-static void load_state_number(void);
 
 #ifdef SIMULATIONS
 extern void simulator (int, char **);
@@ -190,38 +179,6 @@ static void truncate_pidfile(void)
 	}
 }
 
-static void drop_privs(void)
-{
-	struct stat st;
-
-	if (stat(SM_DIR, &st) == -1 &&
-	    stat(DIR_BASE, &st) == -1) {
-		st.st_uid = 0;
-		st.st_gid = 0;
-	}
-
-	if (st.st_uid == 0) {
-		xlog_warn("Running as 'root'.  "
-			"chown %s to choose different user\n", SM_DIR);
-		return;
-	}
-	/* better chown the pid file before dropping, as if it
-	 * if over nfs we might loose access
-	 */
-	if (pidfd >= 0) {
-		if (fchown(pidfd, st.st_uid, st.st_gid) < 0) {
-			xlog(L_ERROR, "Unable to change owner of %s: %d (%s)",
-					SM_DIR, strerror (errno));
-		}
-	}
-	setgroups(0, NULL);
-	if (setgid(st.st_gid) == -1
-	    || setuid(st.st_uid) == -1) {
-		xlog(L_ERROR, "Fail to drop privileges");
-		exit(1);
-	}
-}
-
 static void run_sm_notify(int outport)
 {
 	char op[20];
@@ -316,34 +273,8 @@ int main (int argc, char **argv)
 			MY_NAME = xstrdup(optarg);
 			break;
 		case 'P':
-
-			if ((DIR_BASE = xstrdup(optarg)) == NULL) {
-				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
-					argv[0], optarg);
+			if (!nsm_setup_pathnames(argv[0], optarg))
 				exit(1);
-			}
-
-			SM_DIR = xmalloc(strlen(DIR_BASE) + 1 + sizeof("sm"));
-			SM_BAK_DIR = xmalloc(strlen(DIR_BASE) + 1 + sizeof("sm.bak"));
-			SM_STAT_PATH = xmalloc(strlen(DIR_BASE) + 1 + sizeof("state"));
-
-			if ((SM_DIR == NULL) 
-			    || (SM_BAK_DIR == NULL) 
-			    || (SM_STAT_PATH == NULL)) {
-
-				fprintf(stderr, "%s: xmalloc() failed!\n",
-					argv[0]);
-				exit(1);
-			}
-			if (DIR_BASE[strlen(DIR_BASE)-1] == '/') {
-				sprintf(SM_DIR, "%ssm", DIR_BASE );
-				sprintf(SM_BAK_DIR, "%ssm.bak", DIR_BASE );
-				sprintf(SM_STAT_PATH, "%sstate", DIR_BASE );
-			} else {
-				sprintf(SM_DIR, "%s/sm", DIR_BASE );
-				sprintf(SM_BAK_DIR, "%s/sm.bak", DIR_BASE );
-				sprintf(SM_STAT_PATH, "%s/state", DIR_BASE );
-			}
 			break;
 		case 'H': /* PRC: specify the ha-callout program */
 			if ((ha_callout_prog = xstrdup(optarg)) == NULL) {
@@ -421,10 +352,6 @@ int main (int argc, char **argv)
 		/* Child.	*/
 		close(pipefds[0]);
 		setsid ();
-		if (chdir (DIR_BASE) == -1) {
-			perror("statd: Could not chdir");
-			exit(1);
-		}
 
 		while (pipefds[1] <= 2) {
 			pipefds[1] = dup(pipefds[1]);
@@ -490,7 +417,13 @@ int main (int argc, char **argv)
 	 * pass on any SM_NOTIFY that arrives
 	 */
 	load_state();
-	load_state_number();
+
+	MY_STATE = nsm_get_state(0);
+	if (MY_STATE == 0)
+		exit(1);
+	xlog(D_GENERAL, "Local NSM state number: %d", MY_STATE);
+	nsm_update_kernel_state(MY_STATE);
+
 	pmap_unset (SM_PROG, SM_VERS);
 
 	/* this registers both UDP and TCP services */
@@ -507,7 +440,8 @@ int main (int argc, char **argv)
 		pipefds[1] = -1;
 	}
 
-	drop_privs();
+	if (!nsm_drop_privileges(pidfd))
+		exit(1);
 
 	for (;;) {
 		/*
@@ -536,29 +470,3 @@ int main (int argc, char **argv)
 	}
 	return 0;
 }
-
-static void
-load_state_number(void)
-{
-	int fd;
-	const char *file = "/proc/sys/fs/nfs/nsm_local_state";
-
-	if ((fd = open(SM_STAT_PATH, O_RDONLY)) == -1)
-		return;
-
-	if (read(fd, &MY_STATE, sizeof(MY_STATE)) != sizeof(MY_STATE)) {
-		xlog_warn("Unable to read state from '%s': errno %d (%s)",
-				SM_STAT_PATH, errno, strerror(errno));
-	}
-	close(fd);
-	fd = open(file, O_WRONLY);
-	if (fd >= 0) {
-		char buf[20];
-		snprintf(buf, sizeof(buf), "%d", MY_STATE);
-		if (write(fd, buf, strlen(buf)) != strlen(buf))
-			xlog_warn("Writing to '%s' failed: errno %d (%s)",
-				file, errno, strerror(errno));
-		close(fd);
-	}
-
-}
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 085f32d..542a877 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -14,28 +14,6 @@
 #include "xlog.h"
 
 /*
- * Paths and filenames.
- */
-#if defined(NFS_STATEDIR)
-# define DEFAULT_DIR_BASE	NFS_STATEDIR "/"
-#else
-# define DEFAULT_DIR_BASE	"/var/lib/nfs/"
-#endif
-
-#define DEFAULT_SM_DIR		DEFAULT_DIR_BASE "sm"
-#define DEFAULT_SM_BAK_DIR	DEFAULT_DIR_BASE "sm.bak"
-#define DEFAULT_SM_STAT_PATH	DEFAULT_DIR_BASE "state"
-
-/* Added to support run-time specification of state directory path.
- * j_carlos_gomez@yahoo.com
- */
-
-extern char * DIR_BASE;
-extern char *  SM_DIR;
-extern char *  SM_BAK_DIR;
-extern char *  SM_STAT_PATH;
-
-/*
  * Status definitions.
  */
 #define STAT_FAIL	stat_fail
@@ -53,7 +31,6 @@ extern int	process_notify_list(void);
 extern int	process_reply(FD_SET_TYPE *);
 extern char *	xstrdup(const char *);
 extern void *	xmalloc(size_t);
-extern void	xunlink (char *, char *);
 extern void	load_state(void);
 
 /*

