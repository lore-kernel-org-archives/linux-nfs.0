From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 18] nfsd_translate_wouldblocks
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pK-Hv@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF3-0005rg-2E
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:57 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEy-0000hL-94
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:56 -0800
To: Andrew Morton <akpm@osdl.org>
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



-EAGAIN has a special treatment in the nfsd code since it's used to indicate
that an upcall has been initiated and that a request should be dropped pending
the upcall result.

But when the break_lease functions return -EWOULDBLOCK (==-EAGAIN on most
architectures), we actually prefer to return nfserr_jukebox.  So translate
-EAGAIN returns to -ETIMEDOUT (which will be translated to nfserr_jukebox).

Undo the mapping of -EWOULDBLOCK to nfserr_jukebox, since on most architectures
that has the undesireable effect of mapping -EAGAIN to nfserr_jukebox.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsproc.c |    1 -
 ./fs/nfsd/vfs.c     |    4 ++++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-11-16 14:40:54.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2004-11-16 14:40:54.000000000 +1100
@@ -586,7 +586,6 @@ nfserrno (int errno)
 		{ nfserr_dquot, -EDQUOT },
 #endif
 		{ nfserr_stale, -ESTALE },
-		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-11-16 14:40:54.000000000 +1100
+++ ./fs/nfsd/vfs.c	2004-11-16 14:40:54.000000000 +1100
@@ -304,6 +304,8 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 		 * we need to break all leases.
 		 */
 		err = break_lease(inode, FMODE_WRITE | O_NONBLOCK);
+		if (err == -EWOULDBLOCK)
+			err = -ETIMEDOUT;
 		if (err) /* ENOMEM or EWOULDBLOCK */
 			goto out_nfserr;
 
@@ -668,6 +670,8 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	 * This may block while leases are broken.
 	 */
 	err = break_lease(inode, O_NONBLOCK | ((access & MAY_WRITE) ? FMODE_WRITE : 0));
+	if (err == -EWOULDBLOCK)
+		err = -ETIMEDOUT;
 	if (err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
