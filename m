From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/14] SUNRPC: switch the RPC server to use the new
	rpcbind registration API
Date: Thu, 18 Jan 2007 18:30:31 -0500
Message-ID: <20070118233031.23310.24982.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7gib-0002p8-Lm
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:53 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7giY-0004TZ-Lp
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:52 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
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

Eventually this interface will support versions 3 and 4 of the rpcbind
protocol, which will allow the Linux RPC server to register services on
IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6627759..d38d74a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -666,7 +666,7 @@ svc_register(struct svc_serv *serv, int 
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = rpc_register(progp->pg_prog, i, proto, port, &dummy);
+			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
 			if (error < 0)
 				break;
 			if (port && !dummy) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
