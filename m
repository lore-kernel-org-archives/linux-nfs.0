From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 005 of 16] nfsd4: nfs4_check_delegmode
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006de-3Z@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Ty-Ag
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0000uX-0o
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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



Additional minor code reshuffling to prepare for claim_deleg_cur support.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:38:38.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:39:12.000000000 +1000
@@ -1526,6 +1526,15 @@ out:
 	return status;
 }
 
+static inline int
+nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
+{
+	if ((flags & WR_STATE) && (dp->dl_type == NFS4_OPEN_DELEGATE_READ))
+		return nfserr_openmode;
+	else
+		return nfs_ok;
+}
+
 static struct nfs4_delegation *
 find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 {
@@ -1961,15 +1970,6 @@ out:
 }
 
 static inline int
-nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
-{
-	if ((flags & WR_STATE) && (dp->dl_type == NFS4_OPEN_DELEGATE_READ))
-		return nfserr_openmode;
-	else
-		return nfs_ok;
-}
-
-static inline int
 check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
 {
 	/* Trying to call delegreturn with a special stateid? Yuch: */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
