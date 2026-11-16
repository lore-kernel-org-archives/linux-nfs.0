Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827285;
	b=XqenNZIYLnuSzF9ooMrnprOFi7DyRs0cmpX11p1E8TIrlnYasZxProg79GFZEaeLQ0Uc
	 Xs7cu82AR90GneSvCSgcWGkNvzGU981NenrBwaNX+3BzRcnKR1kVNckdwYY1Ts74o0VsY
	 w2Oh2UDEnoUaxRrHP6nLtzNTTXHDNCyHDuCiPnFDj9uRNK01pgvo6tezfrtKlj/1as31r
	 ZPirAlACanklRf5HHiXg0ySN7yBSQL1YVlORYewmBet5eRP0gVZIKIPZmB+zDccR16XHQ
	 +HGe3O9tFc4UpoG0WBjTzMoXv3mI+oD3/hSq2ciLP4OEUOW9GmW3fjWQs+MUmLngeCA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827285;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=/UpKqXd1Q8PiwEiW91lGeEUdsRaeGgHVBpYK/fx91FQ=;
	b=K6ZHdtkkkQBdAs5fD6H6FV3gZahAxnfdWNFwTkNqrjLIGWEdNsbMjRZAJ9Mn9RjJO0YA
	 /68yNO/46+GtCS70IYMB8OSoze8cEonu8FLNOFhrK1cv7B+yFNLbFQ3ig2D8I2scV/2Rz
	 x6BhNdt5pb9hf/b3daYlbgPGbyI1UqhYPf9wmmuGWxP2Vc+SslrOAHw05sSum9ffurOQ1
	 2RR3eqkRInUpJNdqoLU2mV2Z6880vdAenEDw7WEsIKH34rgSZfvKH8KEdTZLo9ZUMFpkK
	 iN89GUgMo/oNt6dEh8WZa5kTU6nkPWqX4ph6XE8b5o7Gn9r2rXbDORSD+UQ2Q3fgkTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ThaPefJk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6695606A8B8;
	Mon, 16 Nov 2026 11:08:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ThaPefJk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E153D1F000C4;
	Mon, 16 Nov 2026 11:07:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827285;
	bh=/UpKqXd1Q8PiwEiW91lGeEUdsRaeGgHVBpYK/fx91FQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ThaPefJkzYID6A/gJ8BD95JHrrRcoJDueFApgfCzzf6m8AFEdrOPX1V/N0Ou5MSFE
	 3MisKv2jAnh8Lq68niVuDDcQgUlU9KBmq1TWQenImwyQsFWqYvNjMCUA6JECgAVC5Z
	 eCzHZrAVshZEsT9OLL1LKL8EXLhOWYBuwDyPsI88o0Rflk04BSpkmzvraWAQ+wW1P4
	 lJTEA6hSyLJvmV54IXpt4SUS6mx/j+/M7f4C24pf7Qhx12uczYw4UemP32oaW2sS5n
	 2peCadUpW/SatJlkDR04CbDtgimV2EQJ4ss/0BvVQFYbPY9qCuNlO9CEhSFfF6dtOq
	 nUL3+tjJpm9Gg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:49 +0100
Subject: [PATCH RFC v3 16/44] configfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-16-8cbbea1cf34f@kernel.org>
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
 Breno Leitao <leitao@debian.org>, Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1100; i=brauner@kernel.org;
 h=from:subject:message-id; bh=arBHZovnHktbx+8dxEhh1iDCO+7a7q/uQBzsyfGCKl8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elz4yo7/8fTyqPtLu0x0Zv8tjtQzyl68wOHUusK4U
 1piFu/4O0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACayW5nhn4LuCbVth/nnv61W
 jll948YM7hL1TRmv/gSG7k93fv59SRTDP6tHgrPsfflmcXKeOZ47jc/ugU3PlsV14pWbp3dNO/K
 lkwUA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize configfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. configfs never holds executables or
device nodes.

Reviewed-by: Jan Kara <jack@suse.cz>
Acked-by: Breno Leitao <leitao@debian.org>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
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

