Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827345;
	b=cjhEwCuAMDIfSzA/fo4NUGqo51TTfm9HMaAoeJthAOPbyOdi5+ntMXjMz/ythZ+TGA7v
	 /mDYSxWDXB/6r4TNVwmmQxOx9ZZOdtXO3szelMg0zjm/mINeBBkWFtANTyDMMxaIgu5F9
	 DDC81pc1v5tgegQG6CcwwGbiYGiiD3UMUq7uLHKaPraKqPhp0o7iFjwptzHe9TT8EKSv9
	 aUIde0zf2sYj1RptHy6dqPr6LGxwHSqGZjBg8ewaYvnnwMuyTigsnauiWIVdLrWFGdcp5
	 S/wXLZopg8Pwhs6AhVa5uSFsGCh5PEK9b5YQtWWt7BUzyu+3ZJ9GHWQBhVRMgGvZzIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827345;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WZa8raruWf4jzyZcy4zjAHZiv8qEDUIon9hD96nRur0=;
	b=zN94AgayGNeiP67zV9PuiSSb0ujKqu4kxf15U4QfLpDvAIVk2JldDlzqdwnQmSnaygXE
	 RAjfRo8UB3N3BLA4ILAIIFpj3tz/NlFQ6c/y2T4rIBwVqg6j415o2talPJmwFQxBsmvjO
	 /nnyrBTmw1qzSHkxXE4jRAxKDShkJifjA0+zHOdRV2+oBqOCChsMHdT+YvOAMK34lIEQ2
	 I+FNi5U0r0vk7kFU3z7gF9gMRVPvnsYoYPlIHqsi/2qrvj4CNg4z6ckR9brfh1pFaLKlw
	 m8wVllheqIMsKv8ydprdLLrFa6vMJYnvdX5xxd7IaHsNmmc9cmZh7hfYTedqMKeghhA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R9B5RaEQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1E55606C12B;
	Mon, 16 Nov 2026 11:09:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R9B5RaEQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 643CC1F000C7;
	Mon, 16 Nov 2026 11:08:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827345;
	bh=WZa8raruWf4jzyZcy4zjAHZiv8qEDUIon9hD96nRur0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=R9B5RaEQmiwsAP1jIczB2zWH7HySjdmMzkng/+3APaCz2aIiR/5pA6QHlhTGPsx8z
	 CRzgX8ndXpYp0sjoyAbMIp1+MxGD+2DAlrY7udq0z+KNdGy7F3kxcIwyC6zbTjxhWm
	 yirFYavZHEFP6gIEwpXBYIN6SxBglphEPLbBaCq7FRAcuqs7D0l1JDGItjul5ABdHB
	 d9KuKk4ck+bWHEQ7LhylcskCqFiUIBf3v15nKwFrhNFGCCv2wRxQdpOvT+/bHvNnrt
	 DnN5kVqm7vTrOkR80gnd3fRgFIsX/hlTkS2T+BoxTB5bUiUfAjvwd6zlckKAgcRgHy
	 1qyB+N2C8a43g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:57 +0100
Subject: [PATCH RFC v3 24/44] efivarfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-24-8cbbea1cf34f@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=972; i=brauner@kernel.org;
 h=from:subject:message-id; bh=U3c0nafflYvUbB7XCWz+41zdupMknG85VhFAzpOuQl4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elxl0evIXDdr63nf8LI7X+5e612rf6tTU7lporhxj
 mdZts/6jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIl0/WL4K3elzLjM+M6M+brf
 9/5bG75Vlvfsk9/+7EWxqyIett05Vc/wP8X9yuP865WvUu2fte80N+1KFXWeciZ+5nF3c9snSkG
 ZTAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize efivarfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. efivarfs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/efivarfs/super.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/efivarfs/super.c b/fs/efivarfs/super.c
index 12746ced6dc63..e598d42c5f42c 100644
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

