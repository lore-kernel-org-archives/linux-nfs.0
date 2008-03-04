From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs-utils: update mailing list address
Date: Tue, 04 Mar 2008 11:19:11 -0500
Message-ID: <20080304161910.28185.15018.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:44514 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760462AbYCDQTx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2008 11:19:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As part of migrating from nfs-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org to linux-nfs@vger.kernel.org,
update the mailing list address used to report bugs in nfs-utils.

I removed the BUGS section in the mount.nfs and umount.nfs man pages since
they weren't consistent with the contents of the BUGS sections in others
in nfs-utils.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 README                     |    2 +-
 configure.ac               |    2 +-
 utils/mount/mount.nfs.man  |    3 ---
 utils/mount/umount.nfs.man |    3 ---
 4 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/README b/README
index e2196da..e7588cf 100644
--- a/README
+++ b/README
@@ -162,4 +162,4 @@ scripts can be written to work correctly.
 Share And Enjoy!
 
     --	the nfs-utils developers
-	<nfs@lists.sourceforge.net>
+	<linux-nfs@vger.kernel.org>
diff --git a/configure.ac b/configure.ac
index 68c02f3..ab3198a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,6 +1,6 @@
 dnl Process this file with autoconf to produce a configure script.
 dnl
-AC_INIT([linux nfs-utils],[1.1.1],[nfs-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org],[nfs-utils])
+AC_INIT([linux nfs-utils],[1.1.1],[linux-nfs@vger.kernel.org],[nfs-utils])
 AC_CANONICAL_BUILD([])
 AC_CANONICAL_HOST([])
 AC_CONFIG_MACRO_DIR(aclocal)
diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
index 624358c..1a4561b 100644
--- a/utils/mount/mount.nfs.man
+++ b/utils/mount/mount.nfs.man
@@ -82,8 +82,5 @@ table of mounted file systems
 .BR nfs (5),
 .BR mount (8),
 
-.SH "BUGS"
-Please notify nfs@lists.sourceforge.net of any bugs found in this software.
-
 .SH "AUTHOR"
 Amit Gud <agud@redhat.com>
diff --git a/utils/mount/umount.nfs.man b/utils/mount/umount.nfs.man
index ee4cdaf..15addfa 100644
--- a/utils/mount/umount.nfs.man
+++ b/utils/mount/umount.nfs.man
@@ -66,8 +66,5 @@ table of mounted file systems
 .BR nfs (5),
 .BR umount (8),
 
-.SH "BUGS"
-Please notify nfs@lists.sourceforge.net of any bugs found in this software.
-
 .SH "AUTHOR"
 Amit Gud <agud@redhat.com>

