From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 54] replace schedule_timeout() with msleep()
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00016v-EK@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsJ-0002B9-Kr
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:23 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsI-0007wp-Sj
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:23 -0800
To: Andrew Morton <akpm@osdl.org>
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
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-03-07 11:33:41.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-03-07 11:33:41.000000000 +1100
@@ -36,6 +36,7 @@
 #include <linux/module.h>
 #include <linux/namei.h>
 #include <linux/vfs.h>
+#include <linux/delay.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #ifdef CONFIG_NFSD_V3
@@ -969,8 +970,7 @@ nfsd_write(struct svc_rqst *rqstp, struc
 			if (atomic_read(&inode->i_writecount) > 1
 			    || (last_ino == inode->i_ino && last_dev == inode->i_sb->s_dev)) {
 				dprintk("nfsd: write defer %d\n", current->pid);
-				set_current_state(TASK_UNINTERRUPTIBLE);
-				schedule_timeout((HZ+99)/100);
+				msleep(10);
 				dprintk("nfsd: write resume %d\n", current->pid);
 			}
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
