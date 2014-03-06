Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61778 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbaCFWDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 17:03:13 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] fix intr/nointr to match kernel behavior (ignored)
Date: Thu,  6 Mar 2014 17:02:32 -0500
Message-Id: <1394143352-26095-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/mount/nfs.man | 53 ++++++-----------------------------------------------
 1 file changed, 6 insertions(+), 47 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index ef09a31..2ab369c 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -125,6 +125,12 @@ option may mitigate some of the risks of using the
 .B soft
 option.
 .TP 1.5i
+.BR intr " / " nointr
+This option is provided for backward compatibility.
+It is ignored after kernel 2.6.25.
+System calls return EINTR if an in-progress NFS operation is interrupted by
+a signal.
+.TP 1.5i
 .BI timeo= n
 The time in deciseconds (tenths of a second) the NFS client waits for a
 response before it retries an NFS request.
@@ -668,30 +674,6 @@ Using the
 option is also required when mounting exports on NFS servers
 that do not support the NLM protocol.
 .TP 1.5i
-.BR intr " / " nointr
-Selects whether to allow signals to interrupt file operations
-on this mount point. If neither option
-is specified (or if
-.B nointr
-is specified),
-signals do not interrupt NFS file operations. If
-.B intr
-is specified, system calls return EINTR if an in-progress NFS operation is interrupted by
-a signal.
-.IP
-Using the
-.B intr
-option is preferred to using the
-.B soft
-option because it is significantly less likely to result in data corruption.
-.IP
-The
-.BR intr " / " nointr
-mount option is deprecated after kernel 2.6.25.
-Only SIGKILL can interrupt a pending NFS operation on these kernels,
-and if specified, this mount option is ignored to provide backwards
-compatibility with older kernels.
-.TP 1.5i
 .BR cto " / " nocto
 Selects whether to use close-to-open cache coherence semantics.
 If neither option is specified (or if
@@ -807,29 +789,6 @@ The mount request fails if the server's rpcbind service is not available,
 the server's NFS service is not registered with its rpcbind service,
 or the server's NFS service is not available on the advertised port.
 .TP 1.5i
-.BR intr " / " nointr
-Selects whether to allow signals to interrupt file operations
-on this mount point. If neither option is specified (or if
-.B intr
-is specified), system calls return EINTR if an in-progress NFS operation
-is interrupted by a signal.  If
-.B nointr
-is specified, signals do not
-interrupt NFS operations.
-.IP
-Using the
-.B intr
-option is preferred to using the
-.B soft
-option because it is significantly less likely to result in data corruption.
-.IP
-The
-.BR intr " / " nointr
-mount option is deprecated after kernel 2.6.25.
-Only SIGKILL can interrupt a pending NFS operation on these kernels,
-and if specified, this mount option is ignored to provide backwards
-compatibility with older kernels.
-.TP 1.5i
 .BR cto " / " nocto
 Selects whether to use close-to-open cache coherence semantics
 for NFS directories on this mount point.
-- 
1.9.0

