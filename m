From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 01/29] SUNRPC: Use default address length based on
	address	family
Date: Thu, 29 Nov 2007 14:39:56 -0500
Message-ID: <20071129193956.4170.68884.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpFw-0001RZ-Fd
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:04 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpG0-0007SL-Fc
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:10 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

If the address length passed to rpc_create is zero, have it use a default
length based on the address family of the passed in address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..efa7890 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -30,6 +30,7 @@
 #include <linux/smp_lock.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
+#include <linux/in6.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -249,6 +250,21 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	};
 	char servername[20];
 
+	if (args->addrsize == 0) {
+		switch (args->address->sa_family) {
+		case AF_INET:
+			xprtargs.addrlen = sizeof(struct sockaddr_in);
+			break;
+		case AF_INET6:
+			xprtargs.addrlen = sizeof(struct sockaddr_in6);
+			break;
+		default:
+			/* caller wants default address length, but
+			 * address family isn't recognized. */
+			return ERR_PTR(-EINVAL);
+		}
+	}
+
 	xprt = xprt_create_transport(&xprtargs);
 	if (IS_ERR(xprt))
 		return (struct rpc_clnt *)xprt;


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

