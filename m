From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] SUNRPC: Use correct argument type in memcpy()
Date: Tue, 11 Sep 2007 18:00:15 -0400
Message-ID: <20070911220014.26136.17254.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDme-0006qA-NN
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:36 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDmh-0005Bi-Cj
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:41 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Noticed by Tom Talpey <tmt@netapp.com>:

OBTW, there's a nit on that memcpy, too. The r_addr is an array, so

memcpy(&map->r_addr

is passing the address of the array as a char **. It's the same as
map->r_addr, but technically the wrong type.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0bb6709..f88ab90 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -410,7 +410,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_xprt = xprt_get(xprt);
 	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
 						   RPCB_NETID_UDP;
-	memcpy(&map->r_addr,
+	memcpy(map->r_addr,
 	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
 	       sizeof(map->r_addr));
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
