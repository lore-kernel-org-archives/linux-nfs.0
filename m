From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 17/22] [lockd] match GRANTED_RES replies using cookies
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8102@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrk-00079h-VA
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:57 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrk-0003MM-HG
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:57 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 115EB1FFDE
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:49 +0200 (CEST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Olaf Kirch <okir@suse.de>
Subject: [lockd] match GRANTED_RES replies using cookies

 When we send a GRANTED_MSG call, we current copy the NLM cookie
 provided in the original LOCK call - because in 1996, some broken
 clients seemed to rely on this bug. However, this means the cookies
 are not unique, so that when the client's GRANTED_RES message comes
 back, we cannot simply match it based on the cookie, but have to
 use the client's IP address in addition. Which breaks when you have
 a multi-homed NFS client.
 
 The X/Open spec explicitly mentions that clients should not expect the
 same cookie; so one may hope that any clients that were broken in 1996
 have either been fixed or rendered obsolete.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svclock.c          |   24 +++++++++++++-----------
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    2 +-
 4 files changed, 16 insertions(+), 14 deletions(-)

Index: build/fs/lockd/svclock.c
===================================================================
--- build.orig/fs/lockd/svclock.c
+++ build/fs/lockd/svclock.c
@@ -136,19 +136,19 @@ static inline int nlm_cookie_match(struc
  * Find a block with a given NLM cookie.
  */
 static inline struct nlm_block *
-nlmsvc_find_block(struct nlm_cookie *cookie,  struct sockaddr_in *sin)
+nlmsvc_find_block(struct nlm_cookie *cookie)
 {
 	struct nlm_block *block;
 
 	list_for_each_entry(block, &nlm_blocked, b_list) {
-		if (nlm_cookie_match(&block->b_call->a_args.cookie,cookie)
-				&& nlm_cmp_addr(sin, &block->b_host->h_addr))
+		if (nlm_cookie_match(&block->b_call->a_args.cookie,cookie))
 			goto found;
 	}
 
 	return NULL;
 
 found:
+	dprintk("nlmsvc_find_block(%s): block=%p\n", nlmdbg_cookie2a(cookie), block);
 	kref_get(&block->b_count);
 	return block;
 }
@@ -162,6 +162,11 @@ found:
  * request, but (as I found out later) that's because some implementations
  * do just this. Never mind the standards comittees, they support our
  * logging industries.
+ *
+ * 10 years later: I hope we can safely ignore these old and broken
+ * clients by now. Let's fix this so we can uniquely identify an incoming
+ * GRANTED_RES message by cookie, without having to rely on the client's IP
+ * address. --okir
  */
 static inline struct nlm_block *
 nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_file *file,
@@ -194,7 +199,7 @@ nlmsvc_create_block(struct svc_rqst *rqs
 	/* Set notifier function for VFS, and init args */
 	call->a_args.lock.fl.fl_flags |= FL_SLEEP;
 	call->a_args.lock.fl.fl_lmops = &nlmsvc_lock_operations;
-	call->a_args.cookie = *cookie;	/* see above */
+	nlmclnt_next_cookie(&call->a_args.cookie);
 
 	dprintk("lockd: created block %p...\n", block);
 
@@ -650,17 +655,14 @@ static const struct rpc_call_ops nlmsvc_
  * block.
  */
 void
-nlmsvc_grant_reply(struct svc_rqst *rqstp, struct nlm_cookie *cookie, u32 status)
+nlmsvc_grant_reply(struct nlm_cookie *cookie, u32 status)
 {
 	struct nlm_block	*block;
-	struct nlm_file		*file;
 
-	dprintk("grant_reply: looking for cookie %x, host (%08x), s=%d \n", 
-		*(unsigned int *)(cookie->data), 
-		ntohl(rqstp->rq_addr.sin_addr.s_addr), status);
-	if (!(block = nlmsvc_find_block(cookie, &rqstp->rq_addr)))
+	dprintk("grant_reply: looking for cookie %x, s=%d \n", 
+		*(unsigned int *)(cookie->data), status);
+	if (!(block = nlmsvc_find_block(cookie)))
 		return;
-	file = block->b_file;
 
 	if (block) {
 		if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
Index: build/fs/lockd/svc4proc.c
===================================================================
--- build.orig/fs/lockd/svc4proc.c
+++ build/fs/lockd/svc4proc.c
@@ -453,7 +453,7 @@ nlm4svc_proc_granted_res(struct svc_rqst
 
         dprintk("lockd: GRANTED_RES   called\n");
 
-        nlmsvc_grant_reply(rqstp, &argp->cookie, argp->status);
+        nlmsvc_grant_reply(&argp->cookie, argp->status);
         return rpc_success;
 }
 
Index: build/fs/lockd/svcproc.c
===================================================================
--- build.orig/fs/lockd/svcproc.c
+++ build/fs/lockd/svcproc.c
@@ -482,7 +482,7 @@ nlmsvc_proc_granted_res(struct svc_rqst 
 
 	dprintk("lockd: GRANTED_RES   called\n");
 
-	nlmsvc_grant_reply(rqstp, &argp->cookie, argp->status);
+	nlmsvc_grant_reply(&argp->cookie, argp->status);
 	return rpc_success;
 }
 
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -196,7 +196,7 @@ u32		  nlmsvc_cancel_blocked(struct nlm_
 unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					nlm_host_match_fn_t match);
-void	  nlmsvc_grant_reply(struct svc_rqst *, struct nlm_cookie *, u32);
+void		  nlmsvc_grant_reply(struct nlm_cookie *, u32);
 
 /*
  * File handling for the server personality

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
