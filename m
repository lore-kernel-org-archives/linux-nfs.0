Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827240;
	b=WCltuezzVtdqyhiluIP7MRHvADOl9GxEk49es4ay1jFN4Nw8iwek1J6KT0PMFyPpGG0u
	 DK1/cgppW5JZygEJf/r3p6laSG9hHmyqnYsc7dR0tlnbIYNrC1wNShv65STopsM14eAIv
	 W9EuXxM4skhKuSx9wc//03qpvrA1995kI0QUzKJspY0swRbFxrjJeA4DM1BYv/tvIEkQ+
	 awZhIAfxWZT0r421W8DIYfOwG17xRNaaseiQu+Ba3tt/7suJ/VNXv420xlH9u2wxoaJJV
	 YEiEuM9UQ0Q4o7lJZU3eHJueYbrQLJNYHXqsWHSEa7tCO9fjpXbHPO3kH9OrCdAaFAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827240;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CQcOz9pf9yUAnUZyyI8ZqFilBp97onIP4xdHL0RQnuE=;
	b=fQNrAV5+uzSxRFqkk6K2TZ46iZzACd/2Qr4+g7zoU1lzJhOLcTS0lvn84JWeAy5exblF
	 TpZoXm7OVttzoIpNzHDnENWpItnETKRipelvPhVpFUE2S1b7ekoEBoZUMnfQ2HLV63vwN
	 DOETecW0/LqXCEPBmRLT6n4c/Xmi11Sj5kvxVvKVMP6aqLBjROHV4dd8sNmaQppelyl79
	 5oCfHJXro/7KdJ2o5V5edzv3blIZihzlg1xgkEN0h1PbQOhHZeIBKxjc6c3WnNAUxI1+v
	 qI7qjF78IKreyL7Q4AzVBohuemY+HTXUGQXcRsGsX8syyp+eZbWf8qBT60l7jiNn+pQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WAHd6iSb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 885F76073C53;
	Mon, 16 Nov 2026 11:07:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WAHd6iSb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F1991F000C6;
	Mon, 16 Nov 2026 11:07:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827240;
	bh=CQcOz9pf9yUAnUZyyI8ZqFilBp97onIP4xdHL0RQnuE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WAHd6iSbCEtifefZMSqk0cXPnktLAZIBAaCQy60YJ2nJaxqT8DKgVk5VsUN67+gWm
	 z8mxW0ifANULaEn6eoO1YSyCH77pTBjTLQpEuHRCSgNzBdVAIhSKqn4sWkQPFyXdBt
	 tXJ1An451qL0NHQ9VXwP8ewze057R4HqD/VydKBcBWfCdpBT29zz5SWbRmbhPZIy7t
	 krh0rS/lszKzpG2HbfXO42srT3A406priAC+52NrNl/HXbwY35qFpwU2cri/sdCERB
	 F2qr5cKieSSqcVwo+4jbRcbTuZvJ374VxYIuXO00ayF/nT6+GuMDVyrWKkf+vRGeEh
	 HJAAygLW0S83g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:43 +0100
Subject: [PATCH RFC v3 10/44] nullfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-10-8cbbea1cf34f@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1090; i=brauner@kernel.org;
 h=from:subject:message-id; bh=r8cREnFKSRz4SaxSdJTVTJtjPA949EUN40oz/vuaT38=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epx17FvHFoV3U5iXzd8/4c/mG66STx2Sspkf5j38u
 eHRZFGGWR2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQATmR/NyHDKmqvQXFLhWaON
 1Yr9emFz317b8/vF0rgo9uCmt549tVoMf/hXbrBsap/pJMm51TgxM3VdUKfemt6Ay/afb55aob/
 BigkA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize nullfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nullfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nullfs.c b/fs/nullfs.c
index 319c2f5c5a671..2fe24cb97160e 100644
--- a/fs/nullfs.c
+++ b/fs/nullfs.c
@@ -2,6 +2,7 @@
 /* Copyright (c) 2026 Christian Brauner <brauner@kernel.org> */
 #include <linux/fs/super_types.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/magic.h>
 #include <linux/splice.h>
 #include <linux/uio.h>
@@ -174,7 +175,7 @@ static int nullfs_init_fs_context(struct fs_context *fc)
 {
 	fc->ops		= &nullfs_fs_context_ops;
 	fc->sb_flags	|= SB_NOUSER;
-	fc->s_iflags	|= SB_I_NOEXEC | SB_I_NODEV;
+	fc_init_pseudo(fc);
 	return 0;
 }
 

-- 
2.53.0

