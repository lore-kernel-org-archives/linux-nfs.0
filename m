Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302343;
	b=sCDx0Y8fPVDF3rVszPVoMsPGKWcbX+h1Zz0SySA82VOa3e8n41pBO+yyohUCeMiswwhu
	 0GTV1KPXsPR/SzTuP+rTT0GxyHaPtvTK14+FR7rU8hyNM4uLn6gIiX7osDhZ5486pblJm
	 BlRisGa7S/lNzZsfFl80HXGyfIV5Ccap/epaYxH+i0p1kwyQ08aPxWGtYmfvr0ptqKXK3
	 SeQ2sFirsSzT7UMriz2Orgli4HBE5yOFM2iS59jRK76lO2wlaFWS59vguXiC6EqtQYoET
	 1Nqv/sw5XmhfXHyo8FsHtp2vSoXNdnGlDM6RIc6A33VBZgtERVI4xE0T6GeXLtiDjLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302343;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=V9O75TKfTcHeHVPMLenNiZqGn0S/SDcuL2HVenCDHeA=;
	b=cJHVZRISUBXWdTzAtpuy3s7R/gEl6hlJ9NUlnH+Qat1ETiKSKOemno+k0NBMizlp1S2O
	 85hIaDhZLDcTgMeN9np3kW4pmN8pTc5xVD+T3/BNEA2VK/hoXxfMjzsvUxngQ2PsoFuUT
	 M/M1xCy/qbMM3jNx8GFT0w6qJU7RqPpS2m6Yc2u+H8mrM76xarKB1neLVO7RTmY4kUH2t
	 RdyGk2mxRLCMsB/YIX3X0+pNCGaOhVfvS77ZQgN+uf4GoVVAHR/nzq+Vj9QiD/Hkc2RmR
	 +01iWC45G2euBdj5ns/SaZPy0rjRCcBb0dLDfwFXy1uwD2rBWq8cgef1k3C8DGr8dMg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XU5FYslU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9A2D606B9FD;
	Tue, 10 Nov 2026 09:19:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XU5FYslU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D685E1F008A1;
	Tue, 10 Nov 2026 09:18:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302342;
	bh=V9O75TKfTcHeHVPMLenNiZqGn0S/SDcuL2HVenCDHeA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XU5FYslUu/QycaxvYDsVfiLjksSb23n6kAsx0C4TwSSMJEdkUorbOifqhqCOqU1BZ
	 tmBnCWeUwFgQQ+4ZAkQAk/VjPzQ+RPHW3/AblZyzH50Bb47hCUnqPVxJ/GU4Mc1JiA
	 5FFUIjTt/J8XmL5z4nM4R0/u+A/O7oMn8+99R0NQQoD9YRGpBmk26SOy2wcjejpGHl
	 mr0KKFrE0VjNzX1I+Ubt/meHZXfZj8kp1B2dkcgv3kCLJkAik/ieVBt/S0jkqQRk4B
	 ZyDYntU3Wf2Vq8yKC7h12DmuYinSiJ1I+4nWRIhPcZEmr+7PkRUVFiiLnUd0MB8tP5
	 IiA+GGSFyG75Q==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:43 +0100
Subject: [PATCH RFC 27/41] openpromfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-27-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=930; i=brauner@kernel.org;
 h=from:subject:message-id; bh=HbK9i4t197PzSxP5CKS5JO7XvQ/k806ZQREmy2rg/1Q=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erB5yxKrdqWdTL6/ROTOpHFZfYk8FvP4V1D53MDzH
 Vaet0xOdJSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyks5eRYePLZ35LS2WzX6Wn
 +D69nf1re86D6lp5E91F/Asahdd+rGb4Z1YXc0BUZ9rZoskiB0RU3Nyq0xSNReXOZtV9XNcYHfC
 bAQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize openpromfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. openpromfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/openpromfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index fb8d84bdedfb..6cd02d456bac 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -10,6 +10,7 @@
 #include <linux/string.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
@@ -419,6 +420,7 @@ static const struct fs_context_operations openpromfs_context_ops = {
 
 static int openpromfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &openpromfs_context_ops;
 	return 0;
 }

-- 
2.53.0

