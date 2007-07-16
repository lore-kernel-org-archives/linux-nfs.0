From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/17] Use nfs_error in nfsmount.c and nfs4mount.c
Date: Sun, 15 Jul 2007 23:16:10 -0400
Message-ID: <20070716031610.11209.73975.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH4G-0001v4-Or
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:12 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH4K-0000NH-4i
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:16 -0700
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

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs4mount.c |   48 +++++++++++++++++++++----------------------
 utils/mount/nfsmount.c  |   52 ++++++++++++++++++++++-------------------------
 utils/mount/nfsumount.c |   20 ++++++++----------
 3 files changed, 56 insertions(+), 64 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 64f85e0..b890741 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -53,6 +53,7 @@
 #define DEFAULT_DIR "/var/lock/subsys"
 #endif
 
+extern char *progname;
 extern int verbose;
 extern int sloppy;
 
@@ -83,9 +84,8 @@ static int parse_sec(char *sec, int *pseudoflavour)
 
 	for (sec = strtok(sec, ":"); sec; sec = strtok(NULL, ":")) {
 		if (num_flavour >= MAX_USER_FLAVOUR) {
-			fprintf(stderr,
-				_("mount: maximum number of security flavors "
-				  "exceeded\n"));
+			nfs_error(_("%s: maximum number of security flavors "
+				  "exceeded"), progname);
 			return 0;
 		}
 		for (i = 0; i < flav_map_size; i++) {
@@ -95,14 +95,14 @@ static int parse_sec(char *sec, int *pseudoflavour)
 			}
 		}
 		if (i == flav_map_size) {
-			fprintf(stderr,
-				_("mount: unknown security type %s\n"), sec);
+			nfs_error(_("%s: unknown security type %s\n"),
+					progname, sec);
 			return 0;
 		}
 	}
 	if (!num_flavour)
-		fprintf(stderr,
-			_("mount: no security flavors passed to sec= option\n"));
+		nfs_error(_("%s: no security flavors passed to sec= option"),
+				progname);
 	return num_flavour;
 }
 
@@ -111,9 +111,8 @@ static int parse_devname(char *hostdir, char **hostname, char **dirname)
 	char *s;
 
 	if (!(s = strchr(hostdir, ':'))) {
-		fprintf(stderr,
-			_("mount: "
-			  "directory to mount not in host:dir format\n"));
+		nfs_error(_("%s: directory to mount not in host:dir format"),
+				progname);
 		return -1;
 	}
 	*hostname = hostdir;
@@ -123,9 +122,8 @@ static int parse_devname(char *hostdir, char **hostname, char **dirname)
 	   until they can be fully supported. (mack@sgi.com) */
 	if ((s = strchr(hostdir, ','))) {
 		*s = '\0';
-		fprintf(stderr,
-			_("mount: warning: "
-			  "multiple hostnames not supported\n"));
+		nfs_error(_("%s: warning: multiple hostnames not supported"),
+				progname);
 	}
 	return 0;
 }
@@ -138,13 +136,12 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 	if (inet_aton(hostname, &addr->sin_addr))
 		return 0;
 	if ((hp = gethostbyname(hostname)) == NULL) {
-		fprintf(stderr, _("mount: can't get address for %s\n"),
-			hostname);
+		nfs_error(_("%s: can't get address for %s\n"),
+				progname, hostname);
 		return -1;
 	}
 	if (hp->h_length > sizeof(struct in_addr)) {
-		fprintf(stderr,
-			_("mount: got bad hp->h_length\n"));
+		nfs_error(_("%s: got bad hp->h_length"), progname);
 		hp->h_length = sizeof(struct in_addr);
 	}
 	memcpy(&addr->sin_addr, hp->h_addr, hp->h_length);
@@ -157,7 +154,8 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 	struct sockaddr_in myaddr;
 
 	if (gethostname(myname, sizeof(myname))) {
-		fprintf(stderr, _("mount: can't determine client address\n"));
+		nfs_error(_("%s: can't determine client address\n"),
+				progname);
 		return -1;
 	}
 	if (fill_ipv4_sockaddr(myname, &myaddr))
@@ -191,8 +189,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
 
 	retval = EX_FAIL;
 	if (strlen(spec) >= sizeof(hostdir)) {
-		fprintf(stderr, _("mount: "
-				  "excessively long host:dir argument\n"));
+		nfs_error(_("%s: excessively long host:dir argument\n"),
+				progname);
 		goto fail;
 	}
 	strcpy(hostdir, spec);
@@ -210,8 +208,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
 	if (!old_opts)
 		old_opts = "";
 	if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
-		fprintf(stderr, _("mount: "
-				  "excessively long option argument\n"));
+		nfs_error(_("%s: excessively long option argument\n"),
+				progname);
 		goto fail;
 	}
 	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
@@ -404,9 +402,9 @@ int nfs4mount(const char *spec, const char *node, int flags,
 	data.version = NFS4_MOUNT_VERSION;
 	for (;;) {
 		if (verbose) {
-			fprintf(stderr, 
-				"mount: pinging: prog %d vers %d prot %s port %d\n", 
-				NFS_PROGRAM, 4, data.proto == IPPROTO_UDP ? "udp" : "tcp", 
+			printf(_("%s: pinging: prog %d vers %d prot %s port %d\n"),
+				progname, NFS_PROGRAM, 4,
+				data.proto == IPPROTO_UDP ? "udp" : "tcp",
 				ntohs(server_addr.sin_port));
 		}
 		client_addr.sin_family = 0;
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 4807c5b..ed2ab3a 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -460,22 +460,22 @@ static int nfsmnt_check_compat(const struct pmap *nfs_pmap,
 	unsigned int max_mnt_vers = (nfs_mount_data_version >= 4) ? 3 : 2;
 
 	if (nfs_pmap->pm_vers == 4) {
-		fprintf(stderr, _("Please use '-t nfs4' "
-					"instead of '-o vers=4'.\n"));
+		nfs_error(_("%s: Please use '-t nfs4' "
+				"instead of '-o vers=4'"), progname);
 		goto out_bad;
 	}
 
 	if (nfs_pmap->pm_vers) {
 		if (nfs_pmap->pm_vers > max_nfs_vers || nfs_pmap->pm_vers < 2) {
-			fprintf(stderr, _("NFS version %ld is not supported.\n"), 
-					nfs_pmap->pm_vers);
+			nfs_error(_("%s: NFS version %ld is not supported"),
+					progname, nfs_pmap->pm_vers);
 			goto out_bad;
 		}
 	}
 
 	if (mnt_pmap->pm_vers > max_mnt_vers) {
-		fprintf(stderr, _("NFS mount version %ld s not supported.\n"), 
-			mnt_pmap->pm_vers);
+		nfs_error(_("%s: NFS mount version %ld s not supported"),
+				progname, mnt_pmap->pm_vers);
 		goto out_bad;
 	}
 
@@ -517,8 +517,8 @@ nfsmount(const char *spec, const char *node, int flags,
 	time_t timeout;
 
 	if (strlen(spec) >= sizeof(hostdir)) {
-		fprintf(stderr, _("mount: "
-				  "excessively long host:dir argument\n"));
+		nfs_error(_("%s: excessively long host:dir argument"),
+				progname);
 		goto fail;
 	}
 	strcpy(hostdir, spec);
@@ -530,14 +530,13 @@ nfsmount(const char *spec, const char *node, int flags,
 		   until they can be fully supported. (mack@sgi.com) */
 		if ((s = strchr(hostdir, ','))) {
 			*s = '\0';
-			fprintf(stderr,
-				_("mount: warning: "
-				  "multiple hostnames not supported\n"));
+			nfs_error(_("%s: warning: "
+				  "multiple hostnames not supported"),
+					progname);
 		}
 	} else {
-		fprintf(stderr,
-			_("mount: "
-			  "directory to mount not in host:dir format\n"));
+		nfs_error(_("%s: directory to mount not in host:dir format"),
+				progname);
 		goto fail;
 	}
 
@@ -717,10 +716,9 @@ nfsmount(const char *spec, const char *node, int flags,
 
 	if (nfs_pmap->pm_vers == 2) {
 		if (mntres.nfsv2.fhs_status != 0) {
-			fprintf(stderr,
-				_("mount: %s:%s failed, reason given by server: %s\n"),
-				hostname, dirname,
-				nfs_strerror(mntres.nfsv2.fhs_status));
+			nfs_error(_("%s: %s:%s failed, reason given by server: %s"),
+					progname, hostname, dirname,
+					nfs_strerror(mntres.nfsv2.fhs_status));
 			goto fail;
 		}
 		memcpy(data.root.data,
@@ -738,10 +736,9 @@ nfsmount(const char *spec, const char *node, int flags,
 		fhandle3 *fhandle;
 		int i, *flavor, yum = 0;
 		if (mntres.nfsv3.fhs_status != 0) {
-			fprintf(stderr,
-				_("mount: %s:%s failed, reason given by server: %s\n"),
-				hostname, dirname,
-				nfs_strerror(mntres.nfsv3.fhs_status));
+			nfs_error(_("%s: %s:%s failed, reason given by server: %s"),
+					progname, hostname, dirname,
+					nfs_strerror(mntres.nfsv3.fhs_status));
 			goto fail;
 		}
 #if NFS_MOUNT_VERSION >= 5
@@ -769,10 +766,9 @@ nfsmount(const char *spec, const char *node, int flags,
 #endif
 		}
 		if (!yum) {
-			fprintf(stderr,
-				"mount: %s:%s failed, "
-				"security flavor not supported\n",
-				hostname, dirname);
+			nfs_error(_("%s: %s:%s failed, security flavor "
+					"not supported"),
+					progname, hostname, dirname);
 			/* server has registered us in rmtab, send umount */
 			nfs_call_umount(&mnt_server, &dirname);
 			goto fail;
@@ -839,8 +835,8 @@ noauth_flavors:
  out_ok:
 	/* Ensure we have enough padding for the following strcat()s */
 	if (strlen(new_opts) + strlen(s) + 30 >= sizeof(new_opts)) {
-		fprintf(stderr, _("mount: "
-				  "excessively long option argument\n"));
+		nfs_error(_("%s: excessively long option argument"),
+				progname);
 		goto fail;
 	}
 
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 05d13dd..43bcdfd 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -123,9 +123,8 @@ int del_mtab(const char *spec, const char *node)
                             MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
                 if (res == 0) {
                         struct mntent remnt;
-                        fprintf(stderr,
-                                _("umount: %s busy - remounted read-only\n"),
-                                spec);
+                        nfs_error(_("%s: %s busy - remounted read-only"),
+                                	progname, spec);
                         remnt.mnt_type = remnt.mnt_fsname = NULL;
                         remnt.mnt_dir = xstrdup(node);
                         remnt.mnt_opts = xstrdup("ro");
@@ -134,9 +133,8 @@ int del_mtab(const char *spec, const char *node)
                         return 0;
                 } else if (errno != EBUSY) {    /* hmm ... */
                         perror("remount");
-                        fprintf(stderr,
-                                _("umount: could not remount %s read-only\n"),
-                                spec);
+                        nfs_error(_("%s: could not remount %s read-only"),
+                                	progname, spec);
                 }
         }
 
@@ -224,7 +222,7 @@ int _nfsumount(const char *spec, char *opts)
 		goto out_bad;
 	return nfs_call_umount(&mnt_server, &dirname);
  out_bad:
-	fprintf(stderr, "%s: %s: not found or not mounted\n", progname, spec);
+	nfs_error(_("%s: %s: not found or not mounted"), progname, spec);
 	return 0;
 }
 
@@ -305,8 +303,8 @@ int nfsumount(int argc, char *argv[])
 
 	if (mc && strcmp(mc->m.mnt_type, "nfs") != 0 &&
 	    strcmp(mc->m.mnt_type, "nfs4") != 0) {
-		fprintf(stderr, "umount.nfs: %s on %s it not an nfs filesystem\n",
-			mc->m.mnt_fsname, mc->m.mnt_dir);
+		nfs_error(_("%s: %s on %s it not an nfs filesystem"),
+				progname, mc->m.mnt_fsname, mc->m.mnt_dir);
 		exit(1);
 	}
 
@@ -319,8 +317,8 @@ int nfsumount(int argc, char *argv[])
 			return 0;
 
 		only_root:
-			fprintf(stderr,"%s: You are not permitted to unmount %s\n",
-				progname, spec);
+			nfs_error(_("%s: You are not permitted to unmount %s"),
+					progname, spec);
 			return 0;
 		}
 		if (hasmntopt(&mc->m, "users") == NULL) {


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
