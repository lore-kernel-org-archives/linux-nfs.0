From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: [ 1018450 ] man page typo
Date: Fri, 4 Mar 2005 16:24:20 -0500
Message-ID: <20050304212420.GA21390@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7KHh-00032K-Bj
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 13:24:33 -0800
Received: from mta13.adelphia.net ([68.168.78.44])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D7KHf-0007wr-O5
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 13:24:33 -0800
Received: from harpo ([68.235.28.141]) by mta13.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050304212425.UBBZ4618.mta13.adelphia.net@harpo>
          for <nfs@lists.sourceforge.net>; Fri, 4 Mar 2005 16:24:25 -0500
Received: from gam3 by harpo with local (Exim 3.36 #1 (Debian))
	id 1D7KHU-0005Zh-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Mar 2005 16:24:20 -0500
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I plan to commit the patch below.  This will close bug [ 1018450 ] 

Allen

Index: exports.man
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/exportfs/exports.man,v
retrieving revision 1.13
diff -u -r1.13 exports.man
--- exports.man	15 Sep 2004 01:58:41 -0000	1.13
+++ exports.man	4 Mar 2005 21:19:54 -0000
@@ -1,5 +1,4 @@
-.TH EXPORTS 5 "28 October 1999"
-.UC 5
+.TH EXPORTS 5 "4 March 2005" "Linux" "Linux File Formats Manual"
 .SH NAME
 exports \- NFS file systems being exported (for Kernel based NFS)
 .SH SYNOPSIS
@@ -171,7 +170,7 @@
 .TP
 .IR no_subtree_check
 This option disables subtree checking, which has mild security
-implications, but can improve reliability is some circumstances.
+implications, but can improve reliability in some circumstances.
 
 If a subdirectory of a filesystem is exported, but the whole
 filesystem isn't then whenever a NFS request arrives, the server must
@@ -190,7 +189,7 @@
 directories to which only root has access can only be accessed if the
 filesystem is exported with
 .I no_root_squash
-(see below), even the file itself allows more general access.
+(see below), even if the file itself allows more general access.
 
 As a general guide, a home directory filesystem, which is normally
 exported at the root and may see lots of file renames, should be
@@ -487,6 +486,12 @@
 '''entry.
 .SH FILES
 /etc/exports
+.SH SEE ALSO
+.BR exportfs (8),
+.BR netgroup (5),
+.BR mountd (8),
+.BR nfsd (8),
+.BR showmount (8).
 '''.SH DIAGNOSTICS
 '''An error parsing the file is reported using syslogd(8) as level NOTICE from
 '''a DAEMON whenever nfsd(8) or mountd(8) is started up.  Any unknown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
