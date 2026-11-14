Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661656;
	b=oHw97XzD0dZSvB73MG7AQiwFDF5PUvo8yBa3Br5vFPkQT7bnx2QQocmsVCdYGMpgnYJH
	 ShrlKssYBewUONvs2Dn1LQAeVC8JOSugbCXB4ir6jEo5e633TjNPkueOEJrJsAY5HJ8n+
	 W3Gkp1lGgYLBb7edysVln6xi6raNW5hqWpZkSCblJXj/aTFK/KzLQBsChfnwGU6+hC0nd
	 bcpkKbkHv1KJWbIckjlBiTm5kPTNIpb6lIUINL2iTwuFva6dpiNVXQYIlI9WOK7z+70Mb
	 Q4UdDkYiZHrlpTZvbpFs1VtfI7Fj+IPoxTBLgVfUSv+HM0uvQAr8lOvBwP7nvXzaQvg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661656;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=++ggQwwawp+5fpIFwG3B4KdeRqD55EsEpWBb7WM/wus=;
	b=KCJ9yrge9EUZXQWTs8wI23bACkbLJkmX/HzcdltlDeeJX2VNA9FVgesi20Vc22j2Mf1A
	 s0nys50H9bDfZlQOM5aPqwNST6WkeH0SVSbSNQkhzLRXDw1kklxbUUPQqBJXpz12V6mCW
	 QviUXnNfKJpYv3Wxhbm90H7AWkyy0C4xbnqunQktesNuRsSDbLkG6CVsHqiB9KPaPnCSQ
	 lxwo9Tu0fsUvWYu2GfvUk/ewIO8/6dje0e3HcHY/QY3z+Wk3cq07uLJgfI1BPCLrcft7S
	 AZTmKK9VZt537H07/pPbttI7TpbemVTEnHSp6dss6znXh1CSS3hJH76iF0xrsXYq+fQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ISqS1X59;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA537606F275;
	Sat, 14 Nov 2026 13:07:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ISqS1X59
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C6731F000C7;
	Sat, 14 Nov 2026 13:07:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661656;
	bh=++ggQwwawp+5fpIFwG3B4KdeRqD55EsEpWBb7WM/wus=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ISqS1X59OqSfExtxsOiSjr1wpv0Z7FsnoV/unXwmI2iC0oAeE1CZBnUm2rpLbQChY
	 UlVbIerFORk8Me/5GU683vDPV9tRnmC60uPE2FjWgnWj28UM6HQcw92GM6dJnxpsla
	 EP0uXvdgCUnVRc67H/T1UGcUcSsgA+crZYnm8xvt2wJzIa3kLO4Fm6nJf9PjOQCsNv
	 FSz8gs4T9BgUNPq3f8HpnSRTAiJYTu/lTuBvbPvos8+G1tK0oFpzC1YL2EUS2ey9zn
	 SEWINxYSWGGXxTx69tavZlufHiP8xSylFop7fahaOM11VSh8OruW5Bhgixy7FFv+V+
	 ODZZedD26ol2g==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:58 +0100
Subject: [PATCH RFC v2 17/42] securityfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1094; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FF9e/eJ7LhW9MgInOaUNZ5e/JVsIh5RgAJXPuTh0Dg8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKnMnrLSQPUw2yXBp68+bj4dIDU/cEGPtJHXzrJlj
 K0vlnZd7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIwjxGhufubMVtdsLcrI83
 V3z50Gdhay43R1RMqFp4dcnRaZXmXYwMLWe+THc1O5jMduZaU5272ykVxUsi197p3xOIjl0gESb
 NCAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize securityfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. securityfs never holds executables or
device nodes.

AppArmor puts a .null device node into securityfs but only ever opens
it via dentry_open() which doesn't care about SB_I_NODEV.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/inode.c b/security/inode.c
index 0804023676741..93997a9f16fcb 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -14,6 +14,7 @@
 #include <linux/kobject.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
@@ -64,6 +65,7 @@ static const struct fs_context_operations securityfs_context_ops = {
 
 static int securityfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &securityfs_context_ops;
 	return 0;
 }

-- 
2.53.0

