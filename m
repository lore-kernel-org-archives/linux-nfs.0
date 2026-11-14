Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661761;
	b=LbWF0V9eaigxEAtieeJosu1yHsr9ZrjWLx46SPdOxbO/XgllZdElBFpFB40N8J9a7OR+
	 IGd8irXSJs6LSN+L3wgriOqcVPDYeoe5XgvE/N5AJEOWH8NvjMe7dpNwubW23NJwJEjW/
	 1MH96o449hp0eDxeKBKWmlHOODT3nesEUvGmBay8tQa6ZGATJeh6/L7DSr64N5ADrEBNU
	 RiXaTTnDtMTzUSygMpjQrCFWbhcuZOGiiqaEkwPyelLsh+zGhaFoGGN7ViNJ/jwOSO/Eo
	 GOVU7oBG9NSebAOlMZaL1YMOAMVdED6Q56ihGnY73nrsVw6caaji/bLD1vnEu2o3bqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661761;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=OdlKWawwdwZpGTfkQNHBk5b32jOSAzRsLtI4xTW1vDQ=;
	b=ZAnAQbSqC2pVrDCw9p1b7rRDsviPVHdVQnFOChkfEtRLWk32gFe33R0kaoWFXlLaSYvU
	 psGMkeQqvWZqJTAsHGlo2qTK9+UbqE99/f0gDVmsGLLvSV1jYUEt67ek7Q69xGml83UG6
	 nQZ3QxQkhuuOxbd8gxY0Wo48VH8/mHOWeS6jry9Yb10nttrWu5JspOqqKdJs3mMaYwDtb
	 xDdNHFCa3VIat1rcTrw2qqqjSKrl/v8VhbxulG9PL4YL9n+AhdtUH9edsrrGUZw3p8OCi
	 iuxXPB/ZXWx0U8MuCLSuoLcao5qqmBPoP5C6elOph86o9EMvfZ+2Js4SRag9U2Eb/lQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ahGg+gbK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DABF86075C64;
	Sat, 14 Nov 2026 13:09:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ahGg+gbK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BEE61F000C7;
	Sat, 14 Nov 2026 13:09:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661761;
	bh=OdlKWawwdwZpGTfkQNHBk5b32jOSAzRsLtI4xTW1vDQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ahGg+gbKJXxbgqkOcSvuZjZ7iPlwqVzDb7EoxKqbMYLfnwG2b1ybTE6823Yt3K+6g
	 6pxGQrYoIqiTMRS2KhVum/gBvAKYjwtRqLYJCBO/9ug+3ibc96rUKSQG8oL+uPM/Cp
	 otj/ItmyYhEy+iuvYfxXHkC9TxP25a1aDbikvQC0LaWKFqqkHfvi1rF3sXkQx5MRrH
	 gup6EgTCHwl6mcX33AkMw33YPKcSKfn9nILfmzWaqX+7hRwWvA8CVF1JFBWIvMizqB
	 9iaDWPBWP9dpOG/jN3GKX5YzZjKL84UtGahKm/OO3Hrc5uHtCRmGPTFTPgEI2L+fkM
	 4xc2owYmq/A9A==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:13 +0100
Subject: [PATCH RFC v2 32/42] usb: gadget: gadgetfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-32-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=982; i=brauner@kernel.org;
 h=from:subject:message-id; bh=YWRf7GOro6drmYRPuYvYnNI62ZxquNzo3CA3o8p8z3k=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOkuXt19v9szNHxy/sSShDNHi+s1AhW1jvfPOLx+v
 43t+vdHOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZi95Dhn+K7b5fV2hevnL5D
 2vJ8vvv+x1/kZkmvkvsmunJ/0t+X6ZmMDDeNr0oHP1bwdTnx7e2hwBWKTidX/diQpKYmvejZFYN
 lK7gB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize gadgetfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. gadgetfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/legacy/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 7f6d8460152f9..8490e5d0351e1 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/uts.h>
 #include <linux/wait.h>
@@ -2223,6 +2224,7 @@ static const struct fs_context_operations gadgetfs_context_ops = {
 
 static int gadgetfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &gadgetfs_context_ops;
 	return 0;
 }

-- 
2.53.0

