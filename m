Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3AB8418340
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 18:55:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792263303; cv=none; b=BKHCC2SECE78eoqn3h9jX3GqbcHUO7VlPXd0ESaC4aAz241LDhWhpcOxPeD6fZVr4mZ9lLULpZGfU70xcJm4Rmx9s436V2AEH9K6JDvTdOdAcMypfpks4bS7HXPAj2FE2FvkbJ/IgfFzNoTozkF+Ib1oJxpgrBsOsPcWMDsro2o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792263303; c=relaxed/simple;
	bh=XkxojKhO3MaT1icdBW3Dg0X2QaCb8vOHu3CjP/o6eh4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MGWE2Ldf7c9BYNST2jts+SUTTDy4rr3Cf7t7OExkQDC9EpB3LvFPvC6KXSggvJyO4+PYSYnXT+YZuLxWaFzbumayhUs3UdLs1dzdmnpZ+ZhbwvWh9+uyvIMfb0aWGtPje7WggesNyUkTOPDA5hIhMNrv6Ugb/ghBDJFYbUi1Ick=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lt2f4VAq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lt2f4VAq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 544701F000C5;
	Sat, 17 Oct 2026 18:55:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792263301;
	bh=cKxpaQfh387ep6bwtRUlH/CimaMVl6PpvksVwuLcWUk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=lt2f4VAqT4wGUjU5xZg71nJ5FKO1ZqMxYrtzylD/VIvyqYQyGjqTVFqYjGw6ED1cP
	 9SldIG/QtoVx4TbU3PA7vlOkcbkxfZWFWeSt89oR8nj7+e0CeKrnchzy6Q4V6mwk8r
	 HuT5auXhxbgWsf/VUQOIPPZQ/a2phzDt7nhY1xuIOy7fU8snI5alohrD9Los093ypa
	 FQijii2eD4BBwy19St7b4zTZ7gj15fjY4ulXNcsmLuvvdEk1fH3u3kxSHmokcyxzar
	 ayCxEWOgQCykTZVB/iWvme8XN4EHliG5r+Plt2VYozlyfGLSC+cfQWDWsX6Henu2dk
	 Ahn2rO5DQUQug==
Date: Sat, 17 Oct 2026 14:55:00 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Subject: [PATCH v4 11/10] NFSD: mark a shared boundary page only once the
 other WRITE has written it
Message-ID: <atPEhOdHqV7momDw@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>

[incremental fix to v4's 9/10 which will be folded into it for v5]

nfsd_write_dio_boundary_claim() treats finding the shared page already in
the page cache (-EEXIST) as "this WRITE is the second of the two", and the
second marks the page drop-behind once its own segment is written.  But a
folio already there says only that the other WRITE has claimed the page,
not that it has written its part.  WRITEs that arrive together -- the RPCs
of one O_DIRECT write larger than the client's wsize, which the client
sends at the same time -- both claim before either writes, so the "second"
can mark the page, and have it dropped, before the other WRITE's data is
in it.  That WRITE then reads the page back from the device.

Treat the page as written by the other WRITE only if its folio is uptodate
when this WRITE finds it: an empty claimed folio becomes uptodate only once
a write fills it.  When it is not, neither WRITE marks the page, and it is
an ordinary cached page.  It is written back like any dirty page, by the
WRITE's fsync, the client's COMMIT or the flusher, but that writeback does
not drop it, since only a drop-behind folio is dropped, and it is not
counted as DONTCACHE dirty, so it does not wake the DONTCACHE writeback
kick.  It stays in the page cache, clean and reclaimable, until reclaim,
truncate or a later direct write over it removes it: one cached page per
concurrent pair instead of a device read.

Measured with 32 interleaved writers of 47008-byte records, NFSD DIRECT,
4 KiB pages, device reads per WRITE before and after this change:

  WRITEs per record      halves arrive     client      before   after
  1 x 47008              -                 FILE_SYNC   0.0102   0.0014
  32768 + 14240          one, then other   FILE_SYNC   0.0021   0.0011
  32768 + 14240          together          FILE_SYNC   0.0401   0.0030
  32768 + 14240          together          UNSTABLE    0.0944   0.0082

In the concurrent cases 90% (FILE_SYNC) and 95% (UNSTABLE) of the pages
read back before the change were the page where a record's two WRITEs
meet.  After it, 14993 (FILE_SYNC) and 22549 (UNSTABLE) of the 90615
boundary pages, 59 and 88 MiB of the 2 GiB written, were still cached at
the end of the run, against 484 and 403 before; with
direct_misaligned_dontcache=N every boundary page stays cached.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/vfs.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e30c50b9b518..424fa3b05705 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1330,9 +1330,22 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
  * DONTCACHE write marks only a folio it allocates, so neither WRITE marks
  * this one and no writeback drops it before the other WRITE has written it.
  *
- * Return: true if a folio was already there.  This WRITE is then the
- * second of the two and calls nfsd_write_dio_boundary_complete() after
- * writing the page.
+ * A folio already there says only that the other WRITE has claimed the page,
+ * not that it has written its part.  Two WRITEs that arrive together -- the
+ * RPCs of one O_DIRECT write larger than the client's wsize -- both claim the
+ * page before either writes, and a page marked now would be dropped before
+ * the other WRITE's data is in it.  This WRITE completes the page only if the
+ * folio is uptodate, which an empty claimed folio becomes only once a write
+ * fills it.  Otherwise neither WRITE marks the page, and it is an ordinary
+ * cached page: written back by the WRITE's fsync, the client's COMMIT or the
+ * flusher like any dirty page, but not dropped by that writeback, which drops
+ * only a drop-behind folio, and not counted as DONTCACHE dirty, so it does
+ * not wake the DONTCACHE writeback kick.  It leaves the page cache when
+ * reclaim, truncate or a later direct write over it removes it.
+ *
+ * Return: true if the other WRITE has already written the page.  This WRITE
+ * is then the second of the two and calls nfsd_write_dio_boundary_complete()
+ * after writing the page.
  */
 static bool
 nfsd_write_dio_boundary_claim(struct file *file, loff_t pos)
@@ -1354,7 +1367,16 @@ nfsd_write_dio_boundary_claim(struct file *file, loff_t pos)
 	if (!err)
 		folio_unlock(folio);
 	folio_put(folio);
-	return err == -EEXIST;
+	if (err != -EEXIST)
+		return false;
+
+	/* FGP_DONTCACHE: a plain lookup would clear a drop-behind mark. */
+	folio = __filemap_get_folio(mapping, pos >> PAGE_SHIFT, FGP_DONTCACHE, 0);
+	if (IS_ERR(folio))
+		return false;
+	err = folio_test_uptodate(folio);
+	folio_put(folio);
+	return err;
 }
 
 /*
-- 
2.52.0

