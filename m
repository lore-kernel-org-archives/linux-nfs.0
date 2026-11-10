Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302431;
	b=3JnAOyf0Er8YU0IWi5QT8kru7PXPsbDimSO4RdUf082bCo13kaFxF6muZUVfaxr7O1uv
	 UyAkT3GLu87MlEFGjWTy4NnAgF5e5bKpVi2E2Zz3AeOfOHW+c5ZyJ2jv4rC6J9iht5EKI
	 wuOeu09ombIcFgjDuesGKzpx9BP5x0HXNFRgNi/hJUnhMnJryYIfAxzuKT1TzY51O4dTi
	 KJOZtq5T9vFvSvo6AECZeq/7MwFSiO+vKdxVHOKgOKRnTVXkE1hk+tigR7C9ryyl8KcxS
	 xTBU7aDVBShWwmtLAau1PC6HbQK5aEi9Ch+NchX1qR3+0ERS54quY5yvNbP1o8eb/ZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302431;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YJdQfmNRZIjJZmJ7eXlopktH5jFS//yu5Pe53ZYQ028=;
	b=HLaW8xkInnJ/mx46BIDFftnkDi2P2Vbo1OG0oj5T4UVF77SdDMEoRgdidTcHRnTMT4NC
	 TMoNIW492yktuSAgk3S8Jk/Fz+EuTh/3WznSvjObnzrWuwwE+TgbVECVTROkFc432jWVB
	 2e6mxXIZrZ4BIxjl/rZyG+LwN7O/J1ym48C9aVl0uGN6f8QCWn4pyLOjc8EaDmMHEVpY6
	 OctSST1f87jLEmGYwU3xoAlu5VV7eqHu2F7Etj1/OhZW3OwJt8AoZSaSAm9DY5py2Mg65
	 3aSzIA5cAt4aJGfMcAb5rD2oSKYSUW33NDgoEGJIxtYPzlPbgdyvh3xxW2qxqA1FYGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aZVzmHBN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85D37607FB6C;
	Tue, 10 Nov 2026 09:20:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aZVzmHBN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 24AA31F008A6;
	Tue, 10 Nov 2026 09:20:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302431;
	bh=YJdQfmNRZIjJZmJ7eXlopktH5jFS//yu5Pe53ZYQ028=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aZVzmHBNuwJ61+F1e2oV+4dv4gNlfmbtkL/jYHqJnnAR8nxpapvLT1jaqObFS3Kt6
	 Ta83UhzRz8CvexZ0ysKoa1MoO3Zu6STABRZGed6dESQ7WUcbM2CZMcu26UAdqYXcUi
	 jGRxcd1PuvngpWsUZ9wdr1xrWLiH+HYWR1UJUrQbfn+O+Yx9/8C2d+1m8jfwdUrWlh
	 x7irI9TSUWj+2x5RTqa6GOQ9Qm8DWqqbMA4ng0XxJzOZmiUTRMHuCfCm4DvyHXloD3
	 13saqaue/D0rL6M4JYSaME0ZwZWtpV6O8u9WPkmcnvoBepeZUJpTLw5Bl66Aroqny1
	 QozwErkn3D9Og==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:56 +0100
Subject: [PATCH RFC 40/41] erofs: refuse files on pseudo filesystems as
 backing files
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261110-work-loop-pseudo-v1-40-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1370; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NydLncApPlv7Xb4803UYyRsruwye9LOqDMcupA3ko3I=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9enCotFA5svjs32+5V/jKOVd3VfaxP+2o4TjJ9eAot
 9K2J1P4O0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbydB0jw66Sm4EFNRm7ox68
 2SVYs2OfsAHnhYkt+fUvbmadaZ28QICR4WLbxMemdRPmu/26Zds+2yJaate+vNkOVz78PC+SI7H
 SjgcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

File-backed mounts take any regular file as the image and the same goes
for the extra devices of such a mount. erofs reads them with the
credentials of the mounter so this doesn't hand out anything the mounter
couldn't read anyway. But files on pseudo filesystems aren't images.
Refuse them just like loop does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/erofs/super.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/erofs/super.c b/fs/erofs/super.c
index ce05557bd998..980d5fc2b576 100644
--- a/fs/erofs/super.c
+++ b/fs/erofs/super.c
@@ -158,7 +158,8 @@ static int erofs_init_device(struct erofs_buf *buf, struct super_block *sb,
 		if (!erofs_is_fileio_mode(sbi)) {
 			dif->dax_dev = fs_dax_get_by_bdev(file_bdev(file),
 					&dif->dax_part_off, NULL, NULL);
-		} else if (!S_ISREG(file_inode(file)->i_mode)) {
+		} else if (!S_ISREG(file_inode(file)->i_mode) ||
+			   file_is_pseudo(file)) {
 			fput(file);
 			return -EINVAL;
 		}
@@ -835,6 +836,9 @@ static int erofs_file_get_tree(struct fs_context *fc)
 {
 	struct erofs_sb_info *sbi = fc->s_fs_info;
 
+	if (file_is_pseudo(sbi->dif0.file))
+		return invalfc(fc, "source is on a pseudo filesystem");
+
 	if (!test_opt(&sbi->opt, SUPERBLOCK_SHARE))
 		return get_tree_nodev(fc, erofs_fc_fill_super);
 

-- 
2.53.0

