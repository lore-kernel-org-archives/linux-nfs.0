Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552629;
	b=Wulik+IFOG69T6YesJ7wZxEqO/wcHz8rkGrr8D2YAtRmcWusunmLhDAkveN2bwje3ST/
	 nEUXxJuJYn9zQLeydz7umdfLzl93eQjkojEzmwkbCC82lJ4XgvxygvJcjRVmCqiUkuH42
	 PtBn6LJB5actBNV0+cCIabIwcbqGaYsNSpiDQ1yaJYhwdTZKYvsfpp5IhkYwvrFcZOwPb
	 dwsrzlycnsDMxuf8hi/LV9pjz1UitZQ8/eLH8KeHxuR+8AXPnCdVEoAsHVJnrUhLU5enD
	 xkh+dudQGg/E92zNEccQdo2k5z4cPcxPzSb7pR6lh4Rb0yegQp+k1Kuykiv/4wAzGsg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552629;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=FoLPiglPVl+us8byBrCSfkhrNtfDFOmejE84GKuPLI4=;
	b=pEhqURwOHzzvNmBxnVqaXKIsSbGZu9reFpyyFEJRQmmUXoJdcNBmpe3YpcA9FSwtz4p7
	 hvmBf9bYxIvnBCk5srkgsSyuFXXZyu7GwMxhp3xr6hL6vWMxjf29fo5vYMd7XqQIy6jE1
	 XWXOitTHvE+J+j1ZmcatFIXlB+PVcyWZaVTxzjK3AUqIkcnNJ0LaSN7yxzlcBiBie9YGX
	 16UHmiNpB3jo8krURJ0ZE2MaCqWkNndf4jsoC8p8ciFOygh4VDPfUbDbdeJdZe1BoifkE
	 wBVexiX/cJUqZVuRTi3lBQKeTrv7Gb47SZZmOdJQpbCG65ZHR5zIs0hKPdpofcg/7GA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C3J+2AEb;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01D5860A3804;
	Wed, 21 Oct 2026 03:17:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 01D5860A3804
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=C3J+2AEb
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552627; bh=ahHoP+KmbDaq9577t3A0gEq/i+cqumLAzataSt6r+6c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=C3J+2AEby3bLJTrGHPCSjycXT81E/5aDLawJ2xISQvBK61i9IDIPm6YIPoaXeHgqX
	 0cipNhvyMNcVHOLKRdJqr3ZAzf07fD9STA2bdUEP7JL0AvdfBwXDUkOJ4n0oQ4lYrI
	 42bpYDCofI3uf5AQzJkIc0BIJ5Qd7pQ9Tdqy4QGMHuTHgn0ZbZN++xe/0RWIapOa3o
	 g23X6hU8LtdtJy7KHeut9KO72V3dMhWvgJlIy3UkIcj3e6RmcGPbxEtTNEVaN2hWBn
	 rWHygFseUiWCwLshJLkRc6I6b+DZo5KrEFdVkynl5ZS/Lc7SD4S/rSHSSoMKPiI4Sf
	 buEXQedcnWrbQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 7988A8A090D;
	Wed, 21 Oct 2026 05:17:06 +0200 (CEST)
Message-ID: <1ced8bf416de4e9600904aafeefd29ed20fd2064.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 31/41] ext4: add the uid_r feature for UUID and GUID
 owners
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:51 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Add a read-only compatible feature, uid_r, that lets inodes have UUID
and GUID owners and groups. The inode gains i_uid_r_type and
i_gid_r_type (0: the classic i_uid/i_gid apply) and 16 bytes for each
id after i_projid, which grows i_extra_isize from 32 to 68 bytes; only
filesystems with the feature reserve the room in new inodes, others
keep the old size.

For a UUID or GUID the classic fields hold 0xffffffff. Kernels without
the feature may only mount read-only, and see such files as owned by an
id nobody has.

With the feature the superblock gets SB_I_UID_R. Inodes from before it,
or with in-inode xattrs in the way, are expanded when they get such an
owner, as for project ids; -EOVERFLOW if that fails. The feature needs
inodes of at least 196 bytes, so in practice 256.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/ext4/ext4.h  |  26 ++++++++++-
 fs/ext4/inode.c | 115 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/ext4/super.c |  16 ++++++-
 3 files changed, 152 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 724a27e8be..1cba42b410 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -850,8 +850,29 @@ struct ext4_inode {
 	__le32  i_crtime_extra; /* extra FileCreationtime (nsec << 2 | epoch) */
 	__le32  i_version_hi;	/* high 32 bits for 64-bit version */
 	__le32	i_projid;	/* Project ID */
+	/* uid_r feature: a UUID or GUID owner and group, see EXT4_ID_R_* */
+	__u8	i_uid_r_type;	/* kind of i_uid_r, EXT4_ID_R_LEGACY: i_uid */
+	__u8	i_gid_r_type;	/* kind of i_gid_r, EXT4_ID_R_LEGACY: i_gid */
+	__le16	i_id_r_reserved;
+	__u8	i_uid_r[16];	/* UUID (RFC 9562 order) or GUID owner */
+	__u8	i_gid_r[16];	/* UUID (RFC 9562 order) or GUID group */
 };
 
+/*
+ * Kinds of i_uid_r/i_gid_r. For a UUID or GUID the classic i_uid/i_gid
+ * fields hold 0xffffffff, which kernels without uid_r -- they may only
+ * mount read-only -- see as an id nobody has.
+ */
+#define EXT4_ID_R_LEGACY	0
+#define EXT4_ID_R_UUID		1
+#define EXT4_ID_R_GUID		2
+
+/* i_extra_isize of inodes without and with the uid_r fields */
+#define EXT4_EXTRA_ISIZE_BASE	(offsetofend(struct ext4_inode, i_projid) - \
+				 EXT4_GOOD_OLD_INODE_SIZE)
+#define EXT4_EXTRA_ISIZE_UID_R	(sizeof(struct ext4_inode) - \
+				 EXT4_GOOD_OLD_INODE_SIZE)
+
 #define EXT4_EPOCH_BITS 2
 #define EXT4_EPOCH_MASK ((1 << EXT4_EPOCH_BITS) - 1)
 #define EXT4_NSEC_MASK  (~0UL << EXT4_EPOCH_BITS)
@@ -2214,6 +2235,7 @@ static inline struct mapping_metadata_bhs *ext4_i_metadata_bhs(
 #define EXT4_FEATURE_RO_COMPAT_VERITY		0x8000
 #define EXT4_FEATURE_RO_COMPAT_ORPHAN_PRESENT	0x10000 /* Orphan file may be
 							   non-empty */
+#define EXT4_FEATURE_RO_COMPAT_UID_R		0x20000 /* UUID and GUID owners */
 
 #define EXT4_FEATURE_INCOMPAT_COMPRESSION	0x0001
 #define EXT4_FEATURE_INCOMPAT_FILETYPE		0x0002
@@ -2313,6 +2335,7 @@ EXT4_FEATURE_RO_COMPAT_FUNCS(readonly,		READONLY)
 EXT4_FEATURE_RO_COMPAT_FUNCS(project,		PROJECT)
 EXT4_FEATURE_RO_COMPAT_FUNCS(verity,		VERITY)
 EXT4_FEATURE_RO_COMPAT_FUNCS(orphan_present,	ORPHAN_PRESENT)
+EXT4_FEATURE_RO_COMPAT_FUNCS(uid_r,		UID_R)
 
 EXT4_FEATURE_INCOMPAT_FUNCS(compression,	COMPRESSION)
 EXT4_FEATURE_INCOMPAT_FUNCS(filetype,		FILETYPE)
@@ -2373,7 +2396,8 @@ EXT4_FEATURE_INCOMPAT_FUNCS(casefold,		CASEFOLD)
 					 EXT4_FEATURE_RO_COMPAT_QUOTA |\
 					 EXT4_FEATURE_RO_COMPAT_PROJECT |\
 					 EXT4_FEATURE_RO_COMPAT_VERITY |\
-					 EXT4_FEATURE_RO_COMPAT_ORPHAN_PRESENT)
+					 EXT4_FEATURE_RO_COMPAT_ORPHAN_PRESENT |\
+					 EXT4_FEATURE_RO_COMPAT_UID_R)
 
 #define EXTN_FEATURE_FUNCS(ver) \
 static inline bool ext4_has_unknown_ext##ver##_compat_features(struct super_block *sb) \
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 26f0f9714f..bed8d535a6 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4780,6 +4780,75 @@ static int ext4_inode_blocks_set(struct ext4_inode *raw_inode,
 	return 0;
 }
 
+/*
+ * uid_r: a UUID or GUID owner and group live in i_uid_r and i_gid_r of
+ * inodes with room for them; i_uid and i_gid then hold 0xffffffff.
+ */
+static int ext4_inode_set_id_r(struct inode *inode, struct ext4_inode *raw_inode)
+{
+	struct ext4_inode_info *ei = EXT4_I(inode);
+	bool fits = EXT4_INODE_SIZE(inode->i_sb) > EXT4_GOOD_OLD_INODE_SIZE &&
+		    EXT4_FITS_IN_INODE(raw_inode, ei, i_gid_r);
+	bool legacy = uid_is_legacy(inode->i_uid) && gid_is_legacy(inode->i_gid);
+
+	if (!legacy && (!ext4_has_feature_uid_r(inode->i_sb) || !fits))
+		return -EOVERFLOW;
+	if (!fits || !ext4_has_feature_uid_r(inode->i_sb))
+		return 0;
+
+	raw_inode->i_id_r_reserved = 0;
+	if (uid_is_legacy(inode->i_uid)) {
+		raw_inode->i_uid_r_type = EXT4_ID_R_LEGACY;
+		memset(raw_inode->i_uid_r, 0, sizeof(raw_inode->i_uid_r));
+	} else {
+		BUILD_BUG_ON(KID_UUID != EXT4_ID_R_UUID ||
+			     KID_GUID != EXT4_ID_R_GUID);
+		raw_inode->i_uid_r_type = inode->i_uid.type;
+		memcpy(raw_inode->i_uid_r, inode->i_uid.uuid.b,
+		       sizeof(raw_inode->i_uid_r));
+	}
+	if (gid_is_legacy(inode->i_gid)) {
+		raw_inode->i_gid_r_type = EXT4_ID_R_LEGACY;
+		memset(raw_inode->i_gid_r, 0, sizeof(raw_inode->i_gid_r));
+	} else {
+		raw_inode->i_gid_r_type = inode->i_gid.type;
+		memcpy(raw_inode->i_gid_r, inode->i_gid.uuid.b,
+		       sizeof(raw_inode->i_gid_r));
+	}
+	return 0;
+}
+
+static int ext4_inode_get_id_r(struct inode *inode, struct ext4_inode *raw_inode)
+{
+	struct ext4_inode_info *ei = EXT4_I(inode);
+	uuid_t id;
+
+	if (!ext4_has_feature_uid_r(inode->i_sb) ||
+	    EXT4_INODE_SIZE(inode->i_sb) <= EXT4_GOOD_OLD_INODE_SIZE ||
+	    !EXT4_FITS_IN_INODE(raw_inode, ei, i_gid_r))
+		return 0;
+
+	if (raw_inode->i_uid_r_type > EXT4_ID_R_GUID ||
+	    raw_inode->i_gid_r_type > EXT4_ID_R_GUID) {
+		ext4_error_inode(inode, __func__, __LINE__, 0,
+				 "iget: bad uid_r kind %u/%u",
+				 raw_inode->i_uid_r_type,
+				 raw_inode->i_gid_r_type);
+		return -EFSCORRUPTED;
+	}
+	if (raw_inode->i_uid_r_type != EXT4_ID_R_LEGACY) {
+		memcpy(id.b, raw_inode->i_uid_r, sizeof(id.b));
+		inode->i_uid = raw_inode->i_uid_r_type == EXT4_ID_R_UUID ?
+			       KUIDT_INIT_UUID(id) : KUIDT_INIT_GUID(*(guid_t *)&id);
+	}
+	if (raw_inode->i_gid_r_type != EXT4_ID_R_LEGACY) {
+		memcpy(id.b, raw_inode->i_gid_r, sizeof(id.b));
+		inode->i_gid = raw_inode->i_gid_r_type == EXT4_ID_R_UUID ?
+			       KGIDT_INIT_UUID(id) : KGIDT_INIT_GUID(*(guid_t *)&id);
+	}
+	return 0;
+}
+
 static int ext4_fill_raw_inode(struct inode *inode, struct ext4_inode *raw_inode)
 {
 	struct ext4_inode_info *ei = EXT4_I(inode);
@@ -4792,8 +4861,10 @@ static int ext4_fill_raw_inode(struct inode *inode, struct ext4_inode *raw_inode
 	err = ext4_inode_blocks_set(raw_inode, ei);
 
 	raw_inode->i_mode = cpu_to_le16(inode->i_mode);
+	/* a UUID or GUID owner: 0xffffffff here, the id in i_uid_r */
 	i_uid = i_uid_read(inode);
 	i_gid = i_gid_read(inode);
+	err = err ?: ext4_inode_set_id_r(inode, raw_inode);
 	i_projid = from_kprojid(&init_user_ns, ei->i_projid);
 	if (!(test_opt(inode->i_sb, NO_UID32))) {
 		raw_inode->i_uid_low = cpu_to_le16(low_16_bits(i_uid));
@@ -5435,6 +5506,9 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
 	}
 	i_uid_write(inode, i_uid);
 	i_gid_write(inode, i_gid);
+	ret = ext4_inode_get_id_r(inode, raw_inode);
+	if (ret)
+		goto bad_inode;
 	ei->i_projid = make_kprojid(&init_user_ns, i_projid);
 	set_nlink(inode, le16_to_cpu(raw_inode->i_links_count));
 
@@ -5547,8 +5621,7 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
 		if (ei->i_extra_isize == 0) {
 			/* The extra space is currently unused. Use it. */
 			BUILD_BUG_ON(sizeof(struct ext4_inode) & 3);
-			ei->i_extra_isize = sizeof(struct ext4_inode) -
-					    EXT4_GOOD_OLD_INODE_SIZE;
+			ei->i_extra_isize = EXT4_SB(inode->i_sb)->s_want_extra_isize;
 		} else {
 			ret = ext4_iget_extra_inode(inode, raw_inode, ei);
 			if (ret)
@@ -6006,6 +6079,40 @@ static void ext4_wait_for_tail_page_commit(struct inode *inode)
  *
  * Called with inode->i_rwsem down.
  */
+/*
+ * An inode from before uid_r, or with in-inode xattrs in the way, may
+ * lack room for i_uid_r and i_gid_r: make it, before it gets a UUID or
+ * GUID owner or group.
+ */
+static int ext4_make_room_for_id_r(struct mnt_idmap *idmap,
+				   struct inode *inode, struct iattr *attr)
+{
+	struct ext4_iloc iloc;
+	bool legacy = true;
+	int err;
+
+	if (attr->ia_valid & ATTR_UID)
+		legacy = uid_is_legacy(from_vfsuid(idmap, i_user_ns(inode),
+						   attr->ia_vfsuid));
+	if (attr->ia_valid & ATTR_GID)
+		legacy &= gid_is_legacy(from_vfsgid(idmap, i_user_ns(inode),
+						    attr->ia_vfsgid));
+	if (legacy)
+		return 0;
+	if (!ext4_has_feature_uid_r(inode->i_sb))
+		return -EOVERFLOW;
+
+	err = ext4_get_inode_loc(inode, &iloc);
+	if (err)
+		return err;
+	if (EXT4_FITS_IN_INODE(ext4_raw_inode(&iloc), EXT4_I(inode), i_gid_r)) {
+		brelse(iloc.bh);
+		return 0;
+	}
+	err = ext4_expand_extra_isize(inode, EXT4_EXTRA_ISIZE_UID_R, &iloc);
+	return err ? -EOVERFLOW : 0;
+}
+
 int ext4_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
 		 struct iattr *attr)
 {
@@ -6045,6 +6152,10 @@ int ext4_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
 	    i_gid_needs_update(idmap, attr, inode)) {
 		handle_t *handle;
 
+		error = ext4_make_room_for_id_r(idmap, inode, attr);
+		if (error)
+			return error;
+
 		/* (user+group)*(old+new) structure, inode write (sb,
 		 * inode block, ? - but truncate inode update has it) */
 		handle = ext4_journal_start(inode, EXT4_HT_QUOTA,
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d636b89090..34ac087c32 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4613,9 +4613,17 @@ static int ext4_inode_info_init(struct super_block *sb,
 		sb->s_time_min = EXT4_TIMESTAMP_MIN;
 	}
 
+	if (ext4_has_feature_uid_r(sb) &&
+	    sbi->s_inode_size < EXT4_GOOD_OLD_INODE_SIZE + EXT4_EXTRA_ISIZE_UID_R) {
+		ext4_msg(sb, KERN_ERR, "uid_r needs inodes of at least %zu bytes",
+			 EXT4_GOOD_OLD_INODE_SIZE + EXT4_EXTRA_ISIZE_UID_R);
+		return -EINVAL;
+	}
+
 	if (sbi->s_inode_size > EXT4_GOOD_OLD_INODE_SIZE) {
-		sbi->s_want_extra_isize = sizeof(struct ext4_inode) -
-			EXT4_GOOD_OLD_INODE_SIZE;
+		/* room for the uid_r fields in new inodes only if needed */
+		sbi->s_want_extra_isize = ext4_has_feature_uid_r(sb) ?
+			EXT4_EXTRA_ISIZE_UID_R : EXT4_EXTRA_ISIZE_BASE;
 		if (ext4_has_feature_extra_isize(sb)) {
 			unsigned v, max = (sbi->s_inode_size -
 					   EXT4_GOOD_OLD_INODE_SIZE);
@@ -5437,6 +5445,10 @@ static int __ext4_fill_super(struct fs_context *fc, struct super_block *sb)
 	/* HSM events are allowed by default. */
 	sb->s_iflags |= SB_I_ALLOW_HSM;
 
+	/* uid_r: inodes can have UUID and GUID owners */
+	if (ext4_has_feature_uid_r(sb) && !test_opt(sb, NO_UID32))
+		sb->s_iflags |= SB_I_UID_R;
+
 	err = ext4_check_feature_compatibility(sb, es, silent);
 	if (err)
 		goto failed_mount;
-- 
2.56.0

