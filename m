Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661814;
	b=DSH5pUpmy0S+HaR3hAa3+PyP9D8HOsmj6dWlNLN4moQVw5HJJMJeIqPoGgMu2qVjJpRS
	 dQN0w+isf6zZtoaOz1/N3Iow4YFGtGdFJkUVNSnUgIyg3Kinfna+9xTW8yKPplMyHUCta
	 8COwULyFfP3jOiLE2xuS9jp1uaYufnvqXg/ANbn+VpRViOe/MiZ7xYfwwI3y7ohBS+jAG
	 Sxbpc7B8Hs0CAIL9yrknao5eJ8YU47QZsOOO/xn/oTBrFmAQnlifoWhZEvVdMFjDDM83H
	 gco+Jo4a2aD5zoUPplx77ps2S+XCAfqT66lzGqA4zMqU2cb55SzdVlFyzOW50HRta3g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661814;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=h/mTAJVuuQhpAVAUlFXnSBfePIty5rSPTob9a1ZdEdY=;
	b=0Ruwf8QHMysoN63D6Y3CLdHoIw/RCbNK2ztmtKTnWXuSd+7q0isDUQEb9JjvFAQqWOwD
	 7/E7jFPGLtg6xSkbifALQIAURkC1f+vJHYVqA7LhsPOqO2bGAjLwYyufZ9275Ybefyj30
	 EVAOGiKCaDoHDM3GxWgALcHhMSAiV4/Twzk94+F8gc/oSVb9L6cgdunFegvm4qXwi9M8p
	 gisu7N5INS7JkZ2+X6kqyibdzdZcEhgqIpzPc6hZKOXVYoLyVkd5jWIe1mvbSPDNOvtBH
	 0V2NgeRx0Jf5GCg1MO44+6waw0wekUUTEfUsWIs0d4AHopKpo1wZ3ABJrc81UALgUJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F26xTNVz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96DB0607B7A1;
	Sat, 14 Nov 2026 13:10:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F26xTNVz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5CE741F000C8;
	Sat, 14 Nov 2026 13:10:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661814;
	bh=h/mTAJVuuQhpAVAUlFXnSBfePIty5rSPTob9a1ZdEdY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=F26xTNVzW9tp8yy8ppp+Dv86UhrCHvWmEOdhHICMiXGEZk2O2+Kja+w/MuQlnOMu+
	 JzTI3R4yuU5GRr42/E3D7uDu4Cr/FBika6QDUGu74GJkDlBEAeX1YGEjS/Dlqk9bBI
	 Om+csVo3teTzJCkmRtuq/I0XgR/m20O/2c2RKOJeToz5F+wAMlJddfR2DNTckBrev0
	 DnzEWbcdtIz1gsrII6cFjNLa4arltfHbmaBXKJT4vFgnQ2RFGqTnnuIxfh6U+NKph/
	 bThJoXJ1oJU7xRahe5YNw1jmbpdofQyjA7ORrMjBcwkVSn1sj7SLDJhUkBv2Vrvutf
	 PFOJUgNRV91oA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:21 +0100
Subject: [PATCH RFC v2 40/42] erofs: refuse files on pseudo filesystems as
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
Message-Id: <20261114-work-loop-pseudo-v2-40-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1554; i=brauner@kernel.org;
 h=from:subject:message-id; bh=G7tJlJJnInVCqA4f4ewlrJ9rtBBg8ilw8miRJBX+0NY=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iJnCssvWLi9e2DJl4eu06dM0Y00/Tfzzb4uTU86rv
 ycsT/wK6ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIUiOGn4wKuxctKVhzQK7P
 /16SfMFr0yMs67VSHrYaCJW87fifu46RYVHfjQK/wyu61EpT3J9naxxhfFH1vl3hrcymU+syTAp
 WMgMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

File-backed mounts take any regular file as the image and the same goes
for the extra devices of such a mount. erofs reads them with the
credentials of the mounter so this doesn't hand out anything the mounter
couldn't read anyway. But files on pseudo filesystems aren't images.
Refuse them just like loop does.

file_check_backing() also checks that the file is open for reading. So
a source file descriptor that erofs can't read from fails the mount
right away instead of on the first read.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/erofs/super.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/erofs/super.c b/fs/erofs/super.c
index ce05557bd9983..517a289b9395c 100644
--- a/fs/erofs/super.c
+++ b/fs/erofs/super.c
@@ -158,7 +158,7 @@ static int erofs_init_device(struct erofs_buf *buf, struct super_block *sb,
 		if (!erofs_is_fileio_mode(sbi)) {
 			dif->dax_dev = fs_dax_get_by_bdev(file_bdev(file),
 					&dif->dax_part_off, NULL, NULL);
-		} else if (!S_ISREG(file_inode(file)->i_mode)) {
+		} else if (file_check_backing(file, FMODE_READ, 0)) {
 			fput(file);
 			return -EINVAL;
 		}
@@ -835,6 +835,9 @@ static int erofs_file_get_tree(struct fs_context *fc)
 {
 	struct erofs_sb_info *sbi = fc->s_fs_info;
 
+	if (file_check_backing(sbi->dif0.file, FMODE_READ, 0))
+		return invalfc(fc, "source can't be used as a backing file");
+
 	if (!test_opt(&sbi->opt, SUPERBLOCK_SHARE))
 		return get_tree_nodev(fc, erofs_fc_fill_super);
 

-- 
2.53.0

