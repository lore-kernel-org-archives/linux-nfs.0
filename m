Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661720;
	b=Rn4vS2NY88LAHTG60G2dabfQWHLMuXjntlCoyG3hNWyLVqsoKwBee39t9rND1N0EaUvY
	 smQrYueTNlGDb/0CTcbp7uMWXIqahWx0CW2xqKt/oOEj0FX4ZGSaW0iBLqY1YfJmJkaOR
	 WNUbZA9PwrzJ0d5yOtKe8ENdY0E1aVBPGNWy0jyiCeYBXXCHbKEzSZq7qfTHbuawC4GH9
	 fCK1XU3ePxoqsnEgbRKwQxgIJq1bpFilHa8AkjOdzrAtVsKeAN1sayLUo0h6D1KHFnNrS
	 wQyjhbQUOG89Utw5crOEPnKR1WkoPgdLQYz74/pHHUpt5qcXc/EHn6AqyK4I26bHRYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661720;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=IrVRaUgylyW7dx1wUoEgP8enLWWhiisOApdkF3tckhc=;
	b=Dg2doyJv5VuCBsV51TZQl94oNhlUTXwqboh8/SVj/1PTJaTVo0eyuvEX1Vf7SRywHxIV
	 Cfv7lgiKLe9el7BQbNyc/O5zZRTHqeQZ3XEoA2FvCjOkvLhh+jofdiWPgcutiRr61IIm0
	 rCgY2nzRqsejPk2dc7sbXsyjoQEuWnlumwegXw8Ob+25GJlUlogtkePpNMtAFCXthZj0P
	 M27Ynb9bWyDTppoCmH3pB+ejoilzt8qqQsDxtglMTa8PeqYzAK4mLtDoLJV6NxK5yJGMs
	 tEqUDMBtgfXXHZpQzSbVI9nQ6yU1/MugY5d3qWkO9UHSOkqEEZG427GP4ucE4fQRqSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CSnJIGlX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67F0F606A8B2;
	Sat, 14 Nov 2026 13:08:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CSnJIGlX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BBB201F000C4;
	Sat, 14 Nov 2026 13:08:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661720;
	bh=IrVRaUgylyW7dx1wUoEgP8enLWWhiisOApdkF3tckhc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CSnJIGlXVCwPfZYGjaLB6IqanwTkuYMOqLjiIV98WyWx8/XlfQskQ4Ncrgj5RhMZR
	 wSZWZkZtit+aDjyLJmmgvMVuloaMpGHPl4V5iV3BBa563e5JY9xO+gJBwtTb9q7Q8C
	 mdg4xQ1+bqoQpc+gIpw5ks/W1KsdFYl1y8ZZRTzVOQ9kvuq4mogGtVJ4dS/PfMNIH3
	 q1Qk3HwuKj12Ep3f9iEkAbgFiSF6DWteKE3HQuNBK6n0301E9uMdY5e48cCjb0q9en
	 cBz3CDPb58li7HRkb67AF/RctpON8mZ6M2WcpSfLnE1Hp/QuclXpoedwNIpfQtb034
	 yVf37SRkLjV4w==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:07 +0100
Subject: [PATCH RFC v2 26/42] xenfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-26-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1019; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FUjiFAJ818KMfzd+kfIYJM0T6xlI1Tybz/61rTbofEc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGk2ymq59kHLQ6h8olLRV6eCMAf3indWE33bRHYYG
 yoaf7zdUcrCIMbFICumyOLQbhIut5ynYrNRpgbMHFYmkCEMXJwCMJEOK4bfbPpa60rvXBGfN9V1
 euu+TdOP9GV/muPCcL7yp0X8f6GmCIb/wbNO6i6ubdGYUd+54ZleikWZyucDWjzxvCyT2fm7JCz
 ZAQ==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize xenfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. xenfs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. xenfs maps the xenstore
page and guest memory through privcmd, both data.

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

