From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] NFS: switch NFSROOT to use new rpcbind client
Date: Wed, 24 Jan 2007 14:20:10 -0500
Message-ID: <20070124192010.31133.18316.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngn-0001AU-NM
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:45 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngk-0004Se-5z
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

It is arguable whether NFSROOT will support IPv6, and thus whether the
rpcb_getport_external API needs to support rpcbind versions greater than 2.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 75f819d..49d1008 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -428,7 +428,7 @@ static int __init root_nfs_getport(int p
 	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %u.%u.%u.%u\n",
 		program, version, NIPQUAD(servaddr));
 	set_sockaddr(&sin, servaddr, 0);
-	return rpc_getport_external(&sin, program, version, proto);
+	return rpcb_getport_external(&sin, program, version, proto);
 }
 
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
