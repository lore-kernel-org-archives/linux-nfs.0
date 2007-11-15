From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: fail init on /proc/fs/nfs/exports creation
	failure
Date: Thu, 15 Nov 2007 16:57:01 -0500
Message-ID: <1195163823-24609-7-git-send-email-bfields@citi.umich.edu>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-4-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-5-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-6-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195163823-24609-6-git-send-email-bfields@citi.umich.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

I assume the reason failure of creation was ignored here was just to
continue support embedded systems that want nfsd but not proc.

However, in cases where proc is supported it would be clearer to fail
entirely than to come up with some features disabled.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   37 ++++++++++++++++++++++++++++---------
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2bfda9b..63d8075 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -674,6 +674,27 @@ static struct file_system_type nfsd_fs_type = {
 	.kill_sb	= kill_litter_super,
 };
 
+#ifdef CONFIG_PROC_FS
+static inline int create_proc_exports_entry(void)
+{
+	struct proc_dir_entry *entry;
+
+	entry = proc_mkdir("fs/nfs", NULL);
+	if (!entry)
+		return -ENOMEM;
+	entry = create_proc_entry("fs/nfs/exports", 0, NULL);
+	if (!entry)
+		return -ENOMEM;
+	entry->proc_fops =  &exports_operations;
+	return 0;
+}
+#else /* CONFIG_PROC_FS */
+static inline int create_proc_exports_entry(void)
+{
+	return 0;
+}
+#endif
+
 static int __init init_nfsd(void)
 {
 	int retval;
@@ -689,23 +710,21 @@ static int __init init_nfsd(void)
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
 	nfsd_idmap_init();      /* Name to ID mapping */
-	if (proc_mkdir("fs/nfs", NULL)) {
-		struct proc_dir_entry *entry;
-		entry = create_proc_entry("fs/nfs/exports", 0, NULL);
-		if (entry)
-			entry->proc_fops =  &exports_operations;
-	}
+	retval = create_proc_exports_entry();
+	if (retval)
+		goto out_free_idmap;
 	retval = register_filesystem(&nfsd_fs_type);
 	if (retval)
 		goto out_free_all;
 	return 0;
 out_free_all:
-	nfsd_idmap_shutdown();
-	nfsd_export_shutdown();
-	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
+	nfsd_idmap_shutdown();
+out_free_idmap:
 	nfsd_lockd_shutdown();
+	nfsd_export_shutdown();
+	nfsd_reply_cache_shutdown();
 out_free_stat:
 	nfsd_stat_shutdown();
 	nfsd4_free_slabs();
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
