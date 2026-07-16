Received: from mail-wr1-f73.google.com (mail-wr1-f73.google.com [209.85.221.73])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37F812E975E
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 14:30:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.73
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784212218; cv=none; b=alMmkV85J/W1K9tMiP+6l0O1373oRNMkMdpL5XgdR8iwnhZ3GwbdqQrdVPRZ9/R2FHMtNmupJKEo6ZNWaV/oD4yo3Syuq8B/tF+oG9e4hzXEX3Eglorc53DeiHBdwuS8tfC4wOsC3DyNeATmn1tR4aZ9i7xEmoKfnfZfqKjuLgk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784212218; c=relaxed/simple;
	bh=AhFdR2QfFg1cCilOo4nyPNsp0iHkjl8xgc5O9th0jWk=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=tgp2T37jZ91M/8biLuFJZZgIIidrlLEKV4AtgGZkBnnRYbe0uAm1t58FPcjfOQbvRbwXTO3N2XXRVfQA9aTaQfJ4o1NVXdTthoAnwa41kMKOV7ouxYvFXMKH8ylGQYzWLx0jxfYmGx2VbJjgsfWmA9jWIVyzjvfF185ZXaO35dc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--jackmanb.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=B9c/VS/8; arc=none smtp.client-ip=209.85.221.73
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--jackmanb.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B9c/VS/8"
Received: by mail-wr1-f73.google.com with SMTP id ffacd0b85a97d-47e81aca584so3506643f8f.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 07:30:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784212215; x=1784817015; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=KK1D0Jn0y9eqfBTpCLM4Znrw9w5QYL14n9pJHOvIIK8=;
        b=B9c/VS/8iaUBo636z/mf0ef/HsJyPEJ5iXy0qRR3DJIJMaB0nWyvJcfkMDz80ZUxsq
         dBR6AZuHtGG4qWsLLUGb+v5jTy2XgpHKU+GEPRACCGR7g26Bq4vgVx+K5nUaolirT1KH
         20ID1POMwhi7eI6N2M5OqQPOvmqOGwWhuC9TXe/PRZw40YqYcBS6RC0+ezdRMDZXX9Sy
         x3FWrSR9VK5CCOgF1bl9J1j4+418O4mEFSmpYzUJZhIObNBKCH+ra/T1ncN15ZfB31DZ
         ILcqV+EOaAfd7armUAPJG9gllb6zqnTAXGZck9Z+XdKJwEeJK1WzVT+zlbYgEVF2fnQv
         Ai3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784212215; x=1784817015;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=KK1D0Jn0y9eqfBTpCLM4Znrw9w5QYL14n9pJHOvIIK8=;
        b=aonx12J4YVELQvy34UQE1OJuBinxtdTZF0wC94L60+Cf2ozmVk1GVrfM2Vj54hBeeM
         MD2h0Xn2NOVlb+vcbPyGgv7I/pNqp8zK6GfqERvXmDuYgnn4d/XEY2KcZukeS/Fb/KRy
         yQDE3XQaB6Xp0KzrKs+5SMQvpd+HiXNWDdgk2SrAOI9rk9bCf4WpiSRLUGUTnpu/nqQ/
         dHp/mzMgsJn39L9ng7uVtBcP6wzcb0xsd4+l1x0vsqWQbthJWjoQYLiqN6AYZL0AUGB+
         VXVmXQ6vJODUbJdSL+d+jbxnMUTIvEC7WWjmn10qo1KStkfxrl8PuMVkxyyBTKJjvtAz
         /wog==
X-Forwarded-Encrypted: i=1; AHgh+RpLlBKHVQRL1i1bwbuCpZGmpeqdSl74IrvQWmXEmmmHjwYCd06su81+6YseiSRxQt86dkY3gvPyQo8=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy6jeizXHpbp6dKwgZZefoY/M6HXeubmXC7XiNX9Z7NBspctwsH
	mmcSA6FMG0wRovKNf+xHkZ8N/dZYLZ2a5EJ59F29hkwqS/ejFjDgVTKbK2Rbisb9PN3xCvFHRTF
	62Qk8KBWoKF+lMA==
X-Received: from wmbdr12.prod.google.com ([2002:a05:600c:608c:b0:490:b58a:2c80])
 (user=jackmanb job=prod-delivery.src-stubby-dispatcher) by
 2002:a05:600c:a4a:b0:495:3e81:770f with SMTP id 5b1f17b1804b1-4953e817874mr72103905e9.15.1784212214740;
 Thu, 16 Jul 2026 07:30:14 -0700 (PDT)
Date: Thu, 16 Jul 2026 14:30:09 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-B4-Tracking: v=1; b=H4sIAPHqWGoC/yXMQQqDMBBA0avIrDuQRFDbq5Qu4nSiIyGRTC2Ce
 Pem7fIt/j9AuQgr3JoDCr9FJacKe2mAZp8mRnlWgzOuM73tMOQoGX2MmZAi+7StiiZwa6/jMFh yUNO1cJD9t70//tZtXJhe3xec5wfuKVxBeAAAAA==
X-Change-Id: 20260716-folio-alloc-cleanups-0fe319b881c2
X-Mailer: b4 0.15.2
Message-ID: <20260716-folio-alloc-cleanups-v1-0-5363b8e92d33@google.com>
Subject: [PATCH 0/3] mm: yet more cleanups for page_alloc APIs
From: Brendan Jackman <jackmanb@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@kernel.org>, 
	Lorenzo Stoakes <ljs@kernel.org>, "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Joshua Hahn <joshua.hahnjy@gmail.com>, Byungchul Park <byungchul@sk.com>, 
	Gregory Price <gourry@gourry.net>, Ying Huang <ying.huang@linux.alibaba.com>, 
	Alistair Popple <apopple@nvidia.com>, Hugh Dickins <hughd@google.com>, 
	Baolin Wang <baolin.wang@linux.alibaba.com>, Chris Li <chrisl@kernel.org>, 
	Kairui Song <kasong@tencent.com>, Kemeng Shi <shikemeng@huaweicloud.com>, 
	Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>, Barry Song <baohua@kernel.org>, 
	Youngjun Park <youngjun.park@lge.com>, "Joerg Roedel (AMD)" <joro@8bytes.org>, Will Deacon <will@kernel.org>, 
	Robin Murphy <robin.murphy@arm.com>, Huacai Chen <chenhuacai@kernel.org>, 
	WANG Xuerui <kernel@xen0n.name>, Thomas Gleixner <tglx@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-fsdevel@vger.kernel.org, iommu@lists.linux.dev, 
	loongarch@lists.linux.dev, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	Brendan Jackman <jackmanb@google.com>
Content-Type: text/plain; charset="utf-8"

Based on mm-new.

Align some APIs with recent cleanups [0][1], and hide more mm-internal APIs
from public headers.

Part of this was also proposed by Vlastimil right as I was writing it:
https://lore.kernel.org/all/ed4572f4-0074-45c5-993d-7b6533eddc31@kernel.org/

And just like with my other recent patches, this has the ulterior motive
of enabling later incoming patches to add alloc_flags arguments to these
internal functions. (But, I do think these are justified as cleanups in
their own right).

[0]: https://lore.kernel.org/all/20260715-spin-trylock-followup-v3-0-fc4d246f705d@google.com/
[1]: https://lore.kernel.org/all/20260703-alloc-trylock-v5-0-c87b714e19d3@google.com/

Signed-off-by: Brendan Jackman <jackmanb@google.com>
---
Brendan Jackman (3):
      mm: move internal mempolicy APIs to new internal header
      mm, treewide: replace __folio_alloc_node() with folio_alloc_node()
      mm: move __folio_alloc() to page_alloc.h

 MAINTAINERS                        |  1 +
 drivers/iommu/iommu-pages.c        |  9 +--------
 drivers/irqchip/irq-loongarch-ir.c |  4 ++--
 include/linux/gfp.h                | 25 +++----------------------
 mm/filemap.c                       |  4 +++-
 mm/mempolicy.c                     |  1 +
 mm/mempolicy.h                     | 31 +++++++++++++++++++++++++++++++
 mm/migrate.c                       |  2 +-
 mm/page_alloc.c                    | 18 +++++++++++++++---
 mm/page_alloc.h                    |  4 ++++
 mm/shmem.c                         |  1 +
 mm/swap_state.c                    |  1 +
 net/sunrpc/svc.c                   |  2 +-
 13 files changed, 65 insertions(+), 38 deletions(-)
---
base-commit: 512c82e906fe2c26023e307c7951d53e90910b57
change-id: 20260716-folio-alloc-cleanups-0fe319b881c2

Best regards,
--  
Brendan Jackman <jackmanb@google.com>

