From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] SUNRPC: fill in remote address before checking
	it's family
Date: Thu, 16 Aug 2007 16:03:21 -0400
Message-ID: <20070816200321.3831.65288.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILlZC-0005hf-F8
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:03:38 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILlZF-0003WT-I1
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 13:03:42 -0700
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

Recent IPv6 changes introduced a regression.  The address family of the
remote address is checked before the address is actually filled in.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 73c0381..4d6ed4e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -359,6 +359,8 @@ void rpcb_getport_async(struct rpc_task *task)
 		goto bailout_nofree;
 	}
 
+	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
+
 	/* Don't ever use rpcbind v2 for AF_INET6 requests */
 	switch (addr.sa_family) {
 	case AF_INET:
@@ -403,7 +405,6 @@ void rpcb_getport_async(struct rpc_task *task)
 			sizeof(map->r_addr));
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
-	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
 	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
