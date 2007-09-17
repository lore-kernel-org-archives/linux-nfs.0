From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] export man page updated.
Date: Mon, 17 Sep 2007 11:34:11 -0400
Message-ID: <46EE9E73.1070002@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060602050907080200000704"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXIrx-00058F-Qt
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 08:50:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXIfa-000698-E2
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 08:37:54 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8HFbljF001866
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 17 Sep 2007 11:37:47 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8HFblIs027027
	for <nfs@lists.sourceforge.net>; Mon, 17 Sep 2007 11:37:47 -0400
Received: from [10.13.248.54] (vpn-248-54.boston.redhat.com [10.13.248.54])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l8HFbkPY005799
	for <nfs@lists.sourceforge.net>; Mon, 17 Sep 2007 11:37:46 -0400
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

This is a multi-part message in MIME format.
--------------060602050907080200000704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

It was pointed that the exportfs man page talks about
the wrong file. In 2.6 kernels the export information
is now kept in /var/lib/nfs/etab not /var/lib/nfs/xtab.

This patch basically does a 's/xtab/etab' and is relative
to the to the Fedora git tree

git://git.infradead.org/~steved/nfs-utils.fedora

steved.

--------------060602050907080200000704
Content-Type: text/x-patch;
 name="exportfs-man-update.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="exportfs-man-update.patch"

commit 0647ed30739b9867a4657bd69467925c868640b3
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Sep 14 13:21:08 2007 -0400

    Updated exportfs man to talk about /var/lib/nfs/etab
    instead of /var/lib/nfs/xtab
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index 2bd8e31..9cfe7b8 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -22,14 +22,14 @@ The
 .B exportfs
 command is used to maintain the current table of exported file systems for
 NFS. This list is kept in a separate file named
-.BR /var/lib/nfs/xtab
+.BR /var/lib/nfs/etab
 which is read by
 .B mountd
 when a remote host requests access to mount a file tree, and parts of
 the list which are active are kept in the kernel's export table.
 .P
 Normally this 
-.B xtab
+.B etab
 file is initialized with the list of all file systems named in
 .B /etc/exports 
 by invoking
@@ -59,7 +59,7 @@ In the new mode,
 does not give any information to the kernel but only provides it to
 .B mountd
 through the
-.B /var/lib/nfs/xtab
+.B /var/lib/nfs/etab
 file.
 .B mountd
 will listen to requests from the kernel and will provide information
@@ -69,7 +69,7 @@ In the legacy mode,
 any export requests which identify a specific host (rather than a
 subnet or netgroup etc) are entered directly into the kernel's export
 table as well as being written to
-.BR /var/lib/nfs/xtab .
+.BR /var/lib/nfs/etab .
 Further, any mount points listed in
 .B /var/lib/nfs/rmtab
 which match a non host-specific export request will cause an
@@ -93,8 +93,8 @@ file, so that only default options and options given on the command
 line are used.
 .TP
 .B -r
-Reexport all directories. It synchronizes /var/lib/nfs/xtab
-with /etc/exports. It removes entries in /var/lib/nfs/xtab
+Reexport all directories. It synchronizes /var/lib/nfs/etab
+with /etc/exports. It removes entries in /var/lib/nfs/etab
 which are deleted from /etc/exports, and remove any entries from the
 kernel export table which are no longer valid.
 .TP
@@ -120,7 +120,7 @@ entries to the export table.  When using
 all directories in
 .B exports(5)
 are added to
-.B xtab
+.B etab
 and the resulting list is pushed into the kernel.
 .P
 The
@@ -152,7 +152,7 @@ directory.
 Modifications of the kernel export table used by
 .B nfsd(8)
 take place immediately after parsing the command line and updating the
-.B xtab
+.B etab
 file.
 .P
 The default export options are
@@ -163,14 +163,14 @@ The third synopsis shows how to unexported a currently exported directory.
 When using
 .BR "exportfs -ua" ,
 all entries listed in
-.B xtab
+.B etab
 are removed from the kernel export tables, and the file is cleared. This
 effectively shuts down all NFS activity.
 .P
 To remove individual export entries, one can specify a
 .I host:/path
 pair. This deletes the specified entry from
-.B xtab
+.B etab
 and removes the corresponding kernel entry (if any).
 .P
 .\" -------------------- Dumping the Export Table -----------------
@@ -186,7 +186,7 @@ option, the list of flags pertaining to each export are shown in addition.
 The following adds all directories listed in
 .B /etc/exports
 to
-.B /var/lib/nfs/xtab
+.B /var/lib/nfs/etab
 and pushes the resulting export entries into the kernel:
 .P
 .nf

--------------060602050907080200000704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------060602050907080200000704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060602050907080200000704--
