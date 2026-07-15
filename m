Received: from mail-pj1-f73.google.com (mail-pj1-f73.google.com [209.85.216.73])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB75638E8A5
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 14:35:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.73
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784126145; cv=none; b=av/H/oN0NuX2GGLBAGm6hWxn+bhMUEvB6UOqc4giKxH1S3rJFvIav8RfI2WN8nf/ii9KVBlLzZf7C2LTZmblHKwVoXgT1fHmvJ5K4Zg+v4fi7W4FBAb9+zlngfB2DX6czKco21v1b/qxhgFoWI75lTrcEwYRwBk3JiOtU5U2cRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784126145; c=relaxed/simple;
	bh=60wkghqW7c7sdbGd+kTkRS1QHQQdDkNmEfh4WEgymJ8=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=CxIpC5UOuV9EFXplEIMqTQ2YWc8etOPvFMAElCY6H66HfxeMkdTT3pKBBRcvDqS31XeCTLhUos4SiHYUFciLrm0SVfcLR4Xm7gkRs7V2BKWlpHdVu6sN6mTo3KdW2R3TRUmgOIf7bSoDro9Gb1Yn8K7bbqhkcZ3hImaZweXNdO4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=s8guWzBQ; arc=none smtp.client-ip=209.85.216.73
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="s8guWzBQ"
Received: by mail-pj1-f73.google.com with SMTP id 98e67ed59e1d1-38e11baa66eso2272769a91.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 07:35:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784126143; x=1784730943; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=TkJoi3hfxu1gji4nOeZGw3S4Uo1UCGNy+6ti5mT4KdM=;
        b=s8guWzBQaVsQpeRHcujHPloDJkfDSJMEtIXXkde1r5xPlqqtq3WpbfUKXX1dTOIiFw
         N31eUmcrjtyu79qY4la6l4DA7H0+j/FOO11+v1K4yHzkqqagXPcl/AJjURd7jywV/fdX
         20aCpNtLdeWUhS67PCRXxVjRBn+8jvLsdR99hmYgVpeggLfXBjFqf8soEH3uA3qoF5BE
         9LOCe3TREffYKLJ6yY2uX8yGjYosYS6UjoLHRpSysC+iLcI3Ht3SHXu0Z+3jiJS8Iomo
         ecJyiI3QW1R5h5BPtgVQ8XN1MB7BQiPW0NPanf+v1hoKLP3wYbmsL/5l2iiWV+jH2/ZN
         zfHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784126143; x=1784730943;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TkJoi3hfxu1gji4nOeZGw3S4Uo1UCGNy+6ti5mT4KdM=;
        b=ETnh0WMdTXjgsq6wdnfAXh7GvYFnSPNX3wOm/s0qqV938gygCMjh60BPxyEMa8AltS
         gkUqqBk8sviFYOhG7iaHg5M3mMUjwBsNa27ELW/CSNthgqZAO22oNbzHBLJ2RyzDm8qm
         QR5MCM4WHYjw25f0FjidWR+Lq3jftQ2gxm9ah2W74isRbk2qg2nWxGtXrrz5wORstI7r
         4wwTXYLwfq6QLtgGmkGTAjLebnR+85xWxz6YGe+EfyV8HKs0thcjEhGJY9GFWkBDtTAW
         T8PqSLR59PvThO/GUB/4EvaiyCKVZvhOgO4oqu60QUyy1pjBZc1u9/EASJ6PEXAhmUBH
         AYMg==
X-Forwarded-Encrypted: i=1; AHgh+RqMUh+EIOKHoMdTj7treLHPqfIlU7RCyNEQTj8TdXaCyrkAJXBi+m+eT++/xE2D4F8pRAwmCS04tfs=@vger.kernel.org
X-Gm-Message-State: AOJu0YxHYi1t53GzFuXGAzA0ZGs8RtSvzBxuq6ijvHR4rUS2NEhLMgRN
	JbCtkOG0gVoaFFglqgnwPdfVaqDL3LaXje4FKOhA5yMCR/ePKmS8maGfZ8ypyZLWwQCbJ5oGY3U
	9zg==
X-Received: from pjbgi13.prod.google.com ([2002:a17:90b:110d:b0:389:477f:4bf9])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:90b:3b89:b0:381:5a08:6291
 with SMTP id 98e67ed59e1d1-38dc7779d6cmr13965306a91.20.1784126142836; Wed, 15
 Jul 2026 07:35:42 -0700 (PDT)
Date: Wed, 15 Jul 2026 14:35:35 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260715143540.3597616-1-praan@google.com>
Subject: [PATCH v3 0/5] nfs: Modernize Direct I/O path
From: Pranjal Shrivastava <praan@google.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Modernize the NFS Direct I/O path as a preparatory step to enable PCI
Peer-to-Peer DMA (P2PDMA) support. Following feedback on the initial
RFC [1], the modernization and architectural changes are split into
different series. Additionally, based on the discussion in the v2 [2]
of this series, the migration of NFS Direct I/O to folios would be
handled in a separate follow-up series.

Currently, NFS O_DIRECT relies on the legacy iov_iter_get_pages_alloc2()
API which does not support the pinning requirements for P2P memory.
The implementation moves NFS to the modern iov_iter_extract_pages() API.

Design
======

1. Pin-Awareness
Standard NFS requests use get_page() and put_page() for memory
management. However, memory extracted via iov_iter_extract_pages()
requires explicit pinning.

Introduce a PG_PINNED flag and a wb_nr_pinned count to struct nfs_page.
This allows the request lifecycle to track ownership of physical pins
and ensure that unpinning is performed only when the I/O is complete.

2. API Migration
Migrate the Direct I/O path to the modern iov_iter_extract_pages()
API. This aligns NFS with the modern extraction model and serves as
the foundation for passing ITER_ALLOW_P2PDMA in a follow-up series.

Upcoming Work / Roadmap
================================

As decided in the RFC [1] & v2 [2], there will be separate series for
P2PDMA Enablement and Migrating NFS Direct I/O to use folios.

This series lays the necessary groundwork for the upcoming work.
Following this, two additional series are planned:

1. Migrating NFS Direct I/O to Folios
A series that introduces and exports helper from iov_iter.c to allow
the nfs_direct_extract_pages() helper introduced here to aggregate
multiple pages into a single large folio-based request, aiming to reduce
the RPC overhead for hugepage I/O.

2. P2PDMA Enablement for NFS
Enabling ITER_ALLOW_P2PDMA for the Direct I/O path and introducing transport-level
negotiation (discovery of P2P-capable RDMA/NVMe devices). This will build
upon the PG_PINNED infrastructure introduced by this series.

Testing
=======
This series has been tested with xfstests [3] on RDMA & TCP transports
by running the quick test suite for each transport vs. version combo:

./check -g quick -s rdma3 -s rdma40 -s rdma41 -s rdma42 -s tcp3 -s tcp40 -s tcp41 -s tcp42

The tests were run before & after applying the series. No regressions were observed. 

The following summary was tabulated via a custom script [4] (on github)
to depict that the tests failing in v1 [5] are now passing.

python3 display.py results/*/check.log

+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
| testcase     | rdma-sys-3   | rdma-sys-4.0 | rdma-sys-4.1 | rdma-sys-4.2 | tcp-sys-3    | tcp-sys-4.0  | tcp-sys-4.1  | tcp-sys-4.2  |
+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+
| generic/091  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/130  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/139  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/143  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/154  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/155  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/183  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/188  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/190  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/196  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/198  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/203  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/214  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/240  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/263  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/287  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/290  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/292  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/330  | skipped      | skipped      | skipped      | pass         | skipped      | skipped      | skipped      | pass         |
| generic/444  | skipped      | skipped      | skipped      | skipped      | skipped      | skipped      | skipped      | skipped      |
| generic/450  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/451  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/586  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/647  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/708  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/729  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
| generic/760  | pass         | pass         | pass         | pass         | pass         | pass         | pass         | pass         |
+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+--------------+

Thanks,
Praan

[1] https://lore.kernel.org/all/20260401194501.2269200-1-praan@google.com/
[2] https://lore.kernel.org/all/ak8-NMsNPOB3zpF-@infradead.org/
[3] https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
[4] https://github.com/pran005/tools/blob/main/display.py
[5] https://lore.kernel.org/all/29a0511d-5216-46f2-a7e4-9c04ae9b1890@app.fastmail.com/


[v3]
 - Dropped patches that added folio support for NFS Direct I/O
 - Folded requested_bytes accounting in patch 5 due to dropped folio support
 - Rebased on fs-next

[v2] 
 - https://lore.kernel.org/all/20260616134000.2733403-1-praan@google.com/
 - Fix data corruption in nfs_direct_extract_pages() by correctly
   calculating intra-page offsets using offset_in_page().
 - Fix requested_bytes accounting in direct read/write paths to only
   increment after successful RPC scheduling.
 - Add missing kernel-doc descriptions for the @pinned parameter in
   nfs_page_create_from_page() and nfs_page_create_from_folio().
 - Rebase on fs-next/

[v1] https://lore.kernel.org/all/20260603053033.3300318-1-praan@google.com/

Pranjal Shrivastava (5):
  nfs: make nfs_page pin-aware
  nfs: Track number of pinned pages in nfs_page
  nfs: Introduce nfs_release_request_list helper
  nfs: migrate direct I/O to iov_iter_extract_pages
  nfs: introduce nfs_direct_extract_pages helper

 fs/nfs/direct.c          | 143 ++++++++++++++++++++-------------------
 fs/nfs/pagelist.c        |  61 ++++++++++++++---
 fs/nfs/read.c            |   2 +-
 fs/nfs/write.c           |   2 +-
 include/linux/nfs_page.h |   8 ++-
 5 files changed, 134 insertions(+), 82 deletions(-)


base-commit: 98cd7881a2161fe187da5636e1c6cb53d741307a
-- 
2.55.0.229.g6434b31f56-goog

