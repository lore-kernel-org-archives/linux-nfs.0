Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34FE4255F2C;
	Sun, 30 Aug 2026 04:19:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063580; cv=none; b=UpfxRVikkCuHQMTRHURK+BTF4UQsA+N/YlN9ZtVugPcuYeSc+nD+0E1ZC555Bguzx/4hSFkiDpRcRIB7Hwx9dgKBj+vzPtBAJunYLdSqvOIoRLRCYuUuG4F6L5DxQWJ2Hr/ID/hiquAoKnmgfpwnlVIkP3nhmN5Jc1fLGdkx8FY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063580; c=relaxed/simple;
	bh=nLPIzmjRfN1fSQXLUCsxWyfSfsn6ZIaCiaqXynREmkc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=f5AEBobbgNpvxVc9y7qjd7xC0ozNxwV4F1bPOYhKBLgl4iIqtmTdccaYNnrAFoFRqb/EodVxu8JAJSWGhpXspbh/jsC4Lx+/6+LsFWSHtjXTttQKC28+1esHtteeRMmAp7RS0hofBvV3wiUuNY6bhNAZ/g0ellN4s9S9+xlUyDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=SXgE0M1y; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SXgE0M1y"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:
	Content-Description:In-Reply-To:References;
	bh=Aq91nEzmhiWcCrw9x2W22xOz/ZEdIqQpE8kWR+O0NkA=; b=SXgE0M1yzk/4IOCBxbi6JCeibY
	l/ZzAsS0d9y+MhWS2Zj9oR1xd6NyCOGh/uXFJXxsDD9xtXsFxzXDUTbwoYyo/r5vkaFA90qrevPzA
	lcSx0f7Ff8JB4PB2wkE+34bN9lcF3sELubj2ZVBVVIerSOgz/TMjaYVTkk0ruejPn9ra/2ubKqhLW
	ctO3gUBseMzwy+wqmQ1R2Fr2PyQcqg5BYkMS5LKClOhhCGxe1P18Ba7RoSizVxbOex3a5H+2Yow2J
	Jh9eKWbRJUSE/07pvTMCiIrwGBZjrjspB9zentyvDPzibetEfrvZQpHdqArWGUVK9Yi3a/4OxIb8n
	TXuImnLQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Y-000000000hK-3Hg9;
	Sun, 30 Aug 2026 04:19:02 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <christian@brauner.io>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Gao Xiang <xiang@kernel.org>,
	Chao Yu <chao@kernel.org>,
	"Theodore Tso" <tytso@mit.edu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	linux-erofs@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ntfs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 0/9] Remove FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:47 +0100
Message-ID: <20260830041901.2668-1-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

There is broad agreement that we should eliminate __GFP_FS in favour of
using memalloc_nofs_save().  This is a small step in that direction by
getting rid of FGP_NOFS.  It's also a nice simplification in its own right.

I added the documentation improvement at the start of this series, not
because anything depends on that (obviously it doesn't), but because
I thought the existing documentation was rather MM centric and it needs
to be FS centric.  Hopefully the cc'd filesystem maintainers will have
the chance to look at patch 1 and see if it makes sense to them.

There's a few different solutions here:

 - Filesystems specifying both FGP_NOWAIT and FGP_NOFS.  If you're not
   waiting, it doesn't matter if you're allowed to reclaim from FS
   context or not, you're just not doing reclaim.
 - We're already under memalloc_nofs.
 - We can prove that the MM should be allowed to reclaim from
   filesystem memory (and so specifying FGP_NOFS was wrong).
 - We can add a call to memalloc_nofs_save().

Matthew Wilcox (Oracle) (9):
  mm: Improve memalloc_nofs_save() documentation
  ext4: Remove uses of FGP_NOFS
  erofs: Remove redundant FGP_NOFS
  nfs: Remove redundant FGP_NOFS
  ntfs: Remove FGP_NOFS from __ntfs_inode_resident_attr_pwrite()
  ntfs: Remove redundant FGP_NOFS from ntfs_wof_collect_dest()
  squashfs: Remove use of FGP_NOFS
  filemap: Remove redundant FGP_NOFS
  filemap: Remove FGP_NOFS

 fs/erofs/internal.h      |  2 +-
 fs/ext4/inline.c         |  6 ++----
 fs/nfs/dir.c             |  2 +-
 fs/ntfs/inode.c          |  2 +-
 fs/ntfs/wof.c            |  7 +++----
 fs/squashfs/file.c       |  5 ++++-
 include/linux/pagemap.h  | 12 +++++-------
 include/linux/sched/mm.h | 31 +++++++++++++++++++++++--------
 mm/filemap.c             |  2 --
 mm/readahead.c           | 14 ++------------
 10 files changed, 42 insertions(+), 41 deletions(-)

-- 
2.47.3

