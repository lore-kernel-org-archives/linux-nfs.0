From: domen@coderock.org
Subject: [patch 1/2] fs/vfs: replace schedule_timeout() with msleep()
Date: Sun, 06 Mar 2005 11:39:20 +0100
Message-ID: <20050306103921.112151F1F0@trashy.coderock.org>
Cc: nfs@lists.sourceforge.net, domen@coderock.org, nacc@us.ibm.com
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7tAU-0008Fm-2f
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 02:39:26 -0800
Received: from coderock.org
	([193.77.147.115] helo=trashy.coderock.org ident=postfix)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D7tAT-0006AY-Fj
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 02:39:25 -0800
To: neilb@cse.unsw.edu.au
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




Use msleep() instead of schedule_timeout() to guarantee the task
delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/fs/nfsd/vfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN fs/nfsd/vfs.c~msleep-fs_nfsd_vfs fs/nfsd/vfs.c
--- kj/fs/nfsd/vfs.c~msleep-fs_nfsd_vfs	2005-03-05 16:10:56.000000000 +0100
+++ kj-domen/fs/nfsd/vfs.c	2005-03-05 16:10:56.000000000 +0100
@@ -36,6 +36,7 @@
 #include <linux/module.h>
 #include <linux/namei.h>
 #include <linux/vfs.h>
+#include <linux/delay.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #ifdef CONFIG_NFSD_V3
@@ -968,8 +969,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 			if (atomic_read(&inode->i_writecount) > 1
 			    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
 				dprintk("nfsd: write defer %d\n", current->pid);
-				set_current_state(TASK_UNINTERRUPTIBLE);
-				schedule_timeout((HZ+99)/100);
+				msleep(10);
 				dprintk("nfsd: write resume %d\n", current->pid);
 			}
 
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
