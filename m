From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] nfs(5): Replace the term "netid" in mount option
	descriptions
Date: Tue, 23 Sep 2008 12:16:36 -0400
Message-ID: <20080923161636.5119.54434.stgit@manray.1015granger.net>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50409 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbYIWQSu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 12:18:50 -0400
In-Reply-To: <20080923161322.5119.20872.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mike Eisler noted that the use of the term "netid" in the descriptions
of the "proto=" option is not appropriate, since Linux does not allow
"udp6" or "tcp6".

Remove the term "netid" from nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 0fc5079..b1037a8 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -411,10 +411,10 @@ for mounting the
 .B nfs
 file system type.
 .TP 1.5i
-.BI proto= netid
+.BI proto= prot
 The transport protocol used by the NFS client
 to transmit requests to the NFS server for this mount point.
-.I netid
+.I prot
 can be either
 .B udp
 or
@@ -489,11 +489,11 @@ or the server's mountd service is not available on the advertised port.
 This option can be used when mounting an NFS server
 through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
-.BI mountproto= netid
+.BI mountproto= prot
 The transport protocol used by the NFS client
 to transmit requests to the NFS server's mountd service when performing
 this mount request, and when later unmounting this mount point.
-.I netid
+.I prot
 can be either
 .B udp
 or
@@ -638,10 +638,10 @@ for mounting the
 .B nfs4
 file system type.
 .TP 1.5i
-.BI proto= netid
+.BI proto= prot
 The transport protocol used by the NFS client
 to transmit requests to the NFS server for this mount point.
-.I netid
+.I prot
 can be either
 .B udp
 or

