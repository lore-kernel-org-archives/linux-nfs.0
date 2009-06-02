From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] nfs-utils: update the nfsd manpage
Date: Tue,  2 Jun 2009 07:43:49 -0400
Message-ID: <1243943029-6400-7-git-send-email-jlayton@redhat.com>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42917 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760376AbZFBLoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 07:44:01 -0400
In-Reply-To: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some clarification about the purpose of the program, info about the
--debug option, and a note about how it behaves when TI-RPC support is
built in.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.man |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 4eb3e21..94b041e 100644
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
@@ -22,6 +23,11 @@ server provides an ancillary service needed to satisfy mount requests
 by NFS clients.
 .SH OPTIONS
 .TP
+.B \-d " or " \-\-debug
+enable debug log messages and log messages to stderr instead of syslog.
+By default, nfsd logs all messages to syslog, except for errors generated
+during option processing which go to stderr.
+.TP
 .B \-H " or " \-\-host  hostname
 specify a particular hostname (or address) that NFS requests will
 be accepted on. By default,
@@ -75,12 +81,19 @@ In particular
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
 Olaf Kirch, Bill Hawes, H. J. Lu, G. Allan Morris III,
 and a host of others.
-- 
1.6.0.6

