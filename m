From: James Lentini <jlentini@netapp.com>
Subject: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Thu, 29 May 2008 15:40:49 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbYE2Tkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2008 15:40:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Bruce,

Below is an update to the NFS/RDMA documentation that clarifies how 
to run mount.nfs. Could you please merge this for 2.6.26?

Signed-off-by: James Lentini <jlentini@netapp.com>

--- a/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:09:38.753033000 -0400
+++ b/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:31:33.374948000 -0400
@@ -5,7 +5,7 @@
 ################################################################################
 
  Author: NetApp and Open Grid Computing
- Date: February 25, 2008
+ Date: May 29, 2008
 
 Table of Contents
 ~~~~~~~~~~~~~~~~~
@@ -242,10 +242,19 @@ NFS/RDMA Setup
 
     > modprobe xprtrdma.ko
 
-    Regardless of how the client was built (module or built-in), issue the mount.nfs command:
+    Regardless of how the client was built (module or built-in), use the mount.nfs command to 
+    mount the NFS/RDMA server.
+
+    If you have nfs-utils version 1.1.1, use this command:
 
     > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/<export> /mnt -i -o rdma,port=2050
 
+    If you have nfs-utils version 1.1.2 or later, use this command (the "-i" flag is no longer 
+    needed; the command checks the kernel's version to see if the NFS string mount API support is 
+    available):
+
+    > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/<export> /mnt -o rdma,port=2050
+
     To verify that the mount is using RDMA, run "cat /proc/mounts" and check the
     "proto" field for the given mount.
 
