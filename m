Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653305;
	b=041u06JNu4RCvsVKKb0iA06M6LLWZPGwxtMOx2rir0+25Acua7SuavITehutUbCjysP0
	 bAA04XkkI1OdwpJua5WKkfIvgVwyOVzAIR6djR5Z3yFT7hk/YXF/ddw1Xbfp+XgukMI00
	 WAMXr7nuvlhnUbbxc5TTSAoY9Yo9QtBNrNTib78mo3WmzWeKz8qMQZcJJYvlNKHeO/XZr
	 xbPXj5RMcjovfVnuJSrX85Iz8bxJ3WuixME3cueo2y+R+dIK5bvRzHlDkL201NDvhTGev
	 F5zHC+i6boFnvpElaWBCZvrEmSElYCHjaAGZxsHmag0Kmvwrlm7rK/nT4CdANeoX23g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653305;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=QUiIdf/VXbV/3ThxPnfV55Q6xZ2QK1e/5J9j2REhcqI=;
	b=dsq9Kgfod0DwnMh32Nbc8MNmlA3jWjoABeX4cqU84OeZKs29KRZKQ2XvSzWNnBdlxyXG
	 jHydbH0gXYxHJU5LwFU/iJCLVg7HjtIsCwskfxiIrzvnHLMJ4L1a/v57Ji4LufDjq1Lmw
	 CMp3WdNOAYy+PmxjZ6gjqSA5VZNKZIsmqX8mXkzxb0jwPcJKTR7oDWmzYCRWIX+DA3Soh
	 knsEaOpaprHTdaWVkRcy1TGrD5ifEJbmcynsLPz1gwq8uVvlhZCX93og03LM7uqy0VErp
	 Qc/NhoxBkoi5diJjkM5lrNWtPQ9IGYUFaKAtk3Q3UmtehwYz7BvK1Kgicvl5I/plPug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BcXfZPnX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA4C4606B96C;
	Sat, 14 Nov 2026 10:48:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BcXfZPnX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DCAF31F000C4;
	Sat, 14 Nov 2026 10:48:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653305;
	bh=QUiIdf/VXbV/3ThxPnfV55Q6xZ2QK1e/5J9j2REhcqI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BcXfZPnX5DH/q7oonex9fT/X+rYPbVzVy3SW8M9e5hd6juWGS+HlERHxEjzACVrWT
	 k/xsHiR/TzavqXyiEx+BvO+ulqU7CJNTn0G+w2Yf7KDHtRAn6T0Ld3J/ry3nL2uUgm
	 MAmMat2Qq9HaH0IbfVUywDsu3PlXMeRX82taYMOWVq0pUJsTi4rNT9l/Er2ZBxChZR
	 3+QNLG2lgMmNYxqY2uHhFcpaWpXeJtIZK/EaloCyD99lbVa012popFxpwQJSF61Q9Y
	 FvcivKzsCbsC41MFq6RoKMNXRY/C4XLQwozR0nCOPUiS351pDqTUQg3GZnNEU8OCxw
	 7FOW7ni0TRhIQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:17 +0100
Subject: [PATCH 10/12] ovl: take freeze protection when storing the uuid
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
Message-Id: <20261114-work-fs-frozen_writes-v1-10-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1269; i=brauner@kernel.org;
 h=from:subject:message-id; bh=R/ypmBhSroYAV5t6Q2PaspAYXgGUjYczfSSW/iihK8s=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sPGourqiPc/vyWQ10RnH7ljd/Jo/d73s5wTlKgefl
 tom8zWtHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABP52cjwh2vJz8XmJRNvKJac
 fW+x7P2GHtZGMdtdB52SnXdI8pqtOM/w3/VZWYSjmNZqWaXnvsaqXpOn3N6T9e997NS5/pf1KvY
 IMQMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

ovl_init_uuid_xattr() stores the persistent uuid in an xattr on the
upper root. That happens after ovl_make_workdir() dropped its write
access to the upper mount and before ovl_get_indexdir() takes it
again. So a freeze of the upper filesystem that lands in between lets
the mount modify a frozen filesystem.

Take write access to the upper mount around the xattr update.

Fixes: d9544c1b0d9e ("ovl: store persistent uuid/fsid with uuid=on")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/overlayfs/util.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
index 521717209b2e4..67aa7b71e9c83 100644
--- a/fs/overlayfs/util.c
+++ b/fs/overlayfs/util.c
@@ -829,8 +829,12 @@ bool ovl_init_uuid_xattr(struct super_block *sb, struct ovl_fs *ofs,
 
 	/* Try to store persistent uuid */
 	set = true;
-	res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID, uuid.b,
-			   UUID_SIZE);
+	res = mnt_want_write(ovl_upper_mnt(ofs));
+	if (!res) {
+		res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID,
+				   uuid.b, UUID_SIZE);
+		mnt_drop_write(ovl_upper_mnt(ofs));
+	}
 	if (res)
 		goto fail;
 

-- 
2.53.0

