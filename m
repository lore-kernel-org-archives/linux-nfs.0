Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827361;
	b=PoFQc56BqgiBtQFFLRSFJn878KdyjYiR4mD6W7+kRTihZsNeFVQLlx9jDzGASfj1bDTx
	 +2xSbJYTK8jEVdWUgIOppJvFZUD39T74UARAaU2GSQdmlMojHf0dgRBu7g29m5CSXCgDy
	 5DqyG335dzL2hGkcHYWaaYApqzUBDEzbk+T3WeDytyfivmUD85L+vJALmJda8ng2ppGG/
	 q50NrEKMo+qM4nUGvK3zdhVn5YYPor3TRbg3jx/SRaJY4U+P28bmv5EsxmS06sDejCnBk
	 R2v9qiGv+YhzNQCvOZ6e8BvF8LeG0StFeFZw6oOAyEer80aGrg+JEtMMZkuQnU9JZug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827361;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=KlwMRZPG/WX1QF1ZB5LjirAXKfzgA2iLS0YZM79kPHY=;
	b=ufK9lOOqn1Csic48OZvUdt7cl+GAAOWeU4Mrlpu6P+GozVb3+2cJMtrb5DBTNZ5M/dsI
	 wc7tHdRX7ToBN7V9EHmkfPSOHqMO3l0/i2olw7jbzF9RRqoLHPjWcz0ZptIVHqqhTN3SN
	 gZLcekox5B8rjyeP2/rEplYPjJ38uB9iDCOuB73J7Okc0Mt+K1rVwQ1IyFb0XRS0Gh8j0
	 0IAXAKwsztinEX8fJRT25CSzOBKEs34iOzeW6AP8O7SA8nfFNjXl9hFQvBLPByTxPSQNL
	 VwvHKu9lghmXdQavecpLOnt1OPVw1DwQYeXm/KdmjWgP7ddCygEos/8IJeIuAqFbOpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OLA1+ogO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04BB9606D785;
	Mon, 16 Nov 2026 11:09:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OLA1+ogO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CF361F000C6;
	Mon, 16 Nov 2026 11:09:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827360;
	bh=KlwMRZPG/WX1QF1ZB5LjirAXKfzgA2iLS0YZM79kPHY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OLA1+ogOJ9Wwkd5TsReAO8ys23e7bh7jaUAOwpd93kXvrDCLtUKOWmFDC+NAofPGk
	 EE18TPYpwpdVL0ZSr3Iet25tX8sM/Ni5/227cFfNUP/xh+/9UimbRNEOt6UgW3hJMd
	 xNDm2VPZOk5BmoOLP/Bjnj450mttQniRwRJI7OfiPwGI5hN5j5yZ938PWE/UmZ5NaE
	 xFrgGbIR8sAD2dDbCYsWVv0cNFetcI+WiADyeSHwxDZOF4DpSZxoHzb4hpbJY/3zjE
	 qratSDqMtqNwDVu6NrMKkRRphEOMxNBGm3MuVnCUDSrt56ZIHBcSIuMZb2nPD8L6Sh
	 vVo7njwM+81nw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:59 +0100
Subject: [PATCH RFC v3 26/44] xenfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-26-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1067; i=brauner@kernel.org;
 h=from:subject:message-id; bh=DjsTre7DB95dewo6bwxjriQruqKLMJT1kfwJFiFYE48=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elxr9HXXqUIT2ZbouKuvw3yk/sQp/0tYti/ufgXjI
 6a2rr2FHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABO5lMfwP6b1LafHDuGqWV/2
 zJwtG8546JFf2UTJZr/ujICbZUmuWQz/jBWNbTe0ah56ppCyZ6kW494w03I2kYzbnRn/Hmpu/Zz
 GAQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize xenfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. xenfs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. xenfs maps the xenstore
page and guest memory through privcmd, both data.

Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/xen/xenfs/super.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/xen/xenfs/super.c b/drivers/xen/xenfs/super.c
index 37ea7c5c03469..aba7d038ed735 100644
--- a/drivers/xen/xenfs/super.c
+++ b/drivers/xen/xenfs/super.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/magic.h>
 
 #include <xen/xen.h>
@@ -80,6 +81,7 @@ static const struct fs_context_operations xenfs_context_ops = {
 
 static int xenfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &xenfs_context_ops;
 	return 0;
 }

-- 
2.53.0

