From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] add MODULE_DESCRIPTION to nfs module, update NFS
 references in MAINTAINERS
Date: Tue, 25 Jan 2005 14:46:34 -0800
Message-ID: <1106692805.4420.34.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtZSN-0003ZB-7H
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:46:43 -0800
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CtZSL-0007g6-Lb
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:46:43 -0800
Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0PMkZul677518
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 17:46:35 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0PMkZpp287202
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 15:46:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0PMkZUO025644
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 15:46:35 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

To direct people to the appropriate resources when experiencing problems
with the NFS client here is a simple patch to 1) add module description
(with link to NFS documentation) to the nfs module, and 2) update the
NFS mailing list and web resources to the MAINTAINERS file.

Patch created against 2.6.11-rc2.

Signed-off-by: Bruce Allan <bwa@us.ibm.com>

diff -urp linux-2.6.11-rc2-vanilla/fs/nfs/inode.c linux-2.6.11-rc2/fs/nfs/inode.c
--- linux-2.6.11-rc2-vanilla/fs/nfs/inode.c	2005-01-24 09:17:59.000000000 -0800
+++ linux-2.6.11-rc2/fs/nfs/inode.c	2005-01-25 14:19:58.000000000 -0800
@@ -1974,6 +1974,7 @@ static void __exit exit_nfs_fs(void)
 /* Not quite true; I just maintain it */
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NFS client module (http://nfs.sourceforge.net)");
 
 module_init(init_nfs_fs)
 module_exit(exit_nfs_fs)
diff -urp linux-2.6.11-rc2-vanilla/MAINTAINERS linux-2.6.11-rc2/MAINTAINERS
--- linux-2.6.11-rc2-vanilla/MAINTAINERS	2005-01-24 09:17:40.000000000 -0800
+++ linux-2.6.11-rc2/MAINTAINERS	2005-01-25 11:29:51.000000000 -0800
@@ -1612,7 +1612,9 @@ S:	Maintained
 NFS CLIENT
 P:	Trond Myklebust
 M:	trond.myklebust@fys.uio.no
-L:	linux-kernel@vger.kernel.org
+L:	nfs@lists.sourceforge.net
+W:	http://nfs.sourceforge.net
+W:	http://linux-nfs.org
 S:	Maintained
 
 NI5010 NETWORK DRIVER


Regards,
---
Bruce Allan
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR USA



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
