From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 14] knfsd: SUNRPC: Use sockaddr_storage to
	store address in svc_deferred_req
Date: Wed, 13 Dec 2006 10:58:59 +1100
Message-ID: <1061212235859.21410@suse.de>
References: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHWI-0002Rx-FI
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:46 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHWH-0006RB-8Y
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:48 -0800
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


From: Chuck Lever <chuck.lever@oracle.com>
Sockaddr_storage will allow us to store arbitrary socket addresses in
the svc_deferred_req struct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    3 ++-
 ./net/sunrpc/svcsock.c       |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-12-13 10:28:52.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2006-12-13 10:29:18.000000000 +1100
@@ -289,7 +289,8 @@ static inline void svc_free_res_pages(st
 
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
-	struct sockaddr_in	addr;
+	struct sockaddr_storage	addr;
+	int			addrlen;
 	struct svc_sock		*svsk;	/* where reply must go */
 	__be32			daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-12-13 10:29:15.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-12-13 10:29:18.000000000 +1100
@@ -1713,7 +1713,8 @@ svc_defer(struct cache_req *req)
 
 		dr->handle.owner = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
-		dr->addr = rqstp->rq_addr;
+		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
+		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
@@ -1737,7 +1738,8 @@ static int svc_deferred_recv(struct svc_
 	rqstp->rq_arg.page_len = 0;
 	rqstp->rq_arg.len = dr->argslen<<2;
 	rqstp->rq_prot        = dr->prot;
-	rqstp->rq_addr        = dr->addr;
+	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
+	rqstp->rq_addrlen     = dr->addrlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_respages    = rqstp->rq_pages;
 	return dr->argslen<<2;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
