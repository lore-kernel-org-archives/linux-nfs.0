Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552602;
	b=cvMgTE0uURGseIZlyP6CKcQY2O1zm5w+YK9eE+DmUTmnVwzIB++81RZ7GlLzZ99ZasVy
	 7DP8xY9zJciAVNH3OlH7rdyJkCYnKlHAdhcadarPaaWEcA1D/IKH8eXKb0lhNpnf3/YRc
	 v+kiwfKqLb/QMC80oeoHsvYtsR1y6S5D2xHIeCICLpArxhjs4ruMeOplGzNWAjb1o+yRB
	 dVkGf4wAtKkWUmxT8zeNP5vloEGE35f/tk5pprhuU026+e5k3fs5kD4PzXtW+FoQ65o4w
	 0fKMyTrYdej5O0DYeODaJxL55b3mW4nK7WVqT2bbEV6rkZ/G2WR8INwJAlYjxJDLtNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552602;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=zPPD7WulZ+WhBnM43LljNf1bKM8kWj+WAvEVavMd2SA=;
	b=lCFvS3nk/RktW8PJpo2P0kY7w9GK6mj+aU9xjAMpf45B+e52em+e649+3NnMvSTsy5fA
	 G8jFCfbN0hM9Q0DSHtGDX6I3slCvdTQbAvgJE8XNF9a7ZfEL7fa4ZY/PdD9P3qM14gRcl
	 MeqMnmAcfNUrLt0qMr5YQBrIjGbPHZme8q4R6AHMMY9fzR0em29fWHaZy8zUyctBF/TQW
	 AAPc9C/o4WEoPZTdHCDkCAGSk6Jrqauz6zcPlKiPu8xtEWpmj3JGxwdSbkZzAPBLI9dWV
	 JEWugHo3/l+NPN1fNbK5ce/OJhNnluGoZb+0pMNKADISaiWUHWMd/60c+iPDAOMk5Mw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=hxrAC8aP;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73782606FB96;
	Wed, 21 Oct 2026 03:16:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 73782606FB96
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=hxrAC8aP
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552599; bh=z1Yb30Fyj4Y2/LMUVQzwPTf4Flb12dTpFmXtDtP1XBE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=hxrAC8aPEK4ltg8wpgxYj+wByDqRN88quU9gGlDJw9t1k8bmImdnSPCfqogMkar+K
	 vVWeT+QeziF0bSj8QXZKrWlqGLMJVui1yHtqrXnIh64G0yTbX5OHWDBXpvwz4vG2Gc
	 1oqdfgttBZe9WFfi63lLGybt+9H0SQ4I/5no1O3G/Khij9DIaFUz4okI+8dMG8/S0U
	 oMZ+XlE6noA5HLtvoV3izkoGQgapGMiWrdYn0pVCLAoP1vBAQ3IW84g8dtciRhOR31
	 w3nsvuYqi79ScCCuQORfBNB86/q8hGF2H9krwUOa/FloiLG8ib0hZUkP6WgoTFZ9P+
	 +kj4kBmlVlN6Q==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 304A38A0964;
	Wed, 21 Oct 2026 05:16:39 +0200 (CEST)
Message-ID: <68b5679a91d1d0f017d088a05595d0bdcefd58f5.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 23/41] statx: report UUID and GUID owners
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
Date: Wed, 21 Oct 2026 05:15:43 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Add stx_uid_r and stx_gid_r, the owner and group as __kernel_uid_r_t,
taking 40 of the 64 spare bytes at the end of struct statx, and
STATX_UID_R and STATX_GID_R for them. Every filesystem provides them,
from the kstat the VFS has anyway. stx_uid and stx_gid keep showing a
UUID or GUID as the overflow id.

struct statx is designed to be extended this way, so there is no new
system call: statx() with the new mask bits is the *_r variant.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/stat.c                 | 24 +++++++++++++++++++++++-
 include/uapi/linux/stat.h | 10 +++++++++-
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index c461c30542..993ca4907a 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -185,7 +185,7 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
 	struct inode *inode = d_backing_inode(path->dentry);
 
 	memset(stat, 0, sizeof(*stat));
-	stat->result_mask |= STATX_BASIC_STATS;
+	stat->result_mask |= STATX_BASIC_STATS | STATX_UID_R | STATX_GID_R;
 	query_flags &= AT_STATX_SYNC_TYPE;
 
 	/* allow the fs to override these if it really wants to */
@@ -206,6 +206,17 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
 	stat->attributes_mask |= (STATX_ATTR_AUTOMOUNT |
 				  STATX_ATTR_DAX);
 
+	/*
+	 * STATX_UID_R and STATX_GID_R are another view of the owner: ask the
+	 * filesystem for STATX_UID and STATX_GID, and report them whenever
+	 * those are valid, also from a ->getattr() that sets result_mask on
+	 * its own.
+	 */
+	if (request_mask & STATX_UID_R)
+		request_mask |= STATX_UID;
+	if (request_mask & STATX_GID_R)
+		request_mask |= STATX_GID;
+
 	idmap = mnt_idmap(path->mnt);
 	if (inode->i_op->getattr) {
 		int ret;
@@ -218,6 +229,15 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
 		generic_fillattr(idmap, request_mask, inode, stat);
 	}
 
+	if (stat->result_mask & STATX_UID)
+		stat->result_mask |= STATX_UID_R;
+	else
+		stat->result_mask &= ~STATX_UID_R;
+	if (stat->result_mask & STATX_GID)
+		stat->result_mask |= STATX_GID_R;
+	else
+		stat->result_mask &= ~STATX_GID_R;
+
 	/*
 	 * If this is a block device inode, override the filesystem attributes
 	 * with the block device specific parameters that need to be obtained
@@ -711,6 +731,8 @@ cp_statx(const struct kstat *stat, struct statx __user *buffer)
 	tmp.stx_nlink = stat->nlink;
 	tmp.stx_uid = from_kuid_munged(current_user_ns(), stat->uid);
 	tmp.stx_gid = from_kgid_munged(current_user_ns(), stat->gid);
+	from_kuid_r_munged(current_user_ns(), stat->uid, &tmp.stx_uid_r);
+	from_kgid_r_munged(current_user_ns(), stat->gid, &tmp.stx_gid_r);
 	tmp.stx_mode = stat->mode;
 	tmp.stx_ino = stat->ino;
 	tmp.stx_size = stat->size;
diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
index 1686861aae..689757d8a1 100644
--- a/include/uapi/linux/stat.h
+++ b/include/uapi/linux/stat.h
@@ -3,6 +3,7 @@
 #define _UAPI_LINUX_STAT_H
 
 #include <linux/types.h>
+#include <linux/uidgid_r.h>
 
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
@@ -187,7 +188,12 @@ struct statx {
 	__u32	__spare2[1];
 
 	/* 0xc0 */
-	__u64	__spare3[8];	/* Spare space for future expansion */
+	/* Owner and group, also UUIDs and GUIDs [STATX_UID_R, STATX_GID_R] */
+	__kernel_uid_r_t	stx_uid_r;
+	__kernel_gid_r_t	stx_gid_r;
+
+	/* 0xe8 */
+	__u64	__spare3[3];	/* Spare space for future expansion */
 
 	/* 0x100 */
 };
@@ -219,6 +225,8 @@ struct statx {
 #define STATX_SUBVOL		0x00008000U	/* Want/got stx_subvol */
 #define STATX_WRITE_ATOMIC	0x00010000U	/* Want/got atomic_write_* fields */
 #define STATX_DIO_READ_ALIGN	0x00020000U	/* Want/got dio read alignment info */
+#define STATX_UID_R		0x00040000U	/* Want/got stx_uid_r */
+#define STATX_GID_R		0x00080000U	/* Want/got stx_gid_r */
 
 #define STATX__RESERVED		0x80000000U	/* Reserved for future struct statx expansion */
 
-- 
2.56.0

