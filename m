Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302302;
	b=GjgKKkTyrGu5m9PgbDIgTO+n75bTKWVX+TlI63r+DBk27yy2rfOQdGIVgUbSZGxZmAkA
	 7s3MT8Zla4LNv7YmEtzUhllrWgtRsmVW6x0WA6Cbj56OjgfqrIrCrEOfMAACPVOhz3CrW
	 KqMUiki4YHsmQHDVSuk1SfPeYDRUExU5qilMOAY0bMEbeKFcEuZWLAT+QaXo1sgLwnv4+
	 vuEm86bLVf1CsBDTJGw++jkMVTo7DjUarcF+hjZu1g8oO2pHx3844iAvj5vBVUUogT2IT
	 I7VuysWLzoZtvFIsDLFM7KSWS9CujYKueElP3CcI3ssXKOZ6MIUAptdlui8umTpasRQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302302;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=6xLCAE1ljQwjM/z7WMvrquNwq7v8NRQjtdpUDUMIMgw=;
	b=Xwt1lRBjBZWqlhfnWloDpfDY+vE8oxFUl3YWGiO/m/OWnuwGGNBNiturZ1DYnjdZvxht
	 bKAOcyBzRRUZHr7XOSA1+AFU9MHmVy5RTxVL4AYVWMollfcYX7Hhogcoet7CAEgumzTN/
	 F7c3MNjbcaZMFogIxvAB8jvFuvUGkLD8OoKZh7BfD2qWuipPCGZklherZB20SDcnuCXt7
	 rQsdpwv2ytKihOOMWAAJ1V1pBjGvtSLXScHstCl3Lo1bUgJWlBvb18Io2KCo6T6ev3YRW
	 p6UtvSO9uu2+BWddDLv/bRnLrAsPiowG2CpCxP+d5qawm6y35FR3vYDeu2HuNrfPfmQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="n/nPEmY/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4532A6072F65;
	Tue, 10 Nov 2026 09:18:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n/nPEmY/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99DB51F008A2;
	Tue, 10 Nov 2026 09:18:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302301;
	bh=6xLCAE1ljQwjM/z7WMvrquNwq7v8NRQjtdpUDUMIMgw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=n/nPEmY/gv4mqB2kXaUIe0isVNNuSFYe4ifWdFJtsRhYXSoI1dEqHjcK8jXDbyzkv
	 ertikRvZXtvN4JZinzjTGl2V2W3t61CK19ISiQm4xZZKjvx6Ilozk7a062A5tyZVek
	 8ONpx6cO+b1cP6f1iIgOK2yxVMDe8jOAVqYq0can3XlRZqUYI7Gp3FGNtEvO8RVw/T
	 f+noE3Lf2FKsSSXSy3unTl1hqIHTI1UMmGoV2c8K2q9ES1gzqhEiirejgIGUZm9nYu
	 NqYxgSkqeO0i1tDzYYX2q1T4FJPsyVEQu1wNublFH2+PjjrVHGb4S/n5iQ5M/xLuTU
	 IGfiSO/ynwQJA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:37 +0100
Subject: [PATCH RFC 21/41] nfsd: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-21-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=896; i=brauner@kernel.org;
 h=from:subject:message-id; bh=O9QykJ0fSa/ei9QzD3DZ9rjO12HqESJ46S14fhxCm3g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erBm2RVdl2pllcvx587P2/2Nj+HEnjubhYUvT5nG7
 rQvYfmalR2lLAxiXAyyYoosDu0m4XLLeSo2G2VqwMxhZQIZwsDFKQATSZVjZOiTVZZ9M+fcLevt
 JuW1WT9C9YytitQ/n2YJq0v/vW9H2Q5Ghh08Evn7XH9MsUgMSb9yk5f97OVSvTP7v7PqSMtvTvm
 Tyg4A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize the nfsd filesystem as a pseudo filesystem. This raises
SB_I_PSEUDO and also SB_I_NOEXEC and SB_I_NODEV. It never holds
executables or device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nfsd/nfsctl.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf..ce2666deddbd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -9,6 +9,7 @@
 #include <linux/namei.h>
 #include <linux/ctype.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/svcsock.h>
@@ -1375,6 +1376,7 @@ static int nfsd_init_fs_context(struct fs_context *fc)
 {
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
+	fc_init_pseudo(fc);
 	fc->ops = &nfsd_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

