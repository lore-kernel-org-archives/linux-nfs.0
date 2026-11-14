Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661635;
	b=1u0D05rCRCapDuIdEfQuXOpbswDbcy/gRdv7q29+85g+RK3w2XOTkk/zBh9O04/qyYEa
	 wIz0dKHfy5BGAFwpeMAPStYFkXvdxxgI9LaNcaSIyIaIjDhWdrOfoTUMVre2Smha8iJnN
	 h9Yh62Zlej9s/5piKgs72xUu7pyo37NPjfwiW/Sfdz5AM6XtNU7S58gqm7gdWZ02rbfKT
	 vRDytmGK+nFkU+P8oZz79NOGhb0/PQp6YkZkBWE45sDlMEvF+RoymiL/urZ0+FPBQqXYt
	 4eVqOS9auhuH68Iji3C9uLvINgifgOFSEztc0Z7xYSbAqUlxm1enaZC4Xj1Wq+gKlbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661635;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=J9s+j/qnomdsSfV9A9X1jZ68ytQ1y88uXgL9lPJcnQQ=;
	b=tRJ8Xlp1S6Oweu7TuCeFpRAASGSFEm9klewpp1WkuhkwYOMu0SFHQQOv/uQ1J+MSUib9
	 Q/sZSKM35gxdsO+nyd95CApyp0iEurqnpewfEt/LugK9kv6FuP05dhfexBdHXTggpt9Dq
	 WrKxHxM2t0Q/OVfKAFElFieQn1F0DzAVvhbOiHprBiBjCPJkf75bYIJa2QWPAzaTpk0pR
	 PnkfjRyFtZ1NpSshzaGppiG4AoOP7e8n5YnSpsW4Wp3Ya0rdtwmFlTSVpYNBblf4u1dGX
	 mUO+PxHoWDcO+cN2GbpQ47uIhWC+bp9LUsV+/PAECEjhW0AoIPUdKUST7Qokj0KJ6Vg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZBduMUGq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A16B606E0FD;
	Sat, 14 Nov 2026 13:07:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZBduMUGq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8CB521F000C4;
	Sat, 14 Nov 2026 13:07:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661635;
	bh=J9s+j/qnomdsSfV9A9X1jZ68ytQ1y88uXgL9lPJcnQQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZBduMUGqp/qi5659mADzFX9+8wf4kVV3NEMIvBS9gKHs6MAUqEHt8cBzj3ZNgbS6d
	 Nf89OZFMZUZCn2jJ6Mafo9wRMxG9W4SB0eAJp1Mg0VKarsMFlGa9zj428VS1a+b0RY
	 D6CTCLMwH/+Gy7FwbJfcjx3qkCoh6LyEfI7rfX1ekkbjm/2l1cn+9zhnqWbhtfdgam
	 Y+PAnxkHWZsnELKY9cqaxrXaHDYmDIwyumXSSeFQKPXZI1w6p3YqMu2+y/31W4BSbI
	 KTWrP3vhpbirbRroyDnQuVG/W+XGJp6QhDHB9PqcU/GjF+Dz5Sq3c8cIAzqE/bRgNS
	 ehuHrQrWIS4kA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:55 +0100
Subject: [PATCH RFC v2 14/42] debugfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-14-98639a2286fb@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1131; i=brauner@kernel.org;
 h=from:subject:message-id; bh=LYVXsmqnxJmzP/zdkj81mpuZ8VVR49+0Ejm2rZDTrDA=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGr4XHWh3hAo/8SIEYNT/j2jncgmX+7HWMmgK6bgfx63CtOSR
 oh1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmr4XHUACgkQkcYbwGV43KJ5WQEAzj30
 a+DH4tqF+HU88MmhFrWuShGbUZ/WYvxekVK9nkMBAMzhgdjjYON010GwrBYO16UXD9hyZA5dodO
 zboH1iSQL
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize debugfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. debugfs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The debugfs files that
can be mapped, kcov, relay channels and powernv's memtrace, map data.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/debugfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index b4915551ad315..f163f0bc5703a 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
@@ -317,6 +318,7 @@ static int debugfs_init_fs_context(struct fs_context *fc)
 	fsi->mode = DEBUGFS_DEFAULT_MODE;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &debugfs_context_ops;
 	return 0;
 }

-- 
2.53.0

