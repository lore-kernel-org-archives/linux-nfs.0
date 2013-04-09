Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:37224 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761865Ab3DIOop (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 10:44:45 -0400
Received: by mail-ie0-f171.google.com with SMTP id e14so8575990iej.30
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2013 07:44:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs(5): Update description of sec= mount option
To: linux-nfs@vger.kernel.org
Date: Tue, 09 Apr 2013 10:44:45 -0400
Message-ID: <20130409144247.1372.3753.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan recently added SECINFO support, and I've beefed up the NFSv3
MNT processing in kernel to do some security flavor negotiation.

Thus the kernel can perform additional security flavor negotiation
now.  Update the description of the sec= mount option and the
SECURITY CONSIDERATIONS section to reflect this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   44 +++++++++++++++++++++++---------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 374ac06..a8ec46c 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -366,21 +366,22 @@ If a value of zero is specified, the
 .BR mount (8)
 command exits immediately after the first failure.
 .TP 1.5i
-.BI sec= mode
-The RPCGSS security flavor to use for accessing files on this mount point.
-If the
-.B sec
-option is not specified, or if
-.B sec=sys
-is specified, the NFS client uses the AUTH_SYS security flavor
-for all NFS requests on this mount point.
-Valid security flavors are
+.BI sec= flavor
+The security flavor to use for accessing files on this mount point.
+If the server does not support this flavor, the mount operation fails.
+If
+.B sec=
+is not specified, the client attempts to find
+a security flavor that both the client and the server supports.
+Valid
+.I flavors
+are
 .BR none ,
 .BR sys ,
 .BR krb5 ,
 .BR krb5i ,
 and
-.BR krb5p ,
+.BR krb5p .
 Refer to the SECURITY CONSIDERATIONS section for details.
 .TP 1.5i
 .BR sharecache " / " nosharecache
@@ -1444,19 +1445,19 @@ These auxiliary protocols use no authentication.
 In addition to combining these sideband protocols with the main NFS protocol,
 NFS version 4 introduces more advanced forms of access control,
 authentication, and in-transit data protection.
-The NFS version 4 specification mandates NFSv4 ACLs,
-RPCGSS authentication, and RPCGSS security flavors
+The NFS version 4 specification mandates support for
+strong authentication and security flavors
 that provide per-RPC integrity checking and encryption.
 Because NFS version 4 combines the
 function of the sideband protocols into the main NFS protocol,
 the new security features apply to all NFS version 4 operations
 including mounting, file locking, and so on.
 RPCGSS authentication can also be used with NFS versions 2 and 3,
-but does not protect their sideband protocols.
+but it does not protect their sideband protocols.
 .P
 The
 .B sec
-mount option specifies the RPCGSS security mode
+mount option specifies the security flavor
 that is in effect on a given NFS mount point.
 Specifying
 .B sec=krb5
@@ -1487,13 +1488,14 @@ Similar support for other forms of cryptographic security
 is also available.
 .P
 The NFS version 4 protocol allows
-clients and servers to negotiate among multiple security flavors
-during mount processing.
-However, Linux does not yet implement such negotiation.
-The Linux client specifies a single security flavor at mount time
-which remains in effect for the lifetime of the mount.
-If the server does not support this flavor,
-the initial mount request is rejected by the server.
+a client to renegotiate the security flavor
+when the client crosses into a new filesystem on the server.
+The newly negotiated flavor effects only accesses of the new filesystem.
+.P
+Such negotiation typically occurs when a client crosses
+from a server's pseudo-fs
+into one of the server's exported physical filesystems,
+which often have more restrictive security settings than the pseudo-fs.
 .SS "Using non-privileged source ports"
 NFS clients usually communicate with NFS servers via network sockets.
 Each end of a socket is assigned a port value, which is simply a number

