From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 012 of 19] nfsd4: relax new lock seqid check
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007Gm-03@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM8-0001lE-Ec
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM7-0007Zq-0C
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
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


We're insisting that the lock sequence id field passed in the open_to_lockowner
struct always be zero.  This is probably thanks to the sentence in rfc3530:
"The first request issued for any given lock_owner is issued with a sequence
number of zero."

But there doesn't seem to be any problem with allowing initial sequence numbers
other than zero.  And currently this is causing lock reclaims from the Linux
client to fail.

In the spirit of "be liberal in what you accept, conservative in what you
send", we'll relax the check (and patch the Linux client as well).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    5 -----
 1 files changed, 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -2715,11 +2715,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 			goto out;
 		}
 
-		/* is the new lock seqid presented by the client zero? */
-		status = nfserr_bad_seqid;
-		if (lock->v.new.lock_seqid != 0)
-			goto out;
-
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(current_fh, 
 				        lock->lk_new_open_seqid,


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
