Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46417432BC9
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:06:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784559973; cv=none; b=O+QgO8DkuZfIeqOJrpwUfSRmY62npncNiK8QDZc+yhJfm/TFtuf9c0IoUGGkFz5lq/ja/dmxX88vquMnA+rPkOhsSxUP2kP9LeSE+kgfCflSiWlr97Ef2EKe1jBWW65+gcQJSyTaIrgK/IN49l42p/3fDmBidghHMSfdp6LnACs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784559973; c=relaxed/simple;
	bh=F1EHaoYJQ650p5KGpCXZKVjiIi5a38caSRNmMXgWBLc=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=r89RCm/kSQ2kfjHq8vtmJ6tPuKzaC/VdJgAu9Xa80Do15Dmd3hfFHUQir05NpQ3KRoORvr15I3kUlJnRLeYmDQHONcg48Q9Mv5SPWyIjaWDGjdt7lBHyhYVl2LlS1LNdka2RjaL9M0vxZrFn29y8ksljqHcv6I9qU3pkzRfVac0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=gNNP6p6q; arc=none smtp.client-ip=209.85.214.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gNNP6p6q"
Received: by mail-pl1-f198.google.com with SMTP id d9443c01a7336-2cefa1a2be6so80845885ad.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:06:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784559971; x=1785164771; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=k+6cTr1jCJ8/nUqKf9ILuxOaSMXLbUb8f8DhcRcxvFc=;
        b=gNNP6p6qbmvdiXBJLc7OIpzBoUx145+ucsjbQIal1zoY9mJPOsijTC+JjMz9E4HhP1
         HEOZ+ixLbVaUBCEYWf5WNaalxWrZUuEkgPfUNLaTunjiqaiqpVkX+zlhxciTiGS6et4C
         M8WtXHFC+pWBfad0hqIOBuGOj0D85A0AY8ac+UQMDIDM5VT6egvEbjEeFg5jhXFBjDXX
         p/SxXl1LoD2T+Hv5wAGu5jETGNs3v3qg4/eajxD9aQqUselIfDCnotFroGONKH64+gsQ
         OBNh4ws3KlWpfonp8+eNWzb0iM8ne5KMYV5l80RZx0OZPuxISEpgn7o49Lt47TnRDqyb
         sycw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784559971; x=1785164771;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=k+6cTr1jCJ8/nUqKf9ILuxOaSMXLbUb8f8DhcRcxvFc=;
        b=lhLfvC7ZzoexFYqvVlcHuAN7STtRXWTb65lXlenJXYnfHcItKnWRy+lfaB4sNwP/38
         7HlbmV085VlVd+E7HyCpRxotLuDTFuBgS0haoqSIoI1no4x710LY8cHvMw6YvqXTRTVb
         DhU7akUvqis43c8QnAdJrS/vDV/5t/CJY4zsktdVmUXMJc7W7qN7IS0Gvgc9UH33Zcnk
         UpIduf/AnByjyi8Zu35chMSzDEI1V9S1pcijJR91jGxrmwv4uH0yhXHLayvIKzcHcl8v
         dhB8ldWlWW2933G9wwM9A1QpUuxKWf6GdLvurnPwwhzneBMUfvslv3WjRBPsi7AlclnR
         b6/A==
X-Gm-Message-State: AOJu0YzSGYEAthJVlqnT5hEyYIjwLmhDdZeXeHGUbWlNAt+qpVMpIK0G
	xE5n0XPbqXMOTzQ+ZkOOONqiRYqByze2np4H6HQUJbfq97UfAhwiFCPz2LnQLSg12A9IMPzV1da
	Qjn/4LmkJJpsBX2yQV3CI1dH0uBhvJSwTsh2kT4/XQvqk21sdHPSIMUk10VGIsj1zrdTKIHYSL7
	xY9OyXYo/XEE0DQ0yPv/zVTC194WbveGjhR3E=
X-Received: from plcx22.prod.google.com ([2002:a17:903:d6:b0:2ce:d12d:d6f5])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:902:ccd1:b0:2ca:1bbe:c3d0
 with SMTP id d9443c01a7336-2cf34a07b66mr161083065ad.43.1784559970295; Mon, 20
 Jul 2026 08:06:10 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:05:56 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260720150601.2702700-1-praan@google.com>
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

[v4]
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

 fs/nfs/direct.c          | 143 ++++++++++++++++++++-------------------
 fs/nfs/pagelist.c        |  62 ++++++++++++++---
 fs/nfs/read.c            |   2 +-
 fs/nfs/write.c           |   2 +-
 include/linux/nfs_page.h |   8 ++-
 5 files changed, 135 insertions(+), 82 deletions(-)


base-commit: 070f41f072722437b7edda13037a400459630a5e
-- 
2.55.0.229.g6434b31f56-goog

