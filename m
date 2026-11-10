Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302294;
	b=3H6tUa56xu6foEOqrJ0AH2o2uRmavuyGqjfvUqyMjqV+g+OvyzoxhfEFxxsGHsEhy/jI
	 KtFZQdMEYy/eE4SkwcQYrurx4Qqu/I4x49cqMLNZx0Qjzhd7b3yun/wQYfpSawhmZdNm7
	 /P6MD26bBW5ECxZIavOra8nvdMQSWCVtV5SiBI4gbNOBQ1qsebpElqV93rnQQZT2RpaNm
	 l18Bkt7G4OPUxQ/IK/HCYF6UkaEmcnR6kbTgnVO2nEmWbK29ljy93CT+jYxMFhaCrLMev
	 vOvRHIAcanx5NeUHr8ttiyqYOtvbU9nb7YHAaF3/nxRvex6AfhoSHRA+9KX0g4TkFIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302294;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pmz9jtGW0ywIGdBu3NtUNt6417QseUuUlLq+Fyk/468=;
	b=zoMGMmqhm2kafrK3C60Fh4WLlwo5bo2OTD9/cGCFTx8LA7+/X9GCNq5WvDwl4+Z8wFZm
	 IIcg4O+iDorjah4/ygLT5WV9kd5wjZxYo7ieagVFD/+FOM1r1ccHVcd7TKd62esFiy5gO
	 w6YKZA4PmiBeSMBb4U5hi3zQ3lR8H3of7wgvaOmhqf+HwrMlKzQWvtgVsY8sZwwNw5ng3
	 zVybl6KsiZdp9ZF9x3Y+KOUqpT3tejz6MZBcYED7KPkijR++Vt6p09drZKoc6gJBtskQZ
	 ia2lWZMXfoK57WKTLKtzUrKU5Ir/P8K9Y2+m0QaPZVOaEqi8QDPvvWcahXq/hVM7eTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GU5e1n38;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 827D2607267C;
	Tue, 10 Nov 2026 09:18:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GU5e1n38
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CE9521F008A1;
	Tue, 10 Nov 2026 09:18:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302294;
	bh=pmz9jtGW0ywIGdBu3NtUNt6417QseUuUlLq+Fyk/468=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GU5e1n38Lz1+Pvtlp7ASXPOHCHk1tuIpx5t08Oh+PNxIh+4HMt2Bb5r94Whq3GWlo
	 vECtZ0duG5TPPJDG1ybdWsZsjAOMuPW/Hb9SEcHwoBF8ATO9BDk3/jhbKvQrg3nc5L
	 1FQsP8KdRKjEyM/BeO40ervx/1NH/WjEJwBb2dvNJPa1GvI7Agf8ZAOGTuuFGlrw7z
	 D4QQjfoUytG04RFCySWSZrW4de4972Y7Kl9IuLxvGElxSqCx/Kci+Zh1lbu+K45JKy
	 ntgiJAxTVhCEzFNboe8IF1iAKS/5NRv9CmLgmQlqgdr6yjLdjFnSiOaCzyVTXMbBQg
	 iNtELDfUm8+4g==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:36 +0100
Subject: [PATCH RFC 20/41] apparmor: use fc_init_pseudo() for apparmorfs
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
Message-Id: <20261110-work-loop-pseudo-v1-20-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=975; i=brauner@kernel.org;
 h=from:subject:message-id; bh=eM74gHkw1JzhCTiSqpoG3xHbWPNk16urIeNgeqxQRac=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erD6usJ7lpTrW3d7tqQWr39pN+HRX+O0+aeqRP44P
 Ht3WOOFS0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBFvBkZDujeP1XSFJdyYUFQ
 s2Z8R5AFc4DNtoZ3s+yre146fp5mxMjQc+SfqFrmzJ/TQj/NlTx9oGXNEve39ZbnKwSC7mx/vmg
 eJwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize apparmorfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. apparmorfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/apparmor/apparmorfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index a99366467217..351ea3a7120e 100644
--- a/security/apparmor/apparmorfs.c
+++ b/security/apparmor/apparmorfs.c
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/poll.h>
 #include <linux/zstd.h>
 #include <linux/string.h>
@@ -263,6 +264,7 @@ static const struct fs_context_operations apparmorfs_context_ops = {
 
 static int apparmorfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &apparmorfs_context_ops;
 	return 0;
 }

-- 
2.53.0

