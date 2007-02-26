From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 04/11] nfs-utils: mount: Added nfs.5 man page
Date: Mon, 26 Feb 2007 06:17:59 -0500
Message-ID: <45E2C1E7.8000309@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080608000901060905060405"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdpL-0000JO-1S
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdpL-0006Ji-JC
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:33 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFPTK000799
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:25 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFPYe005650
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:25 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBFO4P025582
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:24 -0500
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

This is a multi-part message in MIME format.
--------------080608000901060905060405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------080608000901060905060405
Content-Type: text/x-patch;
 name="patch-04.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-04.dif"

commit 999dfb7ece03bee326579b678b9a83a2ad598fef
Author: Karel Zak <kzak@redhat.com>
Date:   Sat Feb 24 15:17:06 2007 -0500

    Added nfs.5 man page from util-linux
    
    Signed-off-by: Karel Zak <kzak@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 1fbbd1d..e8a1861 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -1,9 +1,10 @@
 ## Process this file with automake to produce Makefile.in
 
 man8_MANS	= mount.nfs.man umount.nfs.man
+man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
-EXTRA_DIST = nfsmount.x $(man8_MANS)
+EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
 mount_nfs_SOURCES = mount.c nfsmount.c nfs4mount.c nfsumount.c \
 		  mount_constants.h nfs4_mount.h nfs_mount4.h
 
@@ -29,6 +30,11 @@ install-man-links:
 	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
 	    rm -f $$inst ; \
 	  done)
+	(cd $(DESTDIR)$(man5dir) && \
+	  for m in $(man5_MANS) $(dist_man5_MANS) $(nodist_man5_MANS); do \
+	    inst=`echo $$m | sed -e 's/man$$/5/'`; \
+	    rm -f $$inst ; \
+	  done)
 
 uninstall-man-links:
 	(cd $(DESTDIR)$(man8dir) && \
@@ -36,4 +42,9 @@ uninstall-man-links:
 	    inst=`echo $$m | sed -e 's/man$$/8/'`; \
 	    rm -f $$inst ; \
 	  done)
+	(cd $(DESTDIR)$(man5dir) && \
+	  for m in $(man5_MANS) $(dist_man5_MANS) $(nodist_man5_MANS); do \
+	    inst=`echo $$m | sed -e 's/man$$/5/'`; \
+	    rm -f $$inst ; \
+	  done)
 

--------------080608000901060905060405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080608000901060905060405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080608000901060905060405--
