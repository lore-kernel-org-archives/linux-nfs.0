Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302315;
	b=5Rf3WnHBiKb/WXQMBhQAkxZEcdd3ol0xpb6zDHo2ldQM5dI4zn8cMgOTH00xOij23hxX
	 WnMCP5Gb+5HU15/S4l3jWF4AAAPQZvp47umX6pd1a96bB5AtzM2nBms63NU94+byOxkFF
	 BeXNc4Gxnpu3hRJWbKpy07Ab0ntcxJDFwyNru12qQSYFCF8sY5sUaJiYQkR/d1P1c5NzP
	 JYKE2o9/d1eBQkj4t4kdOrZi7hGl0OIim3b8Wk/dVz3piJKxglQ9nUbbKVfW/C3IUijAT
	 Fig+CtOJE/5mdIWjWGiwMrtYFpb67lIjaB4/bkeLSmMmTAik55gYvJT+52EPQJixyFA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302315;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=B8RQTNfc/eWS72nZHsD5FmaXKvsQcX/MHrv0MZNEckg=;
	b=me4Hjo6yqGv0zhrcbzPLc+KPMPqFDqYHXhaZUqyjgvVAwZtGxzTpyK6C/RO55nVK4FdD
	 L7cRhOO43A3UJ1pSEkG95FwRquENEJLaO0HWBvO883oRr0uwd9GP3kZuFL2zHHNQBBDkW
	 2VGIZfVQGhApFuUejCUt3XwUvK0SJjmncrcCdqgGk2+wb4XU4Iib4XcptWkATsV8Reumy
	 1TsfcSldYO7+nCdd31OXiFt/5ffdSSv1EW/WhimmIU0miKq9D4+YIYxvI/MnC/12756Fz
	 RMu2AfxvgILE0QBnwIfe78gJH64qGQU+3P555MdnGlxCbUA5NE6OSV/tH3gKjZ3t80Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="c/Ap+R4z";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 615A1606B17B;
	Tue, 10 Nov 2026 09:18:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c/Ap+R4z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A20071F0089F;
	Tue, 10 Nov 2026 09:18:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302315;
	bh=B8RQTNfc/eWS72nZHsD5FmaXKvsQcX/MHrv0MZNEckg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=c/Ap+R4zFMvV3/8vcuIEPdB/Gt2XHUlHZTBEX28zCRTGUeuDJCvLmXS2bTYSdzi9R
	 0gr12Xdu/wNWC4bbLqs4TiHsR/YcW9JNs28CEkwEGUBB6TGWOirP4sbeOuKd4a7tZW
	 afM3jYlHN6+MVYSwuAcf1MRkadLxCZQa5Ry8f4ildqJfo+Wt7K+lGKrO7TizAPDeis
	 lj14KsNBHSrSqgHUxSQyH2WPPe6YEGnglY+yEWWsL8vk8c3l5TKaUlKahI+HbhISLF
	 nnD6YXeLZZD0ZUXVgvIwonj2iwv3yWDlAmtq4vfzLGXczqU+vQuxgOQWxGbajWp8T+
	 zqYWbwys3SKng==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:39 +0100
Subject: [PATCH RFC 23/41] fuse: use fc_init_pseudo() for fusectl
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
Message-Id: <20261110-work-loop-pseudo-v1-23-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=893; i=brauner@kernel.org;
 h=from:subject:message-id; bh=hjM1iJ4vU3paA5L4OQPDkADa3AqUdKJFLW5EmBnT+kw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erCuT2albMuTpuPqTDYzVbc45F0XFJ6y9xJTg/iJB
 vndWrxNHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPh02ZkeGybnbLv4dlnla2P
 zh+U1FV/fVEjuEXs+QzeMzuWCLwPtWVk+PIs8Nv5vXPYWX98mZbrdj9iVbPCut91O9M+rQ7YuNr
 gHTMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize fusectl as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. fusectl never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/control.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index 21ffde596d61..4497362e7df0 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 
 #define FUSE_CTL_SUPER_MAGIC 0x65735543
@@ -334,6 +335,7 @@ static const struct fs_context_operations fuse_ctl_context_ops = {
 
 static int fuse_ctl_init_fs_context(struct fs_context *fsc)
 {
+	fc_init_pseudo(fsc);
 	fsc->ops = &fuse_ctl_context_ops;
 	return 0;
 }

-- 
2.53.0

