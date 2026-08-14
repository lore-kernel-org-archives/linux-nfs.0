Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A624A4749ED
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:32:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786717982; cv=none; b=gdBD+VQlDMeTM6iRTMqpOBD4IRd1kJjXfuGgDYINQ/ON30/ckpad36g5oxWzU86RHOZhr2vEmj1SzWXRK7qdUmye8EQoxiu/U2UWydzf1G0P3Z+n07zXl+Kgs506SXQ8e98Ife+3HhP3TM/hT5uyJqLTPWa91AoV6cOxY9NGdd8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786717982; c=relaxed/simple;
	bh=fEf+aoVOmWE9QgWXBBCMkjF2FiCJRCYZ+9VLM2p+ycU=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=fsl0Hi3xCjyJXzVaqMj7EKWMs3tbFmGkkv5mWvJ60DJmFezBA0wkIyXydaDsIE+zKt7oQgA9WsrvrPEUqViDOJSrfXn3lSfPKzKIueyJOYv2ecP4/4NzpibWGYMZlrlpdSIPRa3Kera9bUv9y7Wx9a5vHzOIVsjw5CwkgqF9WDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=MkBwEL5s; arc=none smtp.client-ip=209.85.210.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MkBwEL5s"
Received: by mail-pf1-f198.google.com with SMTP id d2e1a72fcca58-84865f326efso1205641b3a.0
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:32:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786717978; x=1787322778; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=dZBlRjehuCRyYG4VdtgBrAbEd7nP4qKEWqIDe08LiIY=;
        b=MkBwEL5s0bjOGTQBhMlhEd2kmt0hrng4So5pMERYAVhJvB406e94Kwb+xIpwSXjjka
         vGS2BtHsGDzx0ubrPOhI/RzDyIPIP4G3cCvCdrSpSXyUO5lIvce8h98FWSds0fjiBBIr
         Iz5/UjvJd36LjLD76hNjIBzfwyUKghp3Iaio+u/W6O93HjZXtRJfnkCHqGJ/yuwAa2WW
         st7QHWVzbe+O5RdVPNl7d/quYcOMyH8h3eKX5KjDErUbP5gV9tSIq0r/BUaNc5fZwkmn
         J7Bll4IFfYqb3ueY8Rz9WERMwPAPnpky9I+is4bb/KThvWyAYH0k1XyucJPXzHyRK/Um
         CLMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786717978; x=1787322778;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=dZBlRjehuCRyYG4VdtgBrAbEd7nP4qKEWqIDe08LiIY=;
        b=ImqE6welSFllxoJBJE/M6Knpgxw4iCD2C0dkiQjD+gDGhsThF4X2JsAe636efA0Ynz
         f1xb1xOak/giJ5n43ZDBE43X/eVZNuFQxebSNHCFR9abMTGTRWAGfYxdSAZGr7DeqPkt
         i3Lz6bxH4CbAY30feW/6xzMwzuOD7C9Qm87LnBP2cs/XN2wYoyae20qORDQfAP+tE5fS
         NmwveehJyQoZXLuzAf3++5teK7pYw6CasjThfnQVQyUSpMqBZQSIrSvzyci/boBoenoQ
         JwLFRz3h6RVRrWXNNUW3M7etnDM6Tx6QKoWpKGriENDdsebUvs4xv+8ZwALMA3EZ0z3V
         HlJg==
X-Gm-Message-State: AOJu0Yx9b/XldguVXukqIX/1v72JtIecUSXTmDIdhWHksxavLJ/a5QSy
	suumwyRU0NR4oYrMbW+ALhJMbEFf6/tvD5h+dnvZaHlZo+5NVMJ8qAm8JR65L6mnVQdHjk7cOnN
	oeZsfhBJsIWsO91foPeYGWmS2qpYv1V9OT5BP7JJZVIOVwq7LHPDg0BS2qc7z3h9IgQQ+VDJDxk
	gXDcVUd40WG5YjC0ZdR2kYWv54lYqZujHgsEY=
X-Received: from pgdf6.prod.google.com ([2002:a05:6a02:5146:b0:cbb:676d:ab19])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:1818:b0:848:46a0:3d74
 with SMTP id d2e1a72fcca58-84fde3ccf6amr6609292b3a.9.1786717977916; Fri, 14
 Aug 2026 07:32:57 -0700 (PDT)
Date: Fri, 14 Aug 2026 14:32:50 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.55.0.691.gc56d675ccc-goog
Message-ID: <20260814143255.861084-1-praan@google.com>
Subject: [PATCH v6 0/5] nfs: modernize direct I/O path
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

[v6]
 - Fixed double unpin bugs pointed out by Sashiko:
   https://sashiko.dev/#/patchset/20260810195040.2877784-1-praan%40google.com
 - Added R-bs from Christoph (due since v4)

[v5]
 - https://lore.kernel.org/all/20260810195040.2877784-1-praan@google.com/
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
 fs/nfs/pagelist.c        |  66 ++++++++++++++++---
 fs/nfs/read.c            |   2 +-
 fs/nfs/write.c           |   2 +-
 include/linux/nfs_page.h |   8 ++-
 5 files changed, 134 insertions(+), 83 deletions(-)


base-commit: 15db403711f3cd9b7b764716ddf5909091b604bf
-- 
2.55.0.691.gc56d675ccc-goog

