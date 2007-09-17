From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] mount.nfs: Add error messages for errors
	reported by	text-based mount(2)
Date: Mon, 17 Sep 2007 12:29:30 -0400
Message-ID: <20070917162930.25850.38347.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXJTV-0000kI-Qu
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:29:29 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXJTa-0006sH-Ik
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:29:34 -0700
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

The text-based mount(2) system call API can return some additional errors
that we would like to report correctly to our users.  These should be safe
to use with the legacy mount(2) ABI as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 480c944..10d4ed2 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -185,7 +185,7 @@ void sys_mount_errors(char *server, int error, int will_retry, int bg)
 		fprintf(stderr, "%s\n", errbuf);
 }
 
-/*
+/**
  * mount_error - report a foreground mount error
  * @spec: C string containing the device name being mounted
  * @mount_point: C string containing the pathname of the local mounted on dir
@@ -195,12 +195,24 @@ void sys_mount_errors(char *server, int error, int will_retry, int bg)
 void mount_error(const char *spec, const char *mount_point, int error)
 {
 	switch(error) {
+	case EACCES:
+		nfs_error(_("%s: access denied by server while mounting %s"),
+				progname, spec);
+		break;
+	case EINVAL:
+		nfs_error(_("%s: an incorrect mount option was specified"), progname);
+		break;
+	case EOPNOTSUPP:
+		nfs_error(_("%s: requested NFS version or transport"
+				" protocol is not supported"),
+				progname);
+		break;
 	case ENOTDIR:
 		nfs_error(_("%s: mount point %s is not a directory"),
 				progname, mount_point);
 		break;
 	case EBUSY:
-		nfs_error(_("%s: %s is already mounted or busy"),
+		nfs_error(_("%s: %s is busy or already mounted"),
 			progname, mount_point);
 		break;
 	case ENOENT:
@@ -212,6 +224,10 @@ void mount_error(const char *spec, const char *mount_point, int error)
 			nfs_error(_("%s: mount point %s does not exist"),
 				progname, mount_point);
 		break;
+	case EIO:
+	case EFAULT:
+		nfs_error(_("%s: internal error"), progname);
+		break;
 	default:
 		nfs_error(_("%s: %s"),
 			progname, strerror(error));


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
