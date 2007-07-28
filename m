From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/23] umount.nfs: make umount_usage() static
Date: Sat, 28 Jul 2007 17:49:38 -0400
Message-ID: <20070728214938.21871.96816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAY-0007Qu-JR
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:50 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAc-0003fW-F8
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:54 -0700
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

No good reason to export umount_usage.  Make it static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c     |    7 +------
 utils/mount/nfsumount.c |    7 ++++++-
 utils/mount/nfsumount.h |    1 -
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 9503187..d80e5d7 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -374,13 +374,8 @@ int main(int argc, char *argv[])
 
 	discover_nfs_mount_data_version();
 
-	if(!strncmp(progname, "umount", strlen("umount"))) {
-		if(argc < 2) {
-			umount_usage();
-			exit(EX_USAGE);
-		}
+	if(!strncmp(progname, "umount", strlen("umount")))
 		exit(nfsumount(argc, argv));
-	}
 
 	if (argv[1] && argv[1][0] == '-') {
 		if(argv[1][1] == 'V')
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 19e9be3..477f262 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -235,7 +235,7 @@ static struct option umount_longopts[] =
   { NULL, 0, 0, 0 }
 };
 
-void umount_usage()
+static void umount_usage(void)
 {
 	printf(_("usage: %s dir [-fvnrlh]\n"), progname);
 	printf(_("options:\n\t-f\t\tforce unmount\n"));
@@ -252,6 +252,11 @@ int nfsumount(int argc, char *argv[])
 	char *spec;
 	struct mntentchn *mc;
 
+	if (argc < 2) {
+		umount_usage();
+		return EX_USAGE;
+	}
+
 	spec = argv[1];
 
 	argv += 1;
diff --git a/utils/mount/nfsumount.h b/utils/mount/nfsumount.h
index e37eaff..191118d 100644
--- a/utils/mount/nfsumount.h
+++ b/utils/mount/nfsumount.h
@@ -6,6 +6,5 @@
 
 int nfsumount(int, char **);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
-void umount_usage();
 
 #endif


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
