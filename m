From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: [PATCH] various minor manpage fixes
Date: Mon, 20 Nov 2006 23:43:39 +0100
Message-ID: <20061120224339.GA13413@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmHsp-00069I-SF
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:45:00 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmHsn-0002i9-H9
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 14:45:01 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1GmHsi-0006xK-8W
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 23:44:54 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1GmHrX-0003VV-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Nov 2006 23:43:39 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

Here's a few fixes for the man pages. The changelog entry is:

=== snip ===
Author: Steinar H. Gunderson <sesse@debian.org>
Date:   Mon, 20 Nov 2006 23:42:25 +0100

    Various minor manpage fixes.
         This mostly takes care of the difference between
         - and \-; in man pages, the former is hyphen
         (which indicates, among others, that a line might
         be split at that point), while the latter is a
         dash. For options, the latter is correct.

         There's also one minor grammatical fix.
=== snip ===


diff -ur nfs-utils-1.0.10/utils/exportfs/exports.man nfs-utils-1.0.10.patched/utils/exportfs/exports.man
--- nfs-utils-1.0.10/utils/exportfs/exports.man	2006-08-07 08:40:50.000000000 +0200
+++ nfs-utils-1.0.10.patched/utils/exportfs/exports.man	2006-11-15 17:35:08.000000000 +0100
@@ -121,7 +124,7 @@
 .I sync
 is the default, and
 .I async
-must be explicit requested if needed.
+must be explicitly requested if needed.
 To help make system adminstrators aware of this change, 'exportfs'
 will issue a warning if neither
 .I sync
diff -ur nfs-utils-1.0.10/utils/nfsstat/nfsstat.man nfs-utils-1.0.10.patched/utils/nfsstat/nfsstat.man
--- nfs-utils-1.0.10/utils/nfsstat/nfsstat.man	2006-08-07 08:40:50.000000000 +0200
+++ nfs-utils-1.0.10.patched/utils/nfsstat/nfsstat.man	2006-11-15 17:35:08.000000000 +0100
@@ -14,36 +14,36 @@
 displays statistics kept about NFS client and server activity.
 .SH OPTIONS
 .TP
-.B -s, --server
+.B \-s, \-\-server
 Print only server-side statistics. The default is to print both server and
 client statistics.
 .TP
-.B -c, --client
+.B \-c, \-\-client
 Print only client-side statistics.
 .TP
-.B -n, --nfs
+.B \-n, \-\-nfs
 Print only NFS statistics. The default is to print both NFS and RPC
 information.
 .TP
-.B -2
+.B \-2
 Print only NFS v2 statistics. The default is to only print information
 about the versions of \fBNFS\fR that have non-zero counts.
 .TP
-.B -3
+.B \-3
 Print only NFS v3 statistics. 
 .TP
-.B -4
+.B \-4
 Print only NFS v4 statistics. 
 .TP
-.B -m, --mounted
+.B \-m, \-\-mounted
 Print information about each of the mounted \fBNFS\fR file systems.
 
 If this option is used, all other options are ignored.
 .TP
-.B -r, --rpc
+.B \-r, \-\-rpc
 Print only RPC statistics.
 .TP
-.BI -o " facility
+.BI \-o " facility
 Display statistics for the specified facility, which must be one of:
 .RS
 .TP
@@ -69,27 +69,27 @@
 Display all of the above facilities.
 .RE
 .TP
-.B -v, --verbose
-This is equivalent to \fB-o all\fR.
+.B \-v, \-\-verbose
+This is equivalent to \fB\-o all\fR.
 .SH EXAMPLES
 .TP
-.B nfsstat -o all -234
+.B nfsstat \-o all \-234
 Show all information about all versions of \fBNFS\fR.
 .TP
-.B nfsstat --verbose -234
+.B nfsstat \-\-verbose \-234
 Same as above.
 .TP
-.B nfsstat -o all
+.B nfsstat \-o all
 Show all information about about active versions of \fBNFS\fR.
 .TP
-.B nfsstat --nfs --server -3
+.B nfsstat \-\-nfs \-\-server \-3
 Show statistics for \fBNFS\fR version 3 server.
 .TP
-.B nfsstat -m
+.B nfsstat \-m
 Show information about mounted \fBNFS\fR filesystems.
 .\" --------------------- DISPLAY --------------------------------
 .SH DISPLAY
-The \fBFlags\fR output from the \fB-m\fR option is the same as the
+The \fBFlags\fR output from the \fB\-m\fR option is the same as the
 flags give to the \fBmount\fR command.
 .\" --------------------- FILES ----------------------------------
 .SH FILES
@@ -111,11 +111,11 @@
 .BR nfs (5).
 .\" ---------------------- BUGS ----------------------------------
 .SH BUGS
-The default output has be changed.  To get the old default output you must run \fBnfsstat --auto -2\fR.
+The default output has be changed.  To get the old default output you must run \fBnfsstat \-\-auto \-2\fR.
 .P
-The function of the \fB-v\fR and \fB-a\fR options have changed. The \fB-a\fR option
-is now reserved for future use. The \fB-v\fR does what the \fB-a\fR option used to do,
-and the new \fB-[234]\fR options replace the \fB-v\fR option.
+The function of the \fB\-v\fR and \fB\-a\fR options have changed. The \fB\-a\fR option
+is now reserved for future use. The \fB\-v\fR does what the \fB\-a\fR option used to do,
+and the new \fB\-[234]\fR options replace the \fB\-v\fR option.
 .P
 The \fBDisplay\fR section should be more complete.
 .P
diff -ur nfs-utils-1.0.10/utils/showmount/showmount.man nfs-utils-1.0.10.patched/utils/showmount/showmount.man
--- nfs-utils-1.0.10/utils/showmount/showmount.man	2006-08-07 08:40:50.000000000 +0200
+++ nfs-utils-1.0.10.patched/utils/showmount/showmount.man	2006-11-15 17:35:08.000000000 +0100
@@ -21,7 +21,7 @@
 The output from
 .B showmount
 is designed to
-appear as though it were processed through ``sort -u''.
+appear as though it were processed through ``sort \-u''.
 .SH OPTIONS
 .TP
 .BR \-a " or " \-\-all
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
