From: Olaf Hering <olh@suse.de>
Subject: [PATCH] remove unneeded ext2 include from nfsd
Date: Sun, 13 Feb 2005 16:52:57 +0100
Message-ID: <20050213155257.GA21488@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D0M3U-0001qV-FQ
	for nfs@lists.sourceforge.net; Sun, 13 Feb 2005 07:53:04 -0800
Received: from news.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D0M3R-0004Zh-Oh
	for nfs@lists.sourceforge.net; Sun, 13 Feb 2005 07:53:04 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
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


nfs3proc.c includes ext2 headers for some constants, strange.
vfs.c does the same, but doesnt use anything from this header.


Signed-off-by: Olaf Hering <olh@suse.de>

diff -purNx tags ../linux-2.6.11-rc4.orig/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- ../linux-2.6.11-rc4.orig/fs/nfsd/vfs.c	2005-02-13 04:06:05.000000000 +0100
+++ ./fs/nfsd/vfs.c	2005-02-13 16:00:07.702972643 +0100
@@ -24,7 +24,6 @@
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/major.h>
-#include <linux/ext2_fs.h>
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/fcntl.h>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
