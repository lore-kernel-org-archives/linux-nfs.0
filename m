From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/14] umount.nfs: Fix white space damage in
	nfsumount.c
Date: Mon, 24 Sep 2007 11:29:20 -0400
Message-ID: <20070924152920.3804.40497.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZpsC-0006pG-Qk
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:24 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsH-0006Zs-2t
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:29 -0700
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

Replace leading blanks with tabs in del_mtab().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |  116 ++++++++++++++++++++++++-----------------------
 1 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index ca9c801..ffbda63 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -55,68 +55,68 @@ static int del_mtab(const char *spec, const char *node)
 {
 	int umnt_err, res;
 
-        umnt_err = 0;
-        if (lazy) {
-                res = umount2 (node, MNT_DETACH);
-                if (res < 0)
-                        umnt_err = errno;
-                goto writemtab;
-        }
-
-        if (force) {
-                res = umount2 (node, MNT_FORCE);
-                if (res == -1) {
-                        int errsv = errno;
-                        perror(_("umount2"));
-                        errno = errsv;
-                        if (errno == ENOSYS) {
-                                if (verbose)
-                                        printf(_("no umount2, trying umount...\n"));
-                                res = umount (node);
-                        }
-                }
-        } else
-                res = umount (node);
-
-        if (res < 0 && remount && errno == EBUSY && spec) {
-                /* Umount failed - let us try a remount */
-                res = mount(spec, node, NULL,
-                            MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
-                if (res == 0) {
-                        struct mntent remnt;
-                        nfs_error(_("%s: %s busy - remounted read-only"),
-                                	progname, spec);
-                        remnt.mnt_type = remnt.mnt_fsname = NULL;
-                        remnt.mnt_dir = xstrdup(node);
-                        remnt.mnt_opts = xstrdup("ro");
-                        if (!nomtab)
-                                update_mtab(node, &remnt);
-                        return 0;
-                } else if (errno != EBUSY) {    /* hmm ... */
-                        perror(_("remount"));
-                        nfs_error(_("%s: could not remount %s read-only"),
-                                	progname, spec);
-                }
-        }
-
-        if (res >= 0) {
-                /* Umount succeeded */
-                if (verbose)
-                        printf(_("%s umounted\n"), spec ? spec : node);
-        }
+	umnt_err = 0;
+	if (lazy) {
+		res = umount2 (node, MNT_DETACH);
+		if (res < 0)
+			umnt_err = errno;
+		goto writemtab;
+	}
+
+	if (force) {
+		res = umount2 (node, MNT_FORCE);
+		if (res == -1) {
+			int errsv = errno;
+			perror(_("umount2"));
+			errno = errsv;
+			if (errno == ENOSYS) {
+				if (verbose)
+					printf(_("no umount2, trying umount...\n"));
+				res = umount (node);
+			}
+		}
+	} else
+		res = umount (node);
+
+	if (res < 0 && remount && errno == EBUSY && spec) {
+		/* Umount failed - let us try a remount */
+		res = mount(spec, node, NULL,
+			    MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
+		if (res == 0) {
+			struct mntent remnt;
+			nfs_error(_("%s: %s busy - remounted read-only"),
+					progname, spec);
+			remnt.mnt_type = remnt.mnt_fsname = NULL;
+			remnt.mnt_dir = xstrdup(node);
+			remnt.mnt_opts = xstrdup("ro");
+			if (!nomtab)
+				update_mtab(node, &remnt);
+			return 0;
+		} else if (errno != EBUSY) {    /* hmm ... */
+			perror(_("remount"));
+			nfs_error(_("%s: could not remount %s read-only"),
+					progname, spec);
+		}
+	}
+
+	if (res >= 0) {
+		/* Umount succeeded */
+		if (verbose)
+			printf(_("%s umounted\n"), spec ? spec : node);
+	}
 
  writemtab:
-        if (!nomtab &&
-            (umnt_err == 0 || umnt_err == EINVAL || umnt_err == ENOENT)) {
-               update_mtab(node, NULL);
-        }
+	if (!nomtab &&
+	    (umnt_err == 0 || umnt_err == EINVAL || umnt_err == ENOENT)) {
+		update_mtab(node, NULL);
+	}
 
-        if (res >= 0)
-                return 0;
+	if (res >= 0)
+		return 0;
 
-        if (umnt_err)
-                umount_error(umnt_err, node);
-        return EX_FILEIO;
+	if (umnt_err)
+		umount_error(umnt_err, node);
+	return EX_FILEIO;
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
