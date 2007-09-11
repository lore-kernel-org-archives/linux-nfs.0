From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] NFS: Kernel mount client should use async bind
Date: Tue, 11 Sep 2007 18:00:58 -0400
Message-ID: <20070911220057.26136.96662.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDnd-0006z3-Ef
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:37 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDni-00026o-31
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:01:42 -0700
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

Simplify the in-kernel mount client by using autobind instead of an
explicit call to rpc_getport_sync.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e2dbfb5..2cabe09 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1027,15 +1027,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		sin = args->mount_server.address;
 	else
 		sin = args->nfs_server.address;
-	if (args->mount_server.port == 0) {
-		status = rpcb_getport_sync(&sin,
-					   args->mount_server.program,
-					   args->mount_server.version,
-					   args->mount_server.protocol);
-		if (status < 0)
-			goto out_err;
-		sin.sin_port = htons(status);
-	} else
+	if (args->mount_server.port != 0)
 		sin.sin_port = htons(args->mount_server.port);
 
 	/*
@@ -1049,14 +1041,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			   args->mount_server.version,
 			   args->mount_server.protocol,
 			   root_fh);
-	if (status < 0)
-		goto out_err;
-
-	return status;
+	if (status == 0)
+		return 0;
 
-out_err:
-	dfprintk(MOUNT, "NFS: unable to contact server on host "
-		 NIPQUAD_FMT "\n", NIPQUAD(sin.sin_addr.s_addr));
+	dfprintk(MOUNT, "NFS: unable to mount server " NIPQUAD_FMT
+			", error %d\n", NIPQUAD(sin.sin_addr.s_addr), status);
 	return status;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
