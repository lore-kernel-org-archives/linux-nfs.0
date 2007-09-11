From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] SUNRPC: Make rpcb_decode_getaddr more picky
	about	universal addresses
Date: Tue, 11 Sep 2007 18:00:31 -0400
Message-ID: <20070911220030.26136.18494.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDmh-0006qG-P5
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:40 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDmm-0001oS-7j
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:44 -0700
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

Add better sanity checking of server replies to the GETVERSADDR reply
decoder.  Change the error return code: EIO is what other XDR decoding
routines return if there is a failure while decoding.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index f88ab90..34738c5 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -528,12 +528,19 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 
 	*portp = 0;
 	addr_len = ntohl(*p++);
-	if (addr_len > RPCB_MAXADDRLEN)			/* sanity */
-		return -EINVAL;
-
-	dprintk("RPC:       rpcb_decode_getaddr returned string: '%s'\n",
-			(char *) p);
 
+	/*
+	 * Simple sanity check.  The smallest possible universal
+	 * address is an IPv4 address string containing 11 bytes.
+	 */
+	if (addr_len < 11 || addr_len > RPCB_MAXADDRLEN)
+		goto out_err;
+
+	/*
+	 * Start at the end and walk backwards until the first dot
+	 * is encountered.  When the second dot is found, we have
+	 * both parts of the port number.
+	 */
 	addr = (char *)p;
 	val = 0;
 	first = 1;
@@ -555,8 +562,19 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 		}
 	}
 
+	/*
+	 * Simple sanity check.  If we never saw a dot in the reply,
+	 * then this was probably just garbage.
+	 */
+	if (first)
+		goto out_err;
+
 	dprintk("RPC:       rpcb_decode_getaddr port=%u\n", *portp);
 	return 0;
+
+out_err:
+	dprintk("RPC:       rpcbind server returned malformed reply\n");
+	return -EIO;
 }
 
 #define RPCB_program_sz		(1u)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
