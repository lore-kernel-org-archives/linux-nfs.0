From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 9] nfsd4 could leak a stateid in an error path
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-000436-Hg@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-000050-FM
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uM-0004TP-SV
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



nfsd4 could leak a stateid in a case of kmalloc failure; fix.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-03 11:57:20.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-03 11:57:34.000000000 +1000
@@ -2153,8 +2153,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, open_sop->so_client, open_stp, lock)))
 			goto out;
 		if ((lock_stp = alloc_init_lock_stateid(lock->lk_stateowner, 
-						fp, open_stp)) == NULL)
+						fp, open_stp)) == NULL) {
+			release_stateowner(lock->lk_stateowner);
 			goto out;
+		}
 		/* bump the open seqid used to create the lock */
 		open_sop->so_seqid++;
 	} else {


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
