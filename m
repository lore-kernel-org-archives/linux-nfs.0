From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/15] SUNRPC: switch the RPC server to use the new
	rpcbind registration API
Date: Wed, 24 Jan 2007 14:20:07 -0500
Message-ID: <20070124192007.31133.2169.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngk-0001A6-78
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:42 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngi-00015k-Td
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:44 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
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
