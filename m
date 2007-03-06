From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Bug#413661: libblkid1: leaks memory like crazy
Date: Tue, 06 Mar 2007 14:08:43 +0100
Message-ID: <20070306130843.30940.96498.reportbug__38405.101808212$1173187036$gmane$org@trofast.sesse.net>
Reply-To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	413661@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3340174789829491032=="
To: Debian Bug Tracking System <submit@bugs.debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOZVM-0003dA-Bn
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 05:15:00 -0800
Received: from rietz.debian.org ([140.211.166.43])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOZVN-0001NK-K0
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 05:15:02 -0800
Resent-Message-ID: <handler.413661.B.11731865538278@bugs.debian.org>
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

This is a multi-part MIME message sent by reportbug.


--===============3340174789829491032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Package: libblkid1
Version: 1.39+1.40-WIP-2006.11.14+dfsg-1
Severity: grave
Tags: patch

(RMs: I'm unsure if this should be fixed for etch or not, given that I
do not know of anything in etch that actually uses this library enough
for it to leak. Feel free to downgrade or tag etch-ignore, of course.)

nfs-kernel-server 1.0.12 has started using libblkid, and leaks absurd
amounts of memory (in the order of several megabytes per minute).
Tracing using Omega (which is not yet in Debian, but nevertheless really
useful) tracked the leaks down to libblkid. I've attached a diff that
fixes the issues for me, and allows me to run nfs-kernel-server with
only minor leaks (which I'll take with nfs-utils upstream, as they are
not libblkid1 related).

-- System Information:
Debian Release: 4.0
  APT prefers unstable
  APT policy: (500, 'unstable'), (500, 'testing'), (1, 'experimental')
Architecture: amd64 (x86_64)
Shell:  /bin/sh linked to /bin/bash
Kernel: Linux 2.6.19
Locale: LANG=en_DK.UTF-8, LC_CTYPE=en_DK.UTF-8 (charmap=UTF-8)

Versions of packages libblkid1 depends on:
ii  libc6                       2.3.6.ds1-13 GNU C Library: Shared libraries
ii  libdevmapper1.02            2:1.02.12-1  The Linux Kernel Device Mapper use
ii  libselinux1                 1.32-3       SELinux shared libraries
ii  libsepol1                   1.14-3       Security Enhanced Linux policy lib

libblkid1 recommends no packages.

-- debconf-show failed

--===============3340174789829491032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="libblkid-leak-fixes.diff"

Only in e2fsprogs-patched/debian: BUILD-BF
Only in e2fsprogs-patched/debian: BUILD-STD
Only in e2fsprogs-patched/debian: comerr-dev
Only in e2fsprogs-patched/debian: comerr-dev.postinst.debhelper
Only in e2fsprogs-patched/debian: comerr-dev.prerm.debhelper
Only in e2fsprogs-patched/debian: e2fsck-static
Only in e2fsprogs-patched/debian: e2fslibs
Only in e2fsprogs-patched/debian: e2fslibs-dev
Only in e2fsprogs-patched/debian: e2fslibs-dev.postinst.debhelper
Only in e2fsprogs-patched/debian: e2fslibs-dev.prerm.debhelper
Only in e2fsprogs-patched/debian: e2fslibs.postinst.debhelper
Only in e2fsprogs-patched/debian: e2fslibs.postrm.debhelper
Only in e2fsprogs-patched/debian: e2fslibs.substvars
Only in e2fsprogs-patched/debian: e2fsprogs
Only in e2fsprogs-patched/debian: e2fsprogs-udeb
Only in e2fsprogs-patched/debian: e2fsprogs-udeb.substvars
Only in e2fsprogs-patched/debian: e2fsprogs.substvars
Only in e2fsprogs-patched/debian: files
Only in e2fsprogs-patched/debian: files~
Only in e2fsprogs-patched/debian: libblkid-dev
Only in e2fsprogs-patched/debian: libblkid1
Only in e2fsprogs-patched/debian: libblkid1-udeb
Only in e2fsprogs-patched/debian: libblkid1-udeb.substvars
Only in e2fsprogs-patched/debian: libblkid1.postinst.debhelper
Only in e2fsprogs-patched/debian: libblkid1.postrm.debhelper
Only in e2fsprogs-patched/debian: libblkid1.substvars
Only in e2fsprogs-patched/debian: libcomerr2
Only in e2fsprogs-patched/debian: libcomerr2.postinst.debhelper
Only in e2fsprogs-patched/debian: libcomerr2.postrm.debhelper
Only in e2fsprogs-patched/debian: libcomerr2.substvars
Only in e2fsprogs-patched/debian: libss2
Only in e2fsprogs-patched/debian: libss2.postinst.debhelper
Only in e2fsprogs-patched/debian: libss2.postrm.debhelper
Only in e2fsprogs-patched/debian: libss2.substvars
Only in e2fsprogs-patched/debian: libuuid1
Only in e2fsprogs-patched/debian: libuuid1-udeb
Only in e2fsprogs-patched/debian: libuuid1-udeb.substvars
Only in e2fsprogs-patched/debian: libuuid1.postinst.debhelper
Only in e2fsprogs-patched/debian: libuuid1.postrm.debhelper
Only in e2fsprogs-patched/debian: libuuid1.substvars
diff -ur e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/debian/rules e2fsprogs-patched/debian/rules
--- e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/debian/rules	2006-11-13 02:19:40.000000000 +0100
+++ e2fsprogs-patched/debian/rules	2007-03-06 13:41:53.000000000 +0100
@@ -70,7 +70,7 @@
 INSTALL_PROGRAM = $(INSTALL) -p -o root -g root -m 0755
 
 ifeq (,$(findstring noopt,$(DEB_BUILD_OPTIONS)))
-CCOPTS += -O2
+CCOPTS += -O0
 endif
 ifeq (,$(findstring nostrip,$(DEB_BUILD_OPTIONS)))
 INSTALL_PROGRAM += -s
@@ -356,9 +356,9 @@
 		-pe2fslibs -puuid-dev -pe2fsck-static
 
 ifneq ($(ismips),)
-	dh_strip -Xlib64ext2fs-nopic.a
+	#dh_strip -Xlib64ext2fs-nopic.a
 else
-	dh_strip
+	#dh_strip
 endif
 
 	dh_compress
Only in e2fsprogs-patched/debian: ss-dev
Only in e2fsprogs-patched/debian: stampdir
Only in e2fsprogs-patched/debian: tmp
Only in e2fsprogs-patched/debian: uuid-dev
diff -ur e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/lib/blkid/devname.c e2fsprogs-patched/lib/blkid/devname.c
--- e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/lib/blkid/devname.c	2006-09-12 07:25:40.000000000 +0200
+++ e2fsprogs-patched/lib/blkid/devname.c	2007-03-06 14:00:03.000000000 +0100
@@ -305,6 +305,7 @@
 		probe_one(cache, device, dev, BLKID_PRI_DM, only_if_new);
 
 try_next:
+		free(device);
 		next = names->next;
 	} while (next);
 
diff -ur e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/lib/blkid/probe.c e2fsprogs-patched/lib/blkid/probe.c
--- e2fsprogs-1.39+1.40-WIP-2006.11.14+dfsg/lib/blkid/probe.c	2006-09-18 03:12:28.000000000 +0200
+++ e2fsprogs-patched/lib/blkid/probe.c	2007-03-06 13:55:19.000000000 +0100
@@ -888,6 +888,10 @@
 	if (!dev->bid_type) {
 		if (probe.fd >= 0) close(probe.fd);
 		blkid_free_dev(dev);
+		if (probe.sbbuf)
+			free(probe.sbbuf);
+		if (probe.buf)
+			free(probe.buf);
 		return NULL;
 	}
 		

--===============3340174789829491032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============3340174789829491032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============3340174789829491032==--
