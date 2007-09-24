From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] SUNRPC: Transport setup functions should never
	return NULL
Date: Mon, 24 Sep 2007 15:39:44 -0400
Message-ID: <20070924193944.3568.49235.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnG-0001QY-Ca
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:34 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtnI-00082I-V8
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:39 -0700
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

The xs_setup_udp and xs_setup_tcp functions should return an ERR_PTR, not
NULL, when they encounter an unrecognized address family.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 98c5ffc..b81494a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1874,7 +1874,7 @@ struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 		break;
 	default:
 		kfree(xprt);
-		return NULL;
+		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
 	dprintk("RPC:       set up transport to address %s\n",
@@ -1937,7 +1937,7 @@ struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 		break;
 	default:
 		kfree(xprt);
-		return NULL;
+		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
 	dprintk("RPC:       set up transport to address %s\n",


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
