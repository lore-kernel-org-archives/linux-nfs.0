Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:58254 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422626Ab3DEQyO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:54:14 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v4 5/7] NFSv4: Add O_DENY* open flags support
Date: Fri,  5 Apr 2013 20:57:53 +0400
Message-Id: <1365181075-22540-6-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
References: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by passing these flags to NFSv4 open request.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c        |  6 +++---
 fs/nfs/internal.h |  3 ++-
 fs/nfs/nfs4proc.c |  2 ++
 fs/nfs/nfs4xdr.c  | 21 +++++++++++++++++----
 fs/nfs/super.c    |  3 ++-
 5 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 2184ddd..67c68fb 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -852,10 +852,10 @@ deny_lock_file(struct file *filp)
 		return error;
 
 	/*
-	 * Don't set a lock on CIFS file systems because they can process it
-	 * themselves.
+	 * Don't set a lock on CIFS and NFSv4 file systems because they can
+	 * process it themselves.
 	 */
-	if (!strncmp(fsname, "cifs", 4))
+	if (!strncmp(fsname, "cifs", 4) || !strncmp(fsname, "nfs4", 4))
 		return error;
 
 	error = flock_make_lock(filp, &lock, deny_flags_to_cmd(filp->f_flags));
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f0e6c7d..c770830 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -6,7 +6,8 @@
 #include <linux/mount.h>
 #include <linux/security.h>
 
-#define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
+#define NFS_MS_MASK (MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC | \
+		     MS_SYNCHRONOUS | MS_SHARELOCK)
 
 struct nfs_string;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3cb5e77..9e33a54 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -793,6 +793,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	atomic_inc(&sp->so_count);
 	p->o_arg.fh = NFS_FH(dir);
 	p->o_arg.open_flags = flags;
+	if (!IS_SHARELOCK(dir))
+		p->o_arg.open_flags &= ~(O_DENYREAD | O_DENYWRITE);
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
 	 * will return permission denied for all bits until close */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26b1439..8fe0221 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1325,7 +1325,8 @@ static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struc
 	encode_string(xdr, name->len, name->name);
 }
 
-static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
+static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode,
+				int open_flags)
 {
 	__be32 *p;
 
@@ -1343,7 +1344,19 @@ static void encode_share_access(struct xdr_stream *xdr, fmode_t fmode)
 	default:
 		*p++ = cpu_to_be32(0);
 	}
-	*p = cpu_to_be32(0);		/* for linux, share_deny = 0 always */
+	switch (open_flags & (O_DENYREAD|O_DENYWRITE)) {
+	case O_DENYREAD:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_READ);
+		break;
+	case O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_WRITE);
+		break;
+	case O_DENYREAD|O_DENYWRITE:
+		*p = cpu_to_be32(NFS4_SHARE_DENY_BOTH);
+		break;
+	default:
+		*p = cpu_to_be32(0);
+	}
 }
 
 static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_openargs *arg)
@@ -1354,7 +1367,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  * owner 4 = 32
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, arg->open_flags);
 	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
 	*p++ = cpu_to_be32(24);
@@ -1491,7 +1504,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 	encode_op_hdr(xdr, OP_OPEN_DOWNGRADE, decode_open_downgrade_maxsz, hdr);
 	encode_nfs4_stateid(xdr, arg->stateid);
 	encode_nfs4_seqid(xdr, arg->seqid);
-	encode_share_access(xdr, arg->fmode);
+	encode_share_access(xdr, arg->fmode, 0);
 }
 
 static void
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b056b16..ba77e01 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2589,6 +2589,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
+	int sharelock = data->sb->s_flags & MS_SHARELOCK; /* save sharelock option */
 
 	dprintk("--> nfs_xdev_mount()\n");
 
@@ -2600,7 +2601,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	if (IS_ERR(server))
 		mntroot = ERR_CAST(server);
 	else
-		mntroot = nfs_fs_mount_common(server, flags,
+		mntroot = nfs_fs_mount_common(server, flags | sharelock,
 				dev_name, &mount_info, nfs_mod);
 
 	dprintk("<-- nfs_xdev_mount() = %ld\n",
-- 
1.8.1.5

