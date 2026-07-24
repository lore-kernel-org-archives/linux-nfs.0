Received: from mail-m49197.qiye.163.com (mail-m49197.qiye.163.com [45.254.49.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CC64442FB2;
	Fri, 24 Jul 2026 15:12:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.254.49.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784905964; cv=none; b=V8ujzMccRixF6doJaEiT3dmyHvnyTRIpNtQFL+/FcICFnBivrfQZOJ6asKq7OvbKswHFLI77FF++Qb0+ozLrUq0rImQGeUMyz5NN3IRMQ8iiZZTmi4tQU1uCqLPDCmgjVw7+Y68x9y0dkUD7CdRyHCfLxfjlTa+CghCV4txzRYM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784905964; c=relaxed/simple;
	bh=nto4XOxoSU9r3XhbZOGr7aDD66i9MlFfhvInYkigxds=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Xwrzn+SZ7ugBHmWMCfR4xoFsLg+OZMJNJdmYWo+ywHESp+lQJqQbdEys/AaNnzP8O/4jV3YSRqvAfVlFKPhj3lWcI0NTUgFOnxAbN7k0tRYBHJEAn6F1EZmVXYiKaN99WbWvaWnRPmbth2zORN6DG0CG8yUJIzLdA/vEh7ofCb4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn; spf=pass smtp.mailfrom=seu.edu.cn; dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b=TOLHzwj1; arc=none smtp.client-ip=45.254.49.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b="TOLHzwj1"
Received: from ShouCheng-Lab.localdomain (unknown [218.2.107.243])
	by smtp.qiye.163.com (Hmail) with ESMTP id 477b224bc;
	Fri, 24 Jul 2026 23:12:24 +0800 (GMT+08:00)
From: Jiancheng Huang <jchuang@seu.edu.cn>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] NFS: reject oversized callback bitmap lengths
Date: Fri, 24 Jul 2026 23:12:13 +0800
Message-ID: <20260724151213.1392784-1-jchuang@seu.edu.cn>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-HM-Tid: 0a9f94af4d3203a2kunm1f07d375456e8
X-HM-MType: 10
X-HM-Spam-Status: e1kfGhgUHx5ZQUpXWQgPGg8OCBgUHx5ZQUlOS1dZFg8aDwILHllBWSg2Ly
	tZV1koWUFITzdXWRgWCB1ZQUpXWS1ZQUlXWQ8JGhUIEh9ZQVlDTh4aVkgZGkxJGEtCQ0tIHVYeHw
	5VEwETFhoSFyQUDg9ZV1kYEgtZQVlJSkNVSVVKS0xVSU9IWVdZFhoPEhUdFFlBWU9LSFVKS0hKTk
	xOVUpLS1VKQktLWQY+
DKIM-Signature: a=rsa-sha256;
	b=TOLHzwj1bH1NiuITHKNtg4vQ0Ajfrls8IE7Y588jZoBkzeKXDTEVierfxeux8CZ201vaKa0gDQ12zrRyol2NO8MRns1BdIL0WgZqYf2CWTP0VS5sjOiy6W6Xl5rosox7Fdvl0rDh2zQxxAW7d/CLf0o2gflIi6RwX+mbWfvmc+k=; s=default; c=relaxed/relaxed; d=seu.edu.cn; v=1;
	bh=Xqdymv3xT8HulRyHhU4aCNtMCvw1g69acD5VzLof0/8=;
	h=date:mime-version:subject:message-id:from;

decode_bitmap() stores at most three bitmap words, but shifts the
server-supplied word count before validating it. A large attrlen can wrap
the byte count passed to xdr_inline_decode() and leave the fixed-word
reads outside the XDR carrier.

Reject lengths larger than the local three-word representation before the
shift and return NFS4ERR_INVAL for malformed callbacks.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Jiancheng Huang <jchuang@seu.edu.cn>
Assisted-by: Codex:gpt-5.6-luna
---
Changes in v2:
- Add the relevant public mailing lists to Cc; no source changes.

Evidence (v7.2-rc4 KUnit/KASAN oracle under bounded QEMU):
Source: confirmed/nfs_callback_bitmap_overflow_raw_excerpt.log

[    2.650597] KTAP version 1
[    2.650657] 1..1
[    2.653395]     KTAP version 1
[    2.653578]     # Subtest: nfs-callback-bitmap-overflow
[    2.653841]     # module: nfsv4
[    2.653979]     1..2
[    2.658646]     ok 1 nfs_callback_bitmap_overflow_test
[    2.660479] ==================================================================
[    2.660763] BUG: KASAN: stack-out-of-bounds in decode_bitmap+0x1e6/0x240
[    2.661084] Read of size 4 at addr ffff888002f47ab0 by task kunit_try_catch/69
[    2.661084] 
[    2.661084] CPU: 1 UID: 0 PID: 69 Comm: kunit_try_catch Tainted: G                 N  7.2.0-rc4-dirty #3 PREEMPT(full) 
[    2.661084] Tainted: [N]=TEST
[    2.661084] Hardware name: QEMU Ubuntu 24.04 PC v2 (i440FX + PIIX, arch_caps fix, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
[    2.661084] Call Trace:
[    2.661084]  <TASK>
[    2.661084]  dump_stack_lvl+0x53/0x70
[    2.661084]  print_report+0xd0/0x630
[    2.661084]  ? __pfx__raw_spin_lock_irqsave+0x10/0x10
[    2.661084]  ? decode_bitmap+0x1e6/0x240
[    2.661084]  kasan_report+0xe5/0x120
[    2.661084]  ? decode_bitmap+0x1e6/0x240

 fs/nfs/callback_xdr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4382baddc..9dcee0dca 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -109,6 +109,8 @@ static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
 	attrlen = ntohl(*p);
+	if (attrlen > 3)
+		return htonl(NFS4ERR_INVAL);
 	p = xdr_inline_decode(xdr, attrlen << 2);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-- 
2.43.0
