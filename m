From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 8 - Use schedule_work to regular cache cleaning
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qg-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhx-0007Rk-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:13 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:54:58 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Cleaning of the export caches is currently done by idle
nfsd threads which isn't very reliable.

This patch makes use of work_queues to do it all inside
cache.c


 ----------- Diffstat output ------------
 ./fs/nfsd/nfssvc.c   |    4 ++--
 ./net/sunrpc/cache.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2003-06-24 15:49:35.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2003-06-24 15:50:30.000000000 +1000
@@ -209,8 +209,8 @@ nfsd(struct svc_rqst *rqstp)
 		 * recvfrom routine.
 		 */
 		while ((err = svc_recv(serv, rqstp,
-				       5*60*HZ)) == -EAGAIN)
-			cache_clean();
+				       60*60*HZ)) == -EAGAIN)
+			;
 		if (err < 0)
 			break;
 		update_thread_usage(atomic_read(&nfsd_busy));

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-06-24 14:09:03.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-06-24 16:27:26.000000000 +1000
@@ -25,6 +25,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/net.h>
+#include <linux/workqueue.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -165,6 +166,9 @@ static struct file_operations cache_file
 static struct file_operations content_file_operations;
 static struct file_operations cache_flush_operations;
 
+static void do_cache_clean(void *data);
+static DECLARE_WORK(cache_cleaner, do_cache_clean, NULL);
+
 void cache_register(struct cache_detail *cd)
 {
 	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
@@ -208,6 +212,9 @@ void cache_register(struct cache_detail 
 	cd->last_close = 0;
 	list_add(&cd->others, &cache_list);
 	spin_unlock(&cache_list_lock);
+
+	/* start the cleaning process */
+	schedule_work(&cache_cleaner);
 }
 
 int cache_unregister(struct cache_detail *cd)
@@ -229,6 +236,11 @@ int cache_unregister(struct cache_detail
 		cd->proc_ent = NULL;
 		remove_proc_entry(cd->name, proc_net_rpc);
 	}
+	if (list_empty(&cache_list)) {
+		/* module must be being unloaded so its safe to kill the worker */
+		cancel_delayed_work(&cache_cleaner);
+		flush_scheduled_work();
+	}
 	return 0;
 }
 
@@ -341,6 +353,23 @@ int cache_clean(void)
 	return rv;
 }
 
+/*
+ * We want to regularly clean the cache, so we need to schedule some work ...
+ */
+static void do_cache_clean(void *data)
+{
+	int delay = 5;
+	if (cache_clean() == -1)
+		delay = 30*HZ;
+
+	if (list_empty(&cache_list))
+		delay = 0;
+
+	if (delay)
+		schedule_delayed_work(&cache_cleaner, delay);
+}
+
+
 /* 
  * Clean all caches promptly.  This just calls cache_clean
  * repeatedly until we are sure that every cache has had a chance to 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
