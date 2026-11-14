Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661650;
	b=jzNfMNB0mTOQQz74tvO2iORTjXsmpaLfEdWZ6GBw/sPE+0OWb7LTg8wqKkQ4pb+KzvA1
	 p82m27nZOsSKth82dsaeJPYFFgGZ8fAF6aFtoOvT0UinlynRGNsqmAeuCY9IkEJy0OW65
	 QKRRkL621h5MegnZ8kmVWN6JzhrSClft4J4+FQWElAME6nojgewH8st2+/s5ZZQOzWVro
	 BBh6pa+XyTQwzoJzAzRZznr17s/F52z7Z+WGHRs2KBGjac3SecH4hitF3lnr5+Ra6XXKu
	 xwhgxBcV6BkquiIw+Rcfi8osXhT+kHDMhS9fj1wOP4Lof3f7i4vYDHcW83iJaFJhuXg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661650;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8Ytkno3jTVi+FFRUdCUqmeMcgBru4oLAHALyh9TN4hQ=;
	b=PQAAQgTXmzPRy688Bb3E07yP58e6WZE+h8uMNjc7O4e7738y2maJJSPvD+ghhXZuys6I
	 dSFcLBJotH/u0N9ncBG9ke5z+hONz3zgZx9Gvz/ajFHT1X1kQyXd1rOmxnf+b7IG627dm
	 HSeVMQz65e92xJ2G+c5SgIV8usV7huXZqt5Ay0rIJTqdrXh/LeprhgVqH/H5ur8eu6/BO
	 8j97KJfMw26hTSX1ZCx+hKuEhml0RV0mE4pGGSq7tOH731fpRGM5txua1hUEtkk/Gmywt
	 tjbTX6WcRysEX3TXmBIHWBED6xEiLiiuyTUmLNit5j2wpLWbQSqN+1A9vQTA8yA6Efw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GFHvRmPz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A8A8606E9B9;
	Sat, 14 Nov 2026 13:07:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GFHvRmPz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE82A1F000C5;
	Sat, 14 Nov 2026 13:07:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661649;
	bh=8Ytkno3jTVi+FFRUdCUqmeMcgBru4oLAHALyh9TN4hQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GFHvRmPzrl9JT/XnWgZ6mHZe9H02hsU97t3+ppYOuzxqJMSfmYjPWgdxAi/Wgu8V/
	 wrZy1vRHCZdd0bC3qI68hsdNcKgmQ3IfSWbtHayF9hWHqdbEWqPyzLLH8RbYsc2XCZ
	 dXSM6hWaopdLwe6Tk47JXm5nRSuNnbE8q0uiLEKYHIn3zKgz4gm0hCB1eldl8tNsaw
	 9r5Nn1nPEqIl+dH7clVv0JN4xn0WgIG2u28WaYeRfsivii2u6GrnUxXBTzpaIAi0hh
	 87j2TXLbcazLek+XXOfbey7w3PmofUiagXJteCYNZfZvoshvSXFM6Zg0UUYgny94Iv
	 NhCBc31tgKfxA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:57 +0100
Subject: [PATCH RFC v2 16/42] configfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-16-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Breno Leitao <leitao@debian.org>, Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1052; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Cs6hi+IJv6YL+cABcEV5PmkB4gvNrgirbEkbHavmri4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKmo6zy18/cHrrR7f6484D3B9HbNopIHW//r8rL/b
 7n/ouvYt45SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJyIgzMsxe+XjzPdujcT/X
 dlcLtp6+NiOv++ZaxhfruqUl7wfkfepm+O/nmC3+VkJi2/4AH0tulRslnlL+mWJ/ffz2RXNuXWh
 +jh0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize configfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. configfs never holds executables or
device nodes.

Reviewed-by: Jan Kara <jack@suse.cz>
Acked-by: Breno Leitao <leitao@debian.org>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/configfs/mount.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index d8cac1cbf3bd5..60ba24e7ae2b9 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -106,6 +107,7 @@ static const struct fs_context_operations configfs_context_ops = {
 
 static int configfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &configfs_context_ops;
 	return 0;
 }

-- 
2.53.0

