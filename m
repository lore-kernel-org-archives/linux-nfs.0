From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 12] Allow read access over NFS to files with APPEND bit set.
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Vi-Fz@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLiq-0006v8-9z
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:28 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLip-0004Fi-NU
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:28 -0800
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


Write access cannot safely be allowed as NFS doesn't support
append, but read access should be ok.


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-02-07 15:05:19.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-02-07 15:05:19.000000000 +1100
@@ -657,12 +657,15 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
 
-	/* Disallow access to files with the append-only bit set or
-	 * with mandatory locking enabled
+	/* Disallow write access to files with the append-only bit set
+	 * or any access when mandatory locking enabled
 	 */
 	err = nfserr_perm;
-	if (IS_APPEND(inode) || IS_ISMNDLK(inode))
+	if (IS_APPEND(inode) && (access & MAY_WRITE))
 		goto out;
+	if (IS_ISMNDLK(inode))
+		goto out;
+
 	if (!inode->i_fop)
 		goto out;
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
