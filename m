From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 18 of 54] nfsd4: simplify open_delegation
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00017x-LA@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrl-00026U-Mh
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrl-0007so-2K
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
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



The DONT_DELEGATE flag is superfluous.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:12.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:55.000000000 +1100
@@ -1522,8 +1522,6 @@ nfs4_deleg_conflict(u32 share, u32 dtype
 		dtype == NFS4_OPEN_DELEGATE_WRITE));
 }
 
-#define DONT_DELEGATE  8
-
 /*
  * nfs4_check_deleg_recall()
  *
@@ -1544,7 +1542,7 @@ nfs4_check_deleg_recall(struct nfs4_file
 			if(nfs4_deleg_conflict(op->op_share_access, dp->dl_type))
 				status = nfserr_jukebox;
 			else
-				*flag = DONT_DELEGATE;
+				*flag = NFS4_OPEN_DELEGATE_NONE;
 		}
 	}
 	return status;
@@ -1663,10 +1661,8 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	struct file_lock fl, *flp = &fl;
 	int status;
 
-	if (*flag == DONT_DELEGATE) {
-		*flag = NFS4_OPEN_DELEGATE_NONE;
+	if (*flag == NFS4_OPEN_DELEGATE_NONE)
 		return;
-	}
 
 	/* set flag */
 	*flag = NFS4_OPEN_DELEGATE_NONE;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
