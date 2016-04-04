Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37322 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbcDDWIP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2016 18:08:15 -0400
Message-ID: <5702E5C2.8090007@oracle.com>
Date: Mon, 04 Apr 2016 15:08:02 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@redhat.com>
CC: leon@leon.nu, Chuck Lever <Chuck.Lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [PATCH] Documentation nfs-rdma.txt: Update nfs-rdma kernel module
 name and add IPv6 addressing option rdma6
References: <56E9A650.7060409@oracle.com> <56F19F28.9020504@Netapp.com> <5702AF3F.90500@oracle.com> <20160404195020.GH5264@leon.nu> <5702CD3B.4030207@oracle.com>
In-Reply-To: <5702CD3B.4030207@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update NFS/RDMA transport module name from client xprtrdma,
server svcrdma to rpcrdma which supports both server and client.
Add mount proto option rdma6 to use IPv6 addressing for NFS/RDMA.

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
---

 Documentation/filesystems/nfs/nfs-rdma.txt | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs-rdma.txt b/Documentation/filesystems/nfs/nfs-rdma.txt
index 1e65645..6101b57 100644
--- a/Documentation/filesystems/nfs/nfs-rdma.txt
+++ b/Documentation/filesystems/nfs/nfs-rdma.txt
@@ -238,12 +238,13 @@ NFS/RDMA Setup
 
   - Start the NFS server
 
-    If the NFS/RDMA server was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in
-    kernel config), load the RDMA transport module:
+    If the NFS/RDMA was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in
+    kernel config), load the RDMA transport module which supports both client
+    and server:
 
-    $ modprobe svcrdma
+    $ modprobe rpcrdma
 
-    Regardless of how the server was built (module or built-in), start the
+    Regardless of how the rpcrdma was built (module or built-in), start the
     server:
 
     $ /etc/init.d/nfs start
@@ -258,15 +259,14 @@ NFS/RDMA Setup
 
   - On the client system
 
-    If the NFS/RDMA client was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in
-    kernel config), load the RDMA client module:
+    Regardless of how rpcrdma was built (module or built-in), use this command
+    to mount the NFS/RDMA server through IPv4 addressing:
 
-    $ modprobe xprtrdma.ko
+    $ mount -o rdma,port=20049 <IPoIB-server-name-or-IPv4-address>:/<export> /mnt
 
-    Regardless of how the client was built (module or built-in), use this
-    command to mount the NFS/RDMA server:
+    or through IPv6 addressing
 
-    $ mount -o rdma,port=20049 <IPoIB-server-name-or-address>:/<export> /mnt
+    $ mount -o rdma6,port=20049 [<IPoIB-server-name-or-IPv6-address>]:/<export> /mnt
 
     To verify that the mount is using RDMA, run "cat /proc/mounts" and check
     the "proto" field for the given mount.
