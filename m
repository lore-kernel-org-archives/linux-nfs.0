From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 907674: document fsid export option
Date: Thu, 29 Jan 2004 14:48:18 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40188282.36FBA905@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AmfcE-0004Uh-VX
	for nfs@lists.sourceforge.net; Fri, 30 Jan 2004 12:51:50 -0800
Received: from cfcafw.sgi.com ([198.149.23.1] helo=omx1.americas.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Am3B3-000688-3G
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 19:49:13 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

G'day,

This patch against nfs-utils 1.0.6 documents the fsid=num export option.

--- nfs-utils-sgi/nfs-utils-1.0.6/utils/exportfs/exports.man	Thu Jan 29 13:52:34 2004
+++ nfs-utils-work/nfs-utils-1.0.6/utils/exportfs/exports.man	Thu Jan 29 14:22:17
2004
@@ -271,6 +271,24 @@
 then the nominted path must be a mountpoint for the exportpoint to be
 exported.
 
+.TP
+.IR fsid= num
+This option forces the filesystem identification portion of the file
+handle and file attributes used on the wire to be
+.I num
+instead of a number derived from the major and minor number of the
+block device on which the filesystem is mounted.  Any 32 bit number
+can be used, but it must be unique amongst all the exported filesystems.
+
+This can be useful for NFS failover, to ensure that both servers of
+the failover pair use the same NFS file handles for the shared filesystem
+thus avoiding stale file handles after failover.
+
+Some Linux filesystems are not mounted on a block device; exporting
+these via NFS requires the use of the 
+.I fsid
+option (although that may still not be enough).
+
 .SS User ID Mapping
 .PP
 .I nfsd


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
