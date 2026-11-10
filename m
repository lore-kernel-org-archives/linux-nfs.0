Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302377;
	b=XQewFAhyWEgmiPUlsPKFgB3qxxQthrOluwnTrQ2gjUWmkgkNRqAmC45p45ud2mxpmDKK
	 x9dic9gi8U88xwhhm0XkZvng3fmMcJzYxcnNh1wwYMLeDMqkyqelgENc4SzxTxHz+cHle
	 jQSVDemSeYZOm/Mq2nnJJnrGVGHJ2DcEFSEpLnXGPSY6rM0KdtakzLaoS7Gx+V7jYyjZP
	 jKvObbLWFO6VdZvbqO7FvvYiwuap4WaBH3t/5gnSgJu03858rkzpBDTX9yokkLlR/mdDP
	 15ANx70A+yI+Ygw7wnaZ9dsAEBvPyJvszVhV5b+u7NGwItL/EZ3ubJ/oGDImkmVRe1w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302377;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=6F6bixX9VLJl6u/N0LxDxdpy5DWNAw9MIo1FfuiWwlg=;
	b=mbQhQCzwCgfrg3S0yMV3oxBB0FpTo5s9qmf4HA+0yCVwkqfOsPs8NjTAJoHLtSh8MFLc
	 Rj/9dJM9ysvwLbGiYDcDfqkJ3WdWNwZy44vfrr2tVuHrmDNHUkwADgmUrLRUWfMREojrL
	 vCKP5Tk8f6vyxGOtoTbnLnfUPvoXMxQlqSlNCgG01IPaGnjKg4OI2oxukgTgEwJb7fbeJ
	 KiCj15z/WSPVhIc7FU7yUa4m9pXHdFgT/ULstrMJKT5eF1MWYEaXmDT8gkwPX5jC45EVB
	 aJ6k6NofO/aXH+bcaQOlISyyRjb/pevquNbAZdx62SyCBR0uomGLgW0bDlvi5z7istQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bev5vsoQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 033266078865;
	Tue, 10 Nov 2026 09:19:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bev5vsoQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1F84A1F008A3;
	Tue, 10 Nov 2026 09:19:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302376;
	bh=6F6bixX9VLJl6u/N0LxDxdpy5DWNAw9MIo1FfuiWwlg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Bev5vsoQXMD/2z11W7fF7gnr2WOAFCcu91VLKw23i7E0hkqCe1dVrhYy0+KtPJYmF
	 7SwxXGH2SnKEaJ3Gz1JJnuTNJfiSNXCHsVfu0NtJiKPNIwpXKj4acpNvaSgQsC1nOn
	 v9D9W8uBh3avkK864v96nnYuhV8CQ/YD06yiqjObPD/ts1Fa3Yra+s2JNGu1CbzXmf
	 lPoZDKOPKjIY0m0OaT8lZr1lUKx7GexmZFGHwmRV5+QIhPZ8mbIcDCb3vCEt/G7Jt7
	 jjMDsVbCi3OviaEyzsMqCkhdh4WJddoN0LSF4ef8DVIGv0E0SDkQwiCi9hK2AdSt56
	 Gfxo6evUdhVLw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:48 +0100
Subject: [PATCH RFC 32/41] usb: gadget: gadgetfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-32-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=980; i=brauner@kernel.org;
 h=from:subject:message-id; bh=HoqM8TovkVWXxEHW73GnjomtfEF10WO79IJ99ILFhZo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDTyDeb75KLVcD+3CmXFA8amrwrV9AreTDj+7Lby
 8T6ktIfdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExkdS8jw7y61UWZSuzH/CUD
 K7cIZcU05XC2Bbk5/nEKXnZy8lbXBob/3nwJfl+n25nnXWg+epP78Jz1HcW8OwRzuVKbKsKnfvB
 hBAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize gadgetfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. gadgetfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/legacy/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 7f6d8460152f..8490e5d0351e 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/uts.h>
 #include <linux/wait.h>
@@ -2223,6 +2224,7 @@ static const struct fs_context_operations gadgetfs_context_ops = {
 
 static int gadgetfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &gadgetfs_context_ops;
 	return 0;
 }

-- 
2.53.0

