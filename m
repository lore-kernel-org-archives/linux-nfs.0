From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] NFS: Use C99 structure declaration in client.c
Date: Fri, 25 May 2007 17:41:10 -0400
Message-ID: <20070525214110.28668.49762.stgit@schiele.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrhXn-0003zw-CK
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:55 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HrhXq-0003zF-9S
	for nfs@lists.sourceforge.net; Fri, 25 May 2007 14:41:58 -0700
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

And clean up some white space and commas.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 881fa49..e2a8d4c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -72,17 +72,20 @@ struct rpc_program nfs_program = {
 };
 
 struct rpc_stat nfs_rpcstat = {
-	.program		= &nfs_program
+	.program		= &nfs_program,
 };
 
 
 #ifdef CONFIG_NFS_V3_ACL
-static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static struct rpc_version *	nfsacl_version[] = {
+static struct rpc_stat nfsacl_rpcstat = {
+	.program		= &nfsacl_program,
+};
+
+static struct rpc_version *nfsacl_version[] = {
 	[3]			= &nfsacl_version3,
 };
 
-struct rpc_program		nfsacl_program = {
+struct rpc_program nfsacl_program = {
 	.name			= "nfsacl",
 	.number			= NFS_ACL_PROGRAM,
 	.nrvers			= ARRAY_SIZE(nfsacl_version),


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
