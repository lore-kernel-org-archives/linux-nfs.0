From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 02/29] SUNRPC: rpc_create() default hostname should
	support	AF_INET6 addresses
Date: Thu, 29 Nov 2007 14:40:02 -0500
Message-ID: <20071129194002.4170.54273.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpFz-0001Tq-4D
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:07 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpG5-00020d-2l
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:13 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

If the ULP doesn't pass a hostname string to rpc_create(), it manufactures
one based on the passed-in address.  Be smart enough to handle an AF_INET6
address properly in this case.

Move the default servername logic before the xprt_create_transport() call
to simplify error handling in rpc_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   35 ++++++++++++++++++++++++++---------
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index efa7890..0297015 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -248,7 +248,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.addrlen = args->addrsize,
 		.timeout = args->timeout
 	};
-	char servername[20];
+	char servername[48];
 
 	if (args->addrsize == 0) {
 		switch (args->address->sa_family) {
@@ -265,22 +265,39 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		}
 	}
 
-	xprt = xprt_create_transport(&xprtargs);
-	if (IS_ERR(xprt))
-		return (struct rpc_clnt *)xprt;
-
 	/*
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.
 	 */
 	if (args->servername == NULL) {
-		struct sockaddr_in *addr =
-					(struct sockaddr_in *) args->address;
-		snprintf(servername, sizeof(servername), NIPQUAD_FMT,
-			NIPQUAD(addr->sin_addr.s_addr));
+		servername[0] = '\0';
+		switch (args->address->sa_family) {
+		case AF_INET: {
+			struct sockaddr_in *sin =
+					(struct sockaddr_in *)args->address;
+			snprintf(servername, sizeof(servername), NIPQUAD_FMT,
+				 NIPQUAD(sin->sin_addr.s_addr));
+			break;
+		}
+		case AF_INET6: {
+			struct sockaddr_in6 *sin =
+					(struct sockaddr_in6 *)args->address;
+			snprintf(servername, sizeof(servername), NIP6_FMT,
+				 NIP6(sin->sin6_addr));
+			break;
+		}
+		default:
+			/* caller wants default server name, but
+			 * address family isn't recognized. */
+			return ERR_PTR(-EINVAL);
+		}
 		args->servername = servername;
 	}
 
+	xprt = xprt_create_transport(&xprtargs);
+	if (IS_ERR(xprt))
+		return (struct rpc_clnt *)xprt;
+
 	/*
 	 * By default, kernel RPC client connects from a reserved port.
 	 * CAP_NET_BIND_SERVICE will not be set for unprivileged requesters,


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

