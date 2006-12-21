From: Benny Halevy <bhalevy@panasas.com>
Subject: Fwd: [PATCH] move NFS_DEBUG definition
Date: Thu, 21 Dec 2006 14:18:48 +0200
Message-ID: <458A7BA8.9060009@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GxMss-00010i-1j
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 04:18:50 -0800
Received: from gw-e.panasas.com ([65.194.124.178] helo=cassoulet.panasas.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GxMss-0006dw-94
	for nfs@lists.sourceforge.net; Thu, 21 Dec 2006 04:18:51 -0800
Received: from riverside.int.panasas.com (localhost.localdomain [127.0.0.1])
	by cassoulet.panasas.com (8.13.1/8.13.1) with ESMTP id kBLCI9XG026135
	for <nfs@lists.sourceforge.net>; Thu, 21 Dec 2006 07:18:09 -0500
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



-------- Original Message --------
Subject: [PATCH] move NFS_DEBUG definition
Date: Wed, 20 Dec 2006 22:29:46 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: nfsv4@linux-nfs.org

Trond, looks like the changes to include/linux/nfs_fs.h in 2.6.18
that moved the #include's of sunrpc header files into the #ifdef __KERNEL__ block
disabled nfs debugging for all nfs c file not including any sunrpc header.

The following patch moves the definition down, right before its use
for defining ifdebug.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>

--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -9,14 +9,6 @@
 #ifndef _LINUX_NFS_FS_H
 #define _LINUX_NFS_FS_H
 
-/*
- * Enable debugging support for nfs client.
- * Requires RPC_DEBUG.
- */
-#ifdef RPC_DEBUG
-# define NFS_DEBUG
-#endif
-
 /* Default timeout values */
 #define NFS_MAX_UDP_TIMEOUT	(60*HZ)
 #define NFS_MAX_TCP_TIMEOUT	(600*HZ)
@@ -628,6 +620,14 @@ extern void * nfs_root_data(void);
 #define NFSDBG_ODIRECT		0x1000
 #define NFSDBG_ALL		0xFFFF
 
+/*
+ * Enable debugging support for nfs client.
+ * Requires RPC_DEBUG.
+ */
+#ifdef RPC_DEBUG
+# define NFS_DEBUG
+#endif
+
 #ifdef __KERNEL__
 # undef ifdebug
 # ifdef NFS_DEBUG


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
