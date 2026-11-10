Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302370;
	b=q2j8K6lkzTIznOhKx06Y9hQ3Ues+cr7GRZUdTE4yr18IUibw51jcbUhzt2r4n+hKdSkd
	 0b/yFirIhbIVyTWJHTCiPJvkzWDxH6Yh5XMNixk0fqHsTLjl5fp262ZVSKilBbzya1VjK
	 QD+13xgJ7bWe+v9y6TnfU2IGiYAMwDVaQgHguaGdEPBwQSzdJ+L+OmuGIAskA/JM02NqO
	 FIiVHraDILgj+UAQX9WIglB0VnFC+g2gQGZN899hQEMMg7A7jTwcUfuWlt8xhf8JiXTGe
	 6EfcM8uuZbiqJyqQHR8i6pMMqHVQLVPW77lrs+dext2acy8X3TQy4WVNMTjOxxlQ1zA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302370;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=61GGJusgpyzZ+uPz/Xbu5aYUeDmjAfN/VZVh7aWKvTU=;
	b=VvfQsdIlfJtwwoplLNRMLrDpKylOjhRZJsp2LiFbqkyJYxk9bWN7H1gZeb/demj1Hphr
	 4kJWYHAtB4XoGhyJsB5yjJhans3B8xqrkC8QG5J87vw1G2ddjcB6foQVusKAtabqqNbrP
	 frYk/RiLS2yti7ZEfo6eKzvrViFfajovivdwNGLRLsbld2pRsLHetmoI45AWifD9WuYqx
	 +xfw2CDkUScQefDyY+fm8ew3azafhVL6Wkw0QBZTTd8a2eVEBVPiuaWRc1sS2xN3ixkex
	 UTFXfQU5iYJ+h45VkNWTjjMtWRw8yEo4uwUHQrVqF3OpKv7E5tiKeF/O0ECOxqsU5Fg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cqE1KvWE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4BFA6078861;
	Tue, 10 Nov 2026 09:19:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cqE1KvWE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7BAF11F0089F;
	Tue, 10 Nov 2026 09:19:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302369;
	bh=61GGJusgpyzZ+uPz/Xbu5aYUeDmjAfN/VZVh7aWKvTU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cqE1KvWEqfCGk9TU1/lVh6ReyYZK8xzJKhSLwmR1cLY0RyRyETFTNmRX/CBtNbGFm
	 AmuFU6adAiumck8an+GpWWAeHBHqTxVKqL/rOi4J9iHi/mWcjTVLhL+WnDXPLpVbqc
	 yNZwiqRepbCcz+qfyuBGhyN5+Hq+js5kBs4E3JLsZlH6qW37IQzTV15bwwycAzfttl
	 5KH5f71aAWWbWtMYVn2+pgetQgDmUXbkZvrrt3OqlCUUpM/yVT8GMncN9mcbx9GAj6
	 7GM+h1AIZhoDOm6jyzSEu1Y46hB8cYzaIFJvf0HAlzzReo76KuwOVqRDN7hOswsejZ
	 ZJtnzm0RI4l6w==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:47 +0100
Subject: [PATCH RFC 31/41] usb: gadget: f_fs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-31-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=955; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Ax5jIfHABzRtvx1V7vJnXeFPM8kck0XZoDkmZlrhKu4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erAjdtX2CfKp++Zticm3SYuW8v6aMj1ObN8qo7eS1
 x8t/6ib21HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARrwpGhs3ZDExxtr2C+4r8
 vRsu23RvyHzNtz1BoT1I0k34U0vwB4Z/1tUpv1Njvs9dubSC+cKR5tMG9m/4Jj97kF74bYvUGf5
 udgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize functionfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. functionfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/function/f_fs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index c64a268e98a4..a6b3788399a5 100644
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

