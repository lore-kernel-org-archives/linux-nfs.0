Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661748;
	b=vwPtZpgj7yLDZL2spLeBq18NHsMQBzfeEv5rTsi5GjnYvRnJiTblV61nTvIWWdaBbw9H
	 Vp3mhFZTCi1pGuFVEAQGPJuL/Km8aWSf3LqMjna5dsc8hlHgEJqt5NwsfYXysU+0JVdYc
	 LlMDvIZgI/uZ5b1MT2PjRpfypoWZMNTvlC+YwIRHj64yEPIoqC5HCA1dZqf4+dcnPRca4
	 KYPcUvTFizUAT4Goq6p+d9ch6/Tp2rowgA1WCSWKiCUrVpfKqhz3wwNa7omUqiAyCoqFS
	 Wk6Yyb8r4qjNR6NL+WhVqR+rT9DirVFoXySRPWsDoeyTt5X0ZRtAvXHMRq1vEkV5htw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661748;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=id4PRLDY8xxqmv09Cy60S/mO+ESr2mIJ65uM2WRQC7s=;
	b=tdce4vL8iJccLFXroIfDBwqgsODFHvCy1KHMfpmdHGP6zP6gsiBnMLaA9opsqcRNIjCJ
	 v5IbIfu9BlyeaElRuKiTILpe/r9/rJSJS5ZndjoOFfAwF+jzdgGrnoNmgHcWw+8QcuYKg
	 5b4vBRme2B34B1iWycNp7BY4/3hto/7hZlnz2viCMBLZcAyuWpwhE1lkgXNC3vxWVvy4b
	 o91zZXHiiEayuygF8iApAoia/g9b3OZpNWBYf59FuHWdBnvp9GasMwMTfRhe89gftPEg9
	 Te1TSAhQoNfVS8fZL6LNsR0Qk9qGlTJhzoLJi64qROonvYM1H/+c94eV9tjmKOyMU8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OPYvZMcK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EEFF606CDFF;
	Sat, 14 Nov 2026 13:09:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OPYvZMcK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C84511F000C4;
	Sat, 14 Nov 2026 13:09:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661748;
	bh=id4PRLDY8xxqmv09Cy60S/mO+ESr2mIJ65uM2WRQC7s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OPYvZMcKo2pLKQPLfKiB+xqQT7JtU6u/nMFLT+5hYzH3QWTCFPRoRS6r/Oow1VAkL
	 3HYR/sSwpSruxS71lTMziygx7APu494xsLge+qXN+aS/Fp3Yr+SysKiJDxgm9fV8FL
	 LLLNw7kLSad5h56STuFO2hVPqf8d8oG5y+9btaqGaQCPkoLOjBnZy2HRlufPRIqJR9
	 JAGDmN3jPQZ4ZGCu2z1obHGmPT84ifLV2wmvOlYzT12//tpCLC91vE73DnFUFErjrE
	 jtHCCp7HwPDe37nSYEBsn4aY5ZIWlVvyOmtxOFVyVhXkm5TyApjftkdHnhTF0e2OJb
	 Th1bcZaPa1Qrw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:11 +0100
Subject: [PATCH RFC v2 30/42] powerpc/spufs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-30-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1161; i=brauner@kernel.org;
 h=from:subject:message-id; bh=IfUgpka9O6kutLnlSG4nrBix3fgpTd+0l8aZ7VY9Wl0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOmwtup7dlAk4P1lb2Nu/V0Xay46TjCe9C/9OFdZk
 KnsNdfKjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIkw7GT4n/qCU/F0TKjhPQ87
 jwlLc8VsP+cYLxcU+LHbRm/KCV2pdEaGPWc5jk092LJ1wpFjdg3lNRW7ODKTlXubs7L6rYTlL85
 gAwA=
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

