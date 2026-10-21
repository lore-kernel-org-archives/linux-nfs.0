Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552633;
	b=okKm1jrE9nFaNgJSRCjPbt5raYu92yIhPhNRhEdSqabBXKcEkxm0qFw6i9dnSfH6uJ3I
	 YqjVsuld8y4vu+jm+leahTK2vDD1Yu4ZgDGkSFD8Q8zupWEhJ88J8hH4DRewUIBQAIGOt
	 n9x7maK5c0JERiUNUNLz5hdE5HXkura0K6cgWrG5OXKgGfMFHA/evTC0NyD3IO8XCdMms
	 O0oSuENUfCXHFyvjYNsFpP/PuvvPc+fZbH+LaQe/AH3N30ugcovgHUEqqFff95alPzP8L
	 85G3Nz2J4TxJigON/DxTEZ7rXu58oK01bNz55Owxgw/7lGg4siPoV8y0IyPj5THq3Mw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552633;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=fwMHa1W1IVSszIdbDR70AZHZRyAY17q4/sCAtOP5mvo=;
	b=QMj16ZgKOJ4pGKI8G0ipFO2SxNjyxE75dTiu2boQPlU0W8A0tvLL0Qi+oobaq5sB6VO2
	 /A/IKyriufzQpmMQV4qT6IYaLNkNtQKeQcTun4WN0PsKsa/F1gzUx2q0eIGXxUejtrmoz
	 Hs15E1smz5uRVjDppYLdD7ydCF1/yxcgPs7fIzOxkWPtJNaouYkikoZ5bG7jP4NhP9P1t
	 sSVMiuUk1HxZLrDDGwcLLbKU7zP3L6neFReqr2UGCtofPgJBfdvb711kczyWvpZJEn36F
	 gDHHqcMZWT3yiUa0T21IsaiLKYLFLk9wi0etDdgbXqeppMWILjG36KTDbalk4e5oOyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=STp2Kbko;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B9C36076B55;
	Wed, 21 Oct 2026 03:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5B9C36076B55
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=STp2Kbko
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552630; bh=l45vQ8THeJ2togr1MEom1LWcRr4JxIvZ+pgYbJGfZew=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=STp2KbkojUPKVUVLgvlFL2rXCw/IDzvyb+lFFVzDAMfTvjYeqnum0ShcrxbbGCQFa
	 iZ9Vt1rrOPdfPp80lM3A7BeNrLcVe2wocfN883P4UPE4Rd0m+4k6HOP4feWUmdrODT
	 bd2J8zRHNsXU0TIAgxjsROte1ISmGxe6goYKtaPqWJ6DggEYqTOSVIt+7mtiwiBPz8
	 h/CFPFd8I+nxxe7J7e2gu+4To3yXuu5MNXYFELCI934WgNKu774hD3ZKOFWk5K+pbc
	 wIsxzFVsG9pmXNGR1xAzwbcQeOwFd9HsotQLxMWi0ScB8BhpmR/WBJZVaGi9CfNAM9
	 IMViK1cijO4Lg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id D75238A08DF;
	Wed, 21 Oct 2026 05:17:09 +0200 (CEST)
Message-ID: <79f31ae647269df33f8db7fcbfd063840f37e3fa.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 32/41] ext4: let uid_r be turned on while the
 filesystem is mounted
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
Date: Wed, 21 Oct 2026 05:15:52 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

SB_I_UID_R was only set when the filesystem was mounted, so after
"tune2fs -O uid_r" on a mounted filesystem chown() to a UUID or GUID
owner kept failing with -EOVERFLOW until it was unmounted and mounted
again.

Take the feature up on remount, and accept it in
EXT4_IOC_SET_TUNE_SB_PARAM, which then also raises s_want_extra_isize
like tune2fs does and makes it usable at once. The ioctl also takes it
when the feature bit is already on disk but not in use yet, which is
the case after an older tune2fs wrote the superblock directly.

Once on, it stays on until the filesystem is unmounted: cached inodes
may have such owners by then.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/ext4/ext4.h  |  1 +
 fs/ext4/ioctl.c | 30 +++++++++++++++++++++++++++++-
 fs/ext4/super.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 1cba42b410..02a8b93a6f 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -3322,6 +3322,7 @@ extern struct buffer_head *ext4_sb_bread_unmovable(struct super_block *sb,
 						   sector_t block);
 extern struct buffer_head *ext4_sb_bread_nofail(struct super_block *sb,
 						sector_t block);
+void ext4_enable_uid_r(struct super_block *sb);
 void ext4_read_bh_nowait(struct buffer_head *bh, blk_opf_t op_flags,
 		bio_end_io_t end_io, bool simu_fail);
 int ext4_read_bh(struct buffer_head *bh, blk_opf_t op_flags,
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index c8387e6a2c..89bf1d36ec 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1269,7 +1269,8 @@ static int ext4_ioctl_setuuid(struct file *filp,
 		 EXT4_FEATURE_RO_COMPAT_DIR_NLINK |	\
 		 EXT4_FEATURE_RO_COMPAT_EXTRA_ISIZE |	\
 		 EXT4_FEATURE_RO_COMPAT_PROJECT |	\
-		 EXT4_FEATURE_RO_COMPAT_VERITY)
+		 EXT4_FEATURE_RO_COMPAT_VERITY |	\
+		 EXT4_FEATURE_RO_COMPAT_UID_R)
 
 #define EXT4_TUNE_CLEAR_COMPAT_SUPP (0)
 #define EXT4_TUNE_CLEAR_INCOMPAT_SUPP (0)
@@ -1382,6 +1383,13 @@ static void ext4_sb_setparams(struct ext4_sb_info *sbi,
 		if (params->set_feature_incompat_mask &
 		    EXT4_FEATURE_INCOMPAT_CSUM_SEED)
 			es->s_checksum_seed = cpu_to_le32(sbi->s_csum_seed);
+		/* as tune2fs does: room for the uid_r fields in new inodes */
+		if ((params->set_feature_ro_compat_mask &
+		     EXT4_FEATURE_RO_COMPAT_UID_R) &&
+		    ext4_has_feature_extra_isize(sbi->s_sb) &&
+		    le16_to_cpu(es->s_want_extra_isize) < EXT4_EXTRA_ISIZE_UID_R)
+			es->s_want_extra_isize =
+				cpu_to_le16(EXT4_EXTRA_ISIZE_UID_R);
 	}
 	if (params->set_flags & EXT4_TUNE_FL_FORCE_FSCK)
 		es->s_state |= cpu_to_le16(EXT4_ERROR_FS);
@@ -1395,6 +1403,7 @@ static int ext4_ioctl_set_tune_sb(struct file *filp,
 	struct ext4_sb_info *sbi = EXT4_SB(sb);
 	struct ext4_super_block *es = sbi->s_es;
 	int enabling_casefold = 0;
+	bool enabling_uid_r = false;
 	int ret;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -1461,6 +1470,18 @@ static int ext4_ioctl_set_tune_sb(struct file *filp,
 		     ~EXT4_TUNE_CLEAR_RO_COMPAT_SUPP))
 			return -EOPNOTSUPP;
 
+		/*
+		 * uid_r may already be on disk but not in use yet, when it
+		 * was set while the filesystem was mounted: take that up too.
+		 */
+		if (params.set_feature_ro_compat_mask &
+		    EXT4_FEATURE_RO_COMPAT_UID_R) {
+			if (sbi->s_inode_size < EXT4_GOOD_OLD_INODE_SIZE +
+						EXT4_EXTRA_ISIZE_UID_R)
+				return -EINVAL;
+			enabling_uid_r = true;
+		}
+
 		/*
 		 * Filter out the features that are already set from
 		 * the set_mask.
@@ -1532,6 +1553,13 @@ static int ext4_ioctl_set_tune_sb(struct file *filp,
 	if (params.set_flags & EXT4_TUNE_FL_DEF_HASH_ALG)
 		sbi->s_def_hash_version = params.def_hash_alg;
 
+	/* not under mnt_want_write_file(), freeze_super() would wait for us */
+	if (!ret && enabling_uid_r) {
+		down_write(&sb->s_umount);
+		ext4_enable_uid_r(sb);
+		up_write(&sb->s_umount);
+	}
+
 	return ret;
 }
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 34ac087c32..728dce000a 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -6580,6 +6580,32 @@ static int ext4_unfreeze(struct super_block *sb)
 	return 0;
 }
 
+/*
+ * Let the filesystem take UUID and GUID owners when the uid_r feature was
+ * turned on after the mount, by a remount or EXT4_IOC_SET_TUNE_SB_PARAM.
+ * It is never turned off again, as cached inodes may have such owners by
+ * now. Called with s_umount held for writing.
+ */
+void ext4_enable_uid_r(struct super_block *sb)
+{
+	struct ext4_sb_info *sbi = EXT4_SB(sb);
+
+	if (!ext4_has_feature_uid_r(sb) || test_opt(sb, NO_UID32) ||
+	    (sb->s_iflags & SB_I_UID_R))
+		return;
+	if (sbi->s_inode_size <
+	    EXT4_GOOD_OLD_INODE_SIZE + EXT4_EXTRA_ISIZE_UID_R) {
+		ext4_msg(sb, KERN_WARNING,
+			 "uid_r needs inodes of at least %zu bytes, not enabled",
+			 EXT4_GOOD_OLD_INODE_SIZE + EXT4_EXTRA_ISIZE_UID_R);
+		return;
+	}
+	if (sbi->s_want_extra_isize < EXT4_EXTRA_ISIZE_UID_R)
+		WRITE_ONCE(sbi->s_want_extra_isize, EXT4_EXTRA_ISIZE_UID_R);
+	sb->s_iflags |= SB_I_UID_R;
+	ext4_msg(sb, KERN_INFO, "uid_r enabled");
+}
+
 /*
  * Structure to save mount options for ext4_remount's benefit
  */
@@ -6861,6 +6887,9 @@ static int __ext4_remount(struct fs_context *fc, struct super_block *sb)
 	if (!test_opt(sb, BLOCK_VALIDITY) && sbi->s_system_blks)
 		ext4_release_system_zone(sb);
 
+	/* tune2fs may have turned on uid_r since the mount */
+	ext4_enable_uid_r(sb);
+
 	/*
 	 * Reinitialize lazy itable initialization thread based on
 	 * current settings
-- 
2.56.0

