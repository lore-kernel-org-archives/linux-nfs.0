From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 10 - Add a warning when upcalls fail,
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004Bh-UT@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072b-IM
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002W0-SC
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:40 +1000
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


.. to help the user diagnose problems caused by user-level daemons not running.

From: "J. Bruce Fields" <bfields@fieldses.org>

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    3 ++-
 ./net/sunrpc/cache.c           |   18 ++++++++++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2004-05-18 11:15:40.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2004-05-18 11:19:07.000000000 +1000
@@ -97,7 +97,8 @@ struct cache_detail {
 	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
 
 	atomic_t		readers;		/* how many time is /chennel open */
-	time_t			last_close;		/* it no readers, when did last close */
+	time_t			last_close;		/* if no readers, when did last close */
+	time_t			last_warn;		/* when we last warned about no readers */
 };
 
 

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2004-05-18 11:16:01.000000000 +1000
+++ ./net/sunrpc/cache.c	2004-05-18 11:21:24.000000000 +1000
@@ -214,6 +214,7 @@ void cache_register(struct cache_detail 
 	cd->entries = 0;
 	atomic_set(&cd->readers, 0);
 	cd->last_close = 0;
+	cd->last_warn = -1;
 	list_add(&cd->others, &cache_list);
 	spin_unlock(&cache_list_lock);
 
@@ -905,7 +906,15 @@ void qword_addhex(char **bpp, int *lp, c
 	*lp = len;
 }
 
-			
+void warn_no_listener(struct cache_detail *detail)
+{
+	if (detail->last_warn != detail->last_close) {
+		detail->last_warn = detail->last_close;
+		printk(KERN_WARNING "nfsd: nobody listening for %s upcall;"
+				" has some daemon %s?\n", detail->name,
+		      		detail->last_close?"died" : "not been started");
+	}
+}
 
 /*
  * register an upcall request to user-space.
@@ -923,9 +932,10 @@ static int cache_make_upcall(struct cach
 		return -EINVAL;
 
 	if (atomic_read(&detail->readers) == 0 &&
-	    detail->last_close < get_seconds() - 60)
-		/* nobody is listening */
-		return -EINVAL;
+	    detail->last_close < get_seconds() - 30) {
+			warn_no_listener(detail);
+			return -EINVAL;
+	}
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf)


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
