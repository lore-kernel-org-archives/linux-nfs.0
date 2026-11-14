Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661642;
	b=r9yaybIFz7CwFm1+l00VVNWnaVZhlXG+xL3LM0LCeq3EyWXUL32LIMpWq01w+SvCeE7n
	 h0OrHhtveuoYB3dxe4q2fWKXo2qhHlwhZEchgHBkmAfaaQdL15JRyp8aBSm7UDotnMl7z
	 G3GrSqsCO6BnQYfxZURMEMbvukpn5hNGR8jwtfMqT08ak+dW12Mhcy9A3A/qO792RUgbn
	 RwYG6AjvCTl2mJ72LyO3OJPaotiIt4cduH4vV0tMskq36PaZVYuvG0Zom527Zs6q8aVbB
	 ZTxVAiqk/4YG0karnpSQfcKTdgYvi90S9mLL0MrHykl4y2SfW9T39CL//0O7lG2ysUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661642;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fL5qL7JYOP9BGMrgZwawKOkNR34gS09nbbxdAESC5AY=;
	b=j89fNz6MF2JPATCGThS9ms9qOyoxvd3aSbGY55Xk73tzP5GWt7pK/104nrIknhneigvH
	 dmYGGDIuYG6qgrorMT3IhFYP3jTh5RT7SJSLLKuT/wt/hdNuEOj35aYoNAcXcQ7CE4yZG
	 tCnFgh1mZJBuV0TB2U3x8U62JYAih/CFmUjSp/Wn25oUO2VGgYK+zIm3rhEE9i9jNNbSe
	 b8rffO1SLOkUTIqlz15K/VvYZ5JiRp5shOSMNAs5vk3sAG/rgYTuFarRtqmr+wxbKZAnO
	 SFR+p7oJw4CjRhLkf/WONpxtcmmSiaO3TLe5v4Sw4pTMwowvj9vul0RVpdbskpUsASQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XT6Tzz65;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A1B560A6F7A;
	Sat, 14 Nov 2026 13:07:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XT6Tzz65
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B32C21F000C4;
	Sat, 14 Nov 2026 13:07:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661642;
	bh=fL5qL7JYOP9BGMrgZwawKOkNR34gS09nbbxdAESC5AY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XT6Tzz65LCASVZ47tnM9EdK03t2mFYcw5Wfu4oufgcBgXnbaOuckTDE94B5ZXV+Va
	 EU1Hf7/L5yVuBKj4y88q1JGFQui+kFHrJJu7lnns7s22U3Gs5ZcvsCcJTG0I2EyW3Q
	 KDKAn8ifYEBsZ2B7CrL21bmgUbpdyqHWaiX9WluNWeXrhcyYELynQmFzM5mWkYnC0K
	 zpVL3Gebr3O9VCG64/CDLTlwkC6MFMkAzn4mz3EOe5xNvAgcqW17IAQzQdSPmuWMkG
	 /v0whbvR9pbXyF9a4Ry1WJns8QKC3IBONTMY+4RwPAvzY7FdiKnzRHvhdFNFhLYf64
	 ce7gMdf7ac8/Q==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:56 +0100
Subject: [PATCH RFC v2 15/42] tracefs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-15-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1109; i=brauner@kernel.org;
 h=from:subject:message-id; bh=OLdUHvbro/9NsaPkdx9SBi3MWAKl0be+fpwCoTKnM0g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iCk/X7VxtazYZu/77yKX3Lh0lO+Fb1pg5oS3DhfiF
 sop1B6L7ihlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIniMjwzQz1Rr/RW/fHJCR
 aP8X8LL8wFk5r+qdurqGgnf6i89UfGNkmML0ZNu1mkT3zPW72uZLPX/ovVd5gtESM71HojlJH6K
 WsQMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize tracefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. tracefs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The only tracefs files
that can be mapped are the ring buffers and __rb_map_vma() refuses
VM_EXEC already.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/tracefs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/tracefs/inode.c b/fs/tracefs/inode.c
index 5020365ca7048..e04febd868eb4 100644
--- a/fs/tracefs/inode.c
+++ b/fs/tracefs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/kobject.h>
 #include <linux/namei.h>
@@ -510,6 +511,7 @@ static int tracefs_init_fs_context(struct fs_context *fc)
 	fsi->mode = TRACEFS_DEFAULT_MODE;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &tracefs_context_ops;
 	return 0;
 }

-- 
2.53.0

