Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661755;
	b=XorY1jhIrjJ8EdySbULL0opWE1o+1EkOa9pq2RyRAks6fcwRbI6jYzHYOYNK7vDgT3aI
	 xxSE3+p9RJhlktgLtIkAQBlH/g1+UCauUbgt5FaVXsry321iz2Ts3hCMFkeSTcS6LVfQl
	 TrGTuUBwg3GLet2BFxBPFejUbkZOgftpdfz9pWekM20ZaNLlM6oH+e+skzdnZ2TOZdDMX
	 UnPIeVaSLyYfTZP5P0cdxo16kw+5ve/LUfFf7WMJMHsiegMKZ5zltUbBBP6IbsEsLho9p
	 QOsxGa51uQsDF30qZf6D9d/PI0B1HEDNG3SN2xikQvp/AZBNl5AmnMVAEDxVZ7SUIyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661755;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Wp6UiJ6JxspVcAI8vmdp5Pu91b6oGaOfKwkx6Df5sII=;
	b=DwGKhMt67f4qBKqvtIIqGbRkpReD8GXiFg+EhLTL617oLU3Hdy9Fjl6IEtd3tvkl0NnV
	 pG2DiROoZpDSr0GP9zFmRJMJqHVvaQVQLpp2F6XRB/qVdimlGC5kNFSWXQvUq5Pc1gAET
	 pjsn4QBASIvVNDolSMFZVeeMQFcsWGPzaaa7OZgnXoUH95L/bB30pLXiE4We9cI9uNJqw
	 pFmaaShOe3d2E1xMr0YPlblek3UX1bJ9nynA54lQrLz0vNtH9LDn8Vas3FoCMMd0MgBY9
	 x7oDSUiFODRsIVgIzobaM4evjqSU//nfrNpHRFPevyRzEAYCReECa0wF+6g9ZKKYICg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S1xIy3Kr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63F5A6075270;
	Sat, 14 Nov 2026 13:09:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S1xIy3Kr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6EAE1F000C6;
	Sat, 14 Nov 2026 13:09:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661755;
	bh=Wp6UiJ6JxspVcAI8vmdp5Pu91b6oGaOfKwkx6Df5sII=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S1xIy3KriPdoEMTc9dfCxcd8nJZzA6/xLqEC9Ek691tlamme55qJphgP6kTqiLd8a
	 gyYuU7lALuiqsRc4AVPgbXVJK+NhDA4+7zujFjgM6QpBfN5IckM0YEqdbXktr/nw+h
	 Lnumd0/GdHt+C2cs+wHroPF9ZZbqkOvPvOycnwePXHaTKKv61dbwr0kOr8R12Yy/jy
	 TYX37go2jAbTDcgIHhVHfyn/x159FhwjUbvk3VQiFEIoyIL4VPg8k6GDEkPS6GbBRx
	 Ui3KnXYZa0I+MODr9/kXlFNPNu8LZjXuuuvEb5jTNLwqAqpbCB3xy60OP18fpqthQb
	 IPWYjaZ1+0aPw==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:12 +0100
Subject: [PATCH RFC v2 31/42] usb: gadget: f_fs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-31-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=957; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FyQs9iBDL23rPU6G39Bge4Pz9tDFD7sQ36KmSfY2Fy4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOks7Sk79l9iocNp1bT+iXKvo16xtz4Sff5U18j3x
 bKqSoVtHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNhm8PwT/HM2d+nJ4VPen1g
 xROh7Qu3d08LePFy7v6VZ58HB2m7M05hZPgQxrBA0Vj22KJ71q0c77YLbm9fvFXYWin18eItfPY
 MCcwA
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

