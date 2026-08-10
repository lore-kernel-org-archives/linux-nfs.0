Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B5924334AC
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 19:50:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786391445; cv=none; b=nh1iTVjFaZrMieYzij9VsE/bnq5XQN4kxfiXi302U/8EsUu4hVI81G7P95xPIe+SRTBQAtwYP0EQLwhC6eeeUA+/DUAbP4oO7pah5f9SHnXsd8JTzsHQg08KHiKRsOUozpMCiqr/nKycLolcPPE2U3YHnuOOmwx5c3Dcr0zSA54=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786391445; c=relaxed/simple;
	bh=jllGw4LDGlYPMXCqbk8a2XlOmYYFkoF1/M0iq9XzDcs=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=dn7OZ8mB3AN0v87FzJ+orLgp9Ffdw/8NJzXmmb4dGh7nm5bDZWnbdRmTCzkJWe59pe0GDGyP4vwWv0YzaRwpezJCQpYlo/bP1ccYrX0KtDlTuBSN4qppqwPy2525sV52HOFVz5JZELfFw1yi/ZtAsCDL/OJ5rzD757utvrkwkBs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=rncho+ma; arc=none smtp.client-ip=209.85.215.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rncho+ma"
Received: by mail-pg1-f197.google.com with SMTP id 41be03b00d2f7-cb7d6ba548eso127399a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 12:50:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786391443; x=1786996243; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IcwW5XREirtrofqhtr/U6RYRn5/QoCTQXeXDcDL2gg4=;
        b=rncho+majOoSw08b+7rQicHedJ1dU/sLKK1XaA6ONBZRELGk0BgCkBeDpEbKt840bH
         0AeugHszWJ83xI+aRv7UYqaH4ZzgWaC+OydwEujs8TgLQhmgHCfOzaxL62YUfDVWEv6f
         fx7Wu0Jayb2Bhd1Vhm9dPorJ/Lxz1zdyuS1dEdCd4pvah6aypLFJMzHT4DB5V0my8gud
         DZ2Q4B6p+/N0YnRRdxSRI007n1yr4mWa+36K4ttqwjIbqPpj9SmTouTZQg2JIthKujsY
         WXj72suqgPIY7aJr/h4OwD1G2IMoaX6J/VDoH4+bI9XUsBwNYlQw0xbLGU3yKHwIlAUb
         KWtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786391443; x=1786996243;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IcwW5XREirtrofqhtr/U6RYRn5/QoCTQXeXDcDL2gg4=;
        b=YCuCyl5No/OSiR7Gr4QN1uYn6dfBDdIuHRsi+oLOV5XYFtVnUJ4Fp6gXgCWCrSQfIA
         vgVNyq8lrE8RPgSk7m72CY5MqCKYzsUi/QmQSC+otG+z1VZQ+fQ3lxiAUQ6gsFGdMh8O
         9qFluvRw7ab1Mw7yQuWGJDoW9jY5iCbRAfk7UMBMvWqszO6On5kA9yUfBs758KsYKy7v
         7RwQ+XVcigJe6vFBHmVhvgELJUZCGibyZGgPnRrurtcAiM8BjlUVqZ7nl6SXSPHCr4H0
         PsibOAZJ87zYDZYV2B+VWfqh188d2Mwf/EclOVFHO5NEa/wAHUNESKQfd7fMd96c5F5K
         HbCg==
X-Gm-Message-State: AOJu0YyEJycb6H6zY2DiRefe3SPzwWCxc94eHa8YZ00JAD+rD2F9F/0H
	1QLXWvNuxigkaARfaeOTIoQP3zN3RjrmnNSBoJ++2UzChN+yCFK0UzTcNIg7jf4yt2eJHHUOqMD
	gTvYx1VX16unrTWtmIC1cCw4zT+4rSt7BOxAw4qdceku5nsDRLmZoeuh+lY5WSY3OdBA094v4BE
	x4Ke72GQbKj5tFqxWh6VmicOUZ0RBtlLsL2Jw=
X-Received: from pgeq25.prod.google.com ([2002:a63:bc19:0:b0:c96:6f3e:49c9])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:6c82:b0:847:5ec6:3afe
 with SMTP id d2e1a72fcca58-84f2e0588demr53176267b3a.31.1786391442581; Mon, 10
 Aug 2026 12:50:42 -0700 (PDT)
Date: Mon, 10 Aug 2026 19:50:34 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.55.0.679.g6767b8d81c-goog
Message-ID: <20260810195040.2877784-1-praan@google.com>
Subject: [PATCH v4 0/5] nfs: modernize direct I/O path
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
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

[v5]
 - Fixed an iov_iter_revert oops in nfs_direct_extract_pages().
 - Fixed a refcount underflow in nfs_direct_release_pages() during
   swap-over-NFS by ensuring we do not call put_page() on unpinned memory.
 - Rebased on fs-next

[v4]
 - https://lore.kernel.org/all/20260720150601.2702700-1-praan@google.com/
 - Dropped superfluous externs in include/linux/nfs_page.h
 - Scoped `req` locally inside the loop in nfs_release_request_list()
 - Wrapped >80 character lines in Patch 1 to adhere to coding style.
 - Fixed typos and capitalization convention in the commit msgs
 - Collected Reviewed-by tags from Christoph and Shivaji
 - Rebased on fs-next

[v3]
 - https://lore.kernel.org/all/20260715143540.3597616-1-praan@google.com/
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
  nfs: track number of pinned pages in nfs_page
  nfs: introduce nfs_release_request_list helper
  nfs: migrate direct I/O to iov_iter_extract_pages
  nfs: introduce nfs_direct_extract_pages helper

 fs/nfs/direct.c          | 139 ++++++++++++++++++++-------------------
 fs/nfs/pagelist.c        |  62 ++++++++++++++---
 fs/nfs/read.c            |   2 +-
 fs/nfs/write.c           |   2 +-
 include/linux/nfs_page.h |   8 ++-
 5 files changed, 130 insertions(+), 83 deletions(-)


base-commit: 5b57716ed7ad2f4b1724461c8777015c4e4befb1
-- 
2.55.0.679.g6767b8d81c-goog

