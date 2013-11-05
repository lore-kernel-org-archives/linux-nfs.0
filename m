Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2093 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab3KETtC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Nov 2013 14:49:02 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfs.man: add description of multiple sec= options
Date: Tue, 5 Nov 2013 14:48:56 -0500
Message-ID: <1383680936-2170-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client now supports multiple sec= options as a colon delimited list.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Updated with comments from Chuck and Trond - I changed the wording and
added an example.

The example section could use some work... but I'll leave that for another day.

 utils/mount/nfs.man | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2a42b93..67031b5 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -380,9 +380,10 @@ If a value of zero is specified, the
 .BR mount (8)
 command exits immediately after the first failure.
 .TP 1.5i
-.BI sec= flavor
-The security flavor to use for accessing files on this mount point.
-If the server does not support this flavor, the mount operation fails.
+.BI sec= flavors
+A colon-separated list of one or more security flavors to use for accessing
+files on the mounted export. If the server does not support any of these
+flavors, the mount operation fails.
 If
 .B sec=
 is not specified, the client attempts to find
@@ -908,7 +909,7 @@ Here is an example from an /etc/fstab file for an NFS version 2 mount over UDP.
 	server:/export	/mnt	nfs	nfsvers=2,proto=udp	0 0
 .fi
 .P
-Try this example to mount using NFS version 4 over TCP
+This example shows how to mount using NFS version 4 over TCP
 with Kerberos 5 mutual authentication.
 .P
 .nf
@@ -916,6 +917,14 @@ with Kerberos 5 mutual authentication.
 	server:/export	/mnt	nfs4	sec=krb5	0 0
 .fi
 .P
+This example shows how to mount using NFS version 4 over TCP
+with Kerberos 5 privacy or data integrity mode.
+.P
+.nf
+.ta 8n +16n +6n +6n +30n
+	server:/export	/mnt	nfs4	sec=krb5p:krb5i	0 0
+.fi
+.P
 This example can be used to mount /usr over NFS.
 .P
 .nf
-- 
1.8.3.1 (Apple Git-46)

