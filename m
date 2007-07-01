From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/21] NFS: Clean-up: Refactor IP address sanity
	checks in NFS	client
Date: Sun, 01 Jul 2007 12:12:46 -0400
Message-ID: <20070701161245.2786.89488.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523y-0004Xv-QV
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:15 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5242-00043F-5i
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:18 -0700
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

NFS and NFSv4 mounts can now share server address sanity checking.  And, it
provides an easy mechanism for adding IPv6 address checking at some later
point.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/super.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b8839c..f7fd2e7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -448,6 +448,23 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 }
 
 /*
+ * Sanity-check a server address provided by the mount command
+ */
+static int nfs_verify_server_address(struct sockaddr *addr)
+{
+	switch (addr->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *sa = (struct sockaddr_in *) addr;
+		if (sa->sin_addr.s_addr != INADDR_ANY)
+			return 1;
+		break;
+	}
+	}
+
+	return 0;
+}
+
+/*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  */
@@ -502,7 +519,7 @@ static int nfs_validate_mount_data(struct nfs_mount_data *data,
 #endif /* CONFIG_NFS_V3 */
 
 	/* We now require that the mount process passes the remote address */
-	if (data->addr.sin_addr.s_addr == INADDR_ANY) {
+	if (!nfs_verify_server_address((struct sockaddr *) &data->addr)) {
 		dprintk("%s: mount program didn't pass remote address!\n",
 			__FUNCTION__);
 		return -EINVAL;
@@ -870,13 +887,12 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	if (copy_from_user(&addr, data->host_addr, sizeof(addr)))
 		return -EFAULT;
 
-	if (addr.sin_family != AF_INET ||
-	    addr.sin_addr.s_addr == INADDR_ANY
-	    ) {
+	if (!nfs_verify_server_address((struct sockaddr *) &addr)) {
 		dprintk("%s: mount program didn't pass remote IP address!\n",
 				__FUNCTION__);
 		return -EINVAL;
 	}
+
 	/* RFC3530: The default port for NFS is 2049 */
 	if (addr.sin_port == 0)
 		addr.sin_port = htons(NFS_PORT);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
