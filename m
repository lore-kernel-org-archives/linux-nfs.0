From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 15 - Provide 'flush' interface for userspace to flush rpc/svc caches
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xk-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xi-00
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

Userspace can with a time (seconds since epoch) to
  /proc/net/rpc/*/epoch
and all entries created earlier than that time will be flushed.


 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-01-06 10:14:30.000000000 +1100
+++ ./net/sunrpc/cache.c	2003-01-06 10:15:18.000000000 +1100
@@ -163,6 +163,7 @@ static int current_index;
 
 static struct file_operations cache_file_operations;
 static struct file_operations content_file_operations;
+static struct file_operations cache_flush_operations;
 
 void cache_register(struct cache_detail *cd)
 {
@@ -171,6 +172,14 @@ void cache_register(struct cache_detail 
 		struct proc_dir_entry *p;
 		cd->proc_ent->owner = THIS_MODULE;
 		
+ 		p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR,
+ 				      cd->proc_ent);
+ 		if (p) {
+ 			p->proc_fops = &cache_flush_operations;
+ 			p->owner = THIS_MODULE;
+ 			p->data = cd;
+ 		}
+ 
 		if (cd->cache_request || cd->cache_parse) {
 			p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
 					      cd->proc_ent);
@@ -1083,3 +1092,53 @@ static struct file_operations content_fi
 	.llseek		= seq_lseek,
 	.release	= content_release,
 };
+
+static ssize_t read_flush(struct file *file, char *buf,
+			    size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(file->f_dentry->d_inode)->data;
+	char tbuf[20];
+	unsigned long p = *ppos;
+	int len;
+
+	sprintf(tbuf, "%lu\n", cd->flush_time);
+	len = strlen(tbuf);
+	if (p >= len)
+		return 0;
+	len -= p;
+	if (len > count) len = count;
+	if (copy_to_user(buf, (void*)(tbuf+p), len))
+		len = -EFAULT;
+	else
+		*ppos += len;
+	return len;
+}
+
+static ssize_t write_flush(struct file * file, const char * buf,
+			     size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(file->f_dentry->d_inode)->data;
+	char tbuf[20];
+	char *ep;
+	long flushtime;
+	if (*ppos || count > sizeof(tbuf)-1)
+		return -EINVAL;
+	if (copy_from_user(tbuf, buf, count))
+		return -EFAULT;
+	tbuf[count] = 0;
+	flushtime = simple_strtoul(tbuf, &ep, 0);
+	if (*ep && *ep != '\n')
+		return -EINVAL;
+
+	cd->flush_time = flushtime;
+	cd->nextcheck = get_seconds();
+	cache_flush();
+
+	*ppos += count;
+	return count;
+}
+
+static struct file_operations cache_flush_operations = {
+	.read		= read_flush,
+	.write		= write_flush,
+};


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
