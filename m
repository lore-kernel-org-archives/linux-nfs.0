From: Olaf Hering <olh@suse.de>
Subject: [PATCH] hide kernel includes in include/linux/nfs.h
Date: Sun, 20 Feb 2005 22:36:47 +0100
Message-ID: <20050220213647.GB21877@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2yl3-0002ZU-LI
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 13:36:53 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D2yl2-0005oY-38
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 13:36:53 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net
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


msg_prot.h and string.h have both kernel only content. I want to get to
the point were klibc can be shipped standalone with only a few required
headers. This patch shrinks the header file list to include.
It changes also a #ifdef, so unifdef can do its job.


Signed-off-by: Olaf Hering <olh@suse.de>

diff -purN linux-2.6.11-rc4.orig/include/linux/nfs.h linux-2.6.11-rc4-klibc/include/linux/nfs.h
--- linux-2.6.11-rc4.orig/include/linux/nfs.h	2005-02-13 04:07:01.000000000 +0100
+++ linux-2.6.11-rc4-klibc/include/linux/nfs.h	2005-02-20 17:03:31.814003771 +0100
@@ -7,9 +7,6 @@
 #ifndef _LINUX_NFS_H
 #define _LINUX_NFS_H
 
-#include <linux/sunrpc/msg_prot.h>
-#include <linux/string.h>
-
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
 #define NFS_MAXDATA	8192
@@ -129,7 +126,11 @@ enum nfs_ftype {
 	NFFIFO = 8
 };
 
-#if defined(__KERNEL__)
+#ifdef __KERNEL__
+
+#include <linux/sunrpc/msg_prot.h>
+#include <linux/string.h>
+
 /*
  * This is the kernel NFS client file handle representation
  */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
