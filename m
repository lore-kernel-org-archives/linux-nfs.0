From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Tidyup up meaning of 'buffer size' in
	nfsd/sunrpc
Date: Thu, 5 Oct 2006 17:12:12 +1000
Message-ID: <1061005071212.6527@suse.de>
References: <20061005171043.4544.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVNP2-0000ru-VA
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 00:12:21 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVNP2-0006fX-OP
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 00:12:21 -0700
To: Andrew Morton <akpm@osdl.org>
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

Ok, this patch should fix up the remaining issue with a recent
set of NFSD patches.  It has been reviewed by Greg, and I'm convinced:-)

Thanks,
NeilBrown


### Comments for Changeset

There is some confusion about the meaning of 'bufsz' for a
sunrpc server.  In some cases it is the largest message that
can be sent or received.  In other cases it is the largest 'payload'
that can be included in a NFS message.

In either case, it is not possible for both the request and the reply
to be this large.  One of the request or reply may only be one page
long, which fits nicely with NFS.

So we remove 'bufsz' and replace it with two numbers: 'max_payload'
and 'max_mesg'.
Max_payload is the size that the server requests.  It is used
by the server to check the max size allowed on a particular
connection: depending on the protocol a lower limit might be used.

max_mesg is the largest single message that can be sent or received.
It is calculated as the max_payload, rounded up to a multiple of
PAGE_SIZE, and with PAGE_SIZE added to overhead.
Only one of the request and reply may be this size.  The other must
be at most one page.

Cc: Greg Banks <gnb@sgi.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c           |    2 +-
 ./include/linux/sunrpc/svc.h |    3 ++-
 ./net/sunrpc/svc.c           |   17 ++++++++++-------
 ./net/sunrpc/svcsock.c       |   28 ++++++++++++++--------------
 4 files changed, 27 insertions(+), 23 deletions(-)

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2006-10-05 16:51:56.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2006-10-03 11:23:11.000000000 +1000
@@ -217,7 +217,7 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program,
-				      NFSD_BUFSIZE - NFSSVC_MAXBLKSIZE + nfsd_max_blksize,
+				      nfsd_max_blksize,
 				      nfsd_last_thread,
 				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-10-05 16:51:46.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-10-05 16:52:06.000000000 +1000
@@ -57,7 +57,8 @@ struct svc_serv {
 	struct svc_stat *	sv_stats;	/* RPC statistics */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nrthreads;	/* # of server threads */
-	unsigned int		sv_bufsz;	/* datagram buffer size */
+	unsigned int		sv_max_payload;	/* datagram payload size */
+	unsigned int		sv_max_mesg;	/* max_payload + 1 page for overheads */
 	unsigned int		sv_xdrsize;	/* XDR buffer size */
 
 	struct list_head	sv_permsocks;	/* all permanent sockets */

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-10-05 16:51:46.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-10-05 16:52:06.000000000 +1000
@@ -282,7 +282,10 @@ __svc_create(struct svc_program *prog, u
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
 	serv->sv_stats     = prog->pg_stats;
-	serv->sv_bufsz	   = bufsize? bufsize : 4096;
+	if (bufsize > RPCSVC_MAXPAYLOAD)
+		bufsize = RPCSVC_MAXPAYLOAD;
+	serv->sv_max_payload = bufsize? bufsize : 4096;
+	serv->sv_max_mesg  = roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE);
 	serv->sv_shutdown  = shutdown;
 	xdrsize = 0;
 	while (prog) {
@@ -414,9 +417,9 @@ svc_init_buffer(struct svc_rqst *rqstp, 
 	int pages;
 	int arghi;
 	
-	if (size > RPCSVC_MAXPAYLOAD)
-		size = RPCSVC_MAXPAYLOAD;
-	pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
+	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
+				       * We assume one is at most one page
+				       */
 	arghi = 0;
 	BUG_ON(pages > RPCSVC_MAXPAGES);
 	while (pages) {
@@ -463,7 +466,7 @@ __svc_create_thread(svc_thread_fn func, 
 
 	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
 	 || !(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !svc_init_buffer(rqstp, serv->sv_bufsz))
+	 || !svc_init_buffer(rqstp, serv->sv_max_mesg))
 		goto out_thread;
 
 	serv->sv_nrthreads++;
@@ -938,8 +941,8 @@ u32 svc_max_payload(const struct svc_rqs
 
 	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
 		max = RPCSVC_MAXPAYLOAD_UDP;
-	if (rqstp->rq_server->sv_bufsz < max)
-		max = rqstp->rq_server->sv_bufsz;
+	if (rqstp->rq_server->sv_max_payload < max)
+		max = rqstp->rq_server->sv_max_payload;
 	return max;
 }
 EXPORT_SYMBOL_GPL(svc_max_payload);

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-10-05 16:51:46.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-10-05 16:52:06.000000000 +1000
@@ -192,13 +192,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	svsk->sk_pool = pool;
 
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	if (((atomic_read(&svsk->sk_reserved) + serv->sv_bufsz)*2
+	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
 	     > svc_sock_wspace(svsk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
-			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_bufsz,
+			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
 			svc_sock_wspace(svsk));
 		svsk->sk_pool = NULL;
 		clear_bit(SK_BUSY, &svsk->sk_flags);
@@ -220,7 +220,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 				rqstp, rqstp->rq_sock);
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
-		rqstp->rq_reserved = serv->sv_bufsz;
+		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		BUG_ON(svsk->sk_pool != pool);
 		wake_up(&rqstp->rq_wait);
@@ -639,8 +639,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	     * which will access the socket.
 	     */
 	    svc_sock_setbufsize(svsk->sk_sock,
-				(serv->sv_nrthreads+3) * serv->sv_bufsz,
-				(serv->sv_nrthreads+3) * serv->sv_bufsz);
+				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
+				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
 	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
 		svc_sock_received(svsk);
@@ -749,8 +749,8 @@ svc_udp_init(struct svc_sock *svsk)
 	 * svc_udp_recvfrom will re-adjust if necessary
 	 */
 	svc_sock_setbufsize(svsk->sk_sock,
-			    3 * svsk->sk_server->sv_bufsz,
-			    3 * svsk->sk_server->sv_bufsz);
+			    3 * svsk->sk_server->sv_max_mesg,
+			    3 * svsk->sk_server->sv_max_mesg);
 
 	set_bit(SK_DATA, &svsk->sk_flags); /* might have come in before data_ready set up */
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
@@ -993,8 +993,8 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		 * as soon a a complete request arrives.
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    (serv->sv_nrthreads+3) * serv->sv_bufsz,
-				    3 * serv->sv_bufsz);
+				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
+				    3 * serv->sv_max_mesg);
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
 
@@ -1032,7 +1032,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		}
 		svsk->sk_reclen &= 0x7fffffff;
 		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
-		if (svsk->sk_reclen > serv->sv_bufsz) {
+		if (svsk->sk_reclen > serv->sv_max_mesg) {
 			printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (large)\n",
 			       (unsigned long) svsk->sk_reclen);
 			goto err_delete;
@@ -1171,8 +1171,8 @@ svc_tcp_init(struct svc_sock *svsk)
 		 * svc_tcp_recvfrom will re-adjust if necessary
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_bufsz,
-				    3 * svsk->sk_server->sv_bufsz);
+				    3 * svsk->sk_server->sv_max_mesg,
+				    3 * svsk->sk_server->sv_max_mesg);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 		set_bit(SK_DATA, &svsk->sk_flags);
@@ -1234,7 +1234,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 
 
 	/* now allocate needed pages.  If we get a failure, sleep briefly */
-	pages = 2 + (serv->sv_bufsz + PAGE_SIZE -1) / PAGE_SIZE;
+	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
 	for (i=0; i < pages ; i++)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);
@@ -1263,7 +1263,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	if ((svsk = svc_sock_dequeue(pool)) != NULL) {
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
-		rqstp->rq_reserved = serv->sv_bufsz;	
+		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
 		/* No data pending. Go to sleep */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
