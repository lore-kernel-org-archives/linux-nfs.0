From: Steven Cole <elenstev@mesatop.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.4
Date: 14 Jul 2003 13:34:47 -0600
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1058211287.4451.41.camel@spc9.esa.lanl.gov>
References: <1030714170001.24267@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Janusz Niewiadomski <funkysh@isec.pl>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Neil F. Brown" <neilb@cse.unsw.edu.au>
In-Reply-To: <1030714170001.24267@cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2003-07-14 at 11:00, Neil F. Brown wrote:
> This release of nfs-utils contains:
> 
>  1/ Fix for a remotely exploitable buffer-overflow bug.
>  2/ assorted minor bug fixes
>  3/ Extensive changes to make use of new functionality in linux-2.6.0 nfsd
> 
> nfs-utils 1.0.4 can be downloaded from 
>   http://sourceforge.net/project/showfiles.php?group_id=14
> or
>   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
> 
> I consider this release to be a pre-release for 1.1.0 which I hope to
> release before linux-2.6.0-final.  Bug reports are very welcome.

Although it may be a month or three until 2.6.0-final, here is an update
to Documentation/Changes and scripts/ver_linux for nfs-utils.

Your information should be preserved somewhere, and
Documentation/Changes should be one of first places people look when
moving from 2.4 to 2.6.

I moved the nfs-utils table entry up a couple of rows to group it with
other network related items.

If this patch looks OK, please send it upstream.  Otherwise, please fix
and send.

Steven

diff -ur 2.5-bk-current/Documentation/Changes 2.5-linux/Documentation/Changes
--- 2.5-bk-current/Documentation/Changes	Mon Jul 14 12:48:38 2003
+++ 2.5-linux/Documentation/Changes	Mon Jul 14 13:03:05 2003
@@ -61,9 +61,9 @@
 o  quota-tools            3.09                    # quota -V
 o  PPP                    2.4.0                   # pppd --version
 o  isdn4k-utils           3.1pre1                 # isdnctrl 2>&1|grep version
+o  nfs-utils              1.0.4                   # showmount --version
 o  procps                 2.0.9                   # ps --version
 o  oprofile               0.5.3                   # oprofiled --version
-o  nfs-utils              1.0.3                   # showmount --version
 
 Kernel compilation
 ==================
@@ -280,6 +280,33 @@
 Due to changes in the length of the phone number field, isdn4k-utils
 needs to be recompiled or (preferably) upgraded.
 
+NFS-utils
+---------
+
+In 2.4 and earlier kernels, the nfs server needed to know about any
+client that expected to be able to access files via NFS.  This
+information would be given to the kernel by "mountd" when the client
+mounted the filesystem, or by "exportfs" at system startup.  exportfs
+would take information about active clients from /var/lib/nfs/rmtab.
+
+This approach is quite fragile as it depends on rmtab being correct
+which is not always easy, particularly when trying to implement
+fail-over.  Even when the system is working well, rmtab suffers from
+getting lots of old entries that never get removed.
+
+With 2.6 we have the option of having the kernel tell mountd when it
+gets a request from an unknown host, and mountd can give appropriate
+export information to the kernel.  This removes the dependency on
+rmtab and means that the kernel only needs to know about currently
+active clients.
+
+To enable this new functionality, you need to:
+
+  mount -t nfsd nfsd /proc/fs/nfs
+
+before running exportfs or mountd.  It is recommended that all NFS
+services be protected from the internet-at-large where that is possible.
+
 Getting updated software
 ========================
 
@@ -368,6 +395,10 @@
 ------------
 o  <ftp://ftp.isdn4linux.de/pub/isdn4linux/utils/isdn4k-utils.v3.1pre1.tar.gz>
 
+NFS-utils
+---------
+o  <http://sourceforge.net/project/showfiles.php?group_id=14>
+
 Netfilter
 ---------
 o  <http://netfilter.filewatcher.org/iptables-1.2.tar.bz2>
Only in 2.5-linux/Documentation: x
diff -ur 2.5-bk-current/scripts/ver_linux 2.5-linux/scripts/ver_linux
--- 2.5-bk-current/scripts/ver_linux	Mon Jul 14 12:48:09 2003
+++ 2.5-linux/scripts/ver_linux	Mon Jul 14 12:51:19 2003
@@ -54,6 +54,9 @@
 isdnctrl 2>&1 | grep version | awk \
 'NR==1{print "isdn4k-utils          ", $NF}'
 
+showmount --version 2>&1 | grep showmount | awk \
+'NR==1{print "nfs-utils             ", $NF}'
+
 ls -l `ldd /bin/sh | awk '/libc/{print $3}'` | sed \
 -e 's/\.so$//' | awk -F'[.-]'   '{print "Linux C Library        " \
 $(NF-2)"."$(NF-1)"."$NF}'
