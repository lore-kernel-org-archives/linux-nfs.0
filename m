From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Update README
Date: Thu, 1 Feb 2007 12:38:47 -0500
Message-ID: <20070201173847.GA26741@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCfti-0006cx-9Y
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 09:38:58 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCftd-0004MN-Ar
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 09:38:56 -0800
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

The README has bit-rotted: redhat and debian packaging scripts are no
longer included, util-linux mount is (in theory) no longer required, and
instructions on building from latest git would be useful.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---

I'm autotool-clueless and have no clue about the "ltmain.sh" thing
mentioned in the last section; I just followed the bootstrapping
instructions in the commit message for 922d6cfd and found I needed a
copy of ltmain.sh to make it work.

 README |   40 +++++++++++++++-------------------------
 1 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/README b/README
index 3fa3a58..f5a2aee 100644
--- a/README
+++ b/README
@@ -16,10 +16,9 @@ libraries.  They are available from
 Otherwise use --disable-nfsv4
 
 
-1. COMPILING WITHOUT PACKAGE MANAGEMENT
+1. COMPILING
 
-To compile without using a package management system, unpack the
-sources and run these commands:
+Unpack the sources and run these commands:
 
     # ./configure
     # make
@@ -28,38 +27,29 @@ To install binaries and documenation, run this command:
 
     # make install
 
-You will have to install the two NFS service scripts yourself.
-Service scripts for RedHat 6.x and 7.x are in etc/redhat.  They
-have been tested on RedHat 6.2 and 7.1.
 
+2. COMPILING FROM GIT
 
-2. COMPILING WITH RPM
+Getting nfs-utils for the first time:
 
-On RedHat 6.2 and 7.1, you can use
+	git clone git://linux-nfs.org/nfs-utils
 
-    # rpm -ta nfs-utils-1.0.1.tar.gz
+Updating to the latest head after you've already got it.
 
-to build the source and binary RPMs.
+	git pull
 
+Building requires that autotools be installed:
 
-3. COMPILING FOR DEBIAN
-
-The nfs-utils tree has an up-to-date debian directory, so the usual
-debian build scripts should work.  The simplest way to build binary
-debs, however, is simply to become root (or use fakeroot) and run:
-
-    # debian/rules binary
-
-
-4. REQUIRED VERSIONS OF OTHER TOOLS
-
-Proper NFS operation requires a 'mount' program from util-linux 2.11f
-or later.
+	aclocal -I aclocal
+	autoheader
+	automake
+	autoconf
 
+You may also need to copy ltmain.sh to the current directory if the
+above doesn't do that.  Usually there's a copy in
+/usr/share/libtool/ltmain.sh.  Finally, build as usual as above.
 
 Share And Enjoy!
 
     --	the nfs-utils developers
 	<nfs@lists.sourceforge.net>
-	26 Dec 2001
-
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
