From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] nlm: fix f_count leak
Date: Wed, 23 Mar 2005 14:18:39 +1100
Message-ID: <E1DDwOF-0003IA-Gw@notabene.cse.unsw.edu.au>
References: <20050323141612.12609.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDwOk-0006Je-Ix
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 19:19:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDwOQ-00065b-Rq
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 19:19:10 -0800
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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

Hi,
 The following patch is probably appropriate for 2.4.30.  The problem
it fixes is not a major one (no security or data corruption issues)
but is an occasional annoyance, and the fix is trivial (and tested).

NeilBrown


### Comments for Changeset

I can't see any reason for this file->f_count++.  Removing it fixes a
bug which leaves an exported filesystem busy (and so unmountable) if a
callback for a lock held on that filesystem ever failed.

Found by Terence Rokop.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/lockd/svclock.c |    1 -
 1 files changed, 1 deletion(-)

diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2005-03-23 11:28:56.000000000 +1100
+++ ./fs/lockd/svclock.c	2005-03-23 11:29:02.000000000 +1100
@@ -640,7 +640,6 @@ nlmsvc_grant_reply(struct svc_rqst *rqst
 		} else {
 			/* Lock is now held by client, or has been rejected.
 			 * In both cases, the block should be removed. */
-			file->f_count++;
 			up(&file->f_sema);
 			if (status == NLM_LCK_GRANTED)
 				nlmsvc_delete_block(block, 0);


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
