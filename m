From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] mount.nfs: Fix background mounts
Date: Fri, 03 Aug 2007 13:24:15 -0400
Message-ID: <20070803172415.3357.91411.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0su-00024Y-PR
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:21 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sy-0007w0-Nv
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:24:24 -0700
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

The new mount.nfs helper does not support background mounts.  Add support
for background mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index c0c3971..a232519 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -49,6 +49,9 @@ int nomtab;
 int verbose;
 int sloppy;
 
+#define FOREGROUND	(0)
+#define BACKGROUND	(1)
+
 static struct option longopts[] = {
   { "fake", 0, 0, 'f' },
   { "help", 0, 0, 'h' },
@@ -518,7 +521,26 @@ int main(int argc, char *argv[])
 	}
 
 	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
-				mount_opts, fake, nomtab, 0);
+				mount_opts, fake, nomtab, FOREGROUND);
+	if (mnt_err == EX_BG) {
+		printf(_("mount: backgrounding \"%s\"\n"), spec);
+		fflush(stdout);
+
+		/*
+		 * Parent exits immediately with success.  Make
+		 * sure not to free "mount_point"
+		 */
+		if (fork() > 0)
+			exit(0);
+
+		mnt_err = try_mount(spec, mount_point, flags, fs_type,
+					&extra_opts, mount_opts, fake,
+					nomtab, BACKGROUND);
+		if (verbose && mnt_err)
+			printf(_("%s: giving up \"%s\"\n"),
+				progname, spec);
+		exit(0);
+	}
 
 out:
 	free(mount_point);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
