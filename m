From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 10 - Use correct _bh locking on sv_lock.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004As-53@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSQ-00073C-IM
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:50 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSP-0002Wi-V5
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:50 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:39 +1000
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


With the _bh, we can dead-lock..

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2004-05-18 11:15:11.000000000 +1000
@@ -1511,9 +1511,9 @@ static void svc_revisit(struct cache_def
 	dprintk("revisit queued\n");
 	svsk = dr->svsk;
 	dr->svsk = NULL;
-	spin_lock(&serv->sv_lock);
+	spin_lock_bh(&serv->sv_lock);
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock(&serv->sv_lock);
+	spin_unlock_bh(&serv->sv_lock);
 	set_bit(SK_DEFERRED, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 	svc_sock_put(svsk);
@@ -1544,10 +1544,10 @@ svc_defer(struct cache_req *req)
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	spin_lock(&rqstp->rq_server->sv_lock);
+	spin_lock_bh(&rqstp->rq_server->sv_lock);
 	rqstp->rq_sock->sk_inuse++;
 	dr->svsk = rqstp->rq_sock;
-	spin_unlock(&rqstp->rq_server->sv_lock);
+	spin_unlock_bh(&rqstp->rq_server->sv_lock);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -1577,7 +1577,7 @@ static struct svc_deferred_req *svc_defe
 	
 	if (!test_bit(SK_DEFERRED, &svsk->sk_flags))
 		return NULL;
-	spin_lock(&serv->sv_lock);
+	spin_lock_bh(&serv->sv_lock);
 	clear_bit(SK_DEFERRED, &svsk->sk_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -1586,6 +1586,6 @@ static struct svc_deferred_req *svc_defe
 		list_del_init(&dr->handle.recent);
 		set_bit(SK_DEFERRED, &svsk->sk_flags);
 	}
-	spin_unlock(&serv->sv_lock);
+	spin_unlock_bh(&serv->sv_lock);
 	return dr;
 }


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
