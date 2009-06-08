From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 11/11] nfs-utils: update the nfsd manpage and copyright notices
Date: Mon,  8 Jun 2009 14:00:44 -0400
Message-ID: <1244484044-21355-12-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48172 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbZFHSBC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:01:02 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some clarification about the purpose of the program, info about the
--debug and --syslog options, and a note about how it behaves when
TI-RPC support is built in.

Also update copyright messages for the files under utils/nfsd.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c   |    1 +
 utils/nfsd/nfsd.man |   27 +++++++++++++++++++++++----
 utils/nfsd/nfssvc.c |    1 +
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 650c593..53f9bbb 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -5,6 +5,7 @@
  * all the work is now done in the kernel module.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ * Copyright (c) 2009 Jeff Layton <jlayton@redhat.com>
  */
 
 #ifdef HAVE_CONFIG_H
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 4eb3e21..2c8f7f9 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -13,8 +13,9 @@ The
 program implements the user level part of the NFS service. The
 main functionality is handled by the
 .B nfsd
-kernel module; the user space program merely starts the specified
-number of kernel threads.
+kernel module. The user space program merely specifies what sort of sockets
+the kernel service should listen on, what NFS versions it should support, and
+how many kernel threads it should use.
 .P
 The
 .B rpc.mountd
@@ -22,6 +23,9 @@ server provides an ancillary service needed to satisfy mount requests
 by NFS clients.
 .SH OPTIONS
 .TP
+.B \-d " or " \-\-debug
+enable logging of debugging messages
+.TP
 .B \-H " or " \-\-host  hostname
 specify a particular hostname (or address) that NFS requests will
 be accepted on. By default,
@@ -45,6 +49,14 @@ does not offer certain versions of NFS. The current version of
 .B rpc.nfsd
 can support both NFS version 2,3 and the newer version 4.
 .TP
+.B \-s " or " \-\-syslog
+By default,
+.B rpc.nfsd
+logs error messages (and debug messages, if enabled) to stderr. This option makes 
+.B rpc.nfsd
+log these messages to syslog instead. Note that errors encountered during
+option processing will still be logged to stderr regardless of this option.
+.TP
 .B \-T " or " \-\-no-tcp
 Disable 
 .B rpc.nfsd 
@@ -75,12 +87,19 @@ In particular
 .B rpc.nfsd 0
 will stop all threads and thus close any open connections.
 
+.SH NOTES
+If the program is built with TI-RPC support, it will enable any protocol and
+address family combinations that are marked visible in the
+.B netconfig
+database.
+
 .SH SEE ALSO
 .BR rpc.mountd (8),
 .BR exports (5),
 .BR exportfs (8),
 .BR rpc.rquotad (8),
-.BR nfsstat (8).
+.BR nfsstat (8),
+.BR netconfig(5).
 .SH AUTHOR
-Olaf Kirch, Bill Hawes, H. J. Lu, G. Allan Morris III,
+Olaf Kirch, Bill Hawes, H. J. Lu, G. Allan Morris III, Jeff Layton
 and a host of others.
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index ee862b2..c2e90c4 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -4,6 +4,7 @@
  * Run an NFS daemon.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ * Copyright (c) 2009 Jeff Layton <jlayton@redhat.com>
  */
 
 #ifdef HAVE_CONFIG_H
-- 
1.6.0.6

