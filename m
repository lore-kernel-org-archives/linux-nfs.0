From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 019 of 19] nfsd4: fix fh_expire_type
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007HE-J1@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLk-0001kI-UZ
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLh-0006Ig-52
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
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


After discussion at the recent NFSv4 bake-a-thon, I realized that my assumption
that NFS4_FH_PERSISTENT required filehandles to persist was a misreading of the
spec.  This also fixes an interoperability problem with the Solaris client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-07-04 10:57:53.000000000 +1000
@@ -1366,9 +1366,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		if ((buflen -= 4) < 0)
 			goto out_resource;
 		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
-			WRITE32(NFS4_FH_VOLATILE_ANY);
+			WRITE32(NFS4_FH_PERSISTENT);
 		else
-			WRITE32(NFS4_FH_VOLATILE_ANY|NFS4_FH_VOL_RENAME);
+			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
 		/*


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
