Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827389;
	b=jkkszQvud3j8YjlC+FuMfwV5weUGxkurHkVpcHY7VnFQI0bb80us8I7UwJKbWsOHGUOF
	 rgiHhC3XT90ALkMZLsuat3GZLUc0sDN546elOVIVzGUJ90zarDEnuICjoUiluUFjBSzbj
	 UDXnP4yuJ5pGGX3Se40T67ubxNdHSqjVaIoln3Q0fxRZpgAa9j6w9y8G3pTE2bl4jQTkB
	 Y6uRBKlPEOxR1DPRAKCA1IZhRvPJLTuekWNmbEhWkcVgl6QFjTq3V8rtQLgH16FAvllvd
	 KBixYXnPt5KAle4nP+MxgmP5i1GtxPTQVVG+ovgrSjUr9wLJM/YlZsPYHJ/3DGICDsg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827389;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=id4PRLDY8xxqmv09Cy60S/mO+ESr2mIJ65uM2WRQC7s=;
	b=afp+aro9TcCA56Uqo1Ldaxmc/UWLx6SoH4WzpUIifa1BFQV5BnGws+vWo2a03jScVWJz
	 JemqZToJ6mAawBZyypXmMW3mCmrB1SCDY/RVvFlxfLFdgGmsShkj52Q8Xl5N4WoELUQZs
	 0lnAvaRdNmhuy44KTfunDSlThrFN09ko4M+zlpRBtH2XiO++PL72QTCKV9CnQaUqZ3uR0
	 ucn21t6O085CrMbNC40hKmJ6j65TEK0JrNZbb/UgNbaJzx43pIO4ng8K/HpoK0XpesZOn
	 LDZG0JZv5lc3+U32v3BLuq0KZr8vOpfKo7qlW+lqRSl8RCk/jOB0pd2y3fUWqybu6Qg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oFIEwLKD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B4ED606D785;
	Mon, 16 Nov 2026 11:09:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oFIEwLKD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 451AC1F000CC;
	Mon, 16 Nov 2026 11:09:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827389;
	bh=id4PRLDY8xxqmv09Cy60S/mO+ESr2mIJ65uM2WRQC7s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oFIEwLKDMkGdxOt/DDlVAriXa/3JhjU6B0wnumVBLhZbrKad6BNjyN32ljVZe1gr2
	 evSiKb98KYiK7ox0NLucJoulMze+sd3HtzyZ/Phmkxks/AbKfj8BC1no0C9EH7ohN3
	 WQMFdiKsZiXF4sj6E2AcrSrWMXjOjOyhtElSwZvxW5uxffrEIpX/hWkpl+FofkZOLx
	 b2aRFRpLcgHXUzQNqoClVFfyUUZQ+h9kK+k31gD/lsiHRjzSHuUqTUFbozUt5OYusI
	 G8Q6nJwUvut37/TzsrYXpAmX9f8vZm1SSdPUv+Ge/ufOtx/LttiTnVQr4RWG/x7ZZT
	 n5AYYwK7BC2Ig==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:03 +0100
Subject: [PATCH RFC v3 30/44] powerpc/spufs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-30-8cbbea1cf34f@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1161; i=brauner@kernel.org;
 h=from:subject:message-id; bh=IfUgpka9O6kutLnlSG4nrBix3fgpTd+0l8aZ7VY9Wl0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etyY0bbQpb9/stRd2wNcz8MesFWKZlzUZtZQfdaTZ
 /NkW8OzjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIncd2FkuM13RtqwR3sRb/7u
 73H9Vgmqz68LeQWvbp3DZuV3SdfelZHho4jyyh1BXWnl1lUZlWu/W/+8XHi6s7LFRtpfibX7ThQ
 TAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize spufs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. spufs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The spufs files that can
be mapped expose local store and problem state areas of the SPU,
nothing the PPU executes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/cell/spufs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index f066d9c7344d3..54b45932aecd2 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -11,6 +11,7 @@
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/fsnotify.h>
 #include <linux/backing-dev.h>
@@ -741,6 +742,7 @@ static int spufs_init_fs_context(struct fs_context *fc)
 
 	fc->fs_private = ctx;
 	fc->s_fs_info = sbi;
+	fc_init_pseudo(fc);
 	fc->ops = &spufs_context_ops;
 	return 0;
 

-- 
2.53.0

