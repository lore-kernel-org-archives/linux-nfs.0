From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/14] umount.nfs: Refactor remount logic in umount.nfs
Date: Mon, 24 Sep 2007 11:29:26 -0400
Message-ID: <20070924152925.3804.58946.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZpsG-0006pm-1b
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:28 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsK-0006f8-DY
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:33 -0700
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

Clean up: move the remount logic into its own function.  This makes it
easier to fix a bug in the next patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index ffbda63..4311473 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -51,6 +51,30 @@ int force;
 int lazy;
 int remount;
 
+
+static int try_remount(const char *spec, const char *node)
+{
+	int res;
+
+	res = mount(spec, node, NULL,
+		    MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
+	if (res == 0) {
+		struct mntent remnt;
+		nfs_error(_("%s: %s busy - remounted read-only"),
+				progname, spec);
+		remnt.mnt_type = remnt.mnt_fsname = NULL;
+		remnt.mnt_dir = xstrdup(node);
+		remnt.mnt_opts = xstrdup("ro");
+		if (!nomtab)
+			update_mtab(node, &remnt);
+	} else if (errno != EBUSY) {    /* hmm ... */
+		perror(_("remount"));
+		nfs_error(_("%s: could not remount %s read-only"),
+				progname, spec);
+	}
+	return res;
+}
+
 static int del_mtab(const char *spec, const char *node)
 {
 	int umnt_err, res;
@@ -79,24 +103,9 @@ static int del_mtab(const char *spec, const char *node)
 		res = umount (node);
 
 	if (res < 0 && remount && errno == EBUSY && spec) {
-		/* Umount failed - let us try a remount */
-		res = mount(spec, node, NULL,
-			    MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
-		if (res == 0) {
-			struct mntent remnt;
-			nfs_error(_("%s: %s busy - remounted read-only"),
-					progname, spec);
-			remnt.mnt_type = remnt.mnt_fsname = NULL;
-			remnt.mnt_dir = xstrdup(node);
-			remnt.mnt_opts = xstrdup("ro");
-			if (!nomtab)
-				update_mtab(node, &remnt);
+		res = try_remount(spec, node);
+		if (!res)
 			return 0;
-		} else if (errno != EBUSY) {    /* hmm ... */
-			perror(_("remount"));
-			nfs_error(_("%s: could not remount %s read-only"),
-					progname, spec);
-		}
 	}
 
 	if (res >= 0) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
