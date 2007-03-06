From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 2] Avoid flush-when-locking when interclient
	consistency not needed.
Date: Tue, 6 Mar 2007 16:40:29 +1100
Message-ID: <1070306054029.8360@suse.de>
References: <20070306163710.8128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOSQn-0000OT-Ts
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:41:50 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOSQp-0005V5-Hd
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 21:41:52 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


If nolock and nocto mount options are set, then the implication is
that cache consistency with other clients is not desired.  This is
likely to be the case when the filesystem is only access by the one
client - as a nfs-mounted root might be.

In that case, there is no benefit in flushing writes and invalidating
caches around lock/unlock requests.

This patch makes those flushes and invalidates conditional on either
nolock or nocto being clear.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfs/file.c |   46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff .prev/fs/nfs/file.c ./fs/nfs/file.c
--- .prev/fs/nfs/file.c	2007-03-06 16:13:00.000000000 +1100
+++ ./fs/nfs/file.c	2007-03-06 16:13:06.000000000 +1100
@@ -445,11 +445,14 @@ static int do_unlk(struct file *filp, in
 	struct inode *inode = filp->f_mapping->host;
 	int status;
 
-	/*
-	 * Flush all pending writes before doing anything
-	 * with locks..
-	 */
-	nfs_sync_mapping(filp->f_mapping);
+	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
+	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
+		/*
+		 * Flush all pending writes before doing anything
+		 * with locks..
+		 */
+		nfs_sync_mapping(filp->f_mapping);
+	}
 
 	/* NOTE: special case
 	 * 	If we're signalled while cleaning up locks on process exit, we
@@ -470,14 +473,16 @@ static int do_setlk(struct file *filp, i
 	struct inode *inode = filp->f_mapping->host;
 	int status;
 
-	/*
-	 * Flush all pending writes before doing anything
-	 * with locks..
-	 */
-	status = nfs_sync_mapping(filp->f_mapping);
-	if (status != 0)
-		goto out;
-
+	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
+	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
+		/*
+		 * Flush all pending writes before doing anything
+		 * with locks..
+		 */
+		status = nfs_sync_mapping(filp->f_mapping);
+		if (status != 0)
+			goto out;
+	}
 	lock_kernel();
 	/* Use local locking if mounted with "-onolock" */
 	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
@@ -495,12 +500,15 @@ static int do_setlk(struct file *filp, i
 	unlock_kernel();
 	if (status < 0)
 		goto out;
-	/*
-	 * Make sure we clear the cache whenever we try to get the lock.
-	 * This makes locking act as a cache coherency point.
-	 */
-	nfs_sync_mapping(filp->f_mapping);
-	nfs_zap_caches(inode);
+	if (!((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) &&
+	      (NFS_SERVER(inode)->flags & NFS_MOUNT_NOCTO))) {
+		/*
+		 * Make sure we clear the cache whenever we try to get the lock.
+		 * This makes locking act as a cache coherency point.
+		 */
+		nfs_sync_mapping(filp->f_mapping);
+		nfs_zap_caches(inode);
+	}
 out:
 	return status;
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
