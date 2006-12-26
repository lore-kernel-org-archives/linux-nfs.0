From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Allow default options in /etc/exports
Date: Tue, 26 Dec 2006 23:58:48 +0100
Message-ID: <20061226225848.GA18366@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GzLFx-0005uy-PT
	for nfs@lists.sourceforge.net; Tue, 26 Dec 2006 14:58:49 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GzLFx-0003S3-Gj
	for nfs@lists.sourceforge.net; Tue, 26 Dec 2006 14:58:51 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1GzLFr-0007Nv-7v
	for nfs@lists.sourceforge.net; Tue, 26 Dec 2006 23:58:44 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1GzLFw-0004ms-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Dec 2006 23:58:48 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

[Cc-on-reply, please]

Merry Christmas, to those of you who celebrate that. :-) I found some time to
write a patch for a two-year-old feature request which was slowly getting
more and more annoying; hope it can go into upstream, even though it won't
reach our upcoming Debian release.

Patch: Allow default options in /etc/exports

  Implement default options in /etc/exports, to fix a long-standing wishlist
  bug in Debian. (The user claims the syntax matches that of OpenBSD.) This
  makes it possible to write "/srv/www -sync,no_subtree_check host1 host2 host3"
  instead of having to write (sync,no_subtree_check) over and over and over
  again, driving the administrator slowly mad. Such option lines can be
  placed anywhere on the line, and affects anything after them (I do not
  know if OpenBSD allows this). The patch is slightly convoluted in order to
  avoid triggering spurious warnings; for instance, we want
  "/srv/www -sync host1" to trigger a warning, but not "/srv/www
  -sync,no_subtree_check host1" or "/srv/www -sync host1(no_subtree_check)".

  There was also a suggestion for a truly global (ie. per-file) option list,
  but this seemed like the safest bet, given that it matches that of other
  implementations.

  Also, the man page is updated with information on the new possibilities,
  and an example.

  Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

Index: nfs-utils-1.0.10/support/nfs/exports.c
===================================================================
--- nfs-utils-1.0.10.orig/support/nfs/exports.c
+++ nfs-utils-1.0.10/support/nfs/exports.c
@@ -39,12 +39,13 @@ int export_errno;
 static char	*efname = NULL;
 static XFILE	*efp = NULL;
 static int	first;
+static int	has_default_opts, has_default_subtree_opts;
 static int	*squids = NULL, nsquids = 0,
 		*sqgids = NULL, nsqgids = 0;
 
 static int	getexport(char *exp, int len);
 static int	getpath(char *path, int len);
-static int	parseopts(char *cp, struct exportent *ep, int warn);
+static int	parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr);
 static int	parsesquash(char *list, int **idp, int *lenp, char **ep);
 static int	parsenum(char **cpp);
 static int	parsemaptype(char *type);
@@ -68,7 +69,7 @@ setexportent(char *fname, char *type)
 struct exportent *
 getexportent(int fromkernel, int fromexports)
 {
-	static struct exportent	ee;
+	static struct exportent	ee, def_ee;
 	char		exp[512], *hostname;
 	char		rpath[MAXPATHLEN+1];
 	char		*opt, *sp;
@@ -78,31 +79,36 @@ getexportent(int fromkernel, int fromexp
 		return NULL;
 
 	freesquash();
-	ee.e_flags = EXPORT_DEFAULT_FLAGS;
-	/* some kernels assume the default is sync rather than
-	 * async.  More recent kernels always report one or other,
-	 * but this test makes sure we assume same as kernel
-	 * Ditto for wgather
-	 */
-	if (fromkernel) {
-		ee.e_flags &= ~NFSEXP_ASYNC;
-		ee.e_flags &= ~NFSEXP_GATHERED_WRITES;
-	}
-	ee.e_maptype = CLE_MAP_IDENT;
-	ee.e_anonuid = 65534;
-	ee.e_anongid = 65534;
-	ee.e_squids = NULL;
-	ee.e_sqgids = NULL;
-	ee.e_mountpoint = NULL;
-	ee.e_nsquids = 0;
-	ee.e_nsqgids = 0;
 
 	if (first || (ok = getexport(exp, sizeof(exp))) == 0) {
-		ok = getpath(ee.e_path, sizeof(ee.e_path));
+		has_default_opts = 0;
+		has_default_subtree_opts = 0;
+	
+		def_ee.e_flags = EXPORT_DEFAULT_FLAGS;
+		/* some kernels assume the default is sync rather than
+		 * async.  More recent kernels always report one or other,
+		 * but this test makes sure we assume same as kernel
+		 * Ditto for wgather
+		 */
+		if (fromkernel) {
+			def_ee.e_flags &= ~NFSEXP_ASYNC;
+			def_ee.e_flags &= ~NFSEXP_GATHERED_WRITES;
+		}
+		def_ee.e_maptype = CLE_MAP_IDENT;
+		def_ee.e_anonuid = 65534;
+		def_ee.e_anongid = 65534;
+		def_ee.e_squids = NULL;
+		def_ee.e_sqgids = NULL;
+		def_ee.e_mountpoint = NULL;
+		def_ee.e_nsquids = 0;
+		def_ee.e_nsqgids = 0;
+
+		ok = getpath(def_ee.e_path, sizeof(def_ee.e_path));
 		if (ok <= 0)
 			return NULL;
-		strncpy (ee.m_path, ee.e_path, sizeof (ee.m_path) - 1);
-		ee.m_path [sizeof (ee.m_path) - 1] = '\0';
+
+		strncpy (def_ee.m_path, def_ee.e_path, sizeof (def_ee.m_path) - 1);
+		def_ee.m_path [sizeof (def_ee.m_path) - 1] = '\0';
 		ok = getexport(exp, sizeof(exp));
 	}
 	if (ok < 0) {
@@ -111,6 +117,23 @@ getexportent(int fromkernel, int fromexp
 		return NULL;
 	}
 	first = 0;
+		
+	/* Check for default options */
+	if (exp[0] == '-') {
+		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
+			return NULL;
+		
+		has_default_opts = 1;
+
+		ok = getexport(exp, sizeof(exp));
+		if (ok < 0) {
+			xlog(L_ERROR, "expected client(options...)");
+			export_errno = EINVAL;
+			return NULL;
+		}
+	}
+
+	ee = def_ee;
 
 	/* Check for default client */
 	if (ok == 0)
@@ -130,7 +153,8 @@ getexportent(int fromkernel, int fromexp
 		}
 		*sp = '\0';
 	} else {
-	    xlog(L_WARNING, "No options for %s %s: suggest %s(sync) to avoid warning", ee.e_path, exp, exp);
+		if (!has_default_opts)
+			xlog(L_WARNING, "No options for %s %s: suggest %s(sync) to avoid warning", ee.e_path, exp, exp);
 	}
 	if (strlen(hostname) >= sizeof(ee.e_hostname)) {
 		syntaxerr("client name too long");
@@ -140,7 +164,7 @@ getexportent(int fromkernel, int fromexp
 	strncpy(ee.e_hostname, hostname, sizeof (ee.e_hostname) - 1);
 	ee.e_hostname[sizeof (ee.e_hostname) - 1] = '\0';
 
-	if (parseopts(opt, &ee, fromexports) < 0)
+	if (parseopts(opt, &ee, fromexports && !has_default_subtree_opts, NULL) < 0)
 		return NULL;
 
 	/* resolve symlinks */
@@ -293,7 +317,7 @@ mkexportent(char *hname, char *path, cha
 	ee.e_path[sizeof (ee.e_path) - 1] = '\0';
 	strncpy (ee.m_path, ee.e_path, sizeof (ee.m_path) - 1);
 	ee.m_path [sizeof (ee.m_path) - 1] = '\0';
-	if (parseopts(options, &ee, 0) < 0)
+	if (parseopts(options, &ee, 0, NULL) < 0)
 		return NULL;
 	return &ee;
 }
@@ -301,7 +325,7 @@ mkexportent(char *hname, char *path, cha
 int
 updateexportent(struct exportent *eep, char *options)
 {
-	if (parseopts(options, eep, 0) < 0)
+	if (parseopts(options, eep, 0, NULL) < 0)
 		return 0;
 	return 1;
 }
@@ -310,7 +334,7 @@ updateexportent(struct exportent *eep, c
  * Parse option string pointed to by cp and set mount options accordingly.
  */
 static int
-parseopts(char *cp, struct exportent *ep, int warn)
+parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 {
 	int	had_subtree_opt = 0;
 	char 	*flname = efname?efname:"command line";
@@ -461,6 +485,8 @@ out:
 
 				flname, flline,
 				ep->e_hostname, ep->e_path);
+	if (had_subtree_opt_ptr)
+		*had_subtree_opt_ptr = had_subtree_opt;
 
 	return 1;
 }
Index: nfs-utils-1.0.10/utils/exportfs/exports.man
===================================================================
--- nfs-utils-1.0.10.orig/utils/exportfs/exports.man
+++ nfs-utils-1.0.10/utils/exportfs/exports.man
@@ -22,6 +22,11 @@ client may be immediately followed by a 
 list of export options for that client. No whitespace is permitted
 between a client and its option list.
 .PP
+Also, each line may have one or more specifications for default options
+after the path name, in the form of a dash ("\-") followed by an option
+list. The option list is used for all subsequent exports on that line
+only.
+.PP
 Blank lines are ignored.  A pound sign ("#") introduces a comment to the
 end of the line. Entries may be continued across newlines using a
 backslash. If an export name contains spaces it should be quoted using
@@ -502,6 +507,7 @@ is supposedly that of user joe).
 /usr            *.local.domain(ro) @trusted(rw)
 /home/joe       pc001(rw,all_squash,anonuid=150,anongid=100)
 /pub            (ro,insecure,all_squash)
+/srv/www        -sync,rw server @trusted @external(ro)
 '''/pub/private    (noaccess)
 .fi
 .PP
@@ -515,6 +521,9 @@ under the nobody account. The
 .I insecure 
 option in this entry also allows clients with NFS implementations that
 don't use a reserved port for NFS.
+The sixth line exports a directory read-write to the machine 'server'
+as well as the `@trusted' netgroup, and read-only to netgroup `@external',
+all three mounts with the `sync' option enabled.
 ''' The last line denies all NFS clients
 '''access to the private directory.
 '''.SH CAVEATS

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
