Received: from cstnet.cn (smtp25.cstnet.cn [159.226.251.25])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47C5E51B18A;
	Thu, 17 Sep 2026 16:29:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.25
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789662597; cv=none; b=W5oK4QJrWG1qM7lovj+yTy02xJ5sk+LZwjcD8M0K0pzKQ8OXmfVQJuV9m48XUfj0Mc3kBS+6gn2WFzuwKzEyJs/XL1Sfw79d+vzUf8sTl1ynM9AC2AiSC2hxtMUPSja7AfsZGEMjRLMuSH38CemAj7eKflUfU0GXXdzUOS2h9P8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789662597; c=relaxed/simple;
	bh=CG3KDQpn4Azvb63WWSh3jcx4EmhtMXzzfdQytXz+VfE=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=HrhJXPF61p2vDAKgC7cSnKnXRxWpwGANhJLoZYgTxG7QXHJGLgK++rwKfKc4IDvb+n2re/kLxjxFQqpSU+lwNGB723s2D6Pa2WAhfrbZA1+J6rSNkg0x1l3SXrGp7OgNJ7eyd5AbcQW7mTsCtRVg8q+eiwve+TcuwVh129kzGmk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn; spf=pass smtp.mailfrom=iscas.ac.cn; arc=none smtp.client-ip=159.226.251.25
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-05 (Coremail) with SMTP id zQCowADHMTx+FaxqTX+ECA--.6720S2;
	Fri, 18 Sep 2026 00:29:50 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: anna@kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	trondmy@kernel.org,
	Wentao Liang <vulab@iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] NFS: Fix layout header use-after-free in pnfs_update_layout()
Date: Thu, 17 Sep 2026 16:29:50 +0000
Message-Id: <20260917162950.2162357-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:zQCowADHMTx+FaxqTX+ECA--.6720S2
X-Coremail-Antispam: 1UD129KBjvJXoWxJry7CFy8tF15AF4kJFy8uFg_yoW8GF47pr
	ZayayF9FZ8Xw4UA3WkAw4S9a4ay3yUX3y3Cr93Grn8Z3WrJw1fAF4xKw1v9F10yF4kJFya
	qr4UGw4UX3yrZaDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvv1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AE
	w4v_Jr0_Jr4l8cAvFVAK0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2
	IY67AKxVW8JVW5JwA2z4x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwA2z4x0Y4vEx4A2
	jsIE14v26r4j6F4UM28EF7xvwVC2z280aVCY1x0267AKxVW8Jr0_Cr1UM2AIxVAIcxkEcV
	Aq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6xIIjxv20xvE14v26r12
	6r1DMcIj6I8E87Iv67AKxVW8JVWxJwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IYc2Ij64
	vIr41lF7I21c0EjII2zVCS5cI20VAGYxC7MxkF7I0En4kS14v26r126r1DMxAIw28IcxkI
	7VAKI48JMxAIw28IcVCjz48v1sIEY20_Gr43Wr1UJr1l4I8I3I0E4IkC6x0Yz7v_Jr0_Gr
	1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWUGVWUWwC2zVAF1VAY17CE
	14v26r126r1DMIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI0_Jr0_JF4lIxAIcVC0I7
	IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY6I8E
	87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r4j6r4UJbIYCTnIWIevJa73Uj
	IFyTuYvjfUeTmhDUUUU
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiCRMNA2qr9LZOXgAAsH

When waiting for an in-progress layoutreturn to complete, the retry path
drops the reference on the layout header with pnfs_put_layout_hdr() and
only then passes the layout header to trace_pnfs_update_layout(). If
that was the last reference, for example because the layout was torn
down while the task slept in pnfs_prepare_to_retry_layoutget(), the
tracepoint dereferences freed memory.

Move the pnfs_put_layout_hdr() call after the tracepoint so the layout
header is still valid while it is being traced.

Fixes: 2c8d5fc37fe2 ("pNFS: Stricter ordering of layoutget and layoutreturn")
Cc: stable@vger.kernel.org
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 743467e9ba20..aee523134c0f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2229,11 +2229,11 @@ pnfs_update_layout(struct inode *ino,
 		dprintk("%s wait for layoutreturn\n", __func__);
 		lseg = ERR_PTR(pnfs_prepare_to_retry_layoutget(lo));
 		if (!IS_ERR(lseg)) {
-			pnfs_put_layout_hdr(lo);
 			dprintk("%s retrying\n", __func__);
 			trace_pnfs_update_layout(ino, pos, count, iomode, lo,
 						 lseg,
 						 PNFS_UPDATE_LAYOUT_RETRY);
+			pnfs_put_layout_hdr(lo);
 			goto lookup_again;
 		}
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
-- 
2.34.1

