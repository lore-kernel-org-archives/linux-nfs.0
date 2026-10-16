Received: from out28-76.mail.aliyun.com (out28-76.mail.aliyun.com [115.124.28.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D35032FA14;
	Fri, 16 Oct 2026 04:11:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.28.76
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792123912; cv=none; b=W0tkcRKKepWOn7Bk4DZP28yJSRrgRCN7vklXFC8dlps2HrK1pHT02BnNmlAMlLrZx3Yzao9rwyCz1YcsSmqJia1M6pkaEPhvSNIHjBePBx8sh0G2C2grZmGXtlT0nQiEKITHcq2H5iqnECBrbUct+MWX+EUchtAZO1yI6XMNNbA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792123912; c=relaxed/simple;
	bh=qJG4T8b2xd+jwVGD4mig89ddC+uZWVK6R9+iybuo42s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uoG5v9PpwFDMrnwNjYU/DWOBftGRo4ND0YbaGknVl3gUIe/VQsRzy5AEquuBW445ZwDQyJNrdsc8ldXGfpsnk03zzsyl7tStj8Z9RtrGyczk4h0lZN34iucJjyoFdKneCg4I6dQe1he6xjVfKt1CyKUhwbfpuY8C8wP0Rl94ewM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=xiaopeng.com; spf=pass smtp.mailfrom=xiaopeng.com; dkim=pass (1024-bit key) header.d=xiaopeng.com header.i=@xiaopeng.com header.b=Az3RiYRk; arc=none smtp.client-ip=115.124.28.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=xiaopeng.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xiaopeng.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=xiaopeng.com header.i=@xiaopeng.com header.b="Az3RiYRk"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xiaopeng.com; s=default;
	t=1792123901; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=Xs8i31LdX09aP1mqC1EDMy6hhEAeYfoO9IykaFMnu28=;
	b=Az3RiYRkzODonoFKnoE0Gv9iXVm66gJ39iX8le4dob8JifrrSu944ZwjEUO2I3jDKFP/rBisRhUQTXdZWQ2tQYmQaVr6ak88pRnlzQ/2aqDgwzv5whnPltRTsbWRp7GZU57PVuIApCyMLlJQxAgjMY1eZS23RWSbza6nhMQRQEw=
X-Alimail-AntiSpam:AC=CONTINUE;BC=0.07711791|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_system_inform|0.00165608-1.25311e-05-0.998331;FP=18307964864485545690|0|0|0|0|-1|-1|-1;HT=maildocker-contentspam033045220102;MF=liuc63@xiaopeng.com;NM=1;PH=DS;RN=4;RT=4;SR=0;TI=SMTPD_---.jfoJrnz_1792123899;
Received: from localhost(mailfrom:liuc63@xiaopeng.com fp:SMTPD_---.jfoJrnz_1792123899 cluster:ay29)
          by smtp.aliyun-inc.com;
          Fri, 16 Oct 2026 12:11:40 +0800
From: Liu Chao <liuc63@xiaopeng.com>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] nfs/blocklayout: reject stripe volume with zero chunk_size
Date: Fri, 16 Oct 2026 12:11:39 +0800
Message-ID: <20261016041139.2292455-1-liuc63@xiaopeng.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

bl_parse_stripe() copies v->stripe.chunk_size from the volume
descriptor supplied by the server into d->chunk_size without any
validation.  bl_map_stripe() later divides the block offset by
d->chunk_size, so a malicious or broken server that advertises a
stripe volume with chunk_size == 0 triggers a divide error in the
kernel and crashes the client.

Reject the volume at parse time when chunk_size is zero, before the
value is stored, so the deviceid node allocation fails cleanly with
-EIO instead of faulting later.

Reviewed-by: Guo Zihao <guozh23@xiaopeng.com>
Signed-off-by: Liu Chao <liuc63@xiaopeng.com>
---
 fs/nfs/blocklayout/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 134d7f760..6203052e0 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -505,6 +505,9 @@ bl_parse_stripe(struct nfs_server *server, struct pnfs_block_dev *d,
 		len += d->children[i].len;
 	}
 
+	if (!v->stripe.chunk_size)
+		return -EINVAL;
+
 	d->len = len;
 	d->chunk_size = v->stripe.chunk_size;
 	d->map = bl_map_stripe;
-- 
2.50.1

