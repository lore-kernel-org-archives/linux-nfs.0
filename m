From: Olaf Kirch <okir@suse.de>
Subject: nfsd write throughput
Date: Mon, 2 Aug 2004 18:24:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040802162448.GB21365@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Brfip-00045I-Uh
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 09:31:35 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Brfip-0005jv-Af
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 09:31:35 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 2716F9AB6FF
	for <nfs@lists.sourceforge.net>; Mon,  2 Aug 2004 18:24:49 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I've been looking at the write throughput with NFSv3, and played around
a little. Here's a patch that seems to increase iozone's write throughput
from 6MB/s to close to 10MB/s on my test machine.

(The improvement in rewrite throughput is less pronounced). I'm still
doing some testing on this, but I would still appreciate some feedback,
especially from people seeing throughput problems.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfsd-write-speedup

Index: linux-2.6.5/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.5.orig/fs/nfsd/vfs.c	2004-08-02 14:48:02.000000000 +0200
+++ linux-2.6.5/fs/nfsd/vfs.c	2004-08-02 17:54:28.000000000 +0200
@@ -45,6 +45,7 @@
 #include <linux/quotaops.h>
 #include <linux/dnotify.h>
 #include <linux/xattr_acl.h>
+#include <linux/backing-dev.h>
 
 #include <asm/uaccess.h>
 
@@ -810,6 +811,22 @@
 		}
 		last_ino = inode->i_ino;
 		last_dev = inode->i_sb->s_dev;
+	} else if (err >= 0 && !stable) {
+		/* If we've been writing several pages, schedule them
+		 * for the disk immediately. The client may be streaming
+		 * and we don't want to hang on a huge journal sync when the
+		 * commit comes in
+		 */
+		struct address_space	*mapping;
+
+		/* This assumes a minimum page size of 1K, and will issue
+		 * a filemap_flushfast call every 64 pages written by the
+		 * client. */
+		if ((cnt & 1023) == 0
+		 && ((offset / cnt) & 63) == 0
+		 && (mapping = inode->i_mapping) != NULL
+		 && !bdi_write_congested(mapping->backing_dev_info))
+			filemap_flushfast(mapping);
 	}
 
 	dprintk("nfsd: write complete err=%d\n", err);

--cNdxnHkX5QqsyA0e--


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
