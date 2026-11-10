Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302267;
	b=PwsM2sBl7rBq0Dwp0hYnctePUGQKz9iI8YmFbddPGKthLdKp1AZeHIk+UiJ9a67PSZ5r
	 vYMt47b48AZznHjVC21Zt7QHRk9MSkZ6bfeFa53ZSfmt79oviiCIwaJMN0w6hTSmybkQB
	 /heMh74JG6H/eUhT/K171ISoTzfApjZuYVik1iSF9PoVIiYSXF0TK5SiOtptIyxr/8aVX
	 yi11vS/WWuSv1VnALIfZ+Bsdn1CFMpiCiCnF3Cg+QrknVMLxNTb2ArRalABvOuAkI+UpM
	 96M+Ij3Nicz+Zu7aeEfP62Gs+7RlUTwQICh1VozuzgdvAH4FuBIV0/1qlCC9Nwq046Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302267;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=l8LDAQNHphQBAnLKVY0j2bP3Ogdq6gK5b5xHcx0dYsg=;
	b=YC4zEwwBRXGsnDaq0giU+N/8uOA8eRKtaZKNg2/QSpZaQ9gyOACd5gIxNN8eV3WDp071
	 EEhXEgMrHR1aCYbwmUamC0Kz+h6wHbTJFu8/kwodUMzfbhaSFS9kVF7GTTFigHNWlrWBa
	 1rygROC730AhnJ2GEPi4YzWFGaG9i9bF9W0zphBRUkoZamn7GHekSQzxra1phcAhiinWz
	 hhEwNBPmEV/179sGYeS4DipX6TFJHjHnuOx+G+vm3L7x5AkCJ+/UspYr1QLdIiN6y13HZ
	 Yi/qcqL/ul3g67mgFDX3PWn24cA4/+OukP2KNxsR6xPlXHEvMphjd1f2GLzWS0rl0Bg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R9v9qHLP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A452606A9A6;
	Tue, 10 Nov 2026 09:17:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R9v9qHLP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 987041F008A1;
	Tue, 10 Nov 2026 09:17:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302266;
	bh=l8LDAQNHphQBAnLKVY0j2bP3Ogdq6gK5b5xHcx0dYsg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=R9v9qHLPfZZRHObjYnC3o1mAzO1hP+/9155v1wxmmC7hQDax+NvgTbE4W9xrNan6b
	 z0Sdkmw0b24b+Z76hEcw0ec7fC8rhBm0gmhG32Dr9KvOltCueuenMbGzfKiksYbb/R
	 A6o9Yo/dPlBuObvaZL1En87DLRIXfZzEMhiQLtg8EsJhl2E4mtXzQGo9ABc14bgHRe
	 PZldAZR1cxgMtFhW4nTK2eKI2Yi5t+MGsF5VrX1YHsgpjfxFteN0G7738shRXMLGdm
	 N33HXtEWu+Tp9JkAiYvDDygE7C96rLISq1P2stvft/KA/fCZ0rHgRq5v+c5DMmWCFV
	 ymFNp2JgMpqoQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:32 +0100
Subject: [PATCH RFC 16/41] configfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-16-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=912; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FZSn8pZNkelWJZuy96PPD0cDLXKTFQ+NnjbEVUus4Cs=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erAsoPxm8YvkDfvCz87c1p11JmKH6fuChtd3Yuf8U
 K0rc7F601HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARx10M/11uxYdrM97avS7+
 mvJWaemvRj2ydif4HQs8FhZrHNFqm8Dw33+Ncnarxkp9i/liZ7b1r790NO6pyta3nhe6A+fNCn7
 EzQEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize configfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. configfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/configfs/mount.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index d8cac1cbf3bd..60ba24e7ae2b 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -106,6 +107,7 @@ static const struct fs_context_operations configfs_context_ops = {
 
 static int configfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &configfs_context_ops;
 	return 0;
 }

-- 
2.53.0

