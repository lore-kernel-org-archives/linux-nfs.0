From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Error when mounting the same filesystem with
	different options
Date: Tue, 15 May 2007 21:37:01 -0400
Message-ID: <20070516013701.26323.73324.stgit@heimdal.trondhjem.org>
References: <17992.63372.522494.519874@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Ian Kent <raven@themaw.net>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho8Rt-0005zW-Vf
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 18:37:06 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ho8Rv-0007xf-Dd
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 18:37:08 -0700
In-Reply-To: <17992.63372.522494.519874@notabene.brown>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Unless the user sets the NFS_MOUNT_NOSHAREDCACHE mount flag, we should
return EBUSY if the filesystem is already mounted on a superblock that
has set conflicting mount options.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c03120a..fd6e330 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -601,7 +601,9 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_server *server = data, *old = NFS_SB(sb);
 
-	if (old->nfs_client != server->nfs_client)
+	if (memcmp(&old->nfs_client->cl_addr,
+				&server->nfs_client->cl_addr,
+				sizeof(old->nfs_client->cl_addr)) != 0)
 		return 0;
 	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
 	if (old->flags & NFS_MOUNT_UNSHARED)
@@ -611,6 +613,29 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 	return 1;
 }
 
+static int nfs_compare_mount_options(const struct nfs_server *a, const struct nfs_server *b)
+{
+	if (a->nfs_client != b->nfs_client)
+		goto Ebusy;
+	if (a->flags != b->flags)
+		goto Ebusy;
+	if (a->wsize != b->wsize)
+		goto Ebusy;
+	if (a->rsize != b->rsize)
+		goto Ebusy;
+	if (a->acregmin != b->acregmin)
+		goto Ebusy;
+	if (a->acregmax != b->acregmax)
+		goto Ebusy;
+	if (a->acdirmin != b->acdirmin)
+		goto Ebusy;
+	if (a->acdirmax != b->acdirmax)
+		goto Ebusy;
+	return 0;
+Ebusy:
+	return -EBUSY;
+}
+
 static int nfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
@@ -645,8 +670,11 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	}
 
 	if (s->s_fs_info != server) {
+		error = nfs_compare_mount_options(server, NFS_SB(s));
 		nfs_free_server(server);
 		server = NULL;
+		if (error < 0)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -903,8 +931,11 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	}
 
 	if (s->s_fs_info != server) {
+		error = nfs_compare_mount_options(server, NFS_SB(s));
 		nfs_free_server(server);
 		server = NULL;
+		if (error < 0)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
