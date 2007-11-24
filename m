From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Fix nfsstat help and man page
Date: Sat, 24 Nov 2007 18:14:18 +0100
Message-ID: <20071124171418.GA6361@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:33646 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbXKXSGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Nov 2007 13:06:33 -0500
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1IvyaB-0005aX-20
	for linux-nfs@vger.kernel.org; Sat, 24 Nov 2007 18:14:21 +0100
Received: from root by trofast.sesse.net with local (Exim 4.68)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1IvyaA-0001fK-Io
	for linux-nfs@vger.kernel.org; Sat, 24 Nov 2007 18:14:18 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix nfsstat help and man page to say --mounts, instead of --mounted (which is
wrong).

Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

Index: nfs-utils-1.1.1/utils/nfsstat/nfsstat.c
===================================================================
--- nfs-utils-1.1.1.orig/utils/nfsstat/nfsstat.c        2007-11-19 21:57:59.000000000 +0100
+++ nfs-utils-1.1.1/utils/nfsstat/nfsstat.c     2007-11-19 21:58:13.000000000 +0100
@@ -207,7 +207,7 @@
 {
        printf("Usage: %s [OPTION]...\n\
 \n\
-  -m, --mounted\t\tShow statistics on mounted NFS filesystems\n\
+  -m, --mounts\t\tShow statistics on mounted NFS filesystems\n\
   -c, --client\t\tShow NFS client statistics\n\
   -s, --server\t\tShow NFS server statistics\n\
   -2\t\t\tShow NFS version 2 statistics\n\
Index: nfs-utils-1.1.1/utils/nfsstat/nfsstat.man
===================================================================
--- nfs-utils-1.1.1.orig/utils/nfsstat/nfsstat.man      2007-11-19 21:58:16.000000000 +0100
+++ nfs-utils-1.1.1/utils/nfsstat/nfsstat.man   2007-11-19 21:58:48.000000000 +0100
@@ -35,7 +35,7 @@
 .B \-4
 Print only NFS v4 statistics.
 .TP
-.B \-m, \-\-mounted
+.B \-m, \-\-mounts
 Print information about each of the mounted \fBNFS\fR file systems.

 If this option is used, all other options are ignored.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
