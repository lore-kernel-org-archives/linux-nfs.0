From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 1/3] svc: Change sockaddr to sockaddr_storage in
	svc_create_xprt
Date: Wed, 10 Oct 2007 21:28:57 -0500
Message-ID: <20071011022857.3501.4698.stgit@dell3.ogc.int>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfnnJ-00078N-7D
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:01 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfnnM-0001LC-9I
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:29:06 -0700
In-Reply-To: <20071011022356.3501.63859.stgit@dell3.ogc.int>
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


A sockaddr is too small to handle an IPv6 address. Change the 
newsin local variable to point to sockaddr_storage.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4bb2d57..cc752b7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1278,7 +1278,8 @@ svc_create_socket(struct svc_serv *serv,
 	int		error;
 	int		type;
 	char		buf[RPC_MAX_ADDRBUFLEN];
-	struct sockaddr	newsin;
+	struct sockaddr_storage addr;
+	struct sockaddr *newsin = (struct sockaddr *)&addr;
 	int		newlen;
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
@@ -1305,7 +1306,7 @@ svc_create_socket(struct svc_serv *serv,
 		goto bummer;
 
 	newlen = len;
-	error = kernel_getsockname(sock, &newsin, &newlen);
+	error = kernel_getsockname(sock, newsin, &newlen);
 	if (error < 0)
 		goto bummer;
 
@@ -1315,7 +1316,7 @@ svc_create_socket(struct svc_serv *serv,
 	}
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
-		memcpy(&svsk->sk_xprt.xpt_local, &newsin, newlen);
+		memcpy(&svsk->sk_xprt.xpt_local, newsin, newlen);
 		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
