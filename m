Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827308;
	b=yibnFwtkRoUmg3lmYZGlDCvKkbC6oodfFwGPC4LpgjYrWNA0chQTqEc/xmDwW/XB6Yi8
	 H9gOKN8hiyyWnjMirb2LgW5gURQmAN0izWdXW2wH2BN+DLjJwvyQyKE2rkD8oImelSA09
	 ivnTYlZLCZk/SX7l/7aiLXLiX5tJ46sTXrpeiirQv4jCThUsy3CKwPyjo/maYNwmw4KxO
	 rTtnfnSt6GSc4S2Qxt8QYkh6WGoMA8WsZEtziO3JSJBHXjquTW3Z92crbZ7qvX+dp950a
	 qbmg1Tohvzln7ZtgECv0qeRxDbTzAW0gElyU5FsVA52YlNPCYtv2j4pdNiPWFNmL72w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827308;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=2Wy+scJ41Y8KmYhleRQezskd7+v4uNRBlIFkKwTMVMA=;
	b=H+ErvyZdrphRVVVdAb20zOtbstInnNGCPKMizSjA8pRyoyvyp7sltQzabt4pUUDWzkZh
	 o16gxPJWZnbXtD1rX8WKeXaL9TAJQ4CDGiXhusX6jPbhmGq232Zy2O6xFrSk7ooeLCRy7
	 8SxeNpZEWlUfGAjbxJ7iseB5/q+xWlR7xtlPfEOhux7ugoX9bg9W68PXVipzlMtX9OZN1
	 11yUvoi8899iPYqU34aDcYdAVuZkvxWdSQ3eTrcH1G2LnPYmYV2kAa48l6mHKcHHjjozQ
	 oDwbwPAT/0JWWADg+scB1rjfebboRtmep5GjS68Y1ccfL+vj0uEz8GqgttEb+CifZXg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="MAOQF/Rj";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66CBF606AB7E;
	Mon, 16 Nov 2026 11:08:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MAOQF/Rj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CCA281F000C9;
	Mon, 16 Nov 2026 11:08:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827308;
	bh=2Wy+scJ41Y8KmYhleRQezskd7+v4uNRBlIFkKwTMVMA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MAOQF/Rj2EJww59dNiCxumtdpBg6TrUeioHJXL/bnUNEdpUa+TL9z32jyWcX7tf9f
	 YJlPw0lXLJuN+5nu7TRB/0yUYsrayfVUWBWRn7Xag0vLZsz5NbrTs5CwrGSRxbSogs
	 P/9NyJE2TSHUN6IYMouHl5EjNy6A8TIlTWZwYwJV2xPuUnoIigJD+H7vGh9TSZyMxj
	 4DkMGGlnmERtn/y0Q7vC3yziK9l/XelDpyyOK6XcWMfJfoaMe2RgysYQszYJSpfAbK
	 at3Nt4liC7nM7DMOWTOI39ukPd66Pb8dTLPpdP5tvFSKmeh82o41oMaYOJ0Z8Ld/8g
	 6mMsCjtcCJIUw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:52 +0100
Subject: [PATCH RFC v3 19/44] smack: use fc_init_pseudo() for smackfs
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
Message-Id: <20261116-work-loop-pseudo-v3-19-8cbbea1cf34f@kernel.org>
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
 Casey Schaufler <casey@schaufler-ca.com>, 
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1063; i=brauner@kernel.org;
 h=from:subject:message-id; bh=mH75LpQDT6Rg7eXmytbmjrMu8Ad5NprhLDuRN3w7u4E=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elyyYcaRBJX9njuq/Xs+e0qULvo+Ofy7yZPN3Mk2k
 V/3Pt74sqOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAix84x/C+c8DbZ9snBwuZV
 Ot+mNXG6qCX6nmf9lubn7/zkwaWjM1gYGfavmm/06upB/mOHiw4kL0t/3hrNdDv19L7DDxzblqU
 v384EAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize smackfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. smackfs never holds executables or
device nodes.

Acked-by: Casey Schaufler <casey@schaufler-ca.com>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/smack/smackfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index a72bc7fabea99..4a56bbeaeca37 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -25,6 +25,7 @@
 #include <linux/magic.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include "smack.h"
 
 #define BEBITS	(sizeof(__be32) * 8)
@@ -2880,6 +2881,7 @@ static const struct fs_context_operations smk_context_ops = {
  */
 static int smk_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &smk_context_ops;
 	return 0;
 }

-- 
2.53.0

