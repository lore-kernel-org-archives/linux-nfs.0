From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 15 - Allow rpcsvc caches to provide a 'cache_show' method
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xa-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xd-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:05 +1100
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

This provides a /proc/sunrpc/*/content seq_file for caches to display
their content.

This code is based on the code for /proc/fs/nfs/exports



 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    5 +
 ./net/sunrpc/cache.c           |  172 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 169 insertions(+), 8 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-01-06 09:56:27.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2003-01-06 10:12:26.000000000 +1100
@@ -78,6 +78,11 @@ struct cache_detail {
 	int			(*cache_parse)(struct cache_detail *,
 					       char *buf, int len);
 
+	int			(*cache_show)(struct seq_file *m,
+					      struct cache_detail *cd,
+					      struct cache_head *h,
+					      char *pbuf);
+
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
 	 */

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-01-06 09:56:27.000000000 +1100
+++ ./net/sunrpc/cache.c	2003-01-06 10:13:36.000000000 +1100
@@ -22,6 +22,7 @@
 #include <linux/ctype.h>
 #include <asm/uaccess.h>
 #include <linux/poll.h>
+#include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/net.h>
 #include <asm/ioctls.h>
@@ -160,7 +161,8 @@ static spinlock_t cache_list_lock = SPIN
 static struct cache_detail *current_detail;
 static int current_index;
 
-struct file_operations cache_file_operations;
+static struct file_operations cache_file_operations;
+static struct file_operations content_file_operations;
 
 void cache_register(struct cache_detail *cd)
 {
@@ -169,13 +171,24 @@ void cache_register(struct cache_detail 
 		struct proc_dir_entry *p;
 		cd->proc_ent->owner = THIS_MODULE;
 		
-		p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
-				      cd->proc_ent);
-		if (p) {
-			p->proc_fops = &cache_file_operations;
-			p->owner = THIS_MODULE;
-			p->data = cd;
+		if (cd->cache_request || cd->cache_parse) {
+			p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
+					      cd->proc_ent);
+			if (p) {
+				p->proc_fops = &cache_file_operations;
+				p->owner = THIS_MODULE;
+				p->data = cd;
+			}
 		}
+ 		if (cd->cache_show) {
+ 			p = create_proc_entry("content", S_IFREG|S_IRUSR|S_IWUSR,
+ 					      cd->proc_ent);
+ 			if (p) {
+ 				p->proc_fops = &content_file_operations;
+ 				p->owner = THIS_MODULE;
+ 				p->data = cd;
+ 			}
+ 		}
 	}
 	rwlock_init(&cd->hash_lock);
 	INIT_LIST_HEAD(&cd->queue);
@@ -710,7 +723,7 @@ cache_release(struct inode *inode, struc
 
 
 
-struct file_operations cache_file_operations = {
+static struct file_operations cache_file_operations = {
 	.llseek		= no_llseek,
 	.read		= cache_read,
 	.write		= cache_write,
@@ -927,3 +940,146 @@ int qword_get(char **bpp, char *dest, in
 	*dest = '\0';
 	return len;
 }
+
+
+/*
+ * support /proc/sunrpc/cache/$CACHENAME/content
+ * as a seqfile.
+ * We call ->cache_show passing NULL for the item to
+ * get a header, then pass each real item in the cache
+ */
+
+struct handle {
+	struct cache_detail *cd;
+	char 		    *pbuf;
+};
+
+static void *c_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+	unsigned hash, entry;
+	struct cache_head *ch;
+	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	
+
+	read_lock(&cd->hash_lock);
+	if (!n--)
+		return (void *)1;
+	hash = n >> 32;
+	entry = n & ((1LL<<32) - 1);
+
+	for (ch=cd->hash_table[hash]; ch; ch=ch->next)
+		if (!entry--)
+			return ch;
+	n &= ~((1LL<<32) - 1);
+	do {
+		hash++;
+		n += 1LL<<32;
+	} while(hash < cd->hash_size && 
+		cd->hash_table[hash]==NULL);
+	if (hash >= cd->hash_size)
+		return NULL;
+	*pos = n+1;
+	return cd->hash_table[hash];
+}
+
+static void *c_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct cache_head *ch = p;
+	int hash = (*pos >> 32);
+	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+
+	if (p == (void *)1)
+		hash = 0;
+	else if (ch->next == NULL) {
+		hash++;
+		*pos += 1LL<<32;
+	} else {
+		++*pos;
+		return ch->next;
+	}
+	*pos &= ~((1LL<<32) - 1);
+	while (hash < cd->hash_size &&
+	       cd->hash_table[hash] == NULL) {
+		hash++;
+		*pos += 1LL<<32;
+	}
+	if (hash >= cd->hash_size)
+		return NULL;
+	++*pos;
+	return cd->hash_table[hash];
+}
+
+static void c_stop(struct seq_file *m, void *p)
+{
+	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	read_unlock(&cd->hash_lock);
+}
+
+static int c_show(struct seq_file *m, void *p)
+{
+	struct cache_head *cp = p;
+	struct cache_detail *cd = ((struct handle*)m->private)->cd;
+	char *pbuf = ((struct handle*)m->private)->pbuf;
+
+	if (p == (void *)1)
+		return cd->cache_show(m, cd, NULL, pbuf);
+
+	cache_get(cp);
+	if (cache_check(cd, cp, NULL))
+		return 0;
+	cache_put(cp, cd);
+
+	return cd->cache_show(m, cd, cp, pbuf);
+}
+
+struct seq_operations cache_content_op = {
+	.start	= c_start,
+	.next	= c_next,
+	.stop	= c_stop,
+	.show	= c_show,
+};
+
+static int content_open(struct inode *inode, struct file *file)
+{
+	int res;
+	char *namebuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	struct handle *han;
+	struct cache_detail *cd = PDE(inode)->data;
+
+	if (namebuf == NULL)
+		return -ENOMEM;
+
+	han = kmalloc(sizeof(*han), GFP_KERNEL);
+	if (han == NULL) {
+		kfree(namebuf);
+		return -ENOMEM;
+	}
+	han->pbuf = namebuf;
+	han->cd = cd;
+
+	res = seq_open(file, &cache_content_op);
+	if (res) {
+		kfree(namebuf);
+		kfree(han);
+	} else
+		((struct seq_file *)file->private_data)->private = han;
+
+	return res;
+}
+static int content_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m = (struct seq_file *)file->private_data;
+	struct handle *han = m->private;
+	kfree(han->pbuf);
+	kfree(han);
+	m->private = NULL;
+	return seq_release(inode, file);
+}
+
+static struct file_operations content_file_operations = {
+	.open		= content_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= content_release,
+};


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
