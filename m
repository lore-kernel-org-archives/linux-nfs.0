Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827173;
	b=5TiYHn9+OpqKTkYTlMYZ0zI4B/oyQwKJqQeAJ7d0RjqJzPvWPjOZdaEsXdq6JTlCRWtX
	 yajHr39zN65OajPL1mE+7lGzn46uiUMhBvt2v9rEfWxzE6h7p5MBGU/z7PRSgqtCudsmu
	 qCJWLFyRfjva71Dpl53cubFUUOeEuVzvLDen8wFi6h5UEuzyEdyUXnKKVJbB9D/NKBLf4
	 RAetDq24kK8GF8la/aPiHeM0fpJxbNs3usNef3uvWqkAdO67gn5qVk++e8tdrrG3anMQk
	 S03v1H/g/zZ+9AXgIRBlSydlziBbOti7kw6ux4YMAmKXeV50mMNZ5sdCEXWHdkrqeHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827173;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=H9E1u11sECBJWFTmloDJmZ13PYN0Kwn0d7kmiA3OBRM=;
	b=fBGXauI8JP1dHM97zWI223QArr+sA5V1VGQjk7RrLUH0k7rQk7aUGUILGadMH/9M6I1j
	 5rRUiYgNt8jC1/dp8oMCUVCYj/Ebv/zVRVnIuENYNZqiChnpbQA+wTIXjUDhub7H69Gtr
	 pscbzkEbLyeUXtSZaDpM7qPqyrD6hrdQU5ObKBMmi3ljrFi1p3AHxNqJtAiTm/FSr0QXv
	 ZLncr2SynF+Jx/uVi1xb2ZbszMIg3MGw5t9nWXzo4ZqrqYs2Si0ZJilkOQHVPLjKituWg
	 7fK/1LuZFFhcE/mAnTuE734E+o1KsRsfWwcsQEwlQPBPYxzny+QWsN1fOq2Lh6lI1kA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kXBXegK7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5639606AB7C;
	Mon, 16 Nov 2026 11:06:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kXBXegK7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E916E1F000C5;
	Mon, 16 Nov 2026 11:06:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827173;
	bh=H9E1u11sECBJWFTmloDJmZ13PYN0Kwn0d7kmiA3OBRM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kXBXegK7dC1dL/bZ9+nDwuLsEdWqEdkGm3v8QYa4xbauZMWbuGG7TJof+GlVspgc6
	 FrsnozDmBgYNMx5PleVEdEj2kZOxs0GZRkgg5V0hZc5AB3JrL5tiIO0h1vvhhokZG0
	 r5PLjrDcCnZ3+X5jM6ZwF5fzae5BhkGDz/vxX/H+//UMQhBi+YsjA2sgBohg411S3f
	 RN15M3gCu2W0VEVkAPsWZOa8JJoL2By17j+phnGfheP6VMWIuS9AUGqX9gr9kFKR/l
	 67+V1J8Lq73Ymyu3xj3kOn/Rf1GEfYGbirIZghea1NE/yTr0T0Dq2uoKqDapAJl18F
	 AxXY+14O7YRpA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:34 +0100
Subject: [PATCH RFC v3 01/44] loop: refuse backing files that aren't open
 for reading
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
Message-Id: <20261116-work-loop-pseudo-v3-1-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org, 
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1877; i=brauner@kernel.org;
 h=from:subject:message-id; bh=VBI+uMCHtIBDpXye3IfyuEMYz0sbcx7ROCm69jjOsKw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9ehy/1dSsii0m7V7enfhfyQ9t559yePWxhStUzHL59
 E16H/9XdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkexojw+QQwXjlawZzkoPn
 qlueuOPxgnWa9MKE0D0SQYo37ztI+TH8j9bMlUzVqnrt+1BljeVHrpWttpeFOvw6ujdOmSEYuUC
 KAQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

loop_configure() takes any file as long as it implements ->read_iter().
Loop itself never checked whether the file was actually opened for
reading. Buffered I/O went through vfs_iter_read() which refuses files
without FMODE_READ. Direct I/O has called ->read_iter() of the backing
file directly ever since loop grew support for it.

Since commit f2fed441c69b ("loop: stop using vfs_iter_{read,write} for
buffered I/O") buffered I/O calls ->read_iter() directly as well. That
commit was about O_DIRECT handling and the FMODE_READ check went away
as a side effect.

So whoever can set up a loop device can read a file it was only allowed
to open for writing. Open the file O_WRONLY, configure a loop device
with it and read the contents through the loop device.

Refuse backing files that aren't open for reading. Loop always reads
from its backing file so a write-only backing file never made sense in
the first place.

Fixes: bc07c10a3603 ("block: loop: support DIO & AIO")
Fixes: f2fed441c69b ("loop: stop using vfs_iter_{read,write} for buffered I/O")
Cc: stable@vger.kernel.org
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index a3325ceab484a..c96e35c3ef423 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -528,6 +528,9 @@ static void loop_assign_backing_file(struct loop_device *lo, struct file *file)
 
 static int loop_check_backing_file(struct file *file)
 {
+	if (!(file->f_mode & FMODE_READ))
+		return -EBADF;
+
 	if (!file->f_op->read_iter)
 		return -EINVAL;
 

-- 
2.53.0

