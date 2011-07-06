Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253Ab1GFVhj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2011 17:37:39 -0400
Date: Wed, 6 Jul 2011 17:37:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Remove obsolete linux-nfs/ documentation
Message-ID: <20110706213738.GD665@fieldses.org>
References: <20110706213321.GC665@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110706213321.GC665@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

This is all out of date.  It has some historical interest--but we can
leave that in the history.

I recently noticed that Fedora was installing this stuff to
/usr/share/doc, which can only serve to confuse users.  Other distros
may be tempted to do the same.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---

Apologies, that broke the build!  This version also removes references
to the deleted directories.

 Makefile.am           |    2 +-
 configure.ac          |    1 -
 linux-nfs/ChangeLog   |   78 ------------
 linux-nfs/INSTALL     |   11 --
 linux-nfs/KNOWNBUGS   |   37 ------
 linux-nfs/Makefile.am |    5 -
 linux-nfs/NEW         |  319 -------------------------------------------------
 linux-nfs/README      |   56 ---------
 linux-nfs/THANKS      |   10 --
 linux-nfs/TODO        |  121 -------------------
 10 files changed, 1 insertions(+), 639 deletions(-)
 delete mode 100644 linux-nfs/ChangeLog
 delete mode 100644 linux-nfs/INSTALL
 delete mode 100644 linux-nfs/KNOWNBUGS
 delete mode 100644 linux-nfs/Makefile.am
 delete mode 100644 linux-nfs/NEW
 delete mode 100644 linux-nfs/README
 delete mode 100644 linux-nfs/THANKS
 delete mode 100644 linux-nfs/TODO

diff --git a/Makefile.am b/Makefile.am
index ae7cd16..6c3993e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -2,7 +2,7 @@
 
 AUTOMAKE_OPTIONS = foreign
 
-SUBDIRS = tools support utils linux-nfs tests
+SUBDIRS = tools support utils tests
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/configure.ac b/configure.ac
index d8972e4..1686017 100644
--- a/configure.ac
+++ b/configure.ac
@@ -431,7 +431,6 @@ AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
 
 AC_CONFIG_FILES([
 	Makefile
-	linux-nfs/Makefile
 	support/Makefile
 	support/export/Makefile
 	support/include/nfs/Makefile
diff --git a/linux-nfs/ChangeLog b/linux-nfs/ChangeLog
deleted file mode 100644
index 11ffe15..0000000
--- a/linux-nfs/ChangeLog
+++ /dev/null
@@ -1,78 +0,0 @@
-
-Release 0.4.11
-
- *	Added async writes.
- *	Fixed bug where two rpciod's would be started when insmod'ing
-	both nfs.o and nfsd.o.
-
-Release 0.4.12
-
- *	Fixed compile problem after renaming some debug macros.
- *	Improved readdir cache, which can now hold up to 16 (configurable)
-	readdir replies.
- *	Fixed async write bug(s)
- *	client file locking now does at least lock/unlock without
-	crashing the machine
- *	Started to work on NFS swapping
- *	nfs_get_super no longer requires the file handle passed by
-	mount but does a straight xprt_create_proto().
- *	TCP reconnect should work now (not yet tested for long disconnect
-	periods, but it does work if you kill and restart nfsd).
-
-Release 0.4.13
-
- *	More writeback bugs removed.
- *	Added a modified (and ansified) tirpc rpcgen to get rid of all
-	the warnings in files generated from *.x descriptions. That old Sun
-	code is a real mess.
- *	Cleaned up nfsd export handling a bit. All syscalls now
-	take dev/ino rather than the pathname.
- *	Added sysctl interface to set/get debug flags (see tools/rpcdebug).
- *	Cleaned up Makefiles.
- *	(experimental) Gathered writes for nfsd (use the wdelay option in
-	/etc/exports).
- *	Fixed silly bug in nfs_readdir (the in-place decoding of readdir
-	replies requires a temporary buffer).
- *	Fixed readdir bug in nfsd (long directories were truncated).
-
-Release 0.4.14
-
- *	Upgraded to kernel 2.0.23
- *	Fixed bug in rpcdebug
- *	readdir still didn't work right in nfsd. Argh!
- *	nfsd would refuse to create symlinks with slashes in them:-)
- *	nfsd's RPC reply cache should now work again.
- *	Heavily modified rpc.statd for more robust callback/notify handling
-
-Release 0.4.17
-
- *	Upgraded to kernel 2.1.14
- *	Got lockd working with HPUX in most areas.
-
-Release 0.4.19
-
- *	RPC server UDP sockets now receive the sk_buff directly rather
-	than going through sock->ops->recvmsg.
-	Also got rid of all those cli/sti's and replaced them with
-	disable_bh/enable_bh calls.
- *	Fixed a bug in nfsd's handling of rename and friends.
-
-Release 0.4.20
-
- *	Some bugfixes, esp in the writeback code
- *	Avoid some unnecessary cli/sti pairs
- *	Added nhfsstone
-
-Release 0.4.21
-
- *	Minor bugfixes
- *	Moved to post-2.1.16 module handling code
-
-Release 0.4.22
-
- *	Fixed a bug that made rpcinfo -u host nlockmgr provoke a kernel
-	oops.
- *	Upgraded to mount-2.6b
- *	Added NFSv3 support to mountd and nfsd
- *	Made sure it compiles with glibc2.
-
diff --git a/linux-nfs/INSTALL b/linux-nfs/INSTALL
deleted file mode 100644
index 351f733..0000000
--- a/linux-nfs/INSTALL
+++ /dev/null
@@ -1,11 +0,0 @@
-
-Even though the Makefiles offer a `make install' instruction,
-I would suggest against using it yet. I have run nfsd and the nfs
-client without kernel oopses for a while, but the picture may change
-if you start playing with lockd. Automatic installation may not even
-work for the kernel makefiles yet.
-
-I'd therefore advise that you use a separate Linux box for testing
-if you have one. Use the etc/copy script to copy all modules and
-support programs, and run the ins script to start the show. rmm
-will clean up afterwards (provided you didn't trigger an oops).
diff --git a/linux-nfs/KNOWNBUGS b/linux-nfs/KNOWNBUGS
deleted file mode 100644
index b0ecd5c..0000000
--- a/linux-nfs/KNOWNBUGS
+++ /dev/null
@@ -1,37 +0,0 @@
-
-nfsd:
-
- *	We currently keep the inode in the exports struct. This is
-	a bad idea with directories that are intended to be used as
-	a mount point. Must store the file name instead and do a
-	lookup when getfh is called. Yuck!
-
-	Even yuckier: what do we do about exports matching when we
-	can't keep the inode number?
-
- *	stating a file on remote cdrom returns st_blocks == 0 for some
-	apps.
-
- *	Should allow multiple exports per dev if one of the directories
-	isn't a subdir of the other.
-
-nfsclnt:
-
- *	On some occasions, an EAGAIN reported by the transport layer
-	will be propagated to the VFS.
- *	Some operations do not seem to release the inode properly, so
-	unmounting the device fails.
-
-lockd:
-
- *	Handle portmap registration in a separate thread. portmap may
-	not be running when we try to mount the first NFS volume (esp.
-	when mounting /usr).
-
- *	Does not inform rpc.statd when hosts no longer require
-	monitoring; hosts are incorrectly monitored until next system
-	reboot.
-
-exportfs/mountd:
-
- *	Export handling is reported to do odd things at times.
diff --git a/linux-nfs/Makefile.am b/linux-nfs/Makefile.am
deleted file mode 100644
index 9c2065b..0000000
--- a/linux-nfs/Makefile.am
+++ /dev/null
@@ -1,5 +0,0 @@
-## Process this file with automake to produce Makefile.in
-
-EXTRA_DIST = ChangeLog INSTALL KNOWNBUGS NEW README THANKS TODO
-
-MAINTAINERCLEANFILES = Makefile.in
diff --git a/linux-nfs/NEW b/linux-nfs/NEW
deleted file mode 100644
index 43f5c69..0000000
--- a/linux-nfs/NEW
+++ /dev/null
@@ -1,319 +0,0 @@
-This is the Linux kernel NFS daemon 1.4.7. It is based on linux-nfs
-0.4.22. It is tested on Linux/alpha and Linux/x86 running glibc 2.1.1.
-
-WARNING: The NFS servers in Linux 2.2 to 2.2.11 are not compatible with
-other NFS client implemenations. If you plan to use Linux 2.2.x as an
-NFS server for non-Linux NFS clients, you should apply the patches
-enlosed here.
-
-linux-2.2.7-sunrpc.patch, nfsd-2.2.7-2.lockd.patch, nfsd-2.2.7-3.patch
-and nfsd-2.2.7-nfsfh.patch are required for Linux 2.2.7 to 2.2.11.
-For other kernel versions, they have to be applied by hand if they are
-still needed.
-
-For Linux 2.2.7 to 2.2.10, nfsd-2.2.7-1.lock.patch is also required.
-
-I made my knfsd package available only because I use it and noone else
-seems to maintain it. But I don't have much time to really work on it.
-I will only fix bugs in the NFS utilities and serious kernel NFS bugs
-which I can duplcate easily. If you have any kernel NFS server problem,
-please report it to the Linux kernel mailing list. If it can be
-reproduced with Linux NFS server and client in less than 5 minutes, you
-can also send me a copy in addition to sending it to the Linux kernel
-mailing list. I may take a look when I have time. However I will collect
-kernel NFS related patches. Contributions are more than welcome.
-
-The NFS lock only works with lockd. Please make sure the portmapper,
-portmap, is started before mounting NFS.
-
-Changes from knfsd 1.4.6:
-
-1. Fix a typo in knfslock.init.
-2. A new kernel patch, nfsd-2.2.7-1.lock.patch, to fix some NFS lock
-   bugs.
-
-Changes from knfsd 1.4.5:
-
-1. Rename /var/lib/nfs/xtab.export to /var/lib/nfs/etab.
-
-Changes from knfsd 1.4.4:
-
-1. Try to fix mountd performance problem by introducing
-   /var/lib/nfs/xtab.export. That is
-   
-  a. "exportfs" reads from /var/lib/nfs/xtab and writes to
-     /var/lib/nfs/xtab.export.
-  b. "mountd" reads from /var/lib/nfs/xtab.export and writes to
-     /var/lib/nfs/xtab.
-
-  The idea is "mountd" doesn't have to read /var/lib/nfs/xtab, which
-  is very expensive.
-
-Changes from knfsd 1.4.3:
-
-1. nfsd-2.2.7-nfsfh.patch, a new kernel patch for filehandle.
-2. nfsd-2.2.7-2.lockd.patch, a new patch for lockd.
-3. Misc bug fixes.
-
-Changes from knfsd 1.4.2:
-
-1. A mountd patch so that the syslog reports unknown requests, and also
-   reports *what* is being (un)mounted, from Piete Brooks
-   <Piete.Brooks@cl.cam.ac.uk>.
-2. Fix knfsd.init for restart.
-3. Add knfslock.init.
-4. knfsd-compat.spec is removed.
-5. nfsd-2.2.7-lockd.patch, a patch to start lockd independent of
-   nfs and nfsd.
-
-Changes from knfsd 1.4.1:
-
-1. Resolve symlink for umount from Piete.Brooks@cl.cam.ac.uk (Piete
-   Brooks)
-2. Fix knfsd.init for statd.
-
-Changes from knfsd 1.4:
-
-1. nfsd-2.2.7-3.patch. This is the only patch you need for Linux 2.2.7
-   to 2.2.10.
-2. Remove
-	nfsd-2.2.5-1.patch
-	nfsd-2.2.5-3.patch
-	nfsd-2.2.8-1.patch
-	nfsd-2.2.7-iget.diff
-	nfsd-2.2.5-nfsfh.diff
-	nfsd-2.2.5-file.patch
-	nfsd-2.2.7-quota.patch
-	nfsd-2.2.7-mknod.patch
-3. Statd update by Jeff Uphoff <juphoff@transmeta.com>.
-4. netgroups patch from Peter Breitenlohner <peb@mppmu.mpg.de>.
-5. Add option checking to exportfs.
-
-Changes from knfsd 1.3.3b:
-
-1. Add linux-2.2.7-sunrpc.patch for a SMP bug in sunrpc.
-2. Add --port/-P to nfsd/mountd, by Jeff Johnson <jbj@redhat.com>.
-3. Add nfsd.8, mountd.8 and statd.man, by Olaf Kirch
-   <okir@monad.swb.de>.
-4. Update nfsstat.man by Olaf Kirch <okir@monad.swb.de>.
-5. Statd fix by Jeff Uphoff <juphoff@transmeta.com>.
-6. Remove knfsd-nok.patch.
-
-Changes from knfsd 1.3.3a:
-
-1. Fix stdin/stdout/stdout handling in mountd.
-2. nfsd-2.2.7-mknod.patch. A patch for mknod.
-3. nfsd-2.2.7-quota.patch. A patch for quota.
-
-Changes from knfsd 1.3.3:
-
-1. Fix hostname matching for wildcard, subnet and netgroup.
-
-Changes from knfsd 1.3.2:
-
-1. Modified mountd to allow clients without IP address to hostname map.
-
-Changes from knfsd 1.3.1a:
-
-1. nfsd-2.2.5-3.patch. This is the only patch you need for Linux 2.2.5.
-
-Changes from knfsd 1.3.1:
-
-1. A patch for knfsd.spec from Markus Linnala <maage@cs.tut.fi>.
-
-Changes from knfsd 1.3a:
-
-1. nfsd-2.2.8-1.patch. This is the only patch you need for Linux 2.2.8.
-2. nfsd-2.2.7-2.patch. This is the only patch you need for Linux 2.2.7.
-
-Changes from knfsd 1.3:
-
-1. Adding "--no-nfs-version 3" to mountd in knfsd.init from RedHat 6.0.
-
-Changes from knfsd 1.2.2a:
-
-1. Updated knfsd.init from RedHat 6.0.
-2. nfsd-2.2.7-1.patch. This is the only patch you need for Linux 2.2.7.
-3. Misc updates from RedHat 6.0.
-
-Changes from knfsd 1.2.2:
-
-1. Make the default NFS server kernel thread to 8 in the rc script.
-
-Changes from knfsd 1.2:
-
-1. Moved knfsd.spec to knfsd-compat.spec.
-2. Update knfsd.spec from knfsd-981204-3.src.rpm.
-3. Fix the squash_[ug]id parsing in /etc/exports from Anders
-   Hammarquist <iko@cd.chalmers.se>.
-4. nfsd-2.2.5-file.patch to clear the bogus bit for MKDIR and SYMLINK.
-5. nfsd-2.2.5-1.patch. A NFS patch based on nfsd-2.2.3-1.patch for
-   Linux 2.2.5.
-
-Changes from knfsd 1.1:
-
-1. Remove
-	cache-2.1.131-1.patch
-	linux-2.1.1xx.diff
-	lock-2.1.131.diff
-	lock-2.1.1xx.diff
-	nfsd-2.1.127-5.patch
-	nullproc-2.1.1xx.diff
-	procfs-2.1.127.patch
-	quota-2.1.1xx.diff
-	root-2.1.1xx.diff
-	socket-2.1.1xx.diff
-	sunrpc-2.1.123-1.patch
-2. locks-2.2.3.diff. A patch for file lock.
-3. nfsd-2.2.3-1.patch. A NFS patch by "G. Allen Morris III"
-(gam3@acm.org).
-
-Changes from knfsd 1.0:
-
-1. Handle broken /var/lib/nfs/rmtab.
-2. Handle lower/upper cases in wildcard hostnames in /etc/exports.
-
-Changes from knfsd-981204:
-
-1. Modify etc/rc.nfsd to check /var/lib/nfs/rmtab during startup.
-2. Add knfsd.spec for RedHat 5. Need nfs-server-2.2beta37-1.1.src.rpm
-   and initscripts-3.78.1-2.src.rpm.
-3. Add support for "make install prefix=...".
-
-Changes from knfsd-981122:
-
-1. Modify etc/rc.nfsd and etc/rc.nfsfs to handle statd during shutdown.
-2. Remove maximum knfsd count checking.
-3. Clean up mountd.
-4. cache-2.1.131-1.patch from G. Allen Morris III (gam3@acm.org).
-5. lock-2.1.131.diff. A nfsd lock patch for Linux 2.1.131.
-
-Changes from knfsd-981113:
-
-1. procfs-2.1.127.patch from G. Allen Morris III (gam3@acm.org).
-2. Modify etc/rc.nfsd and etc/rc.nfsfs to better handle statd.
-3. Fix the sub-mounted directories.
-
-Changes from knfsd-981022:
-
-1. Fix buffer overruns from Peter Benie <pjb1008@cus.cam.ac.uk>.
-2. Fix hostname matching.
-3. Correctly handle dupilcations in /etc/exports.
-4. Add -F flag to statd.
-5. nfsd-2.1.127-5.patch from G. Allen Morris III (gam3@acm.org).
-
-Changes from knfsd-981014:
-
-1. lock-2.1.1xx.diff. A nfsd lock patch.
-2. nullproc-2.1.1xx.diff. Allow any clients to call the nfsd NULL proc.
-3. Add etc/rc.nfsfs to handle statd.
-3. Update etc/rc.nfsd to handle statd.
-4. nfsd-2.1.125-2.patch from G. Allen Morris III (gam3@acm.org).
-5. Fix inet_ntoa usage in statd.
-
-Changes from knfsd-981010:
-
-1. Check client aliases when matching for wildcard client hostnames.
-2. Fix memory leak in mountd.
-3. Fix filename in nfsd-2.1.125-1.patch.
-
-Changes from knfsd-980930:
-
-1. nfsd-2.1.125-1.patch from G. Allen Morris III (gam3@acm.org) and me.
-2. Fix the hostent bugs in mountd and statd.
-3. Remove "kexportfs -au" for "rc.nfsd stop".
-
-Changes from knfsd-980925:
-
-1. socket-2.1.1xx.diff for creating socket on NFS client.
-2. There is a knsfd root_squash patch for Linux 2.1.1xx,
-   root-2.1.1xx.diff. It is only tested on linux 2.1.123.
-   It also fixes the server side 0711 mode bug.
-3. sunrpc-2.1.123-1.patch from Bill Hawes <whawes@transmeta.com>.
-4. nfsd-2.1.122-3.patch from G. Allen Morris III (gam3@acm.org).
-5. Various buffer overrun changes.
-6. Fix mountd to check the duplicated entry in rmtab.
-7. Change exportfs to ignore warnings for "-r".
-8. Fix showmount -e.
-
-Changes from knfsd-980922:
-
-1. nfsd-2.1.121-4.patch from G. Allen Morris III (gam3@acm.org).
-2. Make async as default for export. It matches the user space NFS
-   server.
-
-Changes from knfsd-980920:
-
-1. Add NFS mount version flags to mountd. Change rc.nfsd to disable
-   NFS V3 for mountd.
-2. Fix client hostname.
-3. rc.nfsd runs kexportfs with -r instead of -a for restart and reload.
-
-Changes from knfsd-980915:
-
-1. There is a knsfd quota patch for Linux 2.1.1xx, quota-2.1.1xx.diff.
-   It is only tested on linux 2.1.122.
-2. The submount pathname is removed from the xtab file.
-3. rc.nfsd runs kexportfs with -r instead of -a for start.
-4. Fix kshowmount -e.
-5. Fix hostname matching.
-6. Fix compiling on libc 5.
-
-Changes from knfsd-980910:
-
-1. nfsd-2.1.121-3.patch from G. Allen Morris III (gam3@acm.org).
-2. A new flag, -r, for exportfs.
-3. Don't put an entry in xtab if kernel rejects it.
-4. Use the official hostname when checking if 2 hostnames are the same.
-5. Allow submounts.
-
-It is available at
-
-ftp://ftp.varesearch.com/pub/support/hjl/knfsd/knfsd-1.4.7.tar.gz
-ftp://ftp.varesearch.com/pub/support/hjl/knfsd/knfsd-1.4.6-1.4.7.diff.gz
-ftp://ftp.kernel.org/pub/linux/devel/gcc/knfsd-1.4.7.tar.gz
-ftp://ftp.kernel.org/pub/linux/devel/gcc/knfsd-1.4.6-1.4.7.diff.gz
-
-You have to apply the patch, locks-2.2.3.diff, to the Linux kernel
-first. It fixes quite some file lock bugs. That patch is against Linux
-2.2.3. If your kernel is different, you have to apply it by hand.
-
-nfsd-2.2.3-1.patch is a new knfsd patch against linux 2.2.3 from
-"G. Allen Morris III" (gam3@acm.org). It works for me on x86 and alpha.
-It is needed for the none-Linux NFS clients. You can get Allen's
-current patch from
-
-http://www.CSUA.Berkeley.EDU/~gam3/knfsd/
-
-nfsd-2.2.7-3.patch is based on nfsd-2.2.3-1.patch for Linux 2.2.7. If
-you use Linux 2.2.7, you should apply nfsd-2.2.7-3.patch instead of
-nfsd-2.2.3-1.patch. Please don't use any other patches included here
-for Linux 2.2.7. For other kernel versions, you may have to apply it
-by hand.
-
-nfsd-2.2.7-2.lockd.patch is also necessary to start lockd independent
-of nfs and nfsd.
-
-To compile, just do
-
-# ./configure
-# make
-
-Makefile will try to determine which C library you are using and compile
-this package accordingly.
-
-# make install
-
-will install the knfsd binaries. You have to install a knfs start up
-script by hand. There is a new rc.nfsd in etc. I use it for both the
-user-space nfsd and the kernel nfsd.
-
-There is one RPM spec file, knfs.spec, which is for a Linux system
-based on Linux 2.2 without support for Linux 2.0. You also need
-knfsd-1.4.6.tar.gz to create the knfsd RPMs.
-
-Thanks.
-
-H.J.
-hjl@lucon.org
-08/14/99
diff --git a/linux-nfs/README b/linux-nfs/README
deleted file mode 100644
index b210c61..0000000
--- a/linux-nfs/README
+++ /dev/null
@@ -1,56 +0,0 @@
-
-This package contains a greatly revised NFS implementation for Linux
-along with the necessary daemons and utilities. There are still several
-features missing that I'd want to include, and there are some recent
-improvements to the Linux NFS kernel client not reflected here (notably
-the attrtimeo fix).
-
-This thing has become much too large for me to handle all alone anymore.
-Originally, I had planned to have most of the NFS implementation running
-stably by August, so I could start to concentrate more on other jobs that
-are currently in the queue (like updating the NAG). As it turned out, it
-was much more work than I anticipated, and I fell short of my time goal.
-I'm therefore looking for volunteers who would like to work with me on
-finishing this package. Otherwise, this project could end up rusting in
-the corner of some FTP site...
-
-Ideally, I would want to hand over parts of the source tree to other
-hackers to maintain/enhance/etc. But that's not a requirement; if you
-feel you don't have that much time, you can also contribute by picking
-up one of the loose ends and finish what needs to be done (take a look
-at the TODO file...) And then, you can also be plainly a tester.
-
-There's currently a mailing list for lockd development at NRAO
-(lockd-statd@linux.nrao.edu --- mail majordomo@linux.nrao.edu to
-subscribe). If Jeff agress, we could turn this into a general linux-nfs
-mailing list.
-
-
-Hope this covers about what I wanted to say,
-Olaf
-
-------------------------------------------------------------------
-
-
-			SOURCE TREE OVERVIEW
-
-
-
-support/	Support libraries for user-space programs
-
-support/nfs	Generic library for nfsd utilities
-support/export	Manipulation of /etc/exports and /var/lib/nfs/{xtab,rmtab}
-
-utils/		Code for various user-space programs.
-utils/exportfs	Management of nfsd export table.
-utils/mount	Modified mount command to support NFS over TCP.
-utils/mountd	New rpc.mountd for kernel nfsd.
-utils/nfsd	New nfsd (just starts kernel nfsd).
-utils/nfsstat	Pretty-print NFS stats from /proc/net/rpc/nfs*
-utils/rquotad	Marco van Wieringen's rquotad
-utils/showmount	Rick Sladkey's showmount client
-utils/statd	Jeff Uphoff's rpc.statd.
-
-tools/		Support tools for developers/debuggers/testers
-tools/rpcdebug	This one sets/gets the debug flags for each of the kernel
-		modules.
diff --git a/linux-nfs/THANKS b/linux-nfs/THANKS
deleted file mode 100644
index 22a80dc..0000000
--- a/linux-nfs/THANKS
+++ /dev/null
@@ -1,10 +0,0 @@
-
-	This piece of software owes a lot to all the people who
-	hacked on Linux NFS before me, most notably Rick Sladkey
-	and Donald Becker.
-
-	I also wish to thank Holger Grothe for loaning me a hard
-	disk and a monitor to get my old 486 flying again so I have
-	a decentish test platform.
-
-	Olaf
diff --git a/linux-nfs/TODO b/linux-nfs/TODO
deleted file mode 100644
index 3a439d4..0000000
--- a/linux-nfs/TODO
+++ /dev/null
@@ -1,121 +0,0 @@
-
-Todo/Status List for Linux-NFS
-
- *	denotes to be done;
- o	denotes draft implementation, possibly commented out
- -	denotes done,
- +	denotes done and tested
-------------------------------------------------------------------
-
-RPC:
-
- *	Server-side AUTH_DES authentication
-
-NFS:
-
- *	stat() calls don't check whether the cached attrs are stil valid
-	(this is a problem in the VFS).
- -	NFS_ROOT stuff needs fixing.
- o	Swapping over NFS.
-
-	Issues of swapout:
-	 *	Avoid recursion in low memory situations where
-		kmalloc may call try_to_swap_out etc ad inf.
-	 *	Don't do async I/O on swap files.
-
-	For special-casing related to NFS swap I/O, flag swap file 
-	semantics in inode->i_flags. In swapfile.c, change functions
-	to call readpage/writepage if available, otherwise proceed
-	as usual.
-
- -	Write-back support.
- *	Disable page cache invalidation/flushing for locked file
-	regions.
- -	Directory caching (we now have page-sized dircache entries
-	which could easily be organized into a linked list). These
-	dircache pages come along as a linked list that can be copied
-	almost 1-to-1 into a dirent struct. If this is put into the
-	VFS, other remote fs's will also benefit.
-
-	[Note: I just increased the readdir cache to hold more than
-	one directory. With this, the exclusive lock on readdir goes
-	away, too. With a larger cache, it may also be worth to think
-	about directory readahead...]
- *	Better lookup caching?
- *	When a read lock is present, don't time out attr cache or
-	page cache for that region. Likewise, if a write lock is present,
-	be lazy on write-back.
- *	Implement CTO.
- -	BUG: Invalidate readdir cache after remove/rename/unlink
- *	Automatic `mounting' when the server crosses mount points
-	transparently (some IRIX machines seem to do this when
-	using -nohide).
- *	NFSv3 support. This requires careful design to maximize
-	code sharing between NFSv2 and NFSv3.
- *	More robust rename handling (see comment before nfs_rename).
- *	Add Miquel's O_EXCL hack for file creation.
- *	Performance improvement: When a complete reply is received, and
-	the (async) task is woken up, don't put it on rpciod's scheduling
-	queue, but add it to a `fast scheduler queue.' The fast scheduler
-	could be a special handler that's registered on the tq_scheduler task
-	queue. This queue is fired by the kernel scheduler as soon as
-	the other bottom halves have been run.
-
-	Note that implementing this for sync tasks is even trickier than
-	for async tasks, because you have to make sure you do the right
-	thing in rpc_sleep_on().
- *	writeback of writable mmaps. Dirty pages are not subject to
-	writeback scheduling. Also, msync should make sure pages are
-	written with O_SYNC on.
-
-
-nfsd:
-
- *	uid/gid mapping, and rpc.ugidd support
- -	Don't read/write a file that might have mandatory locks.
- *	Implement secure/kerberos export options (take care of lockd
-	fopen() calls--most clients seem to use NULL creds for lockd).
- -	there's a bug in readdir wrt large directories. Try mounting
-	the linux source tree and do an ls on include/linux...
- *	Support for UNIX socket creation.
- *	Someone should look over the error return codes. I tend to
-	mix up EPERM and EACCES.
- *	NFSv3 support.
- -	Refuse to look up inodes in procfs (security issues).
- o	Delayed writes (delay syncing of file data when nfsd handles
-	several write requests for the same file concurrently).
-	(Draft - see nfsd_write in fs/nfsd/write.c. Needs benchmarking).
- *	Faster read operations (single copy): mmap the file region
-	to be read into VM, and pass the VMA to the xdr routines
-	which pass the region's VM address into sock->ops->writemsg.
-	This copies the file data directly from the page cache into
-	the network buffer.
-	Release the vma region after encoding.
- *	Faster write operations (single copy, with IPv6 net layout):
-	Get the unfragmented UDP datagram, pull the header and
-	do normal processing. Then mmap the file, copy the write data,
-	and release VMA.
- -	Clear setuid/setgid bit after write().
- *	Quota support.
-
-lockd:
-
- *	Server should run on privileged port.
- *	Testing reclaim support.
- *	HP lockd accepts our GRANT_MSG callback and passes on the grant
-	to the blocking process, but doesn't reply with a GRANT_RES. 
-	It's not clear to me why it would do this.
- *	Unregister hosts (SM_UNMON) with rpc.statd when appropriate.
-
-mountd
-
- *	Unregister service from portmapper upon exit/SIGTERM
-
-mount
-
- *	If available, use version 3 of the mount protocol and
-	obtain pathconf data (fill in data->bsize).
-
-documentation:
-
- -	Manpages need to be written
-- 
1.7.4.1

