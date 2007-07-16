From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/17] mount.nfs: Simplify handling of progname
Date: Sun, 15 Jul 2007 23:14:58 -0400
Message-ID: <20070716031458.11209.98158.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH38-0001hY-1D
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:02 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3A-0005pi-Kp
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:05 -0700
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

 utils/mount/mount.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index c163922..5a7bd1c 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -383,15 +383,10 @@ int main(int argc, char *argv[])
 {
 	int c, flags = 0, nfs_mount_vers = 0, mnt_err = 1, fake = 0;
 	char *spec, *mount_point, *extra_opts = NULL;
-	char *mount_opts = NULL, *p;
+	char *mount_opts = NULL;
 	uid_t uid = getuid();
 
-	progname = argv[0];
-	if (!progname)
-		exit(2);
-
-	if ((p = strrchr(progname, '/')) != NULL)
-		progname = p+1;
+	progname = basename(argv[0]);
 
 	if(!strncmp(progname, "umount", strlen("umount"))) {
 		if(argc < 2) {


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
