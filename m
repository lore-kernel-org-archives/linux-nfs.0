Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827396;
	b=qTlI7Rxp1/griMt2aAsANIzzyfqfLJs/hUdSpXH6V+4xP5xk+WpxX8VTouSF2HcVHEVh
	 GFMo/4ZTo/eTr7rDt+NCD4icm9eOHXMvWvamZ71Zb8p8JSdb+BPB84yOamBeD/l8l4enZ
	 eWgYS/xRfhqu/dZY1MJWHJS8bgjX09l6DAU1qx9wYjMciVTxPDtmcdxQkAieEvHS1R325
	 7VBipxwtaNzPEL7iospvrs6hortlRkax8NNvwltRY5N2gIj/+Y4nzjWjZLWE0fSy1T7wl
	 8DvdmwOkPON8iJTwO6puweQ40xtjRRB5eSVSqUcWO8bpAjOupxzqyutpuSGriORWeyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827396;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=e7Xf/q0YdYNKT2pliNp65/qzLLmVGTQJhtvNXwy/Qs4=;
	b=pb+oOKBt0556n4GW1hnP30VTLdoS2YAEUrAKIllxIWhZOraU+AVazCPlSKDcAZdj2xZE
	 tkulVopwHb/pnwst2Lw/QaVF8vBXVtDuk1GY46gxWHIM1plZfEEOFufUzjAluqDPrxdEk
	 JuHvhBEq7yrQB+V805+MJdWGzNvTh5LNT7xr55rW53PTIbUB9AT9bo129gO4l7Lcfi/To
	 ASPosv7qOIsZhkUNiA7nxIpMbjzayIceP3ftel9Tbo6qL3DIPreRyO18cUtevAcVnk/8h
	 Gm+3W54HMIpUn6jL/3up96prBnYfEMkWOpFN+iPS1NuPsfrXSnANomwxZjq+EcNtLZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ApAW8mvI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88F98607D22F;
	Mon, 16 Nov 2026 11:09:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ApAW8mvI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 711F71F000C5;
	Mon, 16 Nov 2026 11:09:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827396;
	bh=e7Xf/q0YdYNKT2pliNp65/qzLLmVGTQJhtvNXwy/Qs4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ApAW8mvIJJifAjWYMUb5gxMXy16DRqJm4u8pkiJ8hSizBB/4pLJGRptA/5U9yNxIa
	 xMZTa/pyHHSLFSat1QRBXQMIvBBOH46bkiSC+wCMJ30SJAwiKXLJPAdoQxzZ9SEOBZ
	 G3vlURHcW/ctidW9VnUlrwd1CDDFJU9ArynxTn+S/n0TzxhpLUFcGQr0wD8t5rq7s2
	 rDIEi8/j9EeeO+fKzBSz/q63y3Cnlcjn2qFJEho4HKBhrjQbr4WZA5duS6SFL965ai
	 O9BL7oLYto2CBKxBiOiCC10Wh16aWVflnMPiReBgzJqRNlSQVYcwVO7QDBJErdunlS
	 BdqXVb3PPTzKQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:04 +0100
Subject: [PATCH RFC v3 31/44] usb: gadget: f_fs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-31-8cbbea1cf34f@kernel.org>
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
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1005; i=brauner@kernel.org;
 h=from:subject:message-id; bh=X0J/CLc/AEot0Nag6LzWBIr3X5UH9CZnU81QaK4NiqA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etwULH6lXr7MsEdu38TG/l+zfsnXlD8WUt5sYCZW3
 Vn9ScCwo5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCIBCxkZ2p4+qzvcFp18tPiI
 rT/b+7tri/fcdp/2x+vkHoEL9zk/72H4w7PD3/nLRDHRrO6+e50bLORVnr+V233sXs/Uay9DlQN
 bWAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize functionfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. functionfs never holds executables or
device nodes.

Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/function/f_fs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index c64a268e98a43..a6b3788399a56 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -15,6 +15,7 @@
 /* #define VERBOSE_DEBUG */
 
 #include <linux/blkdev.h>
+#include <linux/pseudo_fs.h>
 #include <linux/dma-buf.h>
 #include <linux/dma-fence.h>
 #include <linux/dma-resv.h>
@@ -2166,6 +2167,7 @@ static int ffs_fs_init_fs_context(struct fs_context *fc)
 	ctx->no_disconnect = false;
 
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &ffs_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

