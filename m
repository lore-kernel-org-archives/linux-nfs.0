From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] NFS: Verify server address before invoking
	in-kernel	mount client
Date: Mon, 24 Sep 2007 15:39:50 -0400
Message-ID: <20070924193950.3568.54246.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnG-0001QW-BV
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:34 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtnI-0007b6-Qu
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:39 -0700
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

Re-order mount option sanity checking slightly to ensure we have a valid
server address *before* trying to do the mountd RPC call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 09044e1..a7d77f3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1098,6 +1098,10 @@ static int nfs_validate_mount_data(void *options,
 		if (mntfh->size < sizeof(mntfh->data))
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
+
+		if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
+			goto out_no_address;
+
 		/*
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
@@ -1129,6 +1133,10 @@ static int nfs_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
+		if (!nfs_verify_server_address((struct sockaddr *)
+						&args->nfs_server.address))
+			goto out_no_address;
+
 		c = strchr(dev_name, ':');
 		if (c == NULL)
 			return -EINVAL;
@@ -1157,10 +1165,6 @@ static int nfs_validate_mount_data(void *options,
 		goto out_v3_not_compiled;
 #endif /* !CONFIG_NFS_V3 */
 
-	if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
-		goto out_no_address;
-
 	return 0;
 
 out_no_data:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
