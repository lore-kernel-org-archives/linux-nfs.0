From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 022/100] nfsd: move cache proc (un)registration to separate function
Date: Fri, 25 Jan 2008 18:16:02 -0500
Message-ID: <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762133AbYAYXR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:28 -0500
In-Reply-To: <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just some minor cleanup.

Also I don't see much point in trying to register further proc entries
if initial entries fail; so just stop trying in that case.

Acked-by: NeilBrown <neilb@suse.de>
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
1.5.4.rc2.60.gb2e62

