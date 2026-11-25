Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.199
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795645130;
	b=xPmNBoiTGcxMu1IPgufb8vsl4hqZ5Fe0Ql1ySr//JxmhBOnEbv9e6U+PUcXDjMVejl0T
	 dh89+rFFqHV+sf8W74Mxu7iQB9WAUZHsVkVr9AgSj88HXo9kBFIX/CXjcZKhnLMlKI9ZT
	 My2gkw6muZ6sOVmmsbcn4klP8qz96PbhLZ1GA4yGRbsXAQn9BE5Na7csjrb2OGnC0lRm6
	 f2UvZwx77mDXvw+k/6SZEaxB1+vgvKLSLxbWKIbBfoiPF0cJEZiTOSdcUTk2jq4XelF2J
	 8Rb/bNVgOevGV+oxIPmOtv8U57zgFyvnMBmH1LUtk5S32YddiOvz5fON0X7c2OqqXrg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795645130;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Received:Date:Mime-Version:X-Mailer:Message-ID:
	 Subject:From:To:Cc:Content-Type;
	bh=u2+GtbAzliCVLY4qt9XkKEEOn7y3no8jVdjlKGtflhg=;
	b=HJgo769kO89iPkMWZUQqZstWZAdU72ufNdKkPNMiGj9MwO9IT/2u9L3/FjHm3TiT6hXO
	 Y8lHFNhJwcbvP5dhtO3lmQuyxiW2c+EsL2Oa8CgyW+lqCoDnMfIsqG0Ni2bCgadVRmWDB
	 9ZYmFf0w6765dQxQBvQZ5tHp5aesfYmTMAMSjBNOcOD5QaRqnzKugmbUs4dWwzQ0pX4Sy
	 KGDE8ncHrqA6UkJpoInf9CPHPeybYwgLBT63nlwHjwxfFs7ykElyh479nrj1YEDNMj36n
	 bR3Gzfz+zZJXoCZ9kYihtxTPIxqfh+nmOX30YJZkPhFiHLIGYi2y67G5k903B5NaqiQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--elkin.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=Q1yNJE5J;
	arc=none smtp.remote-ip=74.125.82.199
Received: from mail-dy1-f199.google.com (mail-dy1-f199.google.com [74.125.82.199])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FBE0606A326
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 22:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2FBE0606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--elkin.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=Q1yNJE5J
Received: by mail-dy1-f199.google.com with SMTP id 5a478bee46e88-341eff9e381so9493800eec.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 14:18:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795645129; x=1796249929; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=u2+GtbAzliCVLY4qt9XkKEEOn7y3no8jVdjlKGtflhg=;
        b=Q1yNJE5Jql0gSdpOJaxee+sYbAdE4vnO9HYViUBT7dcZuqOUWfAGz6ujF6vvm059uG
         bkOO8kYVpx4hvdU5anFdhMtCACp8MQ9Zbr0EqqWWUrkKFIgHlYfCush9fml4vs8IRqHq
         F5gHH5hEiTsNDrCCP01faNxe2nOzkQEOMfQ+t3B4mKafRr4igC/56NH8lSjaG1Sx+fKf
         HYI3vqyBaRzdEUzMvXNfBHsgty6iGew4dx8XnqN3hH6xcWtf5ZoFDUmksU5gN9fvnGUl
         9iXb0GXcWrku0pEI0oX5BBEU8Q9QyKSASZ0xpicvvmik7RCSsOFIij8UgbCuwQxtkcF7
         xJAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795645129; x=1796249929;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=u2+GtbAzliCVLY4qt9XkKEEOn7y3no8jVdjlKGtflhg=;
        b=VFKPnhN6zlwJkfs3YZ3fl5teDUpMXc+dCj5TsvtNvCfvD1svblz8DwrZvkQQ3301di
         K9+jgNcgL9i12h+QUQXMW+5ORGQj8jMoUlEw1J8GdAYbJrrmcyq7e0GAV7UojF+SYqKw
         lEu7CXDP/sRqM8COljSm/XTeD+JCalJPZEnBQ2rdZQw1OoNgVhmbdvB7v3bGcpFfBljT
         N6NhYqpn5jF7q/sbdV4iVnn/ysB3gXpwE/Jkf0kwbGtmXAWrVUrgnWoG7AMmn1r9urQR
         z0PiAjzfeaDXlb/XEh0Bz3xBsIrFtN8xZaEpS/R4pwfFI6kBWi4c0alVNo/ZNB1zqkiT
         dOBw==
X-Gm-Message-State: APuU4Z+bPCT246A/1V1crxZAN/mojfHHjArs6WnhX5n9dmE8lIdfe8MW
	WGMnsAIjqUj6cZDsr0qmVB74N1J5og+NQqcG9x6oul9RRPpFvkKjoGREua4tePEkb9OKfH8+KGX
	ZUw==
X-Received: from dybla7.prod.google.com ([2002:a05:7301:1a87:b0:381:610e:404b])
 (user=elkin job=prod-delivery.src-stubby-dispatcher) by 2002:a05:693c:8948:20b0:386:b08e:4b7b
 with SMTP id 5a478bee46e88-386b08e4e93mr10610272eec.29.1795645128820; Wed, 25
 Nov 2026 14:18:48 -0800 (PST)
Date: Wed, 25 Nov 2026 22:18:12 +0000
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.839.g22a8290db9-goog
Message-ID: <20261125221812.1423319-1-elkin@google.com>
Subject: [PATCH] nfs/blocklayout: use div64_u64() for chunk_size in bl_map_stripe()
From: Elkin Cruz <elkin@google.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	llvm@lists.linux.dev, irogers@google.com, Elkin Cruz <elkin@google.com>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

In bl_map_stripe(), dev->chunk_size is a 64-bit integer (u64) decoded
from XDR. Passing dev->chunk_size to div_u64() silently truncates the
divisor to 32 bits, causing division by zero if chunk_size is a multiple
of 4 GiB and silent miscalculation for other values above U32_MAX.

Use div64_u64() to preserve full 64-bit division by dev->chunk_size,
and reject zero chunk_size or volumes_count upfront in bl_parse_stripe().

Fixes: 5466112f0935 ("pnfs/blocklayout: Fix a 64-bit division/remainder issue in bl_map_stripe")
Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
Cc: stable@vger.kernel.org
Signed-off-by: Elkin Cruz <elkin@google.com>
---

I am trying out new Clang static analysis checks for kernel bug
classes, and they flagged this code as possibly buggy. The findings
were triaged/fixed and commit descriptions were drafted with help of AI,
then checked against linux-next (not runtime-tested on hardware).

Thanks,
Elkin

Note: Liu Chao posted a patch on 2026-10-16 checking !chunk_size
(https://lore.kernel.org/r/20261016041139.2292455-1-liuc63@xiaopeng.com),
which is not yet in linux-next. This patch additionally fixes the 64-bit
truncation in div_u64() (which still divides by zero for non-zero multiples
of 4 GiB) and zero volumes_count. Happy to rebase on top of that patch if
it is already queued.

 fs/nfs/blocklayout/dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 00462e6affb1..8c7af13d45d0 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -274,7 +274,7 @@ static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
 	u64 disk_chunk;
 	u64 disk_offset;
 
-	chunk = div_u64(offset, dev->chunk_size);
+	chunk = div64_u64(offset, dev->chunk_size);
 	disk_chunk = div_u64_rem(chunk, dev->nr_children, &chunk_idx);
 
 	if (chunk_idx >= dev->nr_children) {
@@ -536,6 +536,9 @@ bl_parse_stripe(struct nfs_server *server, struct pnfs_block_dev *d,
 	u64 len = 0;
 	int ret, i;
 
+	if (!v->stripe.chunk_size || !v->stripe.volumes_count)
+		return -EINVAL;
+
 	d->children = kzalloc_objs(struct pnfs_block_dev,
 				   v->stripe.volumes_count, gfp_mask);
 	if (!d->children)
-- 
2.56.1.839.g22a8290db9-goog

