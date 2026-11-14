Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661706;
	b=YcqKkYT1Hwbv+bMtPzSC1BGhmFbefA7bnuBdobb4wjfR/rDEiNeWqmzlQbvGqrSWTqex
	 kqdJNFZlaEUgDpKMhKjays9ZJKyJEDw61gjRD/z7vBnLwbLzprTF3Me4QisHWu4KTkbPI
	 aj0ZKryCXyue/SKNTq0ZXJVKj7/peiKutnT9gHzoWOSs8vuvPlrrZbksaOK9ocU5z4HMd
	 oywYW9CpVXQjLHBNbfafnwL8gkOLrfJ4StEs3Tn4MEPK0Tr7ZKOO/uYritbwCPdX4c75q
	 QMh511EZmeAEAjsewJ1K6MfKzoJYzYWV62JRgw9SzuB6JQJMVNDeZraFFUkcyVbhOXw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661706;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=65YvxNKLucMRpYw1FJVCDVm75IlqsZ0/PV8GwJXc1Cg=;
	b=HkG35qHOlGKAI7w6dqjCgD1adQJYN8JZHGHNJtN4McVlGD528LAsDxfDfA7TyA0nycNB
	 NdMd7cxaou/RIXFvTjirB7+m6JPzwdo689Ot+OR5Wv/XABgqkuhfmDjjrtnWKB6LLJ3Qv
	 gXXSFhceSKMn/7IpkNiFym1s+P1S4a1Vx+eh4RcgGIKOORQXcCDoym2DllTyTTieQ+F/b
	 9wrFkvuHGh12Na0Bav2sr81hVFTt52Ia4Ojv8m4eARuaV2bYB/CT3eABafoA+rYIO+NFp
	 iskTYPNxX7ltgm1OFeKi1MHupksDF4s47eZz3QmBN4jOnkap1XjA+zq/VMzKnvLxGTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WeNGCImV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76126606A32D;
	Sat, 14 Nov 2026 13:08:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WeNGCImV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 780FE1F000CE;
	Sat, 14 Nov 2026 13:08:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661706;
	bh=65YvxNKLucMRpYw1FJVCDVm75IlqsZ0/PV8GwJXc1Cg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WeNGCImVr8p7F8Uli86lXrcXcfJcXXznRaJ3ysXgWVWZ+J7qA0GAbUGY1fIKmINzD
	 Gq0TzUSohC0rcSFwgj1YbJpSzLekANRgSJWblc3JmmjY5rfokTtd8Gk9jL+gnxkZgT
	 4+wocUPn+rNI91e8pLzzUTNjDm+8ueFQcqxvqz59WUo1LF78rr/MQUPWyv9vCtF0MO
	 WOAUe4WdgY8nZL3LH08OuHHlMKXJGnRXtdR2lA/Lm4R0Jw4Sg256wkbSmrYt+j5HCg
	 mTSFDIPBWkEk4eVPeI+ryhW2jC/6smQaaaQZ+zk4OTzgM+AIxj8Ie3NyT5lv/+pHem
	 sh1wJsF9nDAxQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:05 +0100
Subject: [PATCH RFC v2 24/42] efivarfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-24-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=924; i=brauner@kernel.org;
 h=from:subject:message-id; bh=WuyzjhSjL7aXRZxi4H+U5QfhpdKUXYV3897MSDhz8qA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGlUe3TDrZdvVhVT2mR3k3we9/eJDiu6538yOSXAr
 Hyo0qCwo5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCJ3ahgZ1rM7x73c6uLQZetU
 O/epajfjD835024Vs10pq1pRdPDiVEaGNQXHTYyVl0ebeNRMbl02gWFxsDZvQuTKh6s+L1DpTtf
 mBwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize efivarfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. efivarfs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/efivarfs/super.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/efivarfs/super.c b/fs/efivarfs/super.c
index 12746ced6dc63..e598d42c5f42c 100644
--- a/fs/efivarfs/super.c
+++ b/fs/efivarfs/super.c
@@ -8,6 +8,7 @@
 #include <linux/efi.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/module.h>
 #include <linux/pagemap.h>
@@ -554,6 +555,7 @@ static int efivarfs_init_fs_context(struct fs_context *fc)
 	}
 
 	fc->s_fs_info = sfi;
+	fc_init_pseudo(fc);
 	fc->ops = &efivarfs_context_ops;
 
 	return 0;

-- 
2.53.0

