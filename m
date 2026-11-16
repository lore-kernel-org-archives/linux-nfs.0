Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827367;
	b=G4STlM1LgprxP+5ZzirgBiQIv+TYdUs0piK0rZGfA9Ua+iA5bDogwv1MLB56EUoLO9kI
	 JlapI2C9xUrv3FS09js+HXVQXjLusJ9RlxceZXSZMgoU3qC9D6DINaYC3HnrBNcFhjA5i
	 w57snGnI33rB40ZQJwjtWn9FRujzRgIf2VHSNjxZEJCKXu0B5ig+4o/biRhB5GdbjwxiG
	 KZ5t+1vl07xC3O2V0RYCGyxArm4Hw9gAkjzbCN91zxTPPG1I6Y6vtFdCc5mj0dbW6QNFF
	 acC9IN1vCONbSW7BQnKcf9o9WFn9u77/m4fQN6qnDv8Ho4JXnr8sJbZ5y6ckSbm1VCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827367;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=QuUCHwL/BY1T2vLOc/gPlh6w5Yz8cRxgbnaJubMSr1o=;
	b=V9e8FCMrCaabLfFdZjfIFhRrAI2uhyhy0cYyOO9lUX33bjskQDw6hlIvODEOXblZbHd+
	 ghOQYFzEH+bij+xJdhPSW0Op/ddfnWMsmtGS26I6t6GqMt569UqWOPSKkRrnqtiEr9Lto
	 vbxs0mWtSZXf5tJ4CRNzZzxzF2L9F9SdADr+0uaOlg19XQEOOjf6ZGSBZ7JF/mcREfvbW
	 Na6dtjysfJhFapfPyKyahpyEbJiGDQECUjNgsFQK9AMACKmBZwZ6o35x7RMbXDtWC7IfT
	 RUoK8D3ZlS8WTnj2KuCBNjeG7eiiqq23/dTF+ISlSyNibWupk8Yh+wdz+Lp0LzApPJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eWqStoTx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CED7E606D785;
	Mon, 16 Nov 2026 11:09:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eWqStoTx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 06D331F000C4;
	Mon, 16 Nov 2026 11:09:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827367;
	bh=QuUCHwL/BY1T2vLOc/gPlh6w5Yz8cRxgbnaJubMSr1o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eWqStoTxh4NNpgnqJQAbTvc3F6THAiwGDN4VqPjGqWwxK7grKrhzbpvrlHik7rWGw
	 LmyHVzhO9Te46cFwbrOlUqPQT0oF/HXwwsXx3MMepT+0OdecMLBteD88v1YwtZDrjb
	 AXsRBPgBjWNowMrMKNpm7VyBaHOaIj2F5J1wA9g6lYlollu4Lr9qETGzAR3sI2AGOJ
	 TSaw2eCAkAKBPUtB9DzHyshTTMIy6e2o89WZ3qLFdUdLDNqsf7hoK4MdFxBxrCMMKa
	 uJI1F89qP7iitUo0oqG6za1D6pwPB3mJIgwX+N8gUTguZ5WCHqvLiCThVUudhF+1hf
	 dv7ajSbH3o8+g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:00 +0100
Subject: [PATCH RFC v3 27/44] openpromfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-27-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=932; i=brauner@kernel.org;
 h=from:subject:message-id; bh=t/2kRMsiGpRT6NTAIUV0TfnxBeUt9A+YVEprnQjtSPo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elx35JxdT7pgb6K/ULzwVsNHP8XWzVsVbHLnnG5L8
 e7oO9JLOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbSYcjwP2Wj/4MPiqKhcgc/
 6/xyjMmNPSASpr2muGTZGal3tfctShgZfp7MXfTHwc5v6+RFB2fUhtm6Ocdt0Pvk2nTfzPHRZid
 ubgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize openpromfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. openpromfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/openpromfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index fb8d84bdedfb2..6cd02d456bac9 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -10,6 +10,7 @@
 #include <linux/string.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
@@ -419,6 +420,7 @@ static const struct fs_context_operations openpromfs_context_ops = {
 
 static int openpromfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &openpromfs_context_ops;
 	return 0;
 }

-- 
2.53.0

