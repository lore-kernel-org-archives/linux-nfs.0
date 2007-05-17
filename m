From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Error when mounting the same filesystem with
	different options
Date: Wed, 16 May 2007 22:13:23 -0400
Message-ID: <20070517021323.32447.13696.stgit@heimdal.trondhjem.org>
References: <17994.32412.173039.15055@notabene.brown>
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
	id 1HoVUd-00053A-3e
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:13:30 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoVUf-00075q-IE
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:13:30 -0700
In-Reply-To: <17994.32412.173039.15055@notabene.brown>
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

 fs/nfs/super.c |   43 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 42 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c03120a..f7f8844 100644
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
@@ -611,6 +613,39 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 	return 1;
 }
 
+#define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
+
+static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
+{
+	const struct nfs_server *a = s->s_fs_info;
+	const struct rpc_clnt *clnt_a = a->client;
+	const struct rpc_clnt *clnt_b = b->client;
+
+	if ((s->s_flags & NFS_MS_MASK) != (flags & NFS_MS_MASK))
+		goto Ebusy;
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
+	if (clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
+		goto Ebusy;
+	return 0;
+Ebusy:
+	return -EBUSY;
+}
+
 static int nfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
@@ -645,8 +680,11 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	}
 
 	if (s->s_fs_info != server) {
+		error = nfs_compare_mount_options(s, server, flags);
 		nfs_free_server(server);
 		server = NULL;
+		if (error < 0)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -903,8 +941,11 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	}
 
 	if (s->s_fs_info != server) {
+		error = nfs_compare_mount_options(s, server, flags);
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
