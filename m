From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/17] mount.nfs: When -v is set and the mount
	succeeds, print the mount info
Date: Sun, 15 Jul 2007 23:16:00 -0400
Message-ID: <20070716031600.11209.62192.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH43-0001pH-1D
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:59 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH44-00066z-TE
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:16:02 -0700
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

Add a bit of logic that appears to be in other mount helpers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index fcb1f5e..53dc731 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -171,6 +171,18 @@ static void discover_nfs_mount_data_version(void)
 		nfs_mount_data_version = NFS_MOUNT_VERSION;
 }
 
+static void print_one(char *spec, char *node, char *type, char *opts)
+{
+	if (verbose) {
+		printf("%s on %s type %s", spec, node, type);
+
+		if (opts != NULL)
+			printf(" (%s)", opts);
+
+		printf("\n");
+	}
+}
+
 /* Try to build a canonical options string.  */
 static char * fix_opts_string (int flags, const char *extra_opts) {
 	const struct opt_map *om;
@@ -474,6 +486,9 @@ int main(int argc, char *argv[])
 	if (mnt_err)
 		exit(EX_FAIL);
 
+	if (!fake)
+		print_one(spec, mount_point, fs_type, mount_opts);
+
 	if (!nomtab)
 		mnt_err = add_mtab(spec, mount_point, fs_type, flags, extra_opts,
 				0, 0 /* these are always zero for NFS */ );


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
