From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] NFS: Integrate support for processing nfs4 mount
	options	in fs/nfs/super.c
Date: Mon, 23 Apr 2007 18:04:14 -0400
Message-ID: <20070423220414.24305.30131.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6e1-0003PW-5h
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:25 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6e0-0008PU-HV
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:24 -0700
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

Finally, hook in the new mount option parsing logic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   73 ++++++++------------------------------------------------
 1 files changed, 11 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 97bbe10..be3f349 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -13,6 +13,8 @@
  *
  *  Split from inode.c by David Howells <dhowells@redhat.com>
  *
+ *  In-kernel mount option parsing by Chuck Lever <chuck.lever@oracle.com>
+ *
  * - superblocks are indexed on server only - all inodes, dentries, etc. associated with a
  *   particular server are held in the same superblock
  * - NFS superblocks can have several effective roots to the dentry tree
@@ -1278,66 +1280,13 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	struct nfs_fh mntfh;
 	struct dentry *mntroot;
 	char *mntpath = NULL, *hostname = NULL, ip_addr[81];
-	void *p;
 	int error;
 
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		return -EINVAL;
-	}
-	if (data->version <= 0 || data->version > NFS4_MOUNT_VERSION) {
-		dprintk("%s: bad mount version\n", __FUNCTION__);
-		return -EINVAL;
-	}
-
-	/* We now require that the mount process passes the remote address */
-	if (data->host_addrlen != sizeof(addr))
-		return -EINVAL;
-
-	if (copy_from_user(&addr, data->host_addr, sizeof(addr)))
-		return -EFAULT;
-
-	if (!nfs_verify_server_address((struct sockaddr *) &addr,
-					data->host_addrlen))
-		return -EINVAL;
-
-	/* RFC3530: The default port for NFS is 2049 */
-	if (addr.sin_port == 0)
-		addr.sin_port = htons(NFS_PORT);
-
-	/* Grab the authentication type */
-	authflavour = RPC_AUTH_UNIX;
-	if (data->auth_flavourlen != 0) {
-		if (data->auth_flavourlen != 1) {
-			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
-					__FUNCTION__, data->auth_flavourlen);
-			error = -EINVAL;
-			goto out_err_noserver;
-		}
-
-		if (copy_from_user(&authflavour, data->auth_flavours,
-				   sizeof(authflavour))) {
-			error = -EFAULT;
-			goto out_err_noserver;
-		}
-	}
-
-	p = nfs_copy_user_string(NULL, &data->hostname, 256);
-	if (IS_ERR(p))
-		goto out_err;
-	hostname = p;
-
-	p = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
-	if (IS_ERR(p))
-		goto out_err;
-	mntpath = p;
-
-	dprintk("MNTPATH: %s\n", mntpath);
-
-	p = nfs_copy_user_string(ip_addr, &data->client_addr,
-				 sizeof(ip_addr) - 1);
-	if (IS_ERR(p))
-		goto out_err;
+	error = nfs4_validate_mount_data(&data, dev_name, &addr,
+					 &authflavour, &hostname,
+					 &mntpath, ip_addr);
+	if (error < 0)
+		return error;
 
 	/* Get a volume representation */
 	server = nfs4_create_server(data, hostname, (struct sockaddr *) &addr,
@@ -1377,17 +1326,17 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	mnt->mnt_root = mntroot;
 	kfree(mntpath);
 	kfree(hostname);
+	if (data->version == 2)
+		kfree(data);
 	return 0;
 
-out_err:
-	error = PTR_ERR(p);
-	goto out_err_noserver;
-
 out_free:
 	nfs_free_server(server);
 out_err_noserver:
 	kfree(mntpath);
 	kfree(hostname);
+	if (data->version == 2)
+		kfree(data);
 	return error;
 
 error_splat_super:


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
