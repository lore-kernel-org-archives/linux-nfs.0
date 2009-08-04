From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] statd: change default state dir to /var/lib/nfs/statd
Date: Tue, 04 Aug 2009 14:07:05 -0400
Message-ID: <20090804180704.21944.64074.stgit@matisse.1015granger.net>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58375 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933025AbZHDSI1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 14:08:27 -0400
In-Reply-To: <20090804180334.21944.64404.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.statd and friends drop root privileges when they start up.  They
set their effective UID and GID to the owner and group of the statd
state directory, which is by default /var/lib/nfs.

This directory contains a number of other objects, however, and is
usually owned by root:root.  This means if distributions aren't
careful about how nfs-utils is built, their statd will run as root
despite dropping privileges.

So change the default behavior to what Red Hat does: use a separate
subdirectory (/var/lib/nfs/statd) that can have unique ownership,
just for the state directory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac              |    4 ++--
 utils/statd/sm-notify.man |   12 ++++++------
 utils/statd/statd.man     |   10 +++++-----
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/configure.ac b/configure.ac
index e0ca70e..2b1994d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -18,9 +18,9 @@ AC_ARG_WITH(release,
 	RELEASE=1)
 	AC_SUBST(RELEASE)
 AC_ARG_WITH(statedir,
-	[  --with-statedir=/foo    use state dir /foo [/var/lib/nfs]],
+	[  --with-statedir=/foo    use state dir /foo [/var/lib/nfs/statd]],
 	statedir=$withval,
-	statedir=/var/lib/nfs)
+	statedir=/var/lib/nfs/statd)
 	AC_SUBST(statedir)
 AC_ARG_WITH(statduser,
 	[AC_HELP_STRING([--with-statduser=rpcuser],
diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index dd03b8d..69b7059 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -33,7 +33,7 @@ but this is configurable.
 For each NFS client or server machine to be monitored,
 .B rpc.statd
 creates a file in
-.BR /var/lib/nfs/sm ", "
+.BR /var/lib/nfs/statd/sm ", "
 and removes the file if monitoring is no longer required.
 .PP
 When the machine is rebooted,
@@ -47,7 +47,7 @@ Each machine has an
 which is basically an integer counter that is incremented
 each time the machine reboots. This counter is stored
 in
-.BR /var/lib/nfs/state ,
+.BR /var/lib/nfs/statd/state ,
 and updated by
 .BR sm-notify .
 .SS Security
@@ -149,13 +149,13 @@ By default,
 .B sm-notify
 forks and puts itself in the background after obtaining the
 list of hosts from
-.BR /var/lib/nfs/sm .
+.BR /var/lib/nfs/statd/sm .
 .SH FILES
-.BR /var/lib/nfs/state
+.BR /var/lib/nfs/statd/state
 .br
-.BR /var/lib/nfs/sm/*
+.BR /var/lib/nfs/statd/sm/*
 .br
-.BR /var/lib/nfs/sm.bak/*
+.BR /var/lib/nfs/statd/sm.bak/*
 .br
 .BR /var/run/sm-notify.pid
 .SH SEE ALSO
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index e8be9f3..4ed186e 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -24,7 +24,7 @@ reboots.
 For each NFS client or server machine to be monitored,
 .B rpc.statd
 creates a file in
-.BR /var/lib/nfs/sm .
+.BR /var/lib/nfs/statd/sm .
 When starting, it normally runs
 .B sm-notify
 to iterate through these files and notify the
@@ -95,7 +95,7 @@ a port may be useful when implementing a firewall.
 .BI "\-P," "" " \-\-state\-directory\-path "  directory
 specify a directory in which to place statd state information.
 If this option is not specified the default of 
-.BR /var/lib/nfs
+.BR /var/lib/nfs/statd
 is used.
 .TP
 .B -N
@@ -176,11 +176,11 @@ and send notifications to clients. This can be used in High Availability NFS
 of an NFS export from another server.
 
 .SH FILES
-.BR /var/lib/nfs/state
+.BR /var/lib/nfs/statd/state
 .br
-.BR /var/lib/nfs/sm/*
+.BR /var/lib/nfs/statd/sm/*
 .br
-.BR /var/lib/nfs/sm.bak/*
+.BR /var/lib/nfs/statd/sm.bak/*
 .SH SEE ALSO
 .BR rpc.nfsd(8),
 .BR portmap(8)

