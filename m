Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302336;
	b=LCN+m6KicBeTo0dQE53sIU0j1t7n7SFOKgevj7ucWfM2ZPosqzBqI5Em5rGABy/02tkg
	 qBJfAQpK78u0Ex/RuIyR9qt3nLTu4pt+j2b3VuZHsSBH51VzYx4L1vrIPmiMrBFVgEYKb
	 suitzp7SenU5F+ogLB2De7Owl2Bua2S7j90wIFHARMSszC4mVnH9Q3w+NoHIW9eLX/WU0
	 9LozsMG8K0GqaVP7E/SMHz3Z6d4SdhWZvnz9LFzFD8NjuJY4DSWlKMYFQUyvxL25pw7Uh
	 W7nlQld2t9jC226GnduHeu9BbSJRviSXKQ81nqryX4imFmTsYFuYB3cU6mPW8bG2V2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302336;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=3vbBpJ70QQUgTHc+9S4BdJlbLsLxsrAejDAnX1SbNic=;
	b=1i2iBcMYNpO/4uruVegThLHWorlvc3yUWCccqUcKbfrZHUlxG3heMBRO/3rO/odVoug+
	 csceGYge2Z8n8zGVspC0q7Cc+atqspkcY1E04EVGwQsztcSTej7B7/lF+/0B+GNUiAjfV
	 1vPKUYggZEHk5eShkqSDWfRtynLnbqC8hswmhgxd8JyLpcSWi7PyrQRkL7Ps8pgUeo6ef
	 9JOL2LFcRsx/1NOohjuVC/PQCTYGoqGR4NaJb+FLE7PacEV/JipFHKO+rMqEba9Rf/GIK
	 GGOXJD9ZKbyhBL7ijAOsogB9mzeYgc1k6Q9T03qjlCR/uD3P+FUg7RufkkNvTq9skWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="XaFZlFw/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1747606B165;
	Tue, 10 Nov 2026 09:18:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XaFZlFw/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0F4BE1F0089F;
	Tue, 10 Nov 2026 09:18:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302335;
	bh=3vbBpJ70QQUgTHc+9S4BdJlbLsLxsrAejDAnX1SbNic=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XaFZlFw/DdnrRtOVsZEGp6QUGtmIPGuUZ+N4Hdx0OM0hwO0dbNjERxcTuZMYTcqjH
	 niXGeBr0dTqT4XuSBUJ4fHJ8LPa5mQ0gDOgO3p3iTEzXRwE29SgFUYzxoeoORUG48o
	 4DJ6Rk3Cvuwko+rTIDQL/lX2vrxaez+zErrVL/jJfRbWQLh2oJpIux07YdOMODEWT1
	 AOcuJ+CDnO6LeM9EEmN9aS0LHpgFim9TfKS15MTiXRxDbWwt1Q2uZLl1zL9z5geSoA
	 YWA/+bXNEPPKIhhzJ78YCVVL+ahtQQQJ2oXlHwFAREVtyR2al+Mwd8OYF0Lie832Vc
	 YrFaKf6APBZQQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:42 +0100
Subject: [PATCH RFC 26/41] xenfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-26-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1017; i=brauner@kernel.org;
 h=from:subject:message-id; bh=xO/6EKTyizodOr3jpQQP+lr/++u9/c+Tcs9J04rmnys=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erBpDZsiO/PvrRUOZYzHr09ZKmN5JzQjsOPDecc1T
 gv0mD6s6ihlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIvSqG/3GRPk4+yw9m6Lz9
 kr3Yn+deca/qnJO3fHSPGiyKaKxs38HwV3xiCl/tWo1fM/4fmOj0yLklovHKITOdd0+MZx7UWyL
 0lg8A
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
index 37ea7c5c0346..aba7d038ed73 100644
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

