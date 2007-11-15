From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: move cache proc (un)registration to separate
	function
Date: Thu, 15 Nov 2007 16:57:02 -0500
Message-ID: <1195163823-24609-8-git-send-email-bfields@citi.umich.edu>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-4-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-5-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-6-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-7-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195163823-24609-7-git-send-email-bfields@citi.umich.edu>
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

Just some minor cleanup.

Also I don't see much point in trying to register further proc entries
if initial entries fail; so just stop trying in that case.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/cache.c |   99 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 54 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d05ea16..504b4e8 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -290,44 +290,63 @@ static const struct file_operations cache_flush_operations;
 static void do_cache_clean(struct work_struct *work);
 static DECLARE_DELAYED_WORK(cache_cleaner, do_cache_clean);
 
-void cache_register(struct cache_detail *cd)
+void remove_cache_proc_entries(struct cache_detail *cd)
 {
-	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
-	if (cd->proc_ent) {
-		struct proc_dir_entry *p;
-		cd->proc_ent->owner = cd->owner;
-		cd->channel_ent = cd->content_ent = NULL;
+	if (cd->proc_ent == NULL)
+		return;
+	if (cd->flush_ent)
+		remove_proc_entry("flush", cd->proc_ent);
+	if (cd->channel_ent)
+		remove_proc_entry("channel", cd->proc_ent);
+	if (cd->content_ent)
+		remove_proc_entry("content", cd->proc_ent);
+	cd->proc_ent = NULL;
+	remove_proc_entry(cd->name, proc_net_rpc);
+}
 
-		p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR,
-				      cd->proc_ent);
-		cd->flush_ent =  p;
-		if (p) {
-			p->proc_fops = &cache_flush_operations;
-			p->owner = cd->owner;
-			p->data = cd;
-		}
+void create_cache_proc_entries(struct cache_detail *cd)
+{
+	struct proc_dir_entry *p;
 
-		if (cd->cache_request || cd->cache_parse) {
-			p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
-					      cd->proc_ent);
-			cd->channel_ent = p;
-			if (p) {
-				p->proc_fops = &cache_file_operations;
-				p->owner = cd->owner;
-				p->data = cd;
-			}
-		}
-		if (cd->cache_show) {
-			p = create_proc_entry("content", S_IFREG|S_IRUSR|S_IWUSR,
-					      cd->proc_ent);
-			cd->content_ent = p;
-			if (p) {
-				p->proc_fops = &content_file_operations;
-				p->owner = cd->owner;
-				p->data = cd;
-			}
-		}
+	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
+	if (cd->proc_ent == NULL)
+		return;
+	cd->proc_ent->owner = cd->owner;
+	cd->channel_ent = cd->content_ent = NULL;
+
+	p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR, cd->proc_ent);
+	cd->flush_ent = p;
+	if (p == NULL)
+		return;
+	p->proc_fops = &cache_flush_operations;
+	p->owner = cd->owner;
+	p->data = cd;
+
+	if (cd->cache_request || cd->cache_parse) {
+		p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
+				      cd->proc_ent);
+		cd->channel_ent = p;
+		if (p == NULL)
+			return;
+		p->proc_fops = &cache_file_operations;
+		p->owner = cd->owner;
+		p->data = cd;
+	}
+	if (cd->cache_show) {
+		p = create_proc_entry("content", S_IFREG|S_IRUSR|S_IWUSR,
+				      cd->proc_ent);
+		cd->content_ent = p;
+		if (p == NULL)
+			return;
+		p->proc_fops = &content_file_operations;
+		p->owner = cd->owner;
+		p->data = cd;
 	}
+}
+
+void cache_register(struct cache_detail *cd)
+{
+	create_cache_proc_entries(cd);
 	rwlock_init(&cd->hash_lock);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
@@ -358,17 +377,7 @@ void cache_unregister(struct cache_detail *cd)
 	list_del_init(&cd->others);
 	write_unlock(&cd->hash_lock);
 	spin_unlock(&cache_list_lock);
-	if (cd->proc_ent) {
-		if (cd->flush_ent)
-			remove_proc_entry("flush", cd->proc_ent);
-		if (cd->channel_ent)
-			remove_proc_entry("channel", cd->proc_ent);
-		if (cd->content_ent)
-			remove_proc_entry("content", cd->proc_ent);
-
-		cd->proc_ent = NULL;
-		remove_proc_entry(cd->name, proc_net_rpc);
-	}
+	remove_cache_proc_entries(cd);
 	if (list_empty(&cache_list)) {
 		/* module must be being unloaded so its safe to kill the worker */
 		cancel_delayed_work_sync(&cache_cleaner);
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
