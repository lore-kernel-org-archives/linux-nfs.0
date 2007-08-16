From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Subject: [PATCH] unfsd: fix invalid argument error for setattr request
Date: Thu, 16 Aug 2007 15:41:00 +0900
Message-ID: <200708160641.AA00237@paprika.lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: moriai.satoshi@lab.ntt.co.jp, nfs@lists.sourceforge.net
To: unfsd@monad.swb.de, okir@monad.swb.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILZ2u-0003Rk-Si
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 23:41:28 -0700
Received: from tama55.ecl.ntt.co.jp ([129.60.39.103])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILZ2x-00084F-Nr
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 23:41:33 -0700
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

Hi folks, 

I found that the Linux user-space NFS server (unfsd) fails
for setattr requests against the kernel 2.6.22 and later.
For instance, it returns an invalid argument error when
overwriting an existing file by dd command as follows.

 # mount -t nfs server:/pub /nfs
 # dd if=/dev/zero of=/nfs/aaa bs=4k count=1
 1+0 records in
 1+0 records out
 4096 bytes (4.1 kB) copied, 0.000462054 seconds, 8.9 MB/s
 # dd if=/dev/zero of=/nfs/aaa bs=4k count=1
 dd: opening `/nfs/aaa': Invalid argument

I found out this is caused by the following two reasons.

(1) Since kernel 2.6.22, range checks of utimes() system call
    got more strict by an utimensat related patch
    (1c710c896eb461895d3c399e15bb5f20b39c9073)

(2) Linux NFS client uses a Sun convention for "set to current
    sever time" in which an invalid value useconds=1000000 is
    passed to server.  However, unfsd tries to use it as-is
    for changing timestamp of requested files through the 
    utimes() system call.

This patch fixes the problem by adding the Sun convention
support to unfsd.

Best regards,
---
Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

Index: nfs-user-server-2.2beta47/setattr.c
===================================================================
--- nfs-user-server-2.2beta47.orig/setattr.c	2007-08-09 17:55:14.000000000 +0900
+++ nfs-user-server-2.2beta47/setattr.c	2007-08-09 21:33:54.000000000 +0900
@@ -16,6 +16,7 @@
 #include "nfsd.h"
 
 #define IGNORE_TIME	((unsigned int) -1)
+#define SET_SERVER_TIME	1000000		/* Sun convention for "set to current server time" */
 
 /*
  * Set file attributes based on file handle
@@ -70,6 +71,17 @@
 	if (flags & SATTR_UTIMES) {
 		unsigned int	a_secs = attr->atime.seconds;
 		unsigned int	m_secs = attr->mtime.seconds;
+		unsigned int	a_usecs = attr->atime.useconds;
+		unsigned int	m_usecs = attr->mtime.useconds;
+		struct timeval	server_time;
+
+		if (a_usecs == SET_SERVER_TIME || m_usecs == SET_SERVER_TIME) {
+			gettimeofday(&server_time, NULL);
+			if (a_usecs == SET_SERVER_TIME)
+				a_secs = server_time.tv_sec;
+			if (m_usecs == SET_SERVER_TIME)
+				m_secs = server_time.tv_sec;
+		}
 
 		if ((a_secs != IGNORE_TIME && a_secs != s->st_atime)
 		 || (m_secs != IGNORE_TIME && m_secs != s->st_mtime)) {
@@ -78,19 +90,30 @@
 			/*
 			 * Cover for partial utime setting
 			 * Alan Cox <alan@redhat.com>
+			 *
+			 * Handle Sun convention for "set to current server time"
+			 * Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
 			 */
 			if (a_secs != IGNORE_TIME) {
-				tvp[0].tv_sec  = attr->atime.seconds;
-				tvp[0].tv_usec = attr->atime.useconds;
-				s->st_atime    = attr->atime.seconds;
+				if (a_usecs != SET_SERVER_TIME) {
+					tvp[0].tv_sec  = attr->atime.seconds;
+					tvp[0].tv_usec = attr->atime.useconds;
+				} else
+					tvp[0] = server_time;
+
+				s->st_atime    = a_secs;
 			} else {
 				tvp[0].tv_sec  = s->st_atime;
 				tvp[0].tv_usec = 0;
 			}
 			if (m_secs != IGNORE_TIME) {
-				tvp[1].tv_sec  = attr->mtime.seconds;
-				tvp[1].tv_usec = attr->mtime.useconds;
-				s->st_mtime    = attr->mtime.seconds;
+				if (m_usecs != SET_SERVER_TIME) {
+					tvp[1].tv_sec  = attr->mtime.seconds;
+					tvp[1].tv_usec = attr->mtime.useconds;
+				} else
+					tvp[1] = server_time;
+
+				s->st_mtime    = m_secs;
 			} else {
 				tvp[1].tv_sec  = s->st_mtime;
 				tvp[1].tv_usec = 0;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
