Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:53153 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaAPRbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 12:31:00 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so4045259iej.17
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 09:31:00 -0800 (PST)
Subject: [PATCH v2] nfs(5): Clarify DATA AND METADATA COHERENCE section
To: steved@redhat.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 16 Jan 2014 12:30:58 -0500
Message-ID: <20140116173058.1852.86450.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |   37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2250963..55103ae 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -288,6 +288,8 @@ attributes of a regular file before it requests
 fresh attribute information from a server.
 If this option is not specified, the NFS client uses
 a 3-second minimum.
+See the DATA AND METADATA COHERENCE section
+for a full discussion of attribute caching.
 .TP 1.5i
 .BI acregmax= n
 The maximum time (in seconds) that the NFS client caches
@@ -295,6 +297,8 @@ attributes of a regular file before it requests
 fresh attribute information from a server.
 If this option is not specified, the NFS client uses
 a 60-second maximum.
+See the DATA AND METADATA COHERENCE section
+for a full discussion of attribute caching.
 .TP 1.5i
 .BI acdirmin= n
 The minimum time (in seconds) that the NFS client caches
@@ -302,6 +306,8 @@ attributes of a directory before it requests
 fresh attribute information from a server.
 If this option is not specified, the NFS client uses
 a 30-second minimum.
+See the DATA AND METADATA COHERENCE section
+for a full discussion of attribute caching.
 .TP 1.5i
 .BI acdirmax= n
 The maximum time (in seconds) that the NFS client caches
@@ -309,6 +315,8 @@ attributes of a directory before it requests
 fresh attribute information from a server.
 If this option is not specified, the NFS client uses
 a 60-second maximum.
+See the DATA AND METADATA COHERENCE section
+for a full discussion of attribute caching.
 .TP 1.5i
 .BI actimeo= n
 Using
@@ -1161,24 +1169,33 @@ perfect cache coherence among their clients.
 Perfect cache coherence among disparate NFS clients
 is expensive to achieve, especially on wide area networks.
 As such, NFS settles for weaker cache coherence that
-satisfies the requirements of most file sharing types. Normally,
-file sharing is completely sequential:
-first client A opens a file, writes something to it, then closes it;
-then client B opens the same file, and reads the changes.
-.DT
+satisfies the requirements of most file sharing types.
 .SS "Close-to-open cache consistency"
-When an application opens a file stored on an NFS server,
-the NFS client checks that it still exists on the server
+Typically file sharing is completely sequential.
+First client A opens a file, writes something to it, then closes it.
+Then client B opens the same file, and reads the changes.
+.P
+When an application opens a file stored on an NFS version 3 server,
+the NFS client checks that the file exists on the server
 and is permitted to the opener by sending a GETATTR or ACCESS request.
+The NFS client sends these requests
+regardless of the freshness of the file's cached attributes.
+.P
 When the application closes the file,
 the NFS client writes back any pending changes
 to the file so that the next opener can view the changes.
 This also gives the NFS client an opportunity to report
-any server write errors to the application
-via the return code from
+write errors to the application via the return code from
 .BR close (2).
+.P
 The behavior of checking at open time and flushing at close time
-is referred to as close-to-open cache consistency.
+is referred to as
+.IR "close-to-open cache consistency" ,
+or
+.IR CTO .
+It can be disabled for an entire mount point using the
+.B nocto
+mount option.
 .SS "Weak cache consistency"
 There are still opportunities for a client's data cache
 to contain stale data.

