From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 12/25] SUNRPC: Create API for displaying remote peer
	address
Date: Wed, 09 Aug 2006 10:59:19 -0400
Message-ID: <20060809145919.3914.27869.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcS-0000oj-Hb
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcS-0005kM-Di
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

Provide an API for formatting the remote peer address for printing without
exposing its internal structure.  The address could be dynamic, so we
support a function call to get the address rather than reading it straight
out of a structure.

Test-plan:
Destructive testing (unplugging the network temporarily).  Probably need
to rig a server where certain services aren't running, or that returns an
error for some typical operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 65196b0..b7d47f0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -124,6 +124,7 @@ size_t		rpc_max_payload(struct rpc_clnt 
 void		rpc_force_rebind(struct rpc_clnt *);
 int		rpc_ping(struct rpc_clnt *clnt, int flags);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
+char *		rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 
 /*
  * Helper function for NFSroot support
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index da377eb..8f21e47 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -557,6 +557,19 @@ size_t rpc_peeraddr(struct rpc_clnt *cln
 }
 EXPORT_SYMBOL(rpc_peeraddr);
 
+/**
+ * rpc_peeraddr2str - return remote peer address in printable format
+ * @clnt: RPC client structure
+ * @format: address format
+ *
+ */
+char *rpc_peeraddr2str(struct rpc_clnt *clnt, enum rpc_display_format_t format)
+{
+	struct rpc_xprt *xprt = clnt->cl_xprt;
+	return xprt->ops->print_addr(xprt, format);
+}
+EXPORT_SYMBOL(rpc_peeraddr2str);
+
 void
 rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
 {

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
