From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] mount.nfs: Update the mount.nfs(8) man page
Date: Thu, 09 Aug 2007 17:36:56 -0400
Message-ID: <20070809213656.16767.65487.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJFgg-0007gC-HB
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:36:58 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJFgk-0001vg-Cc
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 14:37:02 -0700
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

Account for recent changes to the mount.nfs command.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c       |    4 ++--
 utils/mount/mount.nfs.man |   27 ++++++++-------------------
 2 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a232519..94435c8 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -270,7 +270,7 @@ fail_unlock:
 
 void mount_usage(void)
 {
-	printf(_("usage: %s remotetarget dir [-rvVwfnh] [-o nfsoptions]\n"),
+	printf(_("usage: %s remotetarget dir [-rvVwfnsh] [-o nfsoptions]\n"),
 		progname);
 	printf(_("options:\n"));
 	printf(_("\t-r\t\tMount file system readonly\n"));
@@ -279,7 +279,7 @@ void mount_usage(void)
 	printf(_("\t-w\t\tMount file system read-write\n"));
 	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
-	printf(_("\t-s\t\tTolerate sloppy mount options rather than failing.\n"));
+	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
index 231e04f..624358c 100644
--- a/utils/mount/mount.nfs.man
+++ b/utils/mount/mount.nfs.man
@@ -3,7 +3,7 @@
 .SH NAME
 mount.nfs, mount.nfs4 \- mount a Network File System
 .SH SYNOPSIS
-.BI "mount.nfs" " remotetarget dir" " [\-rvVwfnh ] [\-t " version "] [\-o " options "]
+.BI "mount.nfs" " remotetarget dir" " [\-rvVwfnsh ] [\-o " options "]
 .SH DESCRIPTION
 .BR mount.nfs
 is a part of 
@@ -49,27 +49,17 @@ By default, an entry is created in
 .I /etc/mtab 
 for every mounted file system. Use this option to skip making an entry.
 .TP
+.BI "\-s"
+Tolerate sloppy mount options rather than fail.
+.TP
 .BI "\-h"
 Print help message.
 .TP
-.BI "version"
-Specify NFS file system version. Either
-.BR nfs4 
-or 
-.BR nfs.
-If the command is 
-.BR mount.nfs4 
-or the 
-.I vfstype 
-option of 
-.BR mount(8) 
-command is nfs4, then version 4 is used, else version 3 or 2 is used.
-.TP
 .BI "nfsoptions"
 Refer to 
-.BR nfs(5)
+.BR nfs (5)
 or
-.BR mount(8) 
+.BR mount (8) 
 manual pages.
 
 .SH NOTE
@@ -92,9 +82,8 @@ table of mounted file systems
 .BR nfs (5),
 .BR mount (8),
 
-.SH BUGS
-Please notify current developers of NFS of any bugs in the current software or mail nfs@lists.sourceforge.net
+.SH "BUGS"
+Please notify nfs@lists.sourceforge.net of any bugs found in this software.
 
 .SH "AUTHOR"
 Amit Gud <agud@redhat.com>
-


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
