Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302260;
	b=Jr/LTomG7xIRLelFOqJ6Ha0AU+pTy75AIaUO8iMBLv99gKx4G9ZRnbBY2B+8iSstc5dI
	 0dLEm6RdkRvngxIGipJvrqr5pDyEeBxGmmRdmSm1d0lFPz9Mp9WMcOqxsnPB/4IppNN0i
	 GOgRedYPg8a2v9HdV3B8XOaxjlZisuFimADcAAkrxID6MU7NcsMDpvFk9An4/EulixZWA
	 VJWt6hpC56NDSL/faIziLt8TxeUHJ0s07icJFpFQLY0XDdP+Ya2jBgFBuOqW7X5mO/aM5
	 vRS9kfHzD1i+PekhHgB9+LIsRKjgbnrbtNgYzh01Xvf3vviqvtCH2CQKRVJXdvYkj/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302260;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=h94mIi/imn4D3waXvt8ZAO8zbcvNeSGH9zaPuRN/zFo=;
	b=znvsD6qTl4GBAd1HNzQSvE2LRryPA9UPb5LXf1isibw6guS506VuSXJGAEk9mFFSUCin
	 398prGyt8GwuieUa7pe0CPrMBPAaU18AIxsTkZkd/rRXcDigaDz2nJXYnv+vOe9LQkcmA
	 KRZ/+AsKIsMbL1yt3JeCSNz6aQwJetpcaQm3gpwWPGde6H53uAhVT7Uk9lCJM1p5fs243
	 eTQPWIXapAJgGEnNnrY34whJSNZ7M3/g8ny66K6oRx7xvwVImIh9aNPdcMeEQkgiV9CDy
	 druEQU5dXBL6sD/rcew/oBW7czKmbxUfU2IJMxKevOvey6xIMtwtgzj9Sc5GxSARCdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hCKnpX2L;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7275B606A902;
	Tue, 10 Nov 2026 09:17:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hCKnpX2L
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACD6F1F0089F;
	Tue, 10 Nov 2026 09:17:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302260;
	bh=h94mIi/imn4D3waXvt8ZAO8zbcvNeSGH9zaPuRN/zFo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hCKnpX2LMq/yIBVu+3fedTSWRzmEiUKg05k70/cabSsZyN0V70DQNw0habLh5Rp3N
	 c956FUO8f5KMtGhmwZF6JaNrD5YNWgtZGhi2tRzcc2lZ8L4JIxwL79H0b3tBFB4IaO
	 XmqyiHmmqPdau5vX2eMWUrlPCMnRhkbqwrhqOEqbuhQuSJxQhgZLHlWLkOa387kF87
	 c2QE631FmWh521q0EDzd1BLKeXN0jM2x4hEbJfjU0RuxAt/DbvL2B4RJaNxjRNgwuN
	 sRHkcU5kSCaIM/R/aSWv3TJjb6hXOJ6l+gef1isFdWoX5RRm93+0TI6pGc9yKYqXGJ
	 EIZJjyG5YAQyg==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:31 +0100
Subject: [PATCH RFC 15/41] tracefs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-15-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1051; i=brauner@kernel.org;
 h=from:subject:message-id; bh=nNHku2orMRQhrPcnxhaESkf9+5yEVey8qH80JYuUurA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erD0RXLTJKNzrh5L9mkY/O9J+HRKY33C443/9A4Lr
 21xrLd+1VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR+R0M/72Fl4jGuvHt3/5x
 u7NfzPNpdcsMM67cPHfs9ommtv7O3i+MDBdi/75YKJwQsP/1zN8L3y7I88yZX64y724L9xZhYx+
 hQ6wA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize tracefs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. tracefs never holds executables or
device nodes.

SB_I_NOEXEC also refuses PROT_EXEC mappings. The only tracefs files
that can be mapped are the ring buffers and __rb_map_vma() refuses
VM_EXEC already.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/tracefs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/tracefs/inode.c b/fs/tracefs/inode.c
index 5020365ca704..e04febd868eb 100644
--- a/fs/tracefs/inode.c
+++ b/fs/tracefs/inode.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/kobject.h>
 #include <linux/namei.h>
@@ -510,6 +511,7 @@ static int tracefs_init_fs_context(struct fs_context *fc)
 	fsi->mode = TRACEFS_DEFAULT_MODE;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &tracefs_context_ops;
 	return 0;
 }

-- 
2.53.0

