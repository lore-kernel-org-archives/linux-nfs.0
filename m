From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] add MODULE_DESCRIPTION to nfsd module
Date: Tue, 25 Jan 2005 14:40:04 -0800
Message-ID: <1106692803.4420.32.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtZM5-0003Cg-Sv
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:40:13 -0800
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CtZM4-00074B-DD
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 14:40:13 -0800
Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0PMe6Z7565536
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 17:40:06 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0PMe51c345394
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 15:40:05 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0PMe5QZ002737
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 15:40:05 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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
with the NFS server here is a simple patch to add module description
(with link to NFS documentation) to the nfsd module.

Patch created against 2.6.11-rc2.

Signed-off-by: Bruce Allan <bwa@us.ibm.com>

diff -urp linux-2.6.11-rc2-vanilla/fs/nfsd/nfsctl.c linux-2.6.11-rc2/fs/nfsd/nfsctl.c
--- linux-2.6.11-rc2-vanilla/fs/nfsd/nfsctl.c	2004-12-24 13:34:02.000000000 -0800
+++ linux-2.6.11-rc2/fs/nfsd/nfsctl.c	2005-01-25 14:20:10.000000000 -0800
@@ -434,5 +434,6 @@ static void __exit exit_nfsd(void)
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NFS server module (http://nfs.sourceforge.net)");
 module_init(init_nfsd)
 module_exit(exit_nfsd)


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
