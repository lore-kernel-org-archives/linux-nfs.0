Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827476;
	b=24G7DcIaIyYilfFIi6D3PFi0+/yQ0qKTfEsEpEBBYXppRO9hQSPeIZ6co1jc1XHiOYrf
	 M2W4imUHsO62TR8h/JgP0ESYiH+2jNB5rX8+lviyyOeJFvyUL0LcFujMXZ8/cjFeIEYpa
	 PaJ4cF1NgLzoimvoeOGxjcXFHP84m/9Q6N06BfIGdUXsq2teJkgb+V9DUOKp3xn87mC8/
	 9BDI4e/iMNoig7aA4iigsnCEz9JGUS4qhUAWu1rmAUW3HIUF3OdFyuXZ6BQl7C5kKffJ7
	 VHXawMPiKfZUqG0MM3TcorxUTlMAysPL8i3by6pUHjhpN+h6kL2dHH988mlLo8K4H8Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827476;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YaBmWD0H2e/byZAd7Xmvk9z8GUGshWVsh+H9VIaIL8k=;
	b=cIeCk8QEXGmCK+zcUf4on7vah11uCifaRbce2iMmPmxyrJQ59HqFGKWWCKgGP7UhsQ/2
	 /Z/uLVbUoSadui6Vpto+BXgV8V1khvRqfH2WLPDqeBPaonWLfCklkTIE6B2qTA3+NXmuW
	 62F+8IskY1yYLke3SVoomd9pIL/+qZ9V7i/vLCN1BqRwHftsCiTMQgBs/LH0i4LUf8rE/
	 Vfqhd2lNNmkMn62K5ByxvLDtLsXWrJDDRFnk5Lt6wjWpJBLcuOZgKDQgIGD+ykO5Q/HI3
	 Y5u31/4EaWuoHA+qaajZCOiWP5COMucEg9FetAcsV/uT0LaeSzFwZ72NAUa1gLOo6bQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=U7641dzb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B8686073B04;
	Mon, 16 Nov 2026 11:11:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=U7641dzb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CD541F000CC;
	Mon, 16 Nov 2026 11:11:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827476;
	bh=YaBmWD0H2e/byZAd7Xmvk9z8GUGshWVsh+H9VIaIL8k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=U7641dzbHi68FgoVcp+Qc4aB66pQAxq0SE1VggFUvf3UptU6PSOSPxEuUVckdRFis
	 gBdbXWAgknUxf2WOR6QRrK3mJ7qo4sKt2MVBW1KDfKbm9AEAp5P0WwCNwKFdlGvNSy
	 V+LVCf2Qz9d+7FNEGVOUuPu12FvHNYURFOX6j7vwsicSvTt2onQWRzpOR7NkfIWHRv
	 54vr7WI+NATWXTFWM2Ht/34FIxDP08XFbN+qBvortmw0+AQaDGektha4t5P60B/Z7W
	 Rlh6fXap3z/icrBIH9mQxI7rbDe6cWHLoTt0lp7fefcljhZ916IZ4wrFIl7C8tMdpx
	 jCqLwaSdQUg0Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:15 +0100
Subject: [PATCH RFC v3 42/44] erofs: refuse files on pseudo filesystems as
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
Message-Id: <20261116-work-loop-pseudo-v3-42-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Gao Xiang <xiang@kernel.org>, Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1701; i=brauner@kernel.org;
 h=from:subject:message-id; bh=zgPAmU25yXmDAhDS6CiCz+zo4qFZ1Bc8aFsU5Ev1fq4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etw/L55Nunlnx5t7vJ/X/+JYMbt61QHto2pZr1jCR
 HcvcfmU2lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARwyhGhgu3NIKv371gIt3e
 8vqomtbEY4GBy5Y4t/xe8OHknsJosW2MDH/6VfjO+i712/2j3JGf97jpsQb1eOXvkkXpJpPWOPU
 9YAEA
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

Reviewed-by: Gao Xiang <xiang@kernel.org>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

