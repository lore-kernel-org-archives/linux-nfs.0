From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/21] SUNRPC: Allocate a private data area for
	socket-specific rpc_xprt fields
Date: Thu, 16 Nov 2006 15:03:55 -0500
Message-ID: <20061116200354.32549.83871.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko0t-0006pa-DF
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:11 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko0u-0004jT-G1
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:12 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

When setting up a new transport instance, allocate enough memory for an
rpc_xprt and a private area.  As part of the same memory allocation, it
will be easy to find one, given a pointer to the other.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a6f778f..e3888e1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -125,6 +125,10 @@ static inline void xs_pktdump(char *msg,
 }
 #endif
 
+struct sock_xprt {
+	struct rpc_xprt		xprt;
+};
+
 static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
@@ -1353,17 +1357,19 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 static struct rpc_xprt *xs_setup_xprt(struct sockaddr *addr, size_t addrlen, unsigned int slot_table_size)
 {
 	struct rpc_xprt *xprt;
+	struct sock_xprt *new;
 
 	if (addrlen > sizeof(xprt->addr)) {
 		dprintk("RPC:      xs_setup_xprt: address too large\n");
 		return ERR_PTR(-EBADF);
 	}
 
-	xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL);
-	if (xprt == NULL) {
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (new == NULL) {
 		dprintk("RPC:      xs_setup_xprt: couldn't allocate rpc_xprt\n");
 		return ERR_PTR(-ENOMEM);
 	}
+	xprt = &new->xprt;
 
 	xprt->max_reqs = slot_table_size;
 	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
