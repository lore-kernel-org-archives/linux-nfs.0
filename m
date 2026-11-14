Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661727;
	b=nVCTZrHyBZ96g8yYjyoasVxP/5C3+mMcBIBsGXleDeDpkU7I6dhnGCxKGC7J3ygKaBdg
	 Sw6vMSRp2R3Dj4H5GHd8JoX09cuSGbNwhoC1yxaGe5DHNujRZWSRdWWx98pQdHceGL7c6
	 rcumnZHzMIqNViBdA9p+nmVgSXd4EolcDT1vlVOQF6W8sfbiGm4wiMBBgNrRzniRfo9BO
	 fKsR+0Rj30zDDyH5eGBVLLJ0bID/zmCk3zbfLry055NhI905SYY2QtL3h8l5dG+e3XzQu
	 PyQxVwlJpBmi9X8iYmA2Q/fr6Y93E9eFaXTYqJZeOQV9Qbbph5gNbXl0tdVeDVIJDYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661727;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=QuUCHwL/BY1T2vLOc/gPlh6w5Yz8cRxgbnaJubMSr1o=;
	b=E2pZtiySGURzViuB0qZRyXAOqCL56eIbEuJn/KgYJsmzYika3rnTe/Kxf4JI20MAaa9Y
	 grSYmOxFcb4nMCSVycmXT+aAfNdR/JNiP1U0ktPAK6l8fWYQiWcUSr58Tp59WQuIWlbWk
	 SIQrDK7aSwaKeDN2zFsXpUGTJ7DtrCgOlMS03+x9Cz6m3VDh0/pUiiW4Y8O76pMiESaRd
	 uw3zcw+rglPUIW4lGzCr5f+oI40m4FsVFAavf+Q8Wh7daR/h83PqJ6+W3P/xNxe2BNxaa
	 Cf975yfUkkjZPEgfS+7if+ZrU6m89Hc4+fZM/Y/3qL4NS55mY68EB31o1ek/NEb2BCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CNgQBX13;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E9E4606C6B0;
	Sat, 14 Nov 2026 13:08:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CNgQBX13
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA7E61F000C5;
	Sat, 14 Nov 2026 13:08:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661727;
	bh=QuUCHwL/BY1T2vLOc/gPlh6w5Yz8cRxgbnaJubMSr1o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CNgQBX13ffe3JXhue37YFrjDqTi7QHQwoyhDfFs/RUZghZx9ATR26nsVZvuulojy4
	 90+O6VwIW2ujBbvNja5FGpIcp4WGb+E74bFqbxprhGFZj99iPgX1n1tw/xqBz3cMB8
	 MfHWE+d7b/nOaBVNHFm8j1ZuOTqlusKjQeSptMVaBcEBWpesAQInyNISF3BohFJGqH
	 bJv1esG416Dsi1quyPxAWVW6q3d9soXbqUnTAmvb+rCqacLCr6yXrP17cyauuaOm6l
	 BRwaK6kRIFJYfyH8/o8Tz/mBRPJMyObZZn+GgRNk6yY2s2rb/dZsJEqaL3QrXA/Ljp
	 vGyyEiF0/ILGA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:08 +0100
Subject: [PATCH RFC v2 27/42] openpromfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-27-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=932; i=brauner@kernel.org;
 h=from:subject:message-id; bh=t/2kRMsiGpRT6NTAIUV0TfnxBeUt9A+YVEprnQjtSPo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGmZa3HwtJek4ZllxQcnP9aLXbCtiHujUrnojYSNt
 aycMZvDO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZSLcnI0KN9bfIOOwUTHxZF
 s4I0h5P9rySDnr373Sr2jfuvwbaNVgz/rOz3c3VWSW3/KCX0wje956fP+Zc5IiuTJ+y+warBtiC
 RFwA=
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

