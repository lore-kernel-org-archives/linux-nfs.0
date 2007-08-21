From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] mount.nfs: Replace fork() with daemon() for
	backgrounding	mounts
Date: Tue, 21 Aug 2007 12:19:08 -0400
Message-ID: <20070821161907.4373.81726.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INWRk-0003SX-LN
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:12 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INWRn-0000Z3-0N
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:15 -0700
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

Neil recommended this change to address a problem with background mount
processes handling signals properly during an init level change.  It is
also useful for preventing background mount processes from reporting
progress on the parent's tty, which is generally just annoying noise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 40e7958..b350703 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -552,15 +552,20 @@ int main(int argc, char *argv[])
 	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
 				mount_opts, fake, nomtab, FOREGROUND);
 	if (mnt_err == EX_BG) {
-		printf(_("mount: backgrounding \"%s\"\n"), spec);
+		printf(_("%s: backgrounding \"%s\"\n"),
+			progname, spec);
 		fflush(stdout);
 
 		/*
 		 * Parent exits immediately with success.  Make
 		 * sure parent doesn't free "mount_point".
 		 */
-		if (fork() > 0)
-			exit(0);
+		if (daemon(0, 0)) {
+			nfs_error(_("%s: failed to start "
+					"background process: %s\n"),
+						progname, strerror(errno));
+			exit(EX_FAIL);
+		}
 
 		mnt_err = try_mount(spec, mount_point, flags, fs_type,
 					&extra_opts, mount_opts, fake,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
