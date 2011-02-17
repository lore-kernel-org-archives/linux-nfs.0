Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755745Ab1BQNDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Feb 2011 08:03:12 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p1HD3BVl000766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Feb 2011 08:03:11 -0500
Received: from localhost (beach.nrt.redhat.com [10.64.200.71])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p1HD3AQB012980
	for <linux-nfs@vger.kernel.org>; Thu, 17 Feb 2011 08:03:11 -0500
Date: Thu, 17 Feb 2011 22:03:09 +0900 (JST)
Message-Id: <20110217.220309.663885281422297182.yamato@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Update man pages for /etc/exports.d
From: Masatake YAMATO <yamato@redhat.com>
In-Reply-To: <20110217.215900.388120588347145930.yamato@redhat.com>
References: <20110217.215900.388120588347145930.yamato@redhat.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Man page updates for /etc/exports.d.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 utils/exportfs/exportfs.man |   32 +++++++++++++++++++++++++++-----
 utils/exportfs/exports.man  |   19 +++++++++++++++++++
 2 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index 089f75b..7de0aef 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -37,11 +37,15 @@ when a client sends an NFS MOUNT request.
 .PP
 Normally the master export table is initialized with the contents of
 .I /etc/exports
+and files under
+.I /etc/exports.d
 by invoking
 .BR "exportfs -a" .
 However, a system administrator can choose to add or delete
 exports without modifying
 .I /etc/exports
+or files under
+.I /etc/exports.d
 by using the
 .B exportfs
 command.
@@ -92,17 +96,24 @@ Specify a list of export options in the same manner as in
 .B -i
 Ignore the
 .I /etc/exports
-file.  Only default options and options given on the command line are used.
+file and files under
+.I /etc/exports.d
+directory.  Only default options and options given on the command line are used.
 .TP
 .B -r
 Reexport all directories, synchronizing
 .I /var/lib/nfs/etab
 with
-.IR /etc/exports .
+.IR /etc/exports 
+and files under 
+.IR /etc/exports.d .
 This option removes entries in
 .I /var/lib/nfs/etab
 which have been deleted from
-.I /etc/exports, and removes any entries from the
+.I /etc/exports
+or files under
+.IR /etc/exports.d , 
+and removes any entries from the
 kernel export table which are no longer valid.
 .TP
 .B -u
@@ -130,6 +141,8 @@ when adding new entries to the export table.  When using
 .BR "exportfs -a" ,
 all exports listed in
 .I /etc/exports
+and files under
+.I /etc/exports.d
 are added to
 .IR /var/lib/nfs/etab .
 The kernel's export table is also updated as needed.
@@ -149,7 +162,9 @@ several sources.
 The default export options are
 .BR sync,ro,root_squash,wdelay .
 These can be overridden by entries in
-.IR /etc/exports .
+.IR /etc/exports 
+or files under
+.IR /etc/exports.d .
 .PP
 A system administrator may override options from these sources using the
 .B -o
@@ -188,6 +203,8 @@ to display the export options for each export.
 .SH EXAMPLES
 The following adds all directories listed in
 .I /etc/exports
+and files under
+.I /etc/exports.d
 to
 .I /var/lib/nfs/etab
 and pushes the resulting export entries into the kernel:
@@ -215,7 +232,9 @@ directory:
 .fi
 .PP
 To unexport all exports listed in
-.IR /etc/exports :
+.IR /etc/exports 
+and files under
+.IR /etc/exports.d :
 .PP
 .nf
 .B "# exportfs -au
@@ -238,6 +257,9 @@ if they themselves are no longer valid they will be removed.
 .I /etc/exports
 input file listing exports, export options, and access control lists
 .TP 2.5i
+.I /etc/exports.d
+directory where extra input files are stored
+.TP 2.5i
 .I /var/lib/nfs/etab
 master table of exports
 .TP 2.5i
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 4e3edc5..db49165 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -444,6 +444,24 @@ export entry for
 .B /home/joe
 in the example section below, which maps all requests to uid 150 (which
 is supposedly that of user joe).
+.SS Extra Export Tables
+After reading 
+.I /etc/exports 
+.B exportfs
+reads files under 
+.I /etc/exports.d. 
+directory as extra export tables.
+.B exportfs
+regards only a file which name is ended with 
+.I .export
+and
+not started with 
+.I . 
+as an extra export file. A file which name
+is not met this condition is just ignored.
+The format for extra export tables is the same as 
+.I /etc/exports
+.
 .IP
 .SH EXAMPLE
 .PP
@@ -489,6 +507,7 @@ all three mounts with the `sync' option enabled.
 '''entry.
 .SH FILES
 /etc/exports
+/etc/exports.d
 .SH SEE ALSO
 .BR exportfs (8),
 .BR netgroup (5),
-- 
1.7.4

