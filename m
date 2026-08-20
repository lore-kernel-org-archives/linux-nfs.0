Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2CE53C10A7;
	Thu, 20 Aug 2026 19:34:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254447; cv=none; b=L2PtxYHHwu6W5jg8F5XD0wQdj8HYRGieFSm1hlm49J4ercaMQp3s6tmj4R7SlQRZfd9km/mHMvU+ZaXZ1RKpEkMfr/o8of4Pw/TsS6F8H6yWR4eXTrx+NACg+d7Vcg/F1affTeZZiNg9Ftn05eywXHgMPpNl1s9fx2Yg5Qnx+pA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254447; c=relaxed/simple;
	bh=RWxlkBlaSGy4jMTxU4/KGL5mW7uDhVriEc56hh+l3vA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HeSFklZCwWlod8sb8q2E8T75AoCc4jJCIUAGUH/WylwjCLUvR1f5rQ8xu3UKDwMMz3T+jezpPPLvbwU3yvcMmqVxdeA9djYg++BPd6MQZh88c4L3bFzsnXsNXHjH6znJBanvTULcfBwn8xnAuoGuz9apEJdNpkte6CRGMk0O9to=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=C00zMhG8; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C00zMhG8"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:
	Content-Description:In-Reply-To:References;
	bh=yAWljnoK+mvLqOvoWL/pFcjK82r/RJzikRAIfFTqyqY=; b=C00zMhG850WU4xETzkGWp3TH+/
	PUkEAO3MfrJqpeL9uJ2FjdY+CEkLzKmXyFcIzfbCvf4OxOe2/+gV2ZN2KcvZ+pM7C8xwvvxear6rH
	V1BT3J6G7WSU/Hqhc5r7m/kGddxOTrDs1SqwLrrvgNgh95Y8O5fNNx8rmdATP0NURw5xGH9hnZ+zm
	4BoAUzj9B9jhKVg/tixHzG/jYKm5e6FcLyHizYp8tsd1mjChY/D2Lv5vcJIPfJMEkzZZCVw0ncayA
	m7aYUGzSo6HADhCJdm90phuEz1RKeOPc3PPlWi+dg0x+BQWPmGfcVOfD0cgf1UeI8g2XDxv2H7w/E
	z/+gF6OQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WG-0000000GALU-2Ve6;
	Thu, 20 Aug 2026 19:33:44 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <brauner@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>,
	David Sterba <dsterba@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org,
	Pavel Begunkov <asml.silence@gmail.com>
Subject: [PATCH 0/7] Remove aops->launder_folio
Date: Thu, 20 Aug 2026 20:33:33 +0100
Message-ID: <20260820193343.3852967-1-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

There's really no reason to implement ->launder_folio.  Most filesystems
don't.  The only problem is that some filesystems rely on dirty folios
being written back this way, so we need to make sure that folios are
written back before invalidating them.  filemap_invalidate_pages()
works well for that, once we remove the 'nowait' parameter.

Matthew Wilcox (Oracle) (7):
  filemap: Export filemap_invalidate_pages() to modules
  fuse: Use filemap_invalidate_pages()
  btrfs: Use filemap_invalidate_pages()
  nfs: Use filemap_invalidate_pages()
  orangefs: Use filemap_invalidate_pages()
  orangefs: Remove launder_folio implementation
  Remove folio_launder()

 Documentation/filesystems/locking.rst |  8 -----
 Documentation/filesystems/vfs.rst     |  6 ----
 block/ioctl.c                         | 14 +++++---
 fs/btrfs/direct-io.c                  |  2 +-
 fs/btrfs/disk-io.c                    | 11 ++++---
 fs/btrfs/free-space-cache.c           |  4 +--
 fs/btrfs/inode.c                      | 12 ++-----
 fs/btrfs/volumes.c                    |  4 +--
 fs/fuse/dax.c                         | 15 ++-------
 fs/fuse/dir.c                         | 12 ++++---
 fs/fuse/file.c                        | 46 ++++-----------------------
 fs/fuse/inode.c                       | 17 +++-------
 fs/nfs/dir.c                          |  7 ++--
 fs/nfs/direct.c                       |  5 ++-
 fs/nfs/file.c                         | 24 --------------
 fs/nfs/inode.c                        |  5 +--
 fs/nfs/nfs42proc.c                    |  3 +-
 fs/nfs/nfstrace.h                     |  1 -
 fs/orangefs/file.c                    |  4 +--
 fs/orangefs/inode.c                   |  1 -
 include/linux/fs.h                    |  1 -
 include/linux/pagemap.h               |  2 +-
 mm/filemap.c                          | 42 ++++++++++++++++--------
 mm/truncate.c                         | 15 ++-------
 24 files changed, 87 insertions(+), 174 deletions(-)

-- 
2.47.3

