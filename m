From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 10 - Allow larger writes to sunrpc/svc caches.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004B8-EY@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072M-2S
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002yv-I6
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:47 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:39 +1000
To: Andrew Morton <akpm@osdl.org>
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


We currently serialize all writes to these caches with queue_io_sem,
so we only needed one buffer.
There is some need for larger-than-one-page writes, so we can just
statically allocate a buffer.

 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./net/sunrpc/cache.c	2004-05-18 11:16:01.000000000 +1000
@@ -652,12 +652,13 @@ cache_read(struct file *filp, char *buf,
 	return err ? err :  count;
 }
 
+static char write_buf[8192]; /* protected by queue_io_sem */
+
 static ssize_t
 cache_write(struct file *filp, const char *buf, size_t count,
 	    loff_t *ppos)
 {
 	int err;
-	char *page;
 	struct cache_detail *cd = PDE(filp->f_dentry->d_inode)->data;
 
 	if (ppos != &filp->f_pos)
@@ -665,31 +666,22 @@ cache_write(struct file *filp, const cha
 
 	if (count == 0)
 		return 0;
-	if (count > PAGE_SIZE)
+	if (count >= sizeof(write_buf))
 		return -EINVAL;
 
 	down(&queue_io_sem);
 
-	page = kmalloc(PAGE_SIZE, GFP_KERNEL);
-	if (page == NULL) {
-		up(&queue_io_sem);
-		return -ENOMEM;
-	}
-
-	if (copy_from_user(page, buf, count)) {
+	if (copy_from_user(write_buf, buf, count)) {
 		up(&queue_io_sem);
-		kfree(page);
 		return -EFAULT;
 	}
-	if (count < PAGE_SIZE)
-		page[count] = '\0';
+	write_buf[count] = '\0';
 	if (cd->cache_parse)
-		err = cd->cache_parse(cd, page, count);
+		err = cd->cache_parse(cd, write_buf, count);
 	else
 		err = -EINVAL;
 
 	up(&queue_io_sem);
-	kfree(page);
 	return err ? err : count;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
