From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 14] knfsd: SUNRPC: Use sockaddr_storage to store address in svc_deferred_req
Date: Fri, 2 Feb 2007 15:40:13 +1100
Message-ID: <1070202044013.19051@suse.de>
References: <20070202153531.18622.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422932AbXBBElY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: Chuck Lever <chuck.lever@oracle.com>
Sockaddr_storage will allow us to store arbitrary socket addresses in
the svc_deferred_req struct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    5 +++--
 ./net/sunrpc/svcsock.c       |    6 ++++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2007-02-02 15:22:31.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2007-02-02 15:22:31.000000000 +1100
@@ -292,8 +292,9 @@ static inline void svc_free_res_pages(st
 
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
-	struct sockaddr_in	addr;
-	struct svc_sock		*svsk;	/* where reply must go */
+	struct svc_sock		*svsk;
+	struct sockaddr_storage	addr;	/* where reply must go */
+	size_t			addrlen;
 	__be32			daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	int			argslen;

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-02-02 15:22:31.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-02-02 15:22:31.000000000 +1100
@@ -1761,7 +1761,8 @@ svc_defer(struct cache_req *req)
 
 		dr->handle.owner = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
-		dr->addr = rqstp->rq_addr;
+		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
+		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
@@ -1785,7 +1786,8 @@ static int svc_deferred_recv(struct svc_
 	rqstp->rq_arg.page_len = 0;
 	rqstp->rq_arg.len = dr->argslen<<2;
 	rqstp->rq_prot        = dr->prot;
-	rqstp->rq_addr        = dr->addr;
+	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
+	rqstp->rq_addrlen     = dr->addrlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_respages    = rqstp->rq_pages;
 	return dr->argslen<<2;
