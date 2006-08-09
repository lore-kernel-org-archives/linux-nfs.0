From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 13/25] SUNRPC: Teach rpc_pipe.c to use new
	rpc_peeraddr() API
Date: Wed, 09 Aug 2006 10:59:21 -0400
Message-ID: <20060809145921.3914.33558.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000om-7y
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0003FQ-VU
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:17 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

Hide the details of how the RPC client stores remote peer addresses from
the RPC pipefs implementation.

Test plan:
Connectathon with Kerberos 5 authentication.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpc_pipe.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index a3bd2db..ff6d9c2 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -327,10 +327,8 @@ rpc_show_info(struct seq_file *m, void *
 	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
 	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
 			clnt->cl_prog, clnt->cl_vers);
-	seq_printf(m, "address: %u.%u.%u.%u\n",
-			NIPQUAD(clnt->cl_xprt->addr.sin_addr.s_addr));
-	seq_printf(m, "protocol: %s\n",
-			clnt->cl_xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
+	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
+	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
 	return 0;
 }
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
