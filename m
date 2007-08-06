From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/20] SUNRPC: create an IPv6-savvy mechanism for
	binding to a	reserved port
Date: Mon, 06 Aug 2007 11:57:33 -0400
Message-ID: <20070806155733.31233.46535.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II4xi-00012X-25
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:42 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II4xl-0006Am-EI
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 08:57:46 -0700
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

Clone xs_bindresvport into two functions, one that can handle IPv4
addresses, and one that can handle IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/xprtsock.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8e56c38..df14360 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1271,6 +1271,39 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 	return err;
 }
 
+static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
+{
+	struct sockaddr_in6 myaddr = {
+		.sin6_family = AF_INET6,
+	};
+	struct sockaddr_in6 *sa;
+	int err;
+	unsigned short port = transport->port;
+
+	if (!transport->xprt.resvport)
+		port = 0;
+	sa = (struct sockaddr_in6 *)&transport->addr;
+	myaddr.sin6_addr = sa->sin6_addr;
+	do {
+		myaddr.sin6_port = htons(port);
+		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
+						sizeof(myaddr));
+		if (!transport->xprt.resvport)
+			break;
+		if (err == 0) {
+			transport->port = port;
+			break;
+		}
+		if (port <= xprt_min_resvport)
+			port = xprt_max_resvport;
+		else
+			port--;
+	} while (err == -EADDRINUSE && port != transport->port);
+	dprintk("RPC:       xs_bind6 "NIP6_FMT":%u: %s (%d)\n",
+		NIP6(myaddr.sin6_addr), port, err ? "failed" : "ok", err);
+	return err;
+}
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key xs_key[2];
 static struct lock_class_key xs_slock_key[2];


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
