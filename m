From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/21] NFS: Clean-up: fix a compiler warning in
	fs/nfs/super.c
Date: Sun, 01 Jul 2007 12:12:40 -0400
Message-ID: <20070701161240.2786.56660.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523x-0004Xk-Rb
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:13 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5240-000571-7d
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:17 -0700
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

/home/cel/linux/fs/nfs/super.c: In function 'nfs_pseudoflavour_to_name':
/home/cel/linux/fs/nfs/super.c:270: warning: comparison between signed and unsigned

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e98f7ca..2b8839c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -263,11 +263,11 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
 		{ RPC_AUTH_GSS_SPKM, "spkm" },
 		{ RPC_AUTH_GSS_SPKMI, "spkmi" },
 		{ RPC_AUTH_GSS_SPKMP, "spkmp" },
-		{ -1, "unknown" }
+		{ UINT_MAX, "unknown" }
 	};
 	int i;
 
-	for (i=0; sec_flavours[i].flavour != -1; i++) {
+	for (i = 0; sec_flavours[i].flavour != UINT_MAX; i++) {
 		if (sec_flavours[i].flavour == flavour)
 			break;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
