From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 22 of 54] nfsd4: fix nfs4_check_delegmode()
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00018D-Rt@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrp-00027V-F0
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xro-0007tO-VC
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
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



Inline nfs4_check_delegmode, replace & by &&, remove incorrect check. (Note
that it's fine to read using the stateid for a write delegation.)

While we're at it, the status return logic seems like overkill for one simple
check.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:56.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:57.000000000 +1100
@@ -1969,18 +1969,13 @@ out:
 	return status;
 }
 
-static int
+static inline int
 nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
 {
-	int status = nfserr_openmode;
-
-	if ((flags & WR_STATE) & (dp->dl_type == NFS4_OPEN_DELEGATE_READ))
-		goto out;
-	if ((flags & RD_STATE) & (dp->dl_type == NFS4_OPEN_DELEGATE_WRITE))
-		goto out;
-	status = nfs_ok;
-out:
-	return status;
+	if ((flags & WR_STATE) && (dp->dl_type == NFS4_OPEN_DELEGATE_READ))
+		return nfserr_openmode;
+	else
+		return nfs_ok;
 }
 
 static inline int


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
