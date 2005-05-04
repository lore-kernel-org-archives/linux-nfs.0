From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] tiny cleanups in nfscache.c
Date: Wed, 4 May 2005 21:36:28 +0200
Message-ID: <20050504193628.GB21618@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTPfr-0006JT-C2
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 12:36:47 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DTPfp-0002ep-Oe
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 12:36:47 -0700
To: neilb@cse.unsw.edu.au
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

--- 1.11/fs/nfsd/nfscache.c	2005-03-05 07:32:50 +01:00
+++ edited/fs/nfsd/nfscache.c	2005-03-07 06:31:01 +01:00
@@ -32,7 +32,7 @@
 #define REQHASH(xid)		((((xid) >> 24) ^ (xid)) & (HASHSIZE-1))
 
 static struct hlist_head *	hash_list;
-static struct list_head 	lru_head;
+static				LIST_HEAD(lru_head);
 static int			cache_disabled = 1;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
@@ -50,11 +50,11 @@
 	struct svc_cacherep	*rp;
 	int			i;
 
-	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
-	while(i) {
+	while (i) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp) break;
+		if (!rp)
+			break;
 		list_add(&rp->c_lru, &lru_head);
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
@@ -104,8 +104,7 @@
 static void
 lru_put_end(struct svc_cacherep *rp)
 {
-	list_del(&rp->c_lru);
-	list_add_tail(&rp->c_lru, &lru_head);
+	list_move_tail(&rp->c_lru, &lru_head);
 }
 
 /*


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
