From: Greg Banks <gnb@sgi.com>
Subject: [PATCH] SGI 902615: make nohide export option work with wildcard exports
Date: Thu, 23 Sep 2004 18:08:02 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040923080802.GA11180@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAOTv-0003Yv-Hp
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 00:57:35 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAOTu-0003A0-Qs
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 00:57:35 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

G'day,

This patch has been sitting around gathering dust for some months,
I recently updated and tested it.  It changes rpc.mountd to make the
"nohide" export option work with 2.4 kernels or if the nfsd filesystem
isn't mounted, by pre-loading into the kernel and xtab at mount time
all the nohide exports which are enclosed by the export being mounted.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---
 ChangeLog             |    5 ++
 utils/mountd/auth.c   |   47 ++++++++++++-----------
 utils/mountd/mountd.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++--
 utils/mountd/mountd.h |   14 ++++++
 utils/mountd/rmtab.c  |    2 
 5 files changed, 144 insertions(+), 26 deletions(-)


diff -Napur --exclude-from=nfs-utils.excludes nfs-utils-1.0.6.orig/ChangeLog nfs-utils-1.0.6/ChangeLog
--- nfs-utils-1.0.6.orig/ChangeLog	Mon Sep 15 09:44:10 2003
+++ nfs-utils-1.0.6/ChangeLog	Wed Sep 22 23:14:24 2004
@@ -1,3 +1,8 @@
+2004-09-21 Greg Banks <gnb@melbourne.sgi.com>
+
+	* utils/mountd/auth.c, utils/mountd/mountd.c, utils/mountd/mountd.h:
+	Support "nohide" export option on wildcard export entries.
+
 2003-09-15 NeilBrown <neilb@cse.unsw.edu.au>
 
 	Release 1.0.6
diff -Napur --exclude-from=nfs-utils.excludes nfs-utils-1.0.6.orig/utils/mountd/auth.c nfs-utils-1.0.6/utils/mountd/auth.c
--- nfs-utils-1.0.6.orig/utils/mountd/auth.c	Tue Jul 15 08:10:12 2003
+++ nfs-utils-1.0.6/utils/mountd/auth.c	Wed Sep 22 23:14:24 2004
@@ -18,16 +18,6 @@
 #include "mountd.h"
 #include "xmalloc.h"
 
-enum auth_error
-{
-  bad_path,
-  unknown_host,
-  no_entry,
-  not_exported,
-  illegal_port,
-  success
-};
-
 static void		auth_fixpath(char *path);
 static char	*export_file = NULL;
 
@@ -61,6 +51,24 @@ auth_reload()
 	return 1;
 }
 
+/*
+ * That part of the per-export authentication which happens after
+ * an export is found.
+ */
+enum auth_error
+auth_authenticate_export(nfs_export *exp, struct sockaddr_in *caller)
+{
+	if (!new_cache && !exp->m_mayexport)
+		return not_exported;
+
+	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
+	    (ntohs(caller->sin_port) < IPPORT_RESERVED/2 ||
+	     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
+		return illegal_port;
+	}
+	return success;
+}
+
 static nfs_export *
 auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 			   char *path, struct hostent *hp,
@@ -110,24 +118,19 @@ auth_authenticate_internal(char *what, s
 			*error = no_entry;
 			return NULL;
 		}
-		if (!exp->m_mayexport) {
-			*error = not_exported;
-			return NULL;
-		}
 	}
-	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
-		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
-		     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
-		*error = illegal_port;
+
+	if ((*error = auth_authenticate_export(exp, caller)) != success)
 		return NULL;
-	}
+	
 	*error = success;
 
 	return exp;
 }
 
 nfs_export *
-auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
+auth_authenticate(char *what, struct sockaddr_in *caller, char *path,
+    	    	  struct hostent **hpp)
 {
 	nfs_export	*exp = NULL;
 	char		epath[MAXPATHLEN+1];
@@ -202,7 +205,9 @@ auth_authenticate(char *what, struct soc
 		     what, hp->h_name, ntohs(caller->sin_port), path, epath, error);
 	}
 
-	if (hp)
+	if (hpp)
+		*hpp = hp;
+	else if (hp)
 		free (hp);
 
 	return exp;
diff -Napur --exclude-from=nfs-utils.excludes nfs-utils-1.0.6.orig/utils/mountd/mountd.c nfs-utils-1.0.6/utils/mountd/mountd.c
--- nfs-utils-1.0.6.orig/utils/mountd/mountd.c	Tue Sep 21 16:14:14 2004
+++ nfs-utils-1.0.6/utils/mountd/mountd.c	Wed Sep 22 23:23:17 2004
@@ -114,7 +114,7 @@ mount_umnt_1_svc(struct svc_req *rqstp, 
 		p = rpath;
 	}
 
-	if (!(exp = auth_authenticate("unmount", sin, p))) {
+	if (!(exp = auth_authenticate("unmount", sin, p, NULL))) {
 		return 1;
 	}
 	if (new_cache) {
@@ -196,7 +196,7 @@ mount_pathconf_2_svc(struct svc_req *rqs
 	}
 
 	/* Now authenticate the intruder... */
-	if (!(exp = auth_authenticate("pathconf", sin, p))) {
+	if (!(exp = auth_authenticate("pathconf", sin, p, NULL))) {
 		return 1;
 	} else if (stat64(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
@@ -243,6 +243,95 @@ mount_mnt_3_svc(struct svc_req *rqstp, d
 	return 1;
 }
 
+
+/*
+ * Find all exported directories which match these criteria:
+ * -  enclosed by the given export
+ * -  passes authentication check to the given client
+ * -  has the nohide option set
+ * and export them to the kernel and to xtab.  This pre-loads
+ * kernel table so that the nohide option can be used with
+ * wildcard /etc/exports entries instead of having to provide
+ * FQDN /etc/exports entries for each client.
+ */
+ 
+#ifdef NFSEXP_NOHIDE
+#define NOHIDE		NFSEXP_NOHIDE	/* modern nfsutils */
+#else
+#define NOHIDE		NFSEXP_CROSSMNT	/* older nfsutils */
+#endif
+
+ 
+static void
+export_nohide_enclosed(nfs_export *exp, struct sockaddr_in *caller,
+		       struct hostent *hp)
+{
+	int		i;
+	nfs_export	*ee, *newe;
+	int		len = strlen(exp->m_export.e_path);
+	int 		warned = 0;
+	
+	if (!strcmp(exp->m_export.e_path, "/"))
+		len = 0;
+	for (i = 0; i < MCL_MAXTYPES; i++) {
+		if (i == MCL_FQDN)
+			continue;	/* these are already present in the kernel */
+		for (ee = exportlist[i] ; ee ; ee = ee->m_next) {
+			/* skip the given export itself */
+			if (ee == exp)
+				continue;
+			if (!(ee->m_export.e_flags & NOHIDE))
+				continue;
+			/* check for enclosure */
+			if (len > 0 &&
+			    (strncmp(ee->m_export.e_path, exp->m_export.e_path, len) ||
+			     ee->m_export.e_path[len] != '/'))
+				continue;
+			
+			/* check whether the export can be exported to this client */
+			if (auth_authenticate_export(ee, caller) != success)
+				continue;
+
+			/*
+			 * Netgroup entries would work in client_check() but are likely
+			 * to cause a storm of netgroup lookup traffic.  The only solution
+			 * is to have a shortlived cache of netgroup membership in
+			 * support/export/client.c.  So we just drop netgroup entries with
+			 * a warning to the sysadmin.
+			 */
+			if (i == MCL_NETGROUP) {
+				if (!warned) {
+					xlog(L_WARNING, "%s: sorry, netgroup entries do "
+							"not work with nohide",
+							ee->m_export.e_path);
+					warned = 1;
+				}
+				continue;
+			}
+
+			/*
+			 * export_find() will add or return a new nfs_export
+			 * which is in the exportlist[MCL_FQDN] list
+			 */
+			newe = export_find(hp, ee->m_export.e_path);
+			if (newe == NULL)
+				continue;
+			if (!(newe->m_export.e_flags & NOHIDE))
+				continue;	/* FQDN entry without nohide, not dup()ed */
+
+			xlog(L_NOTICE, "pre-exporting nohide directory %s to %s",
+					newe->m_export.e_path,
+					inet_ntoa(caller->sin_addr));
+
+			if (newe->m_exported<1)
+				export_export(newe);
+			if (!newe->m_xtabent)
+				xtab_append(newe);
+		}
+	}
+}
+
+
 static struct nfs_fh_len *
 get_rootfh(struct svc_req *rqstp, dirpath *path, int *error, int v3)
 {
@@ -252,6 +341,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
 	nfs_export	*exp;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
+	struct hostent	*hp = NULL;
 
 	if (*p == '\0')
 		p = "/";
@@ -266,7 +356,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
 	}
 
 	/* Now authenticate the intruder... */
-	if (!(exp = auth_authenticate("mount", sin, p))) {
+	if (!(exp = auth_authenticate("mount", sin, p, &hp))) {
 		*error = NFSERR_ACCES;
 	} else if (stat64(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
@@ -316,6 +406,8 @@ get_rootfh(struct svc_req *rqstp, dirpat
 			export_export(exp);
 		if (!exp->m_xtabent)
 			xtab_append(exp);
+			
+		export_nohide_enclosed(exp, sin, hp);
 
 		if (v3)
 			fh = getfh_size ((struct sockaddr *) sin, p, 64);
@@ -331,12 +423,16 @@ get_rootfh(struct svc_req *rqstp, dirpat
 			mountlist_add(exp->m_client->m_hostname, p);
 			*error = NFS_OK;
 			export_reset (exp);
+			if (hp)
+				free (hp);
 			return fh;
 		}
 		xlog(L_WARNING, "getfh failed: %s", strerror(errno));
 		*error = NFSERR_ACCES;
 	}
 	export_reset (exp);
+	if (hp)
+		free (hp);
 	return NULL;
 }
 
diff -Napur --exclude-from=nfs-utils.excludes nfs-utils-1.0.6.orig/utils/mountd/mountd.h nfs-utils-1.0.6/utils/mountd/mountd.h
--- nfs-utils-1.0.6.orig/utils/mountd/mountd.h	Thu Jul 31 15:27:13 2003
+++ nfs-utils-1.0.6/utils/mountd/mountd.h	Wed Sep 22 23:14:24 2004
@@ -25,6 +25,17 @@ union mountd_results {
 	exports			exports;
 };
 
+/* used internally only */
+enum auth_error
+{
+  bad_path,
+  unknown_host,
+  no_entry,
+  not_exported,
+  illegal_port,
+  success
+};
+
 /*
  * Global Function prototypes.
  */
@@ -42,7 +53,8 @@ void		mount_dispatch(struct svc_req *, S
 void		auth_init(char *export_file);
 int		auth_reload(void);
 nfs_export *	auth_authenticate(char *what, struct sockaddr_in *sin,
-					char *path);
+					char *path, struct hostent **hpp);
+enum auth_error auth_authenticate_export(nfs_export *exp, struct sockaddr_in *);
 void		auth_export(nfs_export *exp);
 
 void		mountlist_add(char *host, const char *path);
diff -Napur --exclude-from=nfs-utils.excludes nfs-utils-1.0.6.orig/utils/mountd/rmtab.c nfs-utils-1.0.6/utils/mountd/rmtab.c
--- nfs-utils-1.0.6.orig/utils/mountd/rmtab.c	Thu Jul 31 15:19:26 2003
+++ nfs-utils-1.0.6/utils/mountd/rmtab.c	Wed Sep 22 23:14:24 2004
@@ -150,7 +150,7 @@ mountlist_del_all(struct sockaddr_in *si
 	}
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
 		if (strcmp(rep->r_client, hp->h_name) == 0 &&
-		    (exp = auth_authenticate("umountall", sin, rep->r_path))) {
+		    (exp = auth_authenticate("umountall", sin, rep->r_path, NULL))) {
 			export_reset(exp);
 			continue;
 		}

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
