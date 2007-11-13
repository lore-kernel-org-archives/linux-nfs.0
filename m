From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/25] NFS: Add AF_INET6 support to nfs_try_mount()
Date: Tue, 13 Nov 2007 13:33:02 -0500
Message-ID: <20071113183302.5087.85854.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0ZF-0000Xi-SO
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:57 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0ZL-0007Ny-Ic
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:33:03 -0800
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

Update nfs_try_mount() to support AF_INET6 family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3ea4a4f..2abef88 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1048,7 +1048,7 @@ out_unknown:
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
-	struct sockaddr_in sin;
+	struct sockaddr *sap = (struct sockaddr *)&args->mount_server.address;
 	int status;
 	char *hostname;
 
@@ -1067,24 +1067,25 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (args->mount_server.addrlen != 0)
-		memcpy(&sin, &args->mount_server.address, sizeof(sin));
-	else
-		memcpy(&sin, &args->nfs_server.address, sizeof(sin));
+	if (args->mount_server.addrlen == 0) {
+		memcpy(&args->mount_server.address,
+		       &args->nfs_server.address,
+		       args->nfs_server.addrlen);
+		args->mount_server.addrlen = args->nfs_server.addrlen;
+	}
 
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	if (nfs_set_address_port((struct sockaddr *)&sin,
-					args->mount_server.port))
+	if (nfs_set_address_port(sap, args->mount_server.port))
 		return -EAFNOSUPPORT;
 
 	/*
 	 * Now ask the mount server to map our export path
 	 * to a file handle.
 	 */
-	status = nfs_mount((struct sockaddr *) &sin,
-			   sizeof(sin),
+	status = nfs_mount(sap,
+			   args->mount_server.addrlen,
 			   hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
