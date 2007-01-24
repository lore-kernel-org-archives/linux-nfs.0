From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] SUNRPC: switch socket-based RPC transports to
	use rpcbind
Date: Wed, 24 Jan 2007 14:20:04 -0500
Message-ID: <20070124192004.31133.42543.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngY-00019h-O7
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:30 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngY-0004QI-4y
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:32 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
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

Now that we have a version of the portmapper that supports versions 3 and 4
of the rpcbind protocol, use it for new RPC client connections over
sockets.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 64736b3..78d5494 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1477,7 +1477,7 @@ static struct rpc_xprt_ops xs_udp_ops = 
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
-	.rpcbind		= rpc_getport,
+	.rpcbind		= rpcb_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
@@ -1494,7 +1494,7 @@ static struct rpc_xprt_ops xs_udp_ops = 
 static struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
-	.rpcbind		= rpc_getport,
+	.rpcbind		= rpcb_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
