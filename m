Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765852;
	b=05WbrF5K+/XyzqY9t/WGwxt8PAz7jr/wbCeRpdf7QPUsdBBlGFOLSboPC2jvnSoH+KpK
	 iCgWQ56yS5ODJi4PVZOIb/9p/zAbYyMuorKQjkNq0cvyfUdCI3tbV41rmS0GVP9yfCyHN
	 HSax8jkKlrZigZ6bsj0TlvFg46soyqSGmtdgJxCFdmjiJjvPZgtH6yN0azchxJ1lBWtyf
	 s9g2abbPuFGh2j5kQU3AJSEgslRGcc4maIbB0Fjn954rgZ4NZpVpLBx6MudkbkeRXwQHM
	 UpIE12jPy6V47nU+ChS+b/0PJimPZiFWrHVx0iqcp26UHdeZ/+2UZR7wi3GwzlQH9Jw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765852;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=Q9ImLBzlDc7yTEjXopdjt0wl8ryX8CGKpq0H4Wm2vqQ=;
	b=3JAkAiR7b0+Mtmbac07kvlILp5DgCeZca/+ZNekLAl/OwWFY+wx1cpvXlioicgoA+NUU
	 c/7qtSMpb4c+oR7sSaLfE6RCR3u+MhxhZHChtxfeOknTS/IyVHwN+n0pWSrzar8eJpsnG
	 muisrevdo6wDMq1BiUsuhuj/3KlPQwaacVSaA2bpE2UxpzgfnunlDmvY5YnmuE3dO4aHt
	 GB3yfnjkxdaIt+8w1jVCfbaOIDjpl4HX3geOlKPPWvIL+3FKqBLVEECaQtgkJ/e9wRCn+
	 izTjs8DYxtdl/tKs0bx25hVZSIZj8JT6cq9liCNZNZKZaIS/VqVIIxpcKXY/oTNFMDg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=PrrwdsWe;
	arc=none smtp.remote-ip=209.85.221.42
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E72D960A3837
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E72D960A3837
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=PrrwdsWe
Received: by mail-wr1-f42.google.com with SMTP id ffacd0b85a97d-48e47347279so1068075f8f.1
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765850; x=1795370650; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Q9ImLBzlDc7yTEjXopdjt0wl8ryX8CGKpq0H4Wm2vqQ=;
        b=PrrwdsWewRRetL+OafyuO3TPg/OLhqcGEu4/QpFNufN3gi7kvGZMLO/Sctt0IC+s+h
         cbMRnv+6lDuwSzJFpIOkfTIs+aSJ0SxPNI9ypZRtLt0fLD9hio3+eIszwQ2U3IoSxsrh
         PS7S6g8lUJ0NW5zlIX08uaTYtDwhcccd0DGnL99hS6tiBZ2CtIh/F6nRb+3hnL45WYbT
         cPzanfZvlBhgQwRD4v+7GB7lqxHGlBdFI616/Paa9AKZz3m1GeHWlwP55XheJDJDfV3K
         WKhyscXlELx/o1NKWLisN+bvDB95Vu7e9bEXfFeTCIId0ltXMLEj8zPqLWNx3RUVtYqH
         iDEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765850; x=1795370650;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Q9ImLBzlDc7yTEjXopdjt0wl8ryX8CGKpq0H4Wm2vqQ=;
        b=rLCszZuHj1BW3E5e0yz/vLEcQ+YUFWqp0+aSaXumxKRKMA6NoU6+0ABxM+aTc3HS74
         1qjBg8fO+yD/s55FCO0/mFvS9/S91vrCFxsrPAE3cX/p97gmq4jueiMxbJ9cesNqwzxA
         3CnD/e1yIL1bYbGLVXSzalgoZrcYMvLbanz8GFC5nvjOaWRoORYxuhOuONRVl0qY7dUJ
         KMsa6MAfU1QuhML68Ed2/CzG5x0UjnSinecs71hkxg6YXEO3ny3PALC6kTN/uWANWhiK
         VxVU4hwby7qRVdSoasaj7d5O3GbPwUW663qIz2mu3AnOJTB3Gfmh5P7yXOenqA4QVjJy
         hkpA==
X-Forwarded-Encrypted: i=1; AL+hErGkLyuvCrCrVmRRd7jy2ohBRIA6RuJ+9SuiPV3UErvhoBkqjuC/gFETOypPRVGVFMLFfbztfRC2qmQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z+9tIG+pGh1Ch2iDb3o3JYCzrl6Zfx18AzzBV7N/KpraABSm2JH
	1o4tgs0JqgrBjp9Sz057TxYfQv3wePkiwBqHVrLECRHNzB3XiMCYKPSV
X-Gm-Gg: AYBFou0s9IPZT1H7p7Skerg1hZft6jb4ENUPAieJgeviM8mrNW3HKDvuvBLqBrUl8Fv
	lBQu+8PcunCtthysKqZ567IjiIU8ozvp92F6VJhFA8U7Z9zLHRsjZU5CdZ//Pd4GN2y19mntYO2
	Qqe/li93eF+vh1NGjhHLMt0kq4cO5ZaazFkyJIrrwz7U6+71QfkQ81UY3Z5JkzGj9JBNDBe5c6d
	yFE1hpAFaETLzfZigE3q9CEJbVox754WPM8ol4dc+zUP5jAI5QAhI/jhX41frvweDxQm6JKIcUC
	zWS8jo4OeRpy6q9eXnKW2n+dDttk8vaZrrx16Jy2H6ACI9NNYeqBu9m9q850Nco2ntdi4v9q47c
	NvswxBLUZOseolMz4V/rc8Hz9zwzcPpRp1CM4EO/ehOsGg5ZakkV30BlVJxWsPtnbsi+AMk1kVt
	/qyucdkaKfLHGggdFIqRjEQCSduFuaa6kwlPxNSJAaYTYu3lnhl6tEIkd7WRRwBVMn9KCSgOVCx
	9oMfqHnr57Uu8sNNb18fIowl4lYfKLBB7zXfNalmOumVHELlwLsjNVrAlXZY3meNt4fOENuC+KP
	5s3HuHV5NmRJLZPtYWjOIiiqDMYGA7cON5F2KB/Vleq8gA==
X-Received: by 2002:a5d:584c:0:b0:48a:f0cd:8712 with SMTP id ffacd0b85a97d-49c7325b837mr20297222f8f.50.1794765850194;
        Sun, 15 Nov 2026 10:04:10 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.04.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:09 -0800 (PST)
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
Subject: [RFC PATCH v4 05/10] btrfs: add provenance time (ptime)
Date: Sun, 15 Nov 2026 19:03:38 +0100
Message-ID: <20261115180343.576773-6-koray.fra@gmail.com>
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

Implement provenance time (ptime) in Btrfs, as introduced in a
previous commit ("vfs: add provenance time (ptime)").

Update the on-disk format by claiming 12 bytes from the reserved[] space
in btrfs_inode_item, putting ptime before other timestamps. When loading
stale garbage data from disk for ptime, warn (rate-limited) to dmesg.

Advertise support for FS_XFLAG_PTIME using fa_xflags_mask in
btrfs_fileattr_get(), and validate that only supported xflags are
requested in btrfs_fileattr_set() using a newly introduced
BTRFS_SUPPORTED_XFLAGS (containing only FS_XFLAG_PTIME for now).

Also, set .fileattr_[gs]et to btrfs_fileattr_[gs]et() for both symlinks
and special files and reject any other flag update on them with
-EOPNOTSUPP.

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/btrfs/btrfs_inode.h          |  4 ++++
 fs/btrfs/delayed-inode.c        |  6 ++++++
 fs/btrfs/inode.c                | 29 ++++++++++++++++++++++++++++-
 fs/btrfs/ioctl.c                | 24 +++++++++++++++++++++++-
 fs/btrfs/print-tree.c           |  1 +
 fs/btrfs/tree-log.c             |  3 +++
 include/uapi/linux/btrfs_tree.h |  3 ++-
 7 files changed, 67 insertions(+), 3 deletions(-)

diff --git a/fs/btrfs/btrfs_inode.h b/fs/btrfs/btrfs_inode.h
index 0782f917fccc..c9822340567a 100644
--- a/fs/btrfs/btrfs_inode.h
+++ b/fs/btrfs/btrfs_inode.h
@@ -332,6 +332,10 @@ struct btrfs_inode {
 	u64 i_otime_sec;
 	u32 i_otime_nsec;
 
+	/* File *data* creation (provenance) time. */
+	s64 i_ptime_sec;
+	u32 i_ptime_nsec;
+
 	/* Hook into fs_info->delayed_iputs */
 	struct list_head delayed_iput;
 
diff --git a/fs/btrfs/delayed-inode.c b/fs/btrfs/delayed-inode.c
index 333ce8b52489..eef73ebb4a52 100644
--- a/fs/btrfs/delayed-inode.c
+++ b/fs/btrfs/delayed-inode.c
@@ -1932,6 +1932,9 @@ static void fill_stack_inode_item(struct btrfs_trans_handle *trans,
 
 	btrfs_set_stack_timespec_sec(&inode_item->otime, inode->i_otime_sec);
 	btrfs_set_stack_timespec_nsec(&inode_item->otime, inode->i_otime_nsec);
+
+	btrfs_set_stack_timespec_sec(&inode_item->ptime, inode->i_ptime_sec);
+	btrfs_set_stack_timespec_nsec(&inode_item->ptime, inode->i_ptime_nsec);
 }
 
 int btrfs_fill_inode(struct btrfs_inode *inode, u32 *rdev)
@@ -1981,6 +1984,9 @@ int btrfs_fill_inode(struct btrfs_inode *inode, u32 *rdev)
 	inode->i_otime_sec = btrfs_stack_timespec_sec(&inode_item->otime);
 	inode->i_otime_nsec = btrfs_stack_timespec_nsec(&inode_item->otime);
 
+	inode->i_ptime_sec = btrfs_stack_timespec_sec(&inode_item->ptime);
+	inode->i_ptime_nsec = btrfs_stack_timespec_nsec(&inode_item->ptime);
+
 	vfs_inode->i_generation = inode->generation;
 	if (S_ISDIR(vfs_inode->i_mode))
 		inode->index_cnt = (u64)-1;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index abaa33471456..ff8f7a0caad3 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4057,6 +4057,17 @@ static int btrfs_read_locked_inode(struct btrfs_inode *inode, struct btrfs_path
 	inode->i_otime_sec = btrfs_timespec_sec(leaf, &inode_item->otime);
 	inode->i_otime_nsec = btrfs_timespec_nsec(leaf, &inode_item->otime);
 
+	inode->i_ptime_sec = btrfs_timespec_sec(leaf, &inode_item->ptime);
+	inode->i_ptime_nsec = btrfs_timespec_nsec(leaf, &inode_item->ptime);
+	/* Avoid old garbage on-disk data making btrfs load a bad value */
+	if (unlikely(inode->i_ptime_nsec >= NSEC_PER_SEC)) {
+		btrfs_warn_rl(fs_info,
+			      "invalid ptime.nsec %u on ino %llu from disk, setting ptime to otime",
+			      inode->i_ptime_nsec, btrfs_ino(inode));
+		inode->i_ptime_sec = inode->i_otime_sec;
+		inode->i_ptime_nsec = inode->i_otime_nsec;
+	}
+
 	inode_set_bytes(vfs_inode, btrfs_inode_nbytes(leaf, inode_item));
 	inode->generation = btrfs_inode_generation(leaf, inode_item);
 	inode->last_trans = btrfs_inode_transid(leaf, inode_item);
@@ -4249,6 +4260,9 @@ static void fill_inode_item(struct btrfs_trans_handle *trans,
 	btrfs_set_timespec_sec(leaf, &item->otime, BTRFS_I(inode)->i_otime_sec);
 	btrfs_set_timespec_nsec(leaf, &item->otime, BTRFS_I(inode)->i_otime_nsec);
 
+	btrfs_set_timespec_sec(leaf, &item->ptime, BTRFS_I(inode)->i_ptime_sec);
+	btrfs_set_timespec_nsec(leaf, &item->ptime, BTRFS_I(inode)->i_ptime_nsec);
+
 	btrfs_set_inode_nbytes(leaf, item, inode_get_bytes(inode));
 	btrfs_set_inode_generation(leaf, item, BTRFS_I(inode)->generation);
 	btrfs_set_inode_sequence(leaf, item, inode_peek_iversion(inode));
@@ -5988,6 +6002,8 @@ static struct btrfs_inode *new_simple_dir(struct inode *dir,
 	inode_set_atime_to_ts(vfs_inode, inode_get_atime(dir));
 	inode->i_otime_sec = ts.tv_sec;
 	inode->i_otime_nsec = ts.tv_nsec;
+	inode->i_ptime_sec = ts.tv_sec;
+	inode->i_ptime_nsec = ts.tv_nsec;
 
 	vfs_inode->i_uid = dir->i_uid;
 	vfs_inode->i_gid = dir->i_gid;
@@ -6714,6 +6730,8 @@ int btrfs_create_new_inode(struct btrfs_trans_handle *trans,
 	ts = simple_inode_init_ts(inode);
 	BTRFS_I(inode)->i_otime_sec = ts.tv_sec;
 	BTRFS_I(inode)->i_otime_nsec = ts.tv_nsec;
+	BTRFS_I(inode)->i_ptime_sec = ts.tv_sec;
+	BTRFS_I(inode)->i_ptime_nsec = ts.tv_nsec;
 
 	/*
 	 * We're going to fill the inode item now, so at this point the inode
@@ -8048,6 +8066,9 @@ struct inode *btrfs_alloc_inode(struct super_block *sb)
 	ei->i_otime_sec = 0;
 	ei->i_otime_nsec = 0;
 
+	ei->i_ptime_sec = 0;
+	ei->i_ptime_nsec = 0;
+
 	inode = &ei->vfs_inode;
 	btrfs_extent_map_tree_init(&ei->extent_tree);
 
@@ -8186,9 +8207,11 @@ static int btrfs_getattr(const struct mnt_idmap *idmap,
 	u32 blocksize = btrfs_sb(inode->i_sb)->sectorsize;
 	u32 bi_flags = BTRFS_I(inode)->flags;
 
-	stat->result_mask |= STATX_BTIME;
+	stat->result_mask |= (STATX_BTIME | STATX_PTIME);
 	stat->btime.tv_sec = BTRFS_I(inode)->i_otime_sec;
 	stat->btime.tv_nsec = BTRFS_I(inode)->i_otime_nsec;
+	stat->ptime.tv_sec = BTRFS_I(inode)->i_ptime_sec;
+	stat->ptime.tv_nsec = BTRFS_I(inode)->i_ptime_nsec;
 	if (bi_flags & BTRFS_INODE_APPEND)
 		stat->attributes |= STATX_ATTR_APPEND;
 	if (bi_flags & BTRFS_INODE_COMPRESS)
@@ -10779,6 +10802,8 @@ static const struct inode_operations btrfs_special_inode_operations = {
 	.get_inode_acl	= btrfs_get_acl,
 	.set_acl	= btrfs_set_acl,
 	.update_time	= btrfs_update_time,
+	.fileattr_get	= btrfs_fileattr_get,
+	.fileattr_set	= btrfs_fileattr_set,
 };
 static const struct inode_operations btrfs_symlink_inode_operations = {
 	.get_link	= page_get_link,
@@ -10787,6 +10812,8 @@ static const struct inode_operations btrfs_symlink_inode_operations = {
 	.permission	= btrfs_permission,
 	.listxattr	= btrfs_listxattr,
 	.update_time	= btrfs_update_time,
+	.fileattr_get	= btrfs_fileattr_get,
+	.fileattr_set	= btrfs_fileattr_set,
 };
 
 const struct dentry_operations btrfs_dentry_operations = {
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 6ba883db107b..f6c5bf9bf217 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -270,11 +270,17 @@ static int btrfs_check_ioctl_vol_args2_subvol_name(const struct btrfs_ioctl_vol_
  * Set flags/xflags from the internal inode flags. The remaining items of
  * fsxattr are zeroed.
  */
+#define BTRFS_SUPPORTED_XFLAGS		(FS_XFLAG_PTIME)
+
 int btrfs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 {
 	const struct btrfs_inode *inode = BTRFS_I(d_inode(dentry));
 
 	fileattr_fill_flags(fa, btrfs_inode_flags_to_fsflags(inode));
+	fa->fsx_ptime.tv_sec = inode->i_ptime_sec;
+	fa->fsx_ptime.tv_nsec = inode->i_ptime_nsec;
+	fa->fsx_xflags |= FS_XFLAG_PTIME;
+	fa->fsx_xflags_mask |= FS_XFLAG_PTIME;
 	return 0;
 }
 
@@ -294,9 +300,21 @@ int btrfs_fileattr_set(const struct mnt_idmap *idmap,
 	if (btrfs_root_readonly(root))
 		return -EROFS;
 
-	if (fileattr_has_fsx(fa))
+	/*
+	 * We now support FS_XFLAG_PTIME, so exclude it from the unsupported
+	 * check
+	 */
+	if (fileattr_has_fsx_mask(fa, BTRFS_SUPPORTED_XFLAGS))
+		return -EOPNOTSUPP;
+
+	if (fa->fsx_xflags_mask & ~BTRFS_SUPPORTED_XFLAGS)
 		return -EOPNOTSUPP;
 
+	if (!S_ISREG(inode->vfs_inode.i_mode) && !S_ISDIR(inode->vfs_inode.i_mode)) {
+		if (fa->flags)
+			return -EOPNOTSUPP;
+	}
+
 	fsflags = btrfs_mask_fsflags_for_type(&inode->vfs_inode, fa->flags);
 	old_fsflags = btrfs_inode_flags_to_fsflags(inode);
 	ret = check_fsflags(old_fsflags, fsflags);
@@ -449,6 +467,10 @@ int btrfs_fileattr_set(const struct mnt_idmap *idmap,
 	}
 
 update_flags:
+	if (!fa->flags_valid && (fa->fsx_xflags_mask & FS_XFLAG_PTIME)) {
+		inode->i_ptime_sec = fa->fsx_ptime.tv_sec;
+		inode->i_ptime_nsec = fa->fsx_ptime.tv_nsec;
+	}
 	inode->flags = inode_flags;
 	btrfs_update_inode_mapping_flags(inode);
 	btrfs_sync_inode_flags_to_i_flags(inode);
diff --git a/fs/btrfs/print-tree.c b/fs/btrfs/print-tree.c
index 53e726119ca7..ba385d0ed9ed 100644
--- a/fs/btrfs/print-tree.c
+++ b/fs/btrfs/print-tree.c
@@ -263,6 +263,7 @@ static void print_inode_item(const struct extent_buffer *eb, int i)
 	print_timespec(eb, &ii->ctime, "\t\tctime ", "\n");
 	print_timespec(eb, &ii->mtime, "\t\tmtime ", "\n");
 	print_timespec(eb, &ii->otime, "\t\totime ", "\n");
+	print_timespec(eb, &ii->ptime, "\t\tptime ", "\n");
 }
 
 static void print_dir_item(const struct extent_buffer *eb, int i)
diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
index 1d9dfb63fc5a..72a4a92b40b9 100644
--- a/fs/btrfs/tree-log.c
+++ b/fs/btrfs/tree-log.c
@@ -4631,6 +4631,9 @@ static void fill_inode_item(struct btrfs_trans_handle *trans,
 	btrfs_set_timespec_sec(leaf, &item->otime, inode->i_otime_sec);
 	btrfs_set_timespec_nsec(leaf, &item->otime, inode->i_otime_nsec);
 
+	btrfs_set_timespec_sec(leaf, &item->ptime, inode->i_ptime_sec);
+	btrfs_set_timespec_nsec(leaf, &item->ptime, inode->i_ptime_nsec);
+
 	/*
 	 * We do not need to set the nbytes field, in fact during a fast fsync
 	 * its value may not even be correct, since a fast fsync does not wait
diff --git a/include/uapi/linux/btrfs_tree.h b/include/uapi/linux/btrfs_tree.h
index 47ee52859b45..c360b3e95f45 100644
--- a/include/uapi/linux/btrfs_tree.h
+++ b/include/uapi/linux/btrfs_tree.h
@@ -900,7 +900,8 @@ struct btrfs_inode_item {
 	 * a little future expansion, for more than this we can
 	 * just grow the inode item and version it
 	 */
-	__le64 reserved[4];
+	__le32 reserved[5];
+	struct btrfs_timespec ptime;
 	struct btrfs_timespec atime;
 	struct btrfs_timespec ctime;
 	struct btrfs_timespec mtime;
-- 
2.56.0

