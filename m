From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 6 - Assort fixes to nfsd auth cache stuff.
Date: Wed, 12 Mar 2003 16:35:29 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytl-0005R3-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sytv-0000Dr-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:39 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:28 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

1/ call cache_fresh when replacing a cache entry (instead of only 
  when updating) so that up-calls waiting on the replaced entry continue.

2/ in svcauth_unix_accept, don't put the verifier until all tests have
   succeeded.

3/ calculate size of request-being-deferred correctly.


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    1 +
 ./net/sunrpc/svcauth_unix.c    |   10 ++++++----
 ./net/sunrpc/svcsock.c         |    7 ++++---
 3 files changed, 11 insertions(+), 7 deletions(-)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-03-12 15:03:48.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2003-03-12 15:03:48.000000000 +1100
@@ -190,6 +190,7 @@ RTN *FNAME ARGS										\
 			else read_unlock(&(DETAIL)->hash_lock);				\
 			if (set)							\
 				cache_fresh(DETAIL, &tmp->MEMBER, item->MEMBER.expiry_time); \
+			if (set==1 && new) cache_fresh(DETAIL, &new->MEMBER, 0);	\
 			if (new) (DETAIL)->cache_put(&new->MEMBER, DETAIL);		\
 			return tmp;							\
 		}									\

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-03-12 15:03:48.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2003-03-12 15:03:48.000000000 +1100
@@ -441,9 +441,6 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		return SVC_DENIED;
 	}
 
-	/* Put NULL verifier */
-	svc_putu32(resv, RPC_AUTH_NULL);
-	svc_putu32(resv, 0);
 
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
 	key.m_addr = rqstp->rq_addr.sin_addr;
@@ -470,8 +467,13 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		}
 	else rv = SVC_DROP;
 
-	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
+	if (rv  == SVC_OK && rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		goto badcred;
+
+	/* Put NULL verifier */
+	svc_putu32(resv, RPC_AUTH_NULL);
+	svc_putu32(resv, 0);
+
 	return rv;
 
 badcred:

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-03-12 15:02:07.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2003-03-12 15:03:48.000000000 +1100
@@ -1438,7 +1438,7 @@ static struct cache_deferred_req *
 svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.head[0].iov_len);
+	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
 	struct svc_deferred_req *dr;
 
 	if (rqstp->rq_arg.page_len)
@@ -1447,6 +1447,7 @@ svc_defer(struct cache_req *req)
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
 	} else {
+		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
 		/* FIXME maybe discard if size too large */
 		dr = kmalloc(size, GFP_KERNEL);
 		if (dr == NULL)
@@ -1455,8 +1456,8 @@ svc_defer(struct cache_req *req)
 		dr->serv = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
 		dr->addr = rqstp->rq_addr;
-		dr->argslen = rqstp->rq_arg.head[0].iov_len >> 2;
-		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base, dr->argslen<<2);
+		dr->argslen = rqstp->rq_arg.len >> 2;
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
 	spin_lock(&rqstp->rq_server->sv_lock);
 	rqstp->rq_sock->sk_inuse++;


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
