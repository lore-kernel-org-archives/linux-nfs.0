From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 10 - Reduce timeout when waiting for idmapper userspace daemon.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004BX-SL@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072Z-Ds
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002Vu-KG
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:47 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:40 +1000
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


1 second should be plenty of time; if we're going to take longer than that it's
probably better just to return NFS4ERR_DELAY and let the client retry anyway.

From: "J. Bruce Fields" <bfields@fieldses.org>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-05-18 11:18:14.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-05-18 11:18:30.000000000 +1000
@@ -470,7 +470,7 @@ idmap_lookup_wait(struct idmap_defer_req
 		if (2 * threads_waiting > rqstp->rq_server->sv_nrthreads)
 			goto out;
 		threads_waiting++;
-		schedule_timeout(10 * HZ);
+		schedule_timeout(1 * HZ);
 		threads_waiting--;
 	}
 out:


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
