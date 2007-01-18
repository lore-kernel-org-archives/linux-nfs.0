From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/13] SUNRPC: fix up svc_create_socket() to take a
	sockaddr struct + length
Date: Thu, 18 Jan 2007 18:51:05 -0500
Message-ID: <20070118235105.24266.88907.stgit@localhost.localdomain>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h2H-0005D5-Ic
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:51:13 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h2J-0001Hc-6M
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:51:15 -0800
To: neilb@suse.de
In-Reply-To: <20070118234855.24266.37463.stgit@localhost.localdomain>
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

Replace existing svc_create_socket() API to allow callers to pass addresses
larger than a sockaddr_in.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 net/sunrpc/svcsock.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7f4f428..ae906b9 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1678,7 +1678,7 @@ EXPORT_SYMBOL_GPL(svc_addsock);
  * Create socket for RPC service.
  */
 static int svc_create_socket(struct svc_serv *serv, int protocol,
-				struct sockaddr_in *sin, int flags)
+				struct sockaddr *sin, int len, int flags)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
@@ -1688,8 +1688,7 @@ static int svc_create_socket(struct svc_
 
 	dprintk("svc: svc_create_socket(%s, %d, %s)\n",
 			serv->sv_program->pg_name, protocol,
-			__svc_print_addr((struct sockaddr *) sin, buf,
-								sizeof(buf)));
+			__svc_print_addr(sin, buf, sizeof(buf)));
 
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "
@@ -1698,15 +1697,14 @@ static int svc_create_socket(struct svc_
 	}
 	type = (protocol == IPPROTO_UDP)? SOCK_DGRAM : SOCK_STREAM;
 
-	if ((error = sock_create_kern(PF_INET, type, protocol, &sock)) < 0)
+	if ((error = sock_create_kern(sin->sa_family, type, protocol, &sock)) < 0)
 		return error;
 
 	svc_reclassify_socket(sock);
 
 	if (type == SOCK_STREAM)
-		sock->sk->sk_reuse = 1; /* allow address reuse */
-	error = kernel_bind(sock, (struct sockaddr *) sin,
-					sizeof(*sin));
+		sock->sk->sk_reuse = 1;		/* allow address reuse */
+	error = kernel_bind(sock, sin, len);
 	if (error < 0)
 		goto bummer;
 
@@ -1784,7 +1782,8 @@ int svc_makesock(struct svc_serv *serv, 
 	};
 
 	dprintk("svc: creating socket proto = %d\n", protocol);
-	return svc_create_socket(serv, protocol, &sin, flags);
+	return svc_create_socket(serv, protocol, (struct sockaddr *) &sin,
+							sizeof(sin), flags);
 }
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
