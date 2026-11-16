Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827404;
	b=oCSjup1IwZNf+7VigGDC6SgExRiHHDpbhsglY9uzBPQM4ylLo+rMfKOU3y/Ym/z9YyyX
	 gfuF95lkRyEDz/QhNqn205fr6g6TBzkW/Ff9PQuGPQxHIBPsuYT09gqF1j4aKK/PI4NPq
	 FwB48xN5ng1XlzEFwiZUyiFOE6W9m6CbFP7b3y/fYWi5XAak1ppW01uoL9u5xC9hwrUvp
	 1uonY6PvmLA9wUJ0zaZcFiNpII/XuBzfXlDYH9/YSU0GpsY3UJ3QeO+0DoyJ8cHRcsclb
	 aF3bDGnbnmzIyTsiGPs+4dHvF7L5M64PR7VdzswecKhGtH5LTWHGRvOLgDQFE5YxTaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827404;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=yVy0s500r+s0cQTnrdL3iNQJg4cLMTqv2Ys59F9WF6I=;
	b=QSRa5XHn8ISXipRGRs2WXQMbgEFZEdwsTE/fItHQVvwx/Xi5kvqmc/3uKS8gny3Ugp2T
	 RzTu7PoTpE1A8hylmP9ZRd6TfwT8vKBhgUJrmmzgBqmQQarByPvS1y8TmQG2Zmux2+++Z
	 LkHq8fgqyhIuGj2F4ASqKwjdOfPDijfY9k3n0/YXViEIytLxuuwMzteFDQNMFWG5hDDfU
	 lb6YobdakDlLJWq1TE1hSvHGJ9/sEPN8B4QhCKkwH1jLvlNQNPK7Yya9yQATJYVcPQuLJ
	 Tj40LeeDEzcQgsDe4z+W2Dt3iMDSoqua1/8sc7OXmz/T4ymCcApf92FScKLPgpbwp/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SGTpzw+u;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40AF260703E2;
	Mon, 16 Nov 2026 11:10:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SGTpzw+u
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD1B01F000CC;
	Mon, 16 Nov 2026 11:09:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827403;
	bh=yVy0s500r+s0cQTnrdL3iNQJg4cLMTqv2Ys59F9WF6I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SGTpzw+uOaYvP/qWVmonGrGKiT2oLbT2udCcq4O82u3mG1fLwCQ9o8RLyYUJt4Z2Q
	 dpAapsEVRxr6oLO/o2rGmqb9CAmt3ErlRs8wAxbEiyz6v0DU4LBOoVm5BMqcicnomC
	 B8WEPz6Gu99rGym2zbIvLEILBo00aGvsodfuAxEMd8k/D48PrDTO0QuTGdS8US31n4
	 Vg8bRB/rVTd/Yp5SFsM+N5GWLqI4Smmmis/xMColxtYtlNVNFPYfrZpPd5XgHFtufK
	 ewpaVp+9XS6onapcIs28W27un4PxSx+n0soDqly36XgM/Z1PmufEv2uBMoEdpSk13h
	 SXrkbTRXnHaqQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:05 +0100
Subject: [PATCH RFC v3 32/44] usb: gadget: gadgetfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-32-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1030; i=brauner@kernel.org;
 h=from:subject:message-id; bh=u0nui1vhf/EmwTq6q2RWgl78HrRK/CPPLvMnc/CZqnI=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etws9fufFq9729RbGXNDfxxYdCtSQifp+r0vMT801
 iTNP1vv21HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRn48YGT5xPd4gYXzpZPj6
 D6f+qX0Qv9TBUcF6ePfLds7DTysVTzQx/I8rXd4sEjq3bduNK/7X+v/Kqk9YyOWe3dsRZqm+TvT
 IXF4A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize gadgetfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. gadgetfs never holds executables or
device nodes.

Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/legacy/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index 7f6d8460152f9..8490e5d0351e1 100644
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

