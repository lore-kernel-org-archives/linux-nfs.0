Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827188;
	b=ydrtJNeaGP+0RFJe7h99kTwSfbBPuP/ON/zg2o1vxOyTbZtmcz77njo7BccN/Olo8goL
	 aCdFlyJyijck/N6Gsp14i+77/wH3L2yAyE3tYMaRA01RfvB+n10Y3djG24JzYPxp+vZR7
	 87nbHBG5qNN+8tJUw2HVYapbRo98YvWFO2EYJcqGc7muUlELVyqo5sSobSuNwsYQp25Eo
	 PLVllJWdkyzSZhvoNAzTDq7qaikxOmW5Waa83ev4k9J5f3ZxlPAPY9qJRey8bRESrYmZl
	 phsRXrOsc5UNOxXfgW7YMIheJUN9MbDHdBXw0MWOaU1ieGlJNTYmW0+W58DEHCJtCtQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827188;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=V+osxLoh40BKAExDHaAgHTnjFjsOBXyAUQavRmbvZdM=;
	b=uCHgSUCoXHpOd+EC7TUk2hJ5nZnBdde6h0gC5VRYZhIl+YaA4CXc3gnn52K/amKbALzB
	 tVjQfHZsqCxpEePD28GyGpwfdyj9VHfKbiW89Z5qfLGt8bq4Mix5fb47E7X6+eZziPiU6
	 wKc1KZm/RQOdyR9ZogofwAcuITmEN9r0rydbxdN3gdrH05Ai1uHUPlDGPrY86K0Pk10LK
	 qfA9XRR4FX+y0tOXMD5EkZ2PpAmBdl+ORtunEInFz1jZ6KKOl/GN/Xu/9YVJ9Hk+9vLzU
	 xV1Fzpu6L5czsu/Z5TOgayKfi/Hxr2L2tbeOMzefneLs6tOJgDalwRP7SB5Vmn2AL1g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mmCSykMY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F21E606A33B;
	Mon, 16 Nov 2026 11:06:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mmCSykMY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3410E1F000C6;
	Mon, 16 Nov 2026 11:06:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827188;
	bh=V+osxLoh40BKAExDHaAgHTnjFjsOBXyAUQavRmbvZdM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mmCSykMYbLbUMgfAzsTRriPXLKntVd5F4h0335Zci+KFp7/M6E26jCvFFmFm6/FOh
	 ZimtlOfuTCf0AKdMb7DArxCbNTGAd0e0/CO69vZW620lEXfAn1pqfCoje10jxhSc1J
	 cSFCUZF5FEkl71fXKb5wgdAjz1AWCWq6VhUkPeo06V02hbI/WxzaCyHgNvxkzI3sLo
	 2GdAQUK0Zyr6xa2Qe+qIUwF/i/vhwqVU6IgGnQbVzU/wiykqChN6i8GKS5TT8NvnN7
	 zLrxUiks7eYGPstb/dmbg814Xp6NJSPByht4od2BBPOlpnQ+JR68HmJS8oj1md4KvV
	 tKiRrZHSvNGsg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:36 +0100
Subject: [PATCH RFC v3 03/44] target: fileio: check that the backing file
 supports ->{read,write}_iter
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
Message-Id: <20261116-work-loop-pseudo-v3-3-8cbbea1cf34f@kernel.org>
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
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1508; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tSA3soIyhcve68q21MuFcaunaKBcO2eetu56IE80bMc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epzEXGTe+sJUZYufjwnje3Vtz4w3241//XLYb7Dlz
 clNJz9d7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZiIxk9Ght6dlz/J/z+mfrBJ
 vHbFY9ZvJotOF860Pjt95QXHWeof7qkzMlxf+8bzxp25H/hkNDaErSk2OqtYfjKAI+ps4N2d1nc
 PbGMBAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

With fd_async_io=1 the fileio backend calls ->read_iter() and
->write_iter() of the backing file directly. The synchronous path goes
through vfs_iter_read() and vfs_iter_write() which check for them but
the aio path doesn't. So a backing file without them calls a NULL
pointer on its first I/O.

Refuse such files when configuring the device. On the synchronous path
every read or write that needed the missing method failed with EINVAL
anyway.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index ab9824a4852f1..a5391e57e9aa5 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -144,6 +144,14 @@ static int fd_configure_device(struct se_device *dev)
 		goto fail;
 	}
 	fd_dev->fd_file = file;
+
+	if (!file->f_op->read_iter || !file->f_op->write_iter) {
+		pr_err("FILEIO: %s lacks ->read_iter or ->write_iter\n",
+		       fd_dev->fd_dev_name);
+		ret = -EINVAL;
+		goto fail;
+	}
+
 	/*
 	 * If using a block backend with this struct file, we extract
 	 * fd_dev->fd_[block,dev]_size from struct block_device.

-- 
2.53.0

