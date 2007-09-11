From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/15] SUNRPC: Make sure server name is reasonable
	before	trying to print it
Date: Tue, 11 Sep 2007 18:00:20 -0400
Message-ID: <20070911220020.26136.45994.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDn2-0006rU-Hr
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:00 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDn6-0005Ka-6E
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:05 -0700
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

Check the length of the passed-in server name before trying to print it in
the log.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c3d571a..0357819 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -127,7 +127,14 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
 	int err;
-	int len;
+	size_t len;
+
+	/* sanity check the name before trying to print it */
+	err = -EINVAL;
+	len = strlen(servname);
+	if (len > RPC_MAXNETNAMELEN)
+		goto out_no_rpciod;
+	len++;
 
 	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
 			program->name, servname, xprt);
@@ -148,7 +155,6 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	clnt->cl_parent = clnt;
 
 	clnt->cl_server = clnt->cl_inline_name;
-	len = strlen(servname) + 1;
 	if (len > sizeof(clnt->cl_inline_name)) {
 		char *buf = kmalloc(len, GFP_KERNEL);
 		if (buf != 0)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
