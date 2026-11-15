Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765859;
	b=dHgG23jH39c1UzdJ96fnXWPjjvdg8fYlXW3+GNajDuzXj79f3wwKhoSpdTMh4T1R0X8U
	 72nYD/CRK4QTIHLPUl0km9ihRmc+nsl19y7aExMsCAaXYc9ze243EjQO1ub4uYUyR7SLa
	 XuV+t75gkX6H41bz9VLd5yk7B6v+aYkaJ3Dw/HJiHQzvF32SHpDkzxvyVOLV8h1TofEcd
	 B33VTcaW0HwaOX+5v0uVsoLx1E+AXIGAHexpEWYmHceBkQh5+DSoPMncUh8YI31MmR8Xk
	 FvAHm6oBz79Cxf0ys1hjGq5vT+89FBilWed72tVFhSG4aPfmdBoT4emyWaVdoYVazRQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765859;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=xf9H7Xpls5bTYgvWPqTUbZKwhVzPiZ1KJIKZ28Qv1VM=;
	b=anIaDw0oiOLUoMQSItCSJKW5oINtI3cCy/g4RpNYgAjMM78l19648nPN1jt7+U2yFVo1
	 lQkfdx/5j2xt3HbwwNKQsZuEncseJtnCWyb1SVnaLgYZHjrgoCQ1FbY1uy+KmaMDVBMAm
	 n9LI6g0ezwKV8TIVjlm92pxyhmPCx5cEvPxoGIi+6LwBo/BSzP+SKLt/5j46kQpWyP2Kx
	 7axlj+Z8k842+DomSdiKgqwgIoEzxL1ryerNuJHH8EEbx2Ot2cln11Njv/SmPFpyIQme7
	 PqKU9m+VhiGX6m6pU0RrZotNSi5coGs6s/9E37cIdVUVG0qOv6ox72fZZBzBQktjQpg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=j9j0Ugd7;
	arc=none smtp.remote-ip=209.85.221.48
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F21060A6F55
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3F21060A6F55
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=j9j0Ugd7
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-48dee593f18so2930412f8f.3
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765857; x=1795370657; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xf9H7Xpls5bTYgvWPqTUbZKwhVzPiZ1KJIKZ28Qv1VM=;
        b=j9j0Ugd7VJ9ks5rDGJwcAQFJKFk9vhh3zfSEndffcNbUrLK01mqCXInIlkneQRVFq5
         Tx1+AFpuiPcr3JcHOzXv4iLA0lCoAs12tvSs5yy8wxNJQ7SfXrFdsGr6g6IQvMrF49J5
         a89C0v0tXyZ2XzmI2H/SKpGQmULgPVYTg8uLw+fOnYKiWjTaZ1+pBZWES1sqWd1HEoqG
         YRVi2cRWHohFAuedi+1l+ZQsaE4PjiGSDahAYKWpEF7ZeCtSDK0XqWKg+LF4WMm+Yd/H
         s0qMu+LwAHij4DQiHGR3w1mh6f4woADhw7IjX2OzkkKxqgNcLkY/UZPlmkHQlmtto6Z/
         pZDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765857; x=1795370657;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=xf9H7Xpls5bTYgvWPqTUbZKwhVzPiZ1KJIKZ28Qv1VM=;
        b=2QqyTxNdKHgWpNh6/ApvSWKxVwvhLNhjUEVDhB7C1kr7N9m+u8nai+x0NDzx69WDvY
         vyD4HWDCgNzmjiAt+Bw5aaMi7hwwil9XtPwLLa0XV97SrzDtRxVnVFWzmqj1IVVdaqWm
         cxr9Pdmnb1jGJrpFGEh08xBdIftJqCUGFP+Wuxze+k9ndqxIiqgSFDcyNMF5nnpGfBQb
         ypt8HqYUTZR6UO2LyyZk6QWHsY/5ld3Za4oouirCM+52Ap9JpThodn0lAyGHD40cYa+Y
         q5BqoqngeZTJVYYJsG+thdIdyZMeq5LPJgCk3AJBemkdawzUqLqQwLnUjHRGAk/8GV5i
         eOgg==
X-Forwarded-Encrypted: i=1; AL+hErEzkBZgH3uCUoOGKvRRlhVUjTZLK7TEOoZF/AlsY+33UeX8S3snUKGueO2p9tFoab5KAdUizoYFZOg=@vger.kernel.org
X-Gm-Message-State: APuU4Z+yvPGHQO68HALNtw2+niKkzeN3QGROjo6V2ZPwCXo72WU7sUPf
	2BHfCIWFpk1Ih5VYymOjTrpqYQKi1ZIdZkr0BT6ZUw46R/b6Qa5IKOKR
X-Gm-Gg: AYBFou2uF6Pn/6v6oH1hRlHDXQ5s0B1eF/olhNXWPrThMa7hcbewkscO/JpFRe+x/s3
	yL9Z+MhSqHA796AQ7QzL60AtVTA6dwZsR8VdV9usXyQgpP4otHsgh5KoArOXdiq7I8CbZCkzz+1
	/KrGTm+0wrJKTuS/xilXh1E7fDyDdf8kuanV1kNWalnorsoJyGOu8lSQrSzBu4PBUdD8mwidC4h
	uHiY7cBEbvEmoS+45M+tGPi3tc6O+IltT/MTdOl81IsP7AZj+e1isGrkOxVoljCKBlK9EO7W0aN
	nonKyjbYOFa4sxmr9G2hyR2xmnSd1ixhzoeaWn5ClHlSX9EOyoFo/iWNYcAMP5TEsT7WFQjpZaw
	D3CjJiDGE3Uvr969rak2hU8i3bu3UHFI2sUKyvW0atdSvtDX4Ycn9UjefFUMBUJT0fUMYRltLyy
	s/jMdSClDPgnamJZ3XmrSUNrKRtx6Sapf6M6Wy83Il6FPuJ1YOxr3oID/QzGeUqvMaCpvI0zaQT
	I0Skjkl14vnL980P9SJq/ROkLzUJFpEqNayhzvgCdzr6nnyXy4UCN8ZdNKiKeTsXvQUrEjjbe/5
	kcPXYRsQl8rohAeUnW+A1PLU
X-Received: by 2002:a05:6000:2886:b0:4a1:bddf:9003 with SMTP id ffacd0b85a97d-4a1bddf9034mr802741f8f.49.1794765856553;
        Sun, 15 Nov 2026 10:04:16 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.04.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:16 -0800 (PST)
From: koraynilay <koray.fra@gmail.com>
To: David Sterba <dsterba@suse.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>
Cc: Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>,
	Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>,
	Amir Goldstein <amir73il@gmail.com>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali@kernel.org>,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev,
	ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org,
	koraynilay <koray.fra@gmail.com>
Subject: [RFC PATCH v4 08/10] nfs: add provenance time (ptime) via FATTR4_TIME_CREATE
Date: Sun, 15 Nov 2026 19:03:41 +0100
Message-ID: <20261115180343.576773-9-koray.fra@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261115180343.576773-1-koray.fra@gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Implement provenance time (ptime) in the NFS client, as introduced in a
previous commit ("vfs: add provenance time (ptime)").

Support reading ptime via statx(2) and file_getattr(), returning the
cached creation time when the server advertises NFS_ATTR_FATTR_BTIME.

Implement sending FATTR4_TIME_CREATE, asking the server to persist the
file creation time using ptime on the underlying filesystem.

Also add .fileattr_set to struct nfs_rpc_ops and set it to
nfs4_fileattr_set() in nfs_v4_clientops. Provide a generic
nfs_fileattr_set() dispatcher so even symlinks can update ptime under
NFSv4 while cleanly returning -EOPNOTSUPP on NFSv2/v3.

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/nfs/inode.c          | 27 ++++++++++++++++----
 fs/nfs/internal.h       |  2 ++
 fs/nfs/nfs4proc.c       | 56 ++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4xdr.c        | 19 +++++++++-----
 fs/nfs/symlink.c        |  1 +
 include/linux/nfs_xdr.h |  3 +++
 6 files changed, 93 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e0a2e92952af..2ddcfd872616 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -955,7 +955,7 @@ static u32 nfs_get_valid_attrmask(struct inode *inode)
 		reply_mask |= STATX_BLOCKS;
 	if (!(cache_validity & NFS_INO_INVALID_BTIME) &&
 	    (fattr_valid & NFS_ATTR_FATTR_BTIME))
-		reply_mask |= STATX_BTIME;
+		reply_mask |= STATX_BTIME | STATX_PTIME;
 	if (!(cache_validity & NFS_INO_INVALID_CHANGE))
 		reply_mask |= STATX_CHANGE_COOKIE;
 	return reply_mask;
@@ -978,10 +978,10 @@ int nfs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 	request_mask &= STATX_TYPE | STATX_MODE | STATX_NLINK | STATX_UID |
 			STATX_GID | STATX_ATIME | STATX_MTIME | STATX_CTIME |
 			STATX_INO | STATX_SIZE | STATX_BLOCKS | STATX_BTIME |
-			STATX_CHANGE_COOKIE;
+			STATX_PTIME | STATX_CHANGE_COOKIE;
 
 	if (!(fattr_valid & NFS_ATTR_FATTR_BTIME))
-		request_mask &= ~STATX_BTIME;
+		request_mask &= ~(STATX_BTIME | STATX_PTIME);
 
 	if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync) {
 		if (readdirplus_enabled)
@@ -1015,7 +1015,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 	if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX_CTIME|
 					STATX_MTIME|STATX_UID|STATX_GID|
 					STATX_SIZE|STATX_BLOCKS|STATX_BTIME|
-					STATX_CHANGE_COOKIE)))
+					STATX_PTIME|STATX_CHANGE_COOKIE)))
 		goto out_no_revalidate;
 
 	/* Check whether the cached attributes are stale */
@@ -1038,7 +1038,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 		do_update |= cache_validity & NFS_INO_INVALID_OTHER;
 	if (request_mask & STATX_BLOCKS)
 		do_update |= cache_validity & NFS_INO_INVALID_BLOCKS;
-	if (request_mask & STATX_BTIME)
+	if (request_mask & (STATX_BTIME | STATX_PTIME))
 		do_update |= cache_validity & NFS_INO_INVALID_BTIME;
 
 	if (do_update) {
@@ -1061,6 +1061,7 @@ int nfs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 	if (S_ISDIR(inode->i_mode))
 		stat->blksize = NFS_SERVER(inode)->dtsize;
 	stat->btime = NFS_I(inode)->btime;
+	stat->ptime = NFS_I(inode)->btime;
 
 	/* Special handling for STATX_DIOALIGN and STATX_DIO_READ_ALIGN
 	 * - NFS doesn't have DIO alignment constraints, avoid getting
@@ -1092,10 +1093,26 @@ int nfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 	}
 	if (nfs_server_capable(inode, NFS_CAP_CASE_NONPRESERVING))
 		fa->fsx_xflags |= FS_XFLAG_CASENONPRESERVING;
+	if (NFS_SERVER(inode)->fattr_valid & NFS_ATTR_FATTR_BTIME) {
+		fa->fsx_xflags |= FS_XFLAG_PTIME;
+		fa->fsx_xflags_mask |= FS_XFLAG_PTIME;
+		fa->fsx_ptime = NFS_I(inode)->btime;
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_fileattr_get);
 
+int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+		     struct file_kattr *fa)
+{
+	const struct nfs_rpc_ops *ops = NFS_PROTO(d_inode(dentry));
+
+	if (ops->fileattr_set)
+		return ops->fileattr_set(idmap, dentry, fa);
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(nfs_fileattr_set);
+
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 {
 	refcount_set(&l_ctx->count, 1);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5af6a032f145..0e47fad944de 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -458,6 +458,8 @@ extern int nfs_wait_bit_killable(struct wait_bit_key *key, int mode);
 
 struct file_kattr;
 int nfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa);
+int nfs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+		     struct file_kattr *fa);
 
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
 /* localio.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1018b03c1cb..31d58ceb4dc0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -55,6 +55,7 @@
 #include <linux/utsname.h>
 #include <linux/freezer.h>
 #include <linux/iversion.h>
+#include <linux/fileattr.h>
 
 #include "nfs4_fs.h"
 #include "delegation.h"
@@ -98,7 +99,8 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fattr *fattr, struct inode *inode);
 static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
-			    struct nfs_open_context *ctx, struct nfs4_label *ilabel);
+			    struct nfs_open_context *ctx, struct nfs4_label *ilabel,
+			    const struct timespec64 *time_create);
 static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		const struct cred *cred,
 		struct nfs4_slot *slot,
@@ -3216,7 +3218,7 @@ static int _nfs4_do_open(struct inode *dir,
 			nfs_fattr_init(opendata->o_res.f_attr);
 			status = nfs4_do_setattr(state->inode, cred,
 					opendata->o_res.f_attr, sattr,
-					ctx, label);
+					ctx, label, NULL);
 			if (status == 0) {
 				nfs_setattr_update_inode(state->inode, sattr,
 						opendata->o_res.f_attr);
@@ -3380,7 +3382,8 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 			   struct nfs_fattr *fattr, struct iattr *sattr,
-			   struct nfs_open_context *ctx, struct nfs4_label *ilabel)
+			   struct nfs_open_context *ctx, struct nfs4_label *ilabel,
+			   const struct timespec64 *time_create)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	__u32 bitmask[NFS4_BITMASK_SZ];
@@ -3391,6 +3394,7 @@ static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 		.server		= server,
 		.bitmask = bitmask,
 		.label		= ilabel,
+		.time_create	= time_create,
 	};
 	struct nfs_setattrres  res = {
 		.fattr		= fattr,
@@ -3414,6 +3418,9 @@ static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 	if (sattr->ia_valid & ATTR_MTIME)
 		adjust_flags |= NFS_INO_INVALID_MTIME;
 
+	if (time_create)
+		adjust_flags |= NFS_INO_INVALID_BTIME;
+
 	do {
 		nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fattr->label),
 					inode, adjust_flags);
@@ -4587,7 +4594,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	if ((sattr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
 		nfs4_inode_make_writeable(inode);
 
-	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, ctx, NULL, NULL);
 	if (status == 0) {
 		nfs_setattr_update_inode(inode, sattr, fattr);
 		nfs_setsecurity(inode, fattr);
@@ -10845,6 +10852,44 @@ static void nfs4_disable_swap(struct inode *inode)
 	wake_up_var(&clp->cl_state);
 }
 
+#define NFS4_SUPPORTED_XFLAGS	(FS_XFLAG_PTIME)
+static int nfs4_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
+			     struct file_kattr *fa)
+{
+	struct inode *inode = d_inode(dentry);
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_fattr *fattr;
+	struct iattr sattr = { .ia_valid = 0 };
+	const struct timespec64 *time_create = NULL;
+	int error;
+
+	if (!(server->fattr_valid & NFS_ATTR_FATTR_BTIME))
+		return -EOPNOTSUPP;
+
+	if (fa->flags_valid)
+		return -EOPNOTSUPP;
+
+	if (fileattr_has_fsx_mask(fa, NFS4_SUPPORTED_XFLAGS))
+		return -EOPNOTSUPP;
+
+	if (fa->fsx_xflags_mask & ~NFS4_SUPPORTED_XFLAGS)
+		return -EOPNOTSUPP;
+
+	if (fa->fsx_xflags_mask & FS_XFLAG_PTIME)
+		time_create = &fa->fsx_ptime;
+
+	fattr = nfs_alloc_fattr_with_label(server);
+	if (!fattr)
+		return -ENOMEM;
+
+	error = nfs4_do_setattr(inode, NULL, fattr, &sattr, NULL, NULL, time_create);
+	if (error == 0)
+		nfs_refresh_inode(inode, fattr);
+
+	nfs_free_fattr(fattr);
+	return error;
+}
+
 static const struct inode_operations nfs4_dir_inode_operations = {
 	.create		= nfs_create,
 	.lookup		= nfs_lookup,
@@ -10861,6 +10906,7 @@ static const struct inode_operations nfs4_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 	.listxattr	= nfs4_listxattr,
 	.fileattr_get	= nfs_fileattr_get,
+	.fileattr_set	= nfs4_fileattr_set,
 };
 
 static const struct inode_operations nfs4_file_inode_operations = {
@@ -10869,6 +10915,7 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.setattr	= nfs_setattr,
 	.listxattr	= nfs4_listxattr,
 	.fileattr_get	= nfs_fileattr_get,
+	.fileattr_set	= nfs4_fileattr_set,
 };
 
 static struct nfs_server *nfs4_clone_server(struct nfs_server *source,
@@ -10905,6 +10952,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.try_get_tree	= nfs4_try_get_tree,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
+	.fileattr_set	= nfs4_fileattr_set,
 	.lookup		= nfs4_proc_lookup,
 	.lookupp	= nfs4_proc_lookupp,
 	.access		= nfs4_proc_access,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 740f3bc4a19d..dc1dff06c5da 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1086,7 +1086,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 				const struct nfs4_label *label,
 				const umode_t *umask,
 				const struct nfs_server *server,
-				const uint32_t attrmask[])
+				const uint32_t attrmask[],
+				const struct timespec64 *time_create)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -1147,6 +1148,10 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 			len += 4;
 		}
 	}
+	if (time_create && (attrmask[1] & FATTR4_WORD1_TIME_CREATE)) {
+		bmval[1] |= FATTR4_WORD1_TIME_CREATE;
+		len += (nfstime4_maxsz << 2);
+	}
 	if (attrmask[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
 		if (iap->ia_valid & ATTR_MTIME_SET) {
 			bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
@@ -1180,6 +1185,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		} else
 			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
+	if (bmval[1] & FATTR4_WORD1_TIME_CREATE)
+		p = xdr_encode_nfstime4(p, time_create);
 	if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
 		if (iap->ia_valid & ATTR_MTIME_SET) {
 			*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
@@ -1252,7 +1259,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 
 	encode_string(xdr, create->name->len, create->name->name);
 	encode_attrs(xdr, create->attrs, create->label, &create->umask,
-			create->server, create->server->attr_bitmask);
+			create->server, create->server->attr_bitmask, NULL);
 }
 
 static void encode_getattr(struct xdr_stream *xdr,
@@ -1440,12 +1447,12 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	case NFS4_CREATE_UNCHECKED:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
 		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
-				arg->server, arg->server->attr_bitmask);
+				arg->server, arg->server->attr_bitmask, NULL);
 		break;
 	case NFS4_CREATE_GUARDED:
 		*p = cpu_to_be32(NFS4_CREATE_GUARDED);
 		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
-				arg->server, arg->server->attr_bitmask);
+				arg->server, arg->server->attr_bitmask, NULL);
 		break;
 	case NFS4_CREATE_EXCLUSIVE:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
@@ -1455,7 +1462,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
 		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
-				arg->server, arg->server->exclcreat_bitmask);
+				arg->server, arg->server->exclcreat_bitmask, NULL);
 	}
 }
 
@@ -1737,7 +1744,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
 	encode_attrs(xdr, arg->iap, arg->label, NULL, server,
-			server->attr_bitmask);
+			server->attr_bitmask, arg->time_create);
 }
 
 static void encode_delegattr(struct xdr_stream *xdr,
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 74a072896f8d..8f50e56fbda0 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -77,4 +77,5 @@ const struct inode_operations nfs_symlink_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 	.fileattr_get	= nfs_fileattr_get,
+	.fileattr_set	= nfs_fileattr_set,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c0e29b4dfa62..8576c8d8e840 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -833,6 +833,7 @@ struct nfs_setattrargs {
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
 	const struct nfs4_label		*label;
+	const struct timespec64		*time_create;
 };
 
 enum nfs4_acl_type {
@@ -1801,6 +1802,8 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *, struct inode *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
+	int	(*fileattr_set)(const struct mnt_idmap *, struct dentry *,
+				struct file_kattr *);
 	int	(*lookup)  (struct inode *, struct dentry *, const struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*lookupp) (struct inode *, struct nfs_fh *,
-- 
2.56.0

