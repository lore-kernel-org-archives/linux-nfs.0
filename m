From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] mount.nfs: Support double-wide characters in
	printed	strings
Date: Fri, 03 Aug 2007 13:23:29 -0400
Message-ID: <20070803172329.3357.47604.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0s7-0001uv-8U
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:31 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sB-0007XA-0Z
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:35 -0700
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

Previous NLS changes missed a spot or two.  This patch tries to get
most of them, but probably misses a few more.

In errors.c:mount_errors() I've removed a period at the end of the error
messages; this is consistent with other error messages I've examined.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c     |   34 +++++++++++++++++++++++-----------
 utils/mount/mount.c     |   35 +++++++++++++++++------------------
 utils/mount/nfs4mount.c |    4 ++--
 utils/mount/nfsmount.c  |    3 +--
 utils/mount/nfsumount.c |   22 +++++++++++-----------
 5 files changed, 54 insertions(+), 44 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index bf056af..cab84c9 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -67,9 +67,11 @@ static int rpc_strerror(int spos)
 		tmp = &errbuf[spos];
 		if (cf_stat == RPC_SYSTEMERROR)
 			pos = snprintf(tmp, (erreob - tmp),
-				"System Error: %s", strerror(cf_errno));
+					_("System Error: %s"),
+						strerror(cf_errno));
 		else
-			pos = snprintf(tmp, (erreob - tmp), "RPC Error:%s", estr);
+			pos = snprintf(tmp, (erreob - tmp),
+					_("RPC Error:%s"), estr);
 	}
 	return pos;
 }
@@ -83,30 +85,40 @@ void mount_errors(char *server, int will_retry, int bg)
 	tmp = &errbuf[pos];
 	if (bg)
 		pos = snprintf(tmp, (erreob - tmp),
-			"mount to NFS server '%s' failed: ", server);
+				_("mount to NFS server '%s' failed: "),
+					server);
 	else
 		pos = snprintf(tmp, (erreob - tmp),
-			       "%s: mount to NFS server '%s' failed: ",
-			       progname, server);
+				_("%s: mount to NFS server '%s' failed: "),
+					progname, server);
 
 	tmp = &errbuf[pos];
 	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
-		pos = snprintf(tmp, (erreob - tmp), "timed out %s",
-			will_retry ? "(retrying)" : "(giving up)");
+		if (will_retry)
+			pos = snprintf(tmp, (erreob - tmp),
+					_("timed out, retrying"));
+		else
+			pos = snprintf(tmp, (erreob - tmp),
+					_("timed out, giving up"));
 	} else {
 		pos += rpc_strerror(pos);
 		tmp = &errbuf[pos];
 		if (bg) {
-			pos = snprintf(tmp, (erreob - tmp), " %s",
-				will_retry ? "(retrying)" : "(giving up)");
+			if (will_retry)
+				pos = snprintf(tmp, (erreob - tmp),
+						_(", retrying"));
+			else
+				pos = snprintf(tmp, (erreob - tmp),
+						_(", giving up"));
 		}
 	}
+
 	if (bg) {
 		if (onlyonce++ < 1)
 			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
-		syslog(LOG_ERR, "%s.", errbuf);
+		syslog(LOG_ERR, "%s", errbuf);
 	} else
-		fprintf(stderr, "%s.\n", errbuf);
+		fprintf(stderr, "%s\n", errbuf);
 }
 
 void mount_error(const char *spec, const char *mount_point, int error)
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index d6d527c..a7ad035 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -174,14 +174,13 @@ static void discover_nfs_mount_data_version(void)
 
 static void print_one(char *spec, char *node, char *type, char *opts)
 {
-	if (verbose) {
-		printf("%s on %s type %s", spec, node, type);
+	if (!verbose)
+		return;
 
-		if (opts != NULL)
-			printf(" (%s)", opts);
-
-		printf("\n");
-	}
+	if (opts)
+		printf(_("%s on %s type %s (%s)\n"), spec, node, type, opts);
+	else
+		printf(_("%s on %s type %s\n"), spec, node, type);
 }
 
 /*
@@ -268,18 +267,18 @@ fail_unlock:
 
 void mount_usage(void)
 {
-	printf("usage: %s remotetarget dir [-rvVwfnh] [-o nfsoptions]\n",
+	printf(_("usage: %s remotetarget dir [-rvVwfnh] [-o nfsoptions]\n"),
 		progname);
-	printf("options:\n");
-	printf("\t-r\t\tMount file system readonly\n");
-	printf("\t-v\t\tVerbose\n");
-	printf("\t-V\t\tPrint version\n");
-	printf("\t-w\t\tMount file system read-write\n");
-	printf("\t-f\t\tFake mount, do not actually mount\n");
-	printf("\t-n\t\tDo not update /etc/mtab\n");
-	printf("\t-s\t\tTolerate sloppy mount options rather than failing.\n");
-	printf("\t-h\t\tPrint this help\n");
-	printf("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n");
+	printf(_("options:\n"));
+	printf(_("\t-r\t\tMount file system readonly\n"));
+	printf(_("\t-v\t\tVerbose\n"));
+	printf(_("\t-V\t\tPrint version\n"));
+	printf(_("\t-w\t\tMount file system read-write\n"));
+	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
+	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
+	printf(_("\t-s\t\tTolerate sloppy mount options rather than failing.\n"));
+	printf(_("\t-h\t\tPrint this help\n"));
+	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
 
 static void parse_opt(const char *opt, int *mask, char *extra_opts, int len)
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index e1b2c3b..2126db4 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -321,8 +321,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
 			else if (!strcmp(opt, "sharecache"))
 				unshared = !val;
 			else if (!sloppy) {
-				printf(_("unknown nfs mount option: "
-					 "%s%s\n"), val ? "" : "no", opt);
+				printf(_("unknown nfs mount option: %s%s\n"),
+						val ? "" : _("no"), opt);
 				goto fail;
 			}
 		}
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index bd3403c..a56bfe1 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -190,7 +190,6 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 		if ((opteq = strchr(opt, '=')) && isdigit(opteq[1])) {
 			int val = atoi(opteq + 1);	
 			*opteq = '\0';
-/* printf("opt=%s\n", opt); */
 			if (!strcmp(opt, "rsize"))
 				data->rsize = val;
 			else if (!strcmp(opt, "wsize"))
@@ -432,7 +431,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 						val ? "" : "no", opt);
 				goto out_bad;
 			}
-			sprintf(cbuf, val ? "%s,":"no%s,", opt);
+			sprintf(cbuf, val ? "%s," : "no%s,", opt);
 		}
 		len += strlen(cbuf);
 		if (len >= opt_size) {
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 0c66717..e8814a3 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -67,7 +67,7 @@ static int del_mtab(const char *spec, const char *node)
                 res = umount2 (node, MNT_FORCE);
                 if (res == -1) {
                         int errsv = errno;
-                        perror("umount2");
+                        perror(_("umount2"));
                         errno = errsv;
                         if (errno == ENOSYS) {
                                 if (verbose)
@@ -93,7 +93,7 @@ static int del_mtab(const char *spec, const char *node)
                                 update_mtab(node, &remnt);
                         return 0;
                 } else if (errno != EBUSY) {    /* hmm ... */
-                        perror("remount");
+                        perror(_("remount"));
                         nfs_error(_("%s: could not remount %s read-only"),
                                 	progname, spec);
                 }
@@ -102,7 +102,7 @@ static int del_mtab(const char *spec, const char *node)
         if (res >= 0) {
                 /* Umount succeeded */
                 if (verbose)
-                        printf (_("%s umounted\n"), spec ? spec : node);
+                        printf(_("%s umounted\n"), spec ? spec : node);
         }
 
  writemtab:
@@ -212,13 +212,13 @@ static struct option umount_longopts[] =
 
 static void umount_usage(void)
 {
-	printf("usage: %s dir [-fvnrlh]\n", progname);
-	printf("options:\n\t-f\t\tforce unmount\n");
-	printf("\t-v\t\tverbose\n");
-	printf("\t-n\t\tDo not update /etc/mtab\n");
-	printf("\t-r\t\tremount\n");
-	printf("\t-l\t\tlazy unmount\n");
-	printf("\t-h\t\tprint this help\n\n");
+	printf(_("usage: %s dir [-fvnrlh]\n"), progname);
+	printf(_("options:\n\t-f\t\tforce unmount\n"));
+	printf(_("\t-v\tverbose\n"));
+	printf(_("\t-n\tDo not update /etc/mtab\n"));
+	printf(_("\t-r\tremount\n"));
+	printf(_("\t-l\tlazy unmount\n"));
+	printf(_("\t-h\tprint this help\n\n"));
 }
 
 int nfsumount(int argc, char *argv[])
@@ -282,7 +282,7 @@ int nfsumount(int argc, char *argv[])
 
 	if (mc && strcmp(mc->m.mnt_type, "nfs") != 0 &&
 	    strcmp(mc->m.mnt_type, "nfs4") != 0) {
-		nfs_error(_("%s: %s on %s it not an nfs filesystem"),
+		nfs_error(_("%s: %s on %s is not an NFS filesystem"),
 				progname, mc->m.mnt_fsname, mc->m.mnt_dir);
 		return EX_USAGE;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
