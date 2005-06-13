From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] simple removal of duplicate code in init_nfsd
Date: Mon, 13 Jun 2005 14:22:10 -0700
Message-ID: <1118697729.3955.184.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhwO0-0004sm-EA
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 14:22:24 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DhwNz-0004Rs-Hk
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 14:22:24 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5DLMHui021315
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 17:22:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5DLMHZY237306
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 17:22:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5DLMGxA031253
	for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 17:22:17 -0400
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

I noticed some duplicate code in init_nfsd() that could be removed with
the following patch built against linux-2.6.12-rc6.  This then also adds
a call to nfsd_idmap_shutdown() for when init_nfsd() fails (I think CITI
may have already provided a patch that does likewise).

Signed-off-by: Bruce Allan <bruce.allan@us.ibm.com>

--- linux-2.6.12-rc6-vanilla/fs/nfsd/nfsctl.c	2005-06-06 08:22:29.000000000 -0700
+++ linux-2.6.12-rc6/fs/nfsd/nfsctl.c	2005-06-13 21:09:50.102015288 -0700
@@ -388,6 +388,21 @@ static struct file_system_type nfsd_fs_t
 	.kill_sb	= kill_litter_super,
 };
 
+static void __exit exit_nfsd(void)
+{
+	nfsd_export_shutdown();
+	nfsd_cache_shutdown();
+	remove_proc_entry("fs/nfs/exports", NULL);
+	remove_proc_entry("fs/nfs", NULL);
+	nfsd_stat_shutdown();
+	nfsd_lockd_shutdown();
+#ifdef CONFIG_NFSD_V4
+	nfsd_idmap_shutdown();
+#endif /* CONFIG_NFSD_V4 */
+	if ((&nfsd_fs_type)->next != NULL)
+		unregister_filesystem(&nfsd_fs_type);
+}
+
 static int __init init_nfsd(void)
 {
 	int retval;
@@ -407,31 +422,11 @@ static int __init init_nfsd(void)
 			entry->proc_fops =  &exports_operations;
 	}
 	retval = register_filesystem(&nfsd_fs_type);
-	if (retval) {
-		nfsd_export_shutdown();
-		nfsd_cache_shutdown();
-		remove_proc_entry("fs/nfs/exports", NULL);
-		remove_proc_entry("fs/nfs", NULL);
-		nfsd_stat_shutdown();
-		nfsd_lockd_shutdown();
-	}
+	if (retval)
+		exit_nfsd();
 	return retval;
 }
 
-static void __exit exit_nfsd(void)
-{
-	nfsd_export_shutdown();
-	nfsd_cache_shutdown();
-	remove_proc_entry("fs/nfs/exports", NULL);
-	remove_proc_entry("fs/nfs", NULL);
-	nfsd_stat_shutdown();
-	nfsd_lockd_shutdown();
-#ifdef CONFIG_NFSD_V4
-	nfsd_idmap_shutdown();
-#endif /* CONFIG_NFSD_V4 */
-	unregister_filesystem(&nfsd_fs_type);
-}
-
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
 module_init(init_nfsd)




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
