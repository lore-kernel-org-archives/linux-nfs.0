From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 9] Calls to break_lease in nfsd should be O_NONBLOCKing.
Date: Fri, 03 Sep 2004 12:34:25 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uD-00042m-VA@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-000053-Ng
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uM-0004Sw-SU
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
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


If we would block, we return "err-jukebox" for nfsv3,
or just drop the request for v2.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsproc.c |    1 +
 ./fs/nfsd/nfssvc.c  |    2 ++
 ./fs/nfsd/vfs.c     |    8 ++++----
 3 files changed, 7 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-09-03 11:34:26.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2004-09-03 11:34:29.000000000 +1000
@@ -586,6 +586,7 @@ nfserrno (int errno)
 		{ nfserr_dquot, -EDQUOT },
 #endif
 		{ nfserr_stale, -ESTALE },
+		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2004-09-03 11:34:26.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2004-09-03 11:34:29.000000000 +1000
@@ -328,6 +328,8 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	if (nfserr == nfserr_jukebox && rqstp->rq_vers == 2)
+		nfserr = nfserr_dropit;
 	if (nfserr == nfserr_dropit) {
 		dprintk("nfsd: Dropping request due to malloc failure!\n");
 		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-09-03 11:34:26.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-09-03 11:34:29.000000000 +1000
@@ -303,8 +303,8 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 		 * If we are changing the size of the file, then
 		 * we need to break all leases.
 		 */
-		err = break_lease(inode, FMODE_WRITE);
-		if (err)
+		err = break_lease(inode, FMODE_WRITE | O_NONBLOCK);
+		if (err) /* ENOMEM or EWOULDBLOCK */
 			goto out_nfserr;
 
 		err = get_write_access(inode);
@@ -669,8 +669,8 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	 * Check to see if there are any leases on this file.
 	 * This may block while leases are broken.
 	 */
-	err = break_lease(inode, (access & MAY_WRITE) ? FMODE_WRITE : 0);
-	if (err)
+	err = break_lease(inode, O_NONBLOCK | ((access & MAY_WRITE) ? FMODE_WRITE : 0));
+	if (err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 
 	if (access & MAY_WRITE) {


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
