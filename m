Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302322;
	b=RxPy/aExOV0eWMW/gUOTRxni4uRvFchTyS7ISK1/PwJ/FKX1EKXaOZbcLo/7WkDuKK0m
	 nxnJ300gWNLfR2uVq8CNNFqtH5doYBwxvr+RRB/vN4LOnF3Gc//DdOavoH5HHPrcH511G
	 Iw4HVJflFWJS//dyViF5gbgGxWdqsPWZS0ZJJsds7E2kFoBoISog16agxltpxR0Fl4L4/
	 hZz2PEjE0sfHBU9Yiq0deAxVz87g2QoTFCAOozxfZ9Xm9yW8UH0v2tZDnncTwP1Phx2Xg
	 vLyiV0SfiwWd7Twc0H12r6p80V1hKVLUSJ5DummsQOEWFWyfjF/kfPZuRVE8Bs9QXHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302322;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=uO5ZhnwfrBSeMm3rjJlHHLu0PoUagP/7+NgvInBYUDY=;
	b=ojaFbwmNX+zsZ8QKCGXQzcdejVfVtG+Kcd5vOGMyOqmuy2hxB6PlHhS/1YG/LnqYajDk
	 jkO369apmrTzU+g8rBlrQjCzAlr0XcONERTgMpd22HAkri8E7UC+F2HMbkT+M5H1ik69r
	 FtKWErMdH/fuWjBTaCNwMmnBrSk639iVg9v7SusiOHsa2mMrGyUiPyTUsPKaRcLof7qDy
	 wNGRWKuo+aLu2sVua2eouw2fpM7ignX9ms7J7X7k4uiDpgoWnhryNyyy7bRTYlMn5QqL5
	 O5EVwoBTI2FCr3LtkEAoaoGumYrB7rJHcyo1GkIN6xxq1ddUqDna3HTzaQJp54KtPhg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DuW47WKH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42D2560A3811;
	Tue, 10 Nov 2026 09:18:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DuW47WKH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 751691F008A5;
	Tue, 10 Nov 2026 09:18:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302321;
	bh=uO5ZhnwfrBSeMm3rjJlHHLu0PoUagP/7+NgvInBYUDY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DuW47WKH0NVzTMh/ahwIWKCilxMxR/d9WzG6ER2dp1mTlW6J1MydE1ZvojfSEZmpM
	 uq0lOj+04qYr2LzZD3LTyEm/+Q92gXEaWwvE/iC7G1ulkggahwu88Ns7v4dd7rnO1G
	 naiygZWzOW8Ejr8jN4j4xWgI+lP7+fWJ/2fBG3q7EDC++MqGUBA1hoyiSEnV+fZYuw
	 hy1tvAOwTNHmlUDoF9ANy8eJuZMUnkycIQm0mbN+PVarFn8O73zcdijbpCI2OxpOxD
	 vHWGX2o5WnjZZ/WfXN04GoN3Kndnr2IYwMYmuMbejP3d/XSHugkw6zesVSwCCkxyfH
	 te+Gj4JjZD/Gw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:40 +0100
Subject: [PATCH RFC 24/41] efivarfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-24-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=866; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RLuH3jkZQnaQmTSPi6KhFuQtT0Hgw2AWtcSWTkbVq0M=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDe5Gh9x1THa+rmx4Rlvmxo+ui4+yFfq7/v4xonh
 odTCnlVO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYiNoPhv8tvZb6ttrc2vz+u
 s+BZwas9Hb/lZN55FfU3872JMM9paGFkmF2qMIfj7/yA36ELzpv87npr17nsS9Y0JvUP+ZZnWlY
 l8gIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize efivarfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. efivarfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/efivarfs/super.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/efivarfs/super.c b/fs/efivarfs/super.c
index 12746ced6dc6..e598d42c5f42 100644
--- a/fs/efivarfs/super.c
+++ b/fs/efivarfs/super.c
@@ -8,6 +8,7 @@
 #include <linux/efi.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/module.h>
 #include <linux/pagemap.h>
@@ -554,6 +555,7 @@ static int efivarfs_init_fs_context(struct fs_context *fc)
 	}
 
 	fc->s_fs_info = sfi;
+	fc_init_pseudo(fc);
 	fc->ops = &efivarfs_context_ops;
 
 	return 0;

-- 
2.53.0

