From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/23] mount.nfs: Support double-wide characters in
	printed	strings
Date: Sat, 28 Jul 2007 17:49:13 -0400
Message-ID: <20070728214913.21871.41624.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuA0-0007P1-5p
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:16 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuA3-0002z8-S0
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:20 -0700
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

NLS changes missed a spot or two.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c     |   19 ++++++++++---------
 utils/mount/mount.c     |   32 ++++++++++++++++----------------
 utils/mount/nfs4mount.c |   10 +++++-----
 utils/mount/nfsmount.c  |    7 +++----
 utils/mount/nfsumount.c |   18 +++++++++---------
 5 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 62f6850..74f8354 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -67,9 +67,10 @@ static int rpc_strerror(int spos)
 		tmp = &errbuf[spos];
 		if (cf_stat == RPC_SYSTEMERROR)
 			pos = snprintf(tmp, (erreob - tmp),
-				"System Error: %s", strerror(cf_errno));
+				_("System Error: %s"), strerror(cf_errno));
 		else
-			pos = snprintf(tmp, (erreob - tmp), "RPC Error:%s", estr);
+			pos = snprintf(tmp, (erreob - tmp),
+					_("RPC Error: %s"), estr);
 	}
 	return pos;
 }
@@ -83,21 +84,21 @@ void mount_errors(char *server, int will_retry, int bg)
 	tmp = &errbuf[pos];
 	if (bg)
 		pos = snprintf(tmp, (erreob - tmp),
-			"mount to NFS server '%s' failed: ", server);
+			_("mount to NFS server '%s' failed: "), server);
 	else
 		pos = snprintf(tmp, (erreob - tmp),
-			"mount: mount to NFS server '%s' failed: ", server);
+			_("mount: mount to NFS server '%s' failed: "), server);
 
 	tmp = &errbuf[pos];
 	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
-		pos = snprintf(tmp, (erreob - tmp), "timed out %s",
-			will_retry ? "(retrying)" : "(giving up)");
+		pos = snprintf(tmp, (erreob - tmp), _("timed out %s"),
+			will_retry ? _("(retrying)") : _("(giving up)"));
 	} else {
 		pos += rpc_strerror(pos);
 		tmp = &errbuf[pos];
 		if (bg) {
-			pos = snprintf(tmp, (erreob - tmp), " %s",
-				will_retry ? "(retrying)" : "(giving up)");
+			pos = snprintf(tmp, (erreob - tmp), _(" %s"),
+				will_retry ? _("(retrying)") : _("(giving up)"));
 		}
 	}
 	if (bg) {
@@ -105,7 +106,7 @@ void mount_errors(char *server, int will_retry, int bg)
 			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
 		syslog(LOG_ERR, "%s.", errbuf);
 	} else
-		fprintf(stderr, "%s.\n", errbuf);
+		fprintf(stderr, _("%s.\n"), errbuf);
 }
 
 void mount_error(const char *spec, const char *mount_point, int error)
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 7a4912e..9503187 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -176,12 +176,12 @@ static void discover_nfs_mount_data_version(void)
 static void print_one(char *spec, char *node, char *type, char *opts)
 {
 	if (verbose) {
-		printf("%s on %s type %s", spec, node, type);
+		printf(_("%s on %s type %s"), spec, node, type);
 
 		if (opts != NULL)
-			printf(" (%s)", opts);
+			printf(_(" (%s)"), opts);
 
-		printf("\n");
+		printf(_("\n"));
 	}
 }
 
@@ -269,18 +269,18 @@ fail_unlock:
 
 void mount_usage()
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
@@ -384,7 +384,7 @@ int main(int argc, char *argv[])
 
 	if (argv[1] && argv[1][0] == '-') {
 		if(argv[1][1] == 'V')
-			printf("%s ("PACKAGE_STRING")\n", progname);
+			printf(_("%s ("PACKAGE_STRING")\n"), progname);
 		else
 			mount_usage();
 		exit(0);
@@ -409,7 +409,7 @@ int main(int argc, char *argv[])
 			++verbose;
 			break;
 		case 'V':
-			printf("%s: ("PACKAGE_STRING")\n", progname);
+			printf(_("%s: ("PACKAGE_STRING")\n"), progname);
 			return 0;
 		case 'w':
 			flags &= ~MS_RDONLY;
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 26a6896..bd20864 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -160,7 +160,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 	}
 	if (fill_ipv4_sockaddr(myname, &myaddr))
 		return -1;
-	snprintf(ip_addr, len, "%s", inet_ntoa(myaddr.sin_addr));
+	snprintf(ip_addr, len, _("%s"), inet_ntoa(myaddr.sin_addr));
 	ip_addr[len-1] = '\0';
 	return 0;
 }
@@ -212,8 +212,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
 				progname);
 		goto fail;
 	}
-	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
-		 old_opts, *old_opts ? "," : "", s);
+	snprintf(new_opts, sizeof(new_opts), _("%s%saddr=%s"),
+		 old_opts, *old_opts ? _(",") : _(""), s);
 	*extra_opts = xstrdup(new_opts);
 
 	/* Set default options.
@@ -322,7 +322,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
 				unshared = !val;
 			else if (!sloppy) {
 				printf(_("unknown nfs mount option: "
-					 "%s%s\n"), val ? "" : "no", opt);
+					 "%s%s\n"), val ? _("") : _("no"), opt);
 				goto fail;
 			}
 		}
@@ -414,7 +414,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
 			if (!ip_addr_in_opts &&
 			    client_addr.sin_family != 0 &&
 			    client_addr.sin_addr.s_addr != 0) {
-				snprintf(ip_addr, sizeof(ip_addr), "%s",
+				snprintf(ip_addr, sizeof(ip_addr), _("%s"),
 					 inet_ntoa(client_addr.sin_addr));
 				data.client_addr.len = strlen(ip_addr);
 			}
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6949b50..ac8d161 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -192,7 +192,6 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 		if ((opteq = strchr(opt, '=')) && isdigit(opteq[1])) {
 			int val = atoi(opteq + 1);	
 			*opteq = '\0';
-/* printf("opt=%s\n", opt); */
 			if (!strcmp(opt, "rsize"))
 				data->rsize = val;
 			else if (!strcmp(opt, "wsize"))
@@ -249,7 +248,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				continue;
 			else
 				goto bad_parameter;
-			sprintf(cbuf, "%s=%s,", opt, opteq+1);
+			sprintf(cbuf, _("%s=%s,"), opt, opteq+1);
 		} else if (opteq) {
 			*opteq = '\0';
 			if (!strcmp(opt, "proto")) {
@@ -332,7 +331,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				continue;
 			else
 				goto bad_parameter;
-			sprintf(cbuf, "%s=%s,", opt, opteq+1);
+			sprintf(cbuf, _("%s=%s,"), opt, opteq+1);
 		} else {
 			int val = 1;
 			if (!strncmp(opt, "no", 2)) {
@@ -431,7 +430,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					 "%s%s\n"), val ? "" : "no", opt);
 				goto out_bad;
 			}
-			sprintf(cbuf, val ? "%s,":"no%s,", opt);
+			sprintf(cbuf, val ? _("%s,") : _("no%s,"), opt);
 		}
 		len += strlen(cbuf);
 		if (len >= opt_size) {
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 303b485..dbfb85b 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -141,7 +141,7 @@ int del_mtab(const char *spec, const char *node)
         if (res >= 0) {
                 /* Umount succeeded */
                 if (verbose)
-                        printf (_("%s umounted\n"), spec ? spec : node);
+                        printf(_("%s umounted\n"), spec ? spec : node);
         }
 
  writemtab:
@@ -238,13 +238,13 @@ static struct option umount_longopts[] =
 
 void umount_usage()
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
@@ -303,7 +303,7 @@ int nfsumount(int argc, char *argv[])
 
 	if (mc && strcmp(mc->m.mnt_type, "nfs") != 0 &&
 	    strcmp(mc->m.mnt_type, "nfs4") != 0) {
-		nfs_error(_("%s: %s on %s it not an nfs filesystem"),
+		nfs_error(_("%s: %s on %s is not an nfs filesystem"),
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
