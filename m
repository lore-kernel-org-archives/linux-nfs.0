From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Subject: [KJ][PATCH 03/04]use set_current_state in fs
Date: Sat, 14 Apr 2007 14:19:56 +0530
Message-ID: <20070414084956.GD14084@arun.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: kernel-janitors@lists.osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcdvD-0001eU-Hr
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 01:47:51 -0700
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcdvE-0004h5-QL
	for nfs@lists.sourceforge.net; Sat, 14 Apr 2007 01:47:54 -0700
Received: by ug-out-1314.google.com with SMTP id z38so618590ugc
	for <nfs@lists.sourceforge.net>; Sat, 14 Apr 2007 01:47:51 -0700 (PDT)
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

use set_current_state(TASK_*) instead of current->state = TASK_*, in fs/nfs

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>


---
 idmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9d4a6b2..054ca15 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -272,7 +272,7 @@ nfs_idmap_id(struct idmap *idmap, struct idmap_hashtable *h,
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	mutex_unlock(&idmap->idmap_im_lock);
 	schedule();
-	current->state = TASK_RUNNING;
+	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&idmap->idmap_wq, &wq);
 	mutex_lock(&idmap->idmap_im_lock);
 
@@ -333,7 +333,7 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	mutex_unlock(&idmap->idmap_im_lock);
 	schedule();
-	current->state = TASK_RUNNING;
+	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&idmap->idmap_wq, &wq);
 	mutex_lock(&idmap->idmap_im_lock);
 
-- 
Milind Arun Choudhary

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
