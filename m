From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Remove "maptype" support
Date: Tue, 13 Mar 2007 13:05:05 -0400
Message-ID: <20070313170505.GA15964@fieldses.org>
References: <20070307022107.GC27862@fieldses.org>
	<17910.13751.310917.35119@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRAQu-0005SZ-9I
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:05:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HRAQt-0006Lc-Gk
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:05:10 -0700
In-Reply-To: <17910.13751.310917.35119@notabene.brown>
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

It appears that this is used only by unfsd, and is obscure enough that
we should be able to just rip it out with no special precautions.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---

Also available from git://linux-nfs.org/~bfields/nfs-utils.git.

 support/export/nfsctl.c   |    6 ------
 support/include/nfslib.h  |    7 -------
 support/nfs/exports.c     |   37 -------------------------------------
 utils/exportfs/exportfs.c |    4 ----
 utils/mountd/cache.c      |    6 ------
 5 files changed, 0 insertions(+), 60 deletions(-)

diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
index b74334c..32d92bd 100644
--- a/support/export/nfsctl.c
+++ b/support/export/nfsctl.c
@@ -92,12 +92,6 @@ expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport)
 	if (stat(exp->m_export.m_path, &stb) < 0)
 		return 0;
 
-	if (exp->m_export.e_maptype != CLE_MAP_IDENT) {
-		xlog(L_ERROR, "%s: unsupported mapping; kernel supports only 'identity' (default)",
-		     exp->m_export.m_path);
-		errno = EINVAL;
-		return 0;
-	}
 	memset(exparg, 0, sizeof(*exparg));
 	strncpy(exparg->ex_path, exp->m_export.m_path,
 		sizeof (exparg->ex_path) - 1);
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 1372635..d4f4150 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -51,12 +51,6 @@
 #define	_PATH_PROC_EXPORTS_ALT	"/proc/fs/nfsd/exports"
 #endif
 
-enum cle_maptypes {
-	CLE_MAP_IDENT = 0,
-	CLE_MAP_FILE,
-	CLE_MAP_UGIDD,
-};
-
 /*
  * Data related to a single exports entry as returned by getexportent.
  * FIXME: export options should probably be parsed at a later time to
@@ -71,7 +65,6 @@ struct exportent {
 	   use it for anything else. */
 	char		m_path[NFS_MAXPATHLEN+1];
 	int		e_flags;
-	int		e_maptype;
 	int		e_anonuid;
 	int		e_anongid;
 	int *		e_squids;
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 9638015..0baa5d0 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -48,7 +48,6 @@ static int	getpath(char *path, int len);
 static int	parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr);
 static int	parsesquash(char *list, int **idp, int *lenp, char **ep);
 static int	parsenum(char **cpp);
-static int	parsemaptype(char *type);
 static void	freesquash(void);
 static void	syntaxerr(char *msg);
 
@@ -94,7 +93,6 @@ getexportent(int fromkernel, int fromexports)
 			def_ee.e_flags &= ~NFSEXP_ASYNC;
 			def_ee.e_flags &= ~NFSEXP_GATHERED_WRITES;
 		}
-		def_ee.e_maptype = CLE_MAP_IDENT;
 		def_ee.e_anonuid = 65534;
 		def_ee.e_anongid = 65534;
 		def_ee.e_squids = NULL;
@@ -245,21 +243,6 @@ putexportent(struct exportent *ep)
 		xlog(L_ERROR, "unknown fsloc method for %s:%s",
 		     ep->e_hostname, ep->e_path);
 	}
-	fprintf(fp, "mapping=");
-	switch (ep->e_maptype) {
-	case CLE_MAP_IDENT:
-		fprintf(fp, "identity,");
-		break;
-	case CLE_MAP_UGIDD:
-		fprintf(fp, "ugidd,");
-		break;
-	case CLE_MAP_FILE:
-		fprintf(fp, "file,");
-		break;
-	default:
-		xlog(L_ERROR, "unknown mapping type for %s:%s",
-					ep->e_hostname, ep->e_path);
-	}
 	if ((id = ep->e_squids) != NULL) {
 		fprintf(fp, "squash_uids=");
 		for (i = 0; i < ep->e_nsquids; i += 2)
@@ -317,7 +300,6 @@ mkexportent(char *hname, char *path, char *options)
 	static struct exportent	ee;
 
 	ee.e_flags = EXPORT_DEFAULT_FLAGS;
-	ee.e_maptype = CLE_MAP_IDENT;
 	ee.e_anonuid = 65534;
 	ee.e_anongid = 65534;
 	ee.e_squids = NULL;
@@ -447,12 +429,6 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
 			ep->e_flags &= ~NFSEXP_NOACL;
 		else if (strcmp(opt, "no_acl") == 0)
 			ep->e_flags |= NFSEXP_NOACL;
-		else if (strncmp(opt, "mapping=", 8) == 0)
-			ep->e_maptype = parsemaptype(opt+8);
-		else if (strcmp(opt, "map_identity") == 0)	/* old style */
-			ep->e_maptype = CLE_MAP_IDENT;
-		else if (strcmp(opt, "map_daemon") == 0)	/* old style */
-			ep->e_maptype = CLE_MAP_UGIDD;
 		else if (strncmp(opt, "anonuid=", 8) == 0) {
 			char *oe;
 			ep->e_anonuid = strtol(opt+8, &oe, 10);
@@ -625,19 +601,6 @@ parsenum(char **cpp)
 }
 
 static int
-parsemaptype(char *type)
-{
-	if (!strcmp(type, "identity"))
-		return CLE_MAP_IDENT;
-	if (!strcmp(type, "ugidd"))
-		return CLE_MAP_UGIDD;
-	if (!strcmp(type, "file"))
-		return CLE_MAP_FILE;
-	syntaxerr("invalid map type");
-	return CLE_MAP_IDENT;	/* default */
-}
-
-static int
 getpath(char *path, int len)
 {
 	xskip(efp, " \t\n");
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 22e13a3..1eca567 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -410,10 +410,6 @@ dump(int verbose)
 				c = dumpopt(c, "mountpoint%s%s", 
 					    ep->e_mountpoint[0]?"=":"", 
 					    ep->e_mountpoint);
-			if (ep->e_maptype == CLE_MAP_UGIDD)
-				c = dumpopt(c, "mapping=ugidd");
-			else if (ep->e_maptype == CLE_MAP_FILE)
-				c = dumpopt(c, "mapping=file");
 			if (ep->e_anonuid != 65534)
 				c = dumpopt(c, "anonuid=%d", ep->e_anonuid);
 			if (ep->e_anongid != 65534)
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 4693216..6cf24ce 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -612,12 +612,6 @@ int cache_export(nfs_export *exp)
 	int err;
 	FILE *f;
 
-	if (exp->m_export.e_maptype != CLE_MAP_IDENT) {
-		xlog(L_ERROR, "%s: unsupported mapping; kernel supports only 'identity' (default)",
-		    exp->m_export.m_path);
-		return -1;
-	}
-
 	f = fopen("/proc/net/rpc/auth.unix.ip/channel", "w");
 	if (!f)
 		return -1;
-- 
1.5.0.gb75812-dirty


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
