From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH]  Fix readahead handling in knfsd.
Date: Tue, 01 Jun 2004 11:22:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BUxzR-0007Qr-TS@notabene.cse.unsw.edu.au>
References: <20040601112157.28553.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUxzY-0008Vn-J5
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 18:23:00 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUxzY-00078r-5z
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 18:23:00 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 1 Jun 2004 11:22:54 +1000
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


The read-ahead structures were not being initialised
properly, and were not having the use-count decremented
after use, making them fairly useless (since Apr 2002!).

From: Colin Gibbs <colin@gibbsonline.net>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-06-01 11:20:45.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-06-01 10:08:51.000000000 +1000
@@ -567,7 +567,7 @@ nfsd_sync_dir(struct dentry *dp)
 static spinlock_t ra_lock = SPIN_LOCK_UNLOCKED;
 
 static inline struct raparms *
-nfsd_get_raparms(dev_t dev, ino_t ino)
+nfsd_get_raparms(dev_t dev, ino_t ino, struct address_space *mapping)
 {
 	struct raparms	*ra, **rap, **frap = NULL;
 	int depth = 0;
@@ -589,7 +589,7 @@ nfsd_get_raparms(dev_t dev, ino_t ino)
 	ra = *frap;
 	ra->p_dev = dev;
 	ra->p_ino = ino;
-	memset(&ra->p_ra, 0, sizeof(ra->p_ra));
+	file_ra_state_init(&ra->p_ra, mapping);
 found:
 	if (rap != &raparm_cache) {
 		*rap = ra->p_next;
@@ -661,7 +661,8 @@ nfsd_read(struct svc_rqst *rqstp, struct
 #endif
 
 	/* Get readahead parameters */
-	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
+	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino, 
+			      inode->i_mapping->host->i_mapping);
 	if (ra)
 		file.f_ra = ra->p_ra;
 
@@ -677,9 +678,12 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	}
 
 	/* Write back readahead params */
-	if (ra)
+	if (ra) {
+		spin_lock(&ra_lock);
 		ra->p_ra = file.f_ra;
-
+		ra->p_count--;
+		spin_unlock(&ra_lock);
+	}
 	if (err >= 0) {
 		nfsdstats.io_read += err;
 		*count = err;


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
