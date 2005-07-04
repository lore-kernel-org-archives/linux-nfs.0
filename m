From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 014 of 19] nfsd4: return better error on io incompatible with open mode
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007Gu-42@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLk-0001kE-Cw
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLh-0007TL-6R
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


from RFC 3530:
"Share reservations are established by OPEN operations and by their
nature are mandatory in that when the OPEN denies READ or WRITE
operations, that denial results in such operations being rejected
with error NFS4ERR_LOCKED."

(Note that share_denied is really only a legal error for OPEN.)

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |    2 +-
 ./include/linux/nfsd/nfsd.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -1295,7 +1295,7 @@ nfs4_share_conflict(struct svc_fh *curre
 	fp = find_file(ino);
 	if (!fp)
 		return nfs_ok;
-	ret = nfserr_share_denied;
+	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 		if (test_bit(deny_type, &stp->st_deny_bmap) ||

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-07-04 10:57:53.000000000 +1000
@@ -231,6 +231,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_reclaim_bad	__constant_htonl(NFSERR_RECLAIM_BAD)
 #define	nfserr_badname		__constant_htonl(NFSERR_BADNAME)
 #define	nfserr_cb_path_down	__constant_htonl(NFSERR_CB_PATH_DOWN)
+#define	nfserr_locked		__constant_htonl(NFSERR_LOCKED)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
