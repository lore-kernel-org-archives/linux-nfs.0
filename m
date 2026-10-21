Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552585;
	b=XgVZThiatzE9fsBJisjKIQFey4klhQiuVWJ/lcxmJus2VIuqI26DYOEkvxMXfLFjEyl2
	 AfIIxy/wFNlU7Iu2IQ0YbQcX7TWE8Mu1kSl/1+1lq1vm/xChyTGh0RNGC6VaM5vTqP+SH
	 VMLGn1uiVIb/IKY756K2m0DPxrhGr37VqWt2WCOulDA9q/RzDae41UQPlTV1/twft1h8o
	 JMwT0Z/7szMGxEKtGw1JUTbdBJcDNCmDFQ7uqYE3PhHMpWxKd0c4xabHl8YjwybtLJVZH
	 eHJVOfIBQ1SvGAEwWgeAICrL2Qr3iyPAJEIE4tzC32QXs2jngnQkftKX4TvjZXtdvTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552585;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=CvkQkO6/tHOtGQIxozrMXB/5r0774vU1wkd8NeZUKA0=;
	b=06VvCt9KE9MnZ6BbJbau3T3J+QngTBWWgbmsaexOCqswEQHAWAw4zGL2WI4WC/6MdEXh
	 AVb87F4YOkvs+So3agWoddhe7y1rxgEAnLlWD/e3xlB1TGBAKk7CfJetYW6mFudEl7dMB
	 JFsMezwzLfe2oVTRal0dnlfHaDJOtWxobG5wy6hwaKnmawS/Hw6AWK6pgEkoY/rp4SEyQ
	 8++fQ4X1/+mnNXLmDqnakgg0xP2pPpNExbasV4EdnmyUwzWBgScs1HCkf5zVtZBLI6+GL
	 dRlwINGt1/l6B76Nkwi7ihljSCZ9mBtET6udOQp9483Rmlz8YWe5YsoiLNHybN5iIBg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=bteuJBvK;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21C8C606C8A2;
	Wed, 21 Oct 2026 03:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 21C8C606C8A2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=bteuJBvK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552583; bh=wdLQ9TCSgiFO0r6WxEurccPWnjAR4v3UlsEy/7qlPFQ=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=bteuJBvK6YxWqdRWq9McoGhEfO2flg7Raoa9+jcjnPdQoaCS1CLHhIQOGA4h03d4Q
	 p0aXG9bWheBt1bnWImgFQJEy/q8SRLcNVSWtF/oYKFYTubLdYvhkmYiOt9RFPcLnWT
	 PrHbM/qn53/ja6xRs0qRxojBbEujVPq0Sxy9hqtkSVkMNTtD7pJeqORQueamMQT1sC
	 CYBBu6LEUetZURFrqEA4K/p2NHtiJDAfLnEoXhwGhFduAx41982WlmT4fYJUFP60Xz
	 j6bhSCu+exDk3a518jzevZImT23sRMMYoT/Z9mJE7S375q3eV8+drrWJS687UyrsGR
	 DmkIO3UdMWTaw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 517E88A0904;
	Wed, 21 Oct 2026 05:16:22 +0200 (CEST)
Message-ID: <d67ff709d9b2a9a8eb0948cebbba445ed48276d1.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 18/41] fs: keep UUID and GUID owners off filesystems
 that can't store them
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
Date: Wed, 21 Oct 2026 05:15:38 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Filesystems write inode owners with i_uid_read()/i_gid_read(), which
turn a UUID or GUID into -1. Add SB_I_UID_R for filesystems that can
store such owners, and refuse them elsewhere with -EOVERFLOW, the error
already used for ids without a mapping in the filesystem's namespace:

- notify_change() refuses ATTR_UID/ATTR_GID with such an id,
- fsuidgid_has_mapping() is false for a caller whose fsuid or fsgid is
  one, so may_create() and friends refuse to create inodes owned by it.

No filesystem sets the flag yet.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/attr.c                      |  7 +++++++
 include/linux/fs.h             | 29 +++++++++++++++++++++++++----
 include/linux/fs/super_types.h |  1 +
 3 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 71888ac903..09d51b1a32 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -526,6 +526,13 @@ int notify_change(struct mnt_idmap *idmap, struct dentry *dentry,
 	    !vfsgid_has_fsmapping(idmap, inode->i_sb->s_user_ns,
 				  attr->ia_vfsgid))
 		return -EOVERFLOW;
+	/* and that the filesystem can store a UUID or GUID owner */
+	if (ia_valid & ATTR_UID &&
+	    !sb_can_own_kuid(inode->i_sb, vfsuid_into_kuid(attr->ia_vfsuid)))
+		return -EOVERFLOW;
+	if (ia_valid & ATTR_GID &&
+	    !sb_can_own_kgid(inode->i_sb, vfsgid_into_kgid(attr->ia_vfsgid)))
+		return -EOVERFLOW;
 
 	/* Don't allow modifications of files with invalid uids or
 	 * gids unless those uids & gids are being made valid.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index deb411e866..05c4611c87 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1563,14 +1563,35 @@ static inline void inode_fsgid_set(struct inode *inode,
 	inode->i_gid = mapped_fsgid(idmap, i_user_ns(inode));
 }
 
+/**
+ * sb_can_own_kuid() - check whether a filesystem can store an owner
+ * @sb: the superblock
+ * @kuid: the owner
+ *
+ * Classic ids fit any filesystem; UUIDs and GUIDs only those that set
+ * SB_I_UID_R. Elsewhere i_uid_read() would turn them into -1.
+ *
+ * Return: true if @sb can store @kuid.
+ */
+static inline bool sb_can_own_kuid(const struct super_block *sb, kuid_t kuid)
+{
+	return uid_is_legacy(kuid) || (sb->s_iflags & SB_I_UID_R);
+}
+
+static inline bool sb_can_own_kgid(const struct super_block *sb, kgid_t kgid)
+{
+	return gid_is_legacy(kgid) || (sb->s_iflags & SB_I_UID_R);
+}
+
 /**
  * fsuidgid_has_mapping() - check whether caller's fsuid/fsgid is mapped
  * @sb: the superblock we want a mapping in
  * @idmap: idmap of the relevant mount
  *
  * Check whether the caller's fsuid and fsgid have a valid mapping in the
- * s_user_ns of the superblock @sb. If the caller is on an idmapped mount map
- * the caller's fsuid and fsgid according to the @idmap first.
+ * s_user_ns of the superblock @sb, and whether @sb can store them as owner
+ * of a new inode. If the caller is on an idmapped mount map the caller's
+ * fsuid and fsgid according to the @idmap first.
  *
  * Return: true if fsuid and fsgid is mapped, false if not.
  */
@@ -1582,10 +1603,10 @@ static inline bool fsuidgid_has_mapping(struct super_block *sb,
 	kgid_t kgid;
 
 	kuid = mapped_fsuid(idmap, fs_userns);
-	if (!uid_valid(kuid))
+	if (!uid_valid(kuid) || !sb_can_own_kuid(sb, kuid))
 		return false;
 	kgid = mapped_fsgid(idmap, fs_userns);
-	if (!gid_valid(kgid))
+	if (!gid_valid(kgid) || !sb_can_own_kgid(sb, kgid))
 		return false;
 	return kuid_has_mapping(fs_userns, kuid) &&
 	       kgid_has_mapping(fs_userns, kgid);
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index ecd96aeb1c..1f5c596b18 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -352,5 +352,6 @@ struct super_block {
 #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this superblock */
 #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this superblock */
 #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data persistence on sync */
+#define SB_I_UID_R	0x00010000	/* fs stores UUID and GUID owners, not just classic ids */
 
 #endif /* _LINUX_FS_SUPER_TYPES_H */
-- 
2.56.0

