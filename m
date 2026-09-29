Received: from mail-qk2-f42.google.com (mail-qk2-f42.google.com [74.125.230.234])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57795552932
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.234
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703269; cv=none; b=s/iN2tlowg8yRVCjc+5C2n15m6HJaF9m3X6gxW7BsTeR2sMK3n26EuUKI/w8dxudwehHK3YvAye/PHy4XpukZvzZ4KQEg3dEZOuYvVKJTk50uK5Uj0jQBMaVdnMD9FHsp54OC7WkZ+lAn8anGbtC+oI2amotJWflFhX6TA+Vdoc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703269; c=relaxed/simple;
	bh=O02UzqJYGq5hGctVGg9XiqL07fkZJ8Eab22m2SMq/Xw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tzR72S2htLya53o95qrOBWwEmeeJcARkYDI9OyV6IT+ijqUFDPw9DjGyk6tchYAMvRdrOuFRZa9niMZ0lvEYVzv2n3BD4bSPWoi3j3f9a9hBZEkudV7noKvdSCdxYyhx2DGLCuwBa8SDELoNaATl61pSMKUavSkQsq+Y8OiFLoE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=hPFRnitL; arc=none smtp.client-ip=74.125.230.234
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hPFRnitL"
Received: by mail-qk2-f42.google.com with SMTP id af79cd13be357-93c56f7c1c8so431096785a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703267; x=1791308067; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=5MCFXci4ZUfJy5NYWJS7Vnzf/JrkEZ2unXYroDIp1lk=;
        b=hPFRnitLC/MdrrkU9J/yyHWpcbRjmeFX3it9Htmz+UrYYUAyXlh514Fe1ryMSDnSXk
         PsSU4obQQ0/kBFt4+RcpybwsZtLXWPdG3juXiJElubgc+Ji3tGCFx5kQEXvWLfRitFwu
         8iRE8cX6BuzeTR15aZXkNvn9PvOwIb5+P/nm0+s6xMKpdQbz4JInirjkSVqCf5heB75C
         LjTiBiXJ5vV/Rd1GHHj5+n9cQtxRd8mqAkqcW3wfmaSsIGBBIyyTsok5BTc1rOe69uCr
         VGKd1Tnlm2XaIs6Yyk7AZqGp2FxubkIA9VlFdATCRas8+uYdJSrENQh17C1R9T/hX71s
         RLZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703267; x=1791308067;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5MCFXci4ZUfJy5NYWJS7Vnzf/JrkEZ2unXYroDIp1lk=;
        b=Lr//tO/30b17pZSBd5yTC2/d8vchDEKdrY1FL0NPUJId/HEqwNfAlKcbWtkPMLt3r1
         yEtASABN9LHBwSeLcUTKGudiNU0yl/W4DHtH8Te/RFFuXQAdyIz7AuzCDvrdn7HWivYo
         j4tfa8ENtEsbXNQqfiyOoQRsY1qFVc3gDUblx9mFSCV7iXzkdbxJNVU2yBWulOzWLLKu
         w2XZ0a8MXRDXEvMXaCBhLC0dCIKUPVr1d7xgqACrwbU8t8Atw0rfIj8XzT8NVI8F8SmU
         NSHawFoPxQ8vCd5+hnMF/Wq/zeRC5sqwTu1msg9gxy9PHzCOvtkorwKqb2yLMusEdO7V
         snMA==
X-Gm-Message-State: AFuF++mcX65j6VARzgUcf+4pOoEHYSvtuZQzlzTM33vmeflNcH27BrV0
	iBQzyH7eEmVZSfF3jWl+/T3xQMUY0Q+U2zZamj1ydH9MfcHUTk+tOlDxatWF1mR2hz8=
X-Gm-Gg: AYBFou0fVlQXGdI6VT5Fb4Ev6ZChaL44/WJqSN+AKH8ZTBkYPHaLZt9D0QTynTLg82j
	ifRSUGVrs5HQpDuxrFb+iA6TgbgyahRerTzCjz78IeHYtZm9iefD88PbePZMYkGRVzDIn2nxbaf
	ozR8PqXSE2nTpRNrfDNmfG8FUumvRX5ew38RocnX0l2T2qENQYeIzYoZxv5G2lyHPzeh+SVwv09
	+65yphXgqzXnOHF4y15+e40HSUNNiKTfnbgObxzc6x9RGOOhCZrzLxAly3XUZssw57Rdd1ypTHQ
	oaJ5hMnLLduQnInONS6wvo6MXaByIzGF6hZPReFcXKtkd9QiVNSgqj0gsVT+rGXoLl6v72hnacK
	cZ8XgeQYxv1zO0RjBU5UuoTX77rNGzyXI9K1VwZKZ2QyGHh0wS3HBgkBHEHKbKH5MBV32gUxLUu
	AlM6Ro/h0YRHGFZIRCA7Zyzx+78uWPYkBmDaU3+NJ0JSStE08/8BO8oyyq0THBTtQ3xrSUn5k+Y
	9DZtFaopvAapc0fNtQcuD+NZMP49kZtYX2/hOrp/QdhhUvq4C7naR0DLB6M2NKIv+vs0zRmRuE=
X-Received: by 2002:a05:620a:808b:b0:93c:6abf:c8ae with SMTP id af79cd13be357-93c9fc00c6amr35349885a.50.1790703266899;
        Tue, 29 Sep 2026 10:34:26 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f4fe9dasm22129385a.26.2026.09.29.10.34.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:26 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
Date: Tue, 29 Sep 2026 13:34:15 -0400
Message-ID: <20260929173423.16149-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_write_dio_iters_init() issues the DIO-aligned middle of a
misaligned WRITE with IOCB_DIRECT.  A file system is free to service
that request with buffered I/O instead: xfs_file_write_iter() retries
via xfs_file_buffered_write() with the same kiocb whenever
xfs_file_dio_write() returns -ENOTBLK, which iomap_dio_rw() produces
when the invalidation it runs before issuing the direct I/O cannot drop
page cache overlapping the range.

That happens routinely in a streaming misaligned WRITE workload with
more than one request in flight.  Request N's direct middle ends inside
the same page that request N+1's buffered prefix starts in.  If N+1's
prefix dirties that page between N's filemap_write_and_wait_range() and
N's invalidate_inode_pages2_range(), the invalidation returns -EBUSY,
iomap returns -ENOTBLK, and XFS re-issues N's entire middle, tens of
kilobytes, as a normal cached buffered write.  Nothing ever drops those
pages.  On a device with dma_alignment=3 (XFS then reports
dio_mem_align=4, which XDR-aligned RPC payloads always satisfy) this is
the only remaining path by which a stream of small misaligned WRITEs in
DIRECT mode fills the page cache.

Set IOCB_DONTCACHE on the middle segment alongside IOCB_DIRECT when the
file system supports FOP_DONTCACHE.  The direct path ignores the flag,
and generic_write_sync() only issues a harmless flusher kick; but if
the file system falls back to buffered I/O the write is now DONTCACHE
rather than cached.  The nfsd_write_direct trace event is unchanged
since it keys on IOCB_DIRECT; the fallback itself remains observable
via the iomap_dio_invalidate_fail event.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 10 ++++++++++
 fs/nfsd/vfs.c                                   |  9 +++++++++
 2 files changed, 19 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index a8e277bcb08b1..c15983e634a3e 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -165,6 +165,16 @@ Misaligned WRITE:
     segments because using normal buffered IO offers significant RMW
     performance benefit when handling streaming misaligned WRITEs.
 
+    The O_DIRECT middle segment also carries the DONTCACHE flag. It has
+    no effect while the IO really is O_DIRECT, but a filesystem may
+    decide on its own to service the segment with buffered IO instead
+    (XFS does so when it cannot invalidate page cache that overlaps the
+    segment, which can happen when another WRITE's buffered start or
+    end segment dirties the shared boundary page at the same time).
+    The flag makes that fallback DONTCACHE buffered IO rather than
+    normal buffered IO. Such fallbacks are visible through the
+    iomap_dio_invalidate_fail trace event; see Tracing below.
+
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391e..5b963f0e3b3f2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1341,6 +1341,15 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
 		goto no_dio;
 	segments[nsegs].flags |= IOCB_DIRECT;
+	/*
+	 * Also mark the direct middle DONTCACHE: the file system may fall
+	 * back to buffered I/O on its own (e.g. XFS on -ENOTBLK when it
+	 * cannot invalidate page cache that a concurrent buffered prefix or
+	 * suffix of an adjacent WRITE just dirtied), and it reuses this kiocb
+	 * to do so.  On the direct path itself the flag is inert.
+	 */
+	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
+		segments[nsegs].flags |= IOCB_DONTCACHE;
 	nsegs++;
 
 	if (suffix)
-- 
2.52.0

