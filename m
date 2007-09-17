From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/5] mountd: make exportent->e_hostname a
	dynamically-allocated string
Date: Mon, 17 Sep 2007 08:52:04 -0400
Message-ID: <200709171252.l8HCq4Wn025385@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXG5B-00016R-QJ
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXG5E-0003Tq-6s
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 05:52:14 -0700
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

This makes the e_hostname field of the exportent into a pointer to a
dynamically allocated string. This is necessary since this is field is
often filled out from the m_hostname. This too adds a few
micro-optimizations as we can avoid copying the string in some places
and simply pass a pointer to the original string instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---
 support/export/export.c  |    5 +++++
 support/export/rmtab.c   |    4 +---
 support/export/xtab.c    |    9 ++-------
 support/include/nfslib.h |    2 +-
 support/nfs/exports.c    |   19 ++++++-------------
 5 files changed, 15 insertions(+), 24 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 74e1d1b..93c58b6 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -85,6 +85,8 @@ export_init(nfs_export *exp, nfs_client *clp, struct exportent *nep)
 	struct exportent	*e = &exp->m_export;
 
 	dupexportent(e, nep);
+	if (nep->e_hostname)
+		e->e_hostname = xstrdup(nep->e_hostname);
 
 	exp->m_exported = 0;
 	exp->m_xtabent = 0;
@@ -109,6 +111,8 @@ export_dup(nfs_export *exp, struct hostent *hp)
 	new = (nfs_export *) xmalloc(sizeof(*new));
 	memcpy(new, exp, sizeof(*new));
 	dupexportent(&new->m_export, &exp->m_export);
+	if (exp->m_export.e_hostname)
+		new->m_export.e_hostname = xstrdup(exp->m_export.e_hostname);
 	clp = client_dup(exp->m_client, hp);
 	clp->m_count++;
 	new->m_client = clp;
@@ -244,6 +248,7 @@ export_freeall(void)
 				free(exp->m_export.e_mountpoint);
 			if (exp->m_export.e_fslocdata)
 				xfree(exp->m_export.e_fslocdata);
+			xfree(exp->m_export.e_hostname);
 			xfree(exp);
 		}
 		exportlist[i] = NULL;
diff --git a/support/export/rmtab.c b/support/export/rmtab.c
index 15aab15..2a882aa 100644
--- a/support/export/rmtab.c
+++ b/support/export/rmtab.c
@@ -43,9 +43,7 @@ rmtab_read(void)
 			if (!exp2) {
 				struct exportent ee;
 				dupexportent(&ee, &exp->m_export);
-				strncpy (ee.e_hostname, rep->r_client,
-					 sizeof (ee.e_hostname) - 1);
-				ee.e_hostname[sizeof (ee.e_hostname) -1] = '\0';
+				ee.e_hostname = rep->r_client;
 				exp2 = export_create(&ee, 0);
 				exp2->m_changed = exp->m_changed;
 			}
diff --git a/support/export/xtab.c b/support/export/xtab.c
index 292087b..990113e 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -108,10 +108,7 @@ xtab_write(char *xtab, char *xtabtmp, int is_export)
 
 			/* write out the export entry using the FQDN */
 			xe = exp->m_export;
-			strncpy(xe.e_hostname,
-				exp->m_client->m_hostname,
-				sizeof (xe.e_hostname) - 1);
-			xe.e_hostname[sizeof (xe.e_hostname) - 1] = '\0';
+			xe.e_hostname = exp->m_client->m_hostname;
 			putexportent(&xe);
 		}
 	}
@@ -146,9 +143,7 @@ xtab_append(nfs_export *exp)
 		return;
 	setexportent(_PATH_XTAB, "a");
 	xe = exp->m_export;
-	strncpy(xe.e_hostname, exp->m_client->m_hostname,
-	       sizeof (xe.e_hostname) - 1);
-	xe.e_hostname[sizeof (xe.e_hostname) - 1] = '\0';
+	xe.e_hostname = exp->m_client->m_hostname;
 	putexportent(&xe);
 	endexportent();
 	xfunlock(lockid);
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 5af9c30..ffa2440 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -65,7 +65,7 @@ struct sec_entry {
  * allow overrides when using exportfs.
  */
 struct exportent {
-	char		e_hostname[NFSCLNT_IDMAX+1];
+	char *		e_hostname;
 	char		e_path[NFS_MAXPATHLEN+1];
 	/* The mount path may be different from the exported path due
 	   to submount. It may change for every mount. The idea is we
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index c82bb0e..6b56708 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -176,13 +176,8 @@ getexportent(int fromkernel, int fromexports)
 		if (!has_default_opts)
 			xlog(L_WARNING, "No options for %s %s: suggest %s(sync) to avoid warning", ee.e_path, exp, exp);
 	}
-	if (strlen(hostname) >= sizeof(ee.e_hostname)) {
-		syntaxerr("client name too long");
-		export_errno = EINVAL;
-		return NULL;
-	}
-	strncpy(ee.e_hostname, hostname, sizeof (ee.e_hostname) - 1);
-	ee.e_hostname[sizeof (ee.e_hostname) - 1] = '\0';
+	xfree(ee.e_hostname);
+	ee.e_hostname = xstrdup(hostname);
 
 	if (parseopts(opt, &ee, fromexports && !has_default_subtree_opts, NULL) < 0)
 		return NULL;
@@ -335,6 +330,7 @@ dupexportent(struct exportent *dst, struct exportent *src)
 		dst->e_mountpoint = strdup(src->e_mountpoint);
 	if (src->e_fslocdata)
 		dst->e_fslocdata = strdup(src->e_fslocdata);
+	dst->e_hostname = NULL;
 }
 
 struct exportent *
@@ -355,12 +351,9 @@ mkexportent(char *hname, char *path, char *options)
 	ee.e_nsqgids = 0;
 	ee.e_uuid = NULL;
 
-	if (strlen(hname) >= sizeof(ee.e_hostname)) {
-		xlog(L_WARNING, "client name %s too long", hname);
-		return NULL;
-	}
-	strncpy(ee.e_hostname, hname, sizeof (ee.e_hostname) - 1);
-	ee.e_hostname[sizeof (ee.e_hostname) - 1] = '\0';
+	xfree(ee.e_hostname);
+	ee.e_hostname = xstrdup(hname);
+
 	if (strlen(path) >= sizeof(ee.e_path)) {
 		xlog(L_WARNING, "path name %s too long", path);
 		return NULL;
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
