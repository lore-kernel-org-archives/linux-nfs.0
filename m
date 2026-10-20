Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792533838;
	b=qyngZgJJWF3LWzxs6QRquSZfux3blxxAC2qgIFln1/mOHpVf4snwz5SRtjVT2xI0qkTl
	 n+ux9odG5rot+riTugLuaQlF8VrS8rc4Fc62gcDsMT7lrB2ghOiyqBzRi6e+CX2iBvnJ5
	 XVAbY2OxVhMY7/ay5R4LUi20/ZnZJUWcZrw4Rz3i4qPDVP11FarANi+vITIBeMOu1s5Qn
	 zfsuXDsw4wASCjlyyum4m/JFH6qZU9PmYruLtbCLa1WMfHqBLKdljrLO7k3IMMM8fpWRJ
	 D9yAf+iI5OUCymWqW37TYvBacEJ6MwpKhzx0qhOm5pTUKx0oaUx9Aojlx6iqcWOgM3g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792533838;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Sender:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ksFooBbHDKfmZxe5xUlfiBIprT9yVQQKPdOzVn3Oh+s=;
	b=oxXoSozIa3QJwKSxbIE4iPjw8xkbiB0I02VSd2eperLDXlzB34cClz1nsyRNuTcR7rlc
	 scim+GPYjR0siCPO3d2G3mh0PGFxlObopfUB1Jr83DgMu35MNOecV6beUm3CQnik64ps7
	 gAQ+oaA0TEpluDvv9jKk5E5mPwB5hpXp8OAjOA4bskwGIWWZ1qB2wwT2XICgg5hJARJGL
	 1ocmT+Ax4AGZHG95Z8dF0Yo2W4F6d6BvedeeGO4CdMQXGUPjaSyVFBbhjwnyeO8pAj57K
	 dRUHctzeEUuVurL/nOSapTIBCdZng6oWpdauz+MATajrTeZZp34GYxQQdizBB/UEVXg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=KCHAIZ52;
	arc=none smtp.remote-ip=209.85.222.182
Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 266BD606A32F
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 22:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 266BD606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=KCHAIZ52
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-93f079a63b8so11257185a.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 15:03:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792533836; x=1793138636; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ksFooBbHDKfmZxe5xUlfiBIprT9yVQQKPdOzVn3Oh+s=;
        b=KCHAIZ52j/MrwJa9jN9Au1AsHJtGxbPeulfqDlWTrCm11mppPPuFDXu+GpigHGd215
         GBYa+enbiDPfapAJoSlx6wvLuS/fkRAoqsIWhEhvfi0eQ4SQUTkv5uSlDorMMBp6ylu6
         l1/5+22AsMjs7UEUq4XagT6EvUsUtMtlfl4JEhkAZwwYC910+C3wgb5FvwTXHapNJ1xe
         ahNmEJ/JGxzBiVpkJC9aVforngwxPWuxpieW4NNVKuwsmCft1Cs7DStCdoqTPIGyuCUj
         znRO7cRIp+zfp0r79DiUvMimQGTAMCDiS8yaj3hBEUBkc0JAU4wbE8zEL32TGBQQiczP
         2Hxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792533836; x=1793138636;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ksFooBbHDKfmZxe5xUlfiBIprT9yVQQKPdOzVn3Oh+s=;
        b=uUP778+y358/MBoK+TMc5jasAuRlk0SDEcpiNS/m28HoXYTOAjJCxEkTHnfSYYZIMT
         4+lOsRAXNn+aVc1zQaZNxM8ZBDGabcNoUxiYSIonplGL4FjJp1c6oqkWnHDompgo9+Kt
         4dtvzz463msnr41F7mW29C7IeR8pj3CQgTSo9CjbNL+gIeZzVXS7nRfrJDTpRYFumzEU
         mNXasgD9d8w6DlPKznnMzXnKevNDT8NI62Z3EHKElAGEXTq/ePXVPDrNHoRxlSUAQexl
         qSHVh+j7ZNmvTKzUhzGiL/Rx9XBQjaS9JwvbM6gm+QXuMatBdFr09nZZ1D8Lq6qGXNhR
         Yh8g==
X-Gm-Message-State: AFq9FYKPTGuEq21LCHj+QCxVvYB5HZVOs/zsq8qSKe1BdcRLVVmR5V8d
	ne7+KNHAXaLxGgXQjzq8bPN/WBIJzO9M3Rar/Fu6yiYBkToDAOwgr0hljv0tdXQ/jcA=
X-Gm-Gg: AYBFou2MTMqLkHcwY2V83jIgXbwKS2egni0R47frnTUY6NmmUTKzcHKtzfAkDzwLbW/
	zyySF1kePnxIEv+YWhLcexW6rl1KKlLhfK2Ymi+MS/BcelDFENwUG84yPn2JMu8d9AFYrAT1SpV
	qT4g5txXBeRD558A65+Op4c5EAkLRaitvvKC1KnCR7HkVt/0gf1xAfCleeAZWu49zaZVF22yt80
	J6w4/6If9s4Fk+R5z25u4WBSB+Y9KvUYb0RcYtJgiVDT+Pcy9XmfRf1cr6HSNLeXYdXOsNEuf9v
	VhtXamwuhQoT+5lWOIy80pzuTIbeiTlVeoh5RJrKKYy6DlpVyfkDCe7I2Z8xTL2Qjfd4gmPOeIJ
	UXqgmhLNgbJElXDjiK/ITezcC7qpEg/NQ5BRtlJlaWnwnysbAW7lbv8yg3QtM41SqbTrDPFc/px
	dkuOChG1kOqjBXBaNJaYut0FIIjwaicFl3pU3d+m2g+JBQSnS5Ny1RM9QFViJZYOwP4sLyoaOJN
	8rgkYaUdHWHqOb/XxAa/l97LMkxn9P8w4LEr8u9UBw5dG50HoSOl0i9K6NbSdtkEdgaqkYApif1
	EgEQsH+G
X-Received: by 2002:a05:620a:4592:b0:93f:2a95:a503 with SMTP id af79cd13be357-93f57f6c6acmr119603485a.67.1792533835652;
        Tue, 20 Oct 2026 15:03:55 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93f56d98978sm89964885a.10.2026.10.20.15.03.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 15:03:55 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v7 5/5] NFSD: drop a shared boundary page only once both WRITEs have written it
Date: Tue, 20 Oct 2026 18:03:46 -0400
Message-ID: <20261020220346.28020-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261020220346.28020-1-snitzer@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A buffered DONTCACHE segment of a direct-mode WRITE -- the misaligned
start or end of a split WRITE, or the whole of one too small to split --
covers its first and last page only partly when it does not start or end
on a page boundary.  Such a page is shared with the neighbouring WRITE,
which may arrive before, after or at the same time, from any client.

The page cache keeps a page an uncached write covers only partly for the
write that completes it ("mm, iomap: keep a partly covered page until an
uncached write completes it"), so the second WRITE does not have to read
it back from disk.  Left at that, the page cache marks the page drop-
behind while it is still dirty, which counts it as DONTCACHE dirty and
wakes the DONTCACHE writeback kick for every segment of a stable WRITE,
only to write back what NFSD's single fsync is about to write.

Issue the buffered segments IOCB_DONTCACHE_DEFER and mark the pages here
instead ("mm, iomap: let an uncached writer complete its shared pages
itself").  Immediately before writing a segment, NFSD asks
filemap_dontcache_edge_completes() whether each page it covers only
partly has already been written by the neighbouring WRITE; once the
whole WRITE, its fsync included, is complete, it calls
filemap_dontcache_edge_complete() for those pages, which drops a clean
page at once.  An UNSTABLE WRITE marks them dirty, and the writeback
that cleans them, by the flusher or for the client's COMMIT, drops them.

A page whose neighbouring WRITE never arrives, such as the last page of
the file, or arrives at the same time, so that neither finds the other's
part, stays cached until it is reclaimed.  Nothing changes when the
buffered segments are normal buffered I/O (direct_misaligned_dontcache
is N, or the file system lacks FOP_DONTCACHE); the page cache keeps
partly covered pages only for file systems that use iomap for buffered
writes.

Measured with 32 interleaved writers of 47008-byte records over an
emulated 4Kn NVMe with 4 KiB pages, NFSD DIRECT with
direct_misaligned_dontcache=Y, each run from a freshly made file system:
device reads per WRITE are 0.0001-0.0002 whether each record is one
FILE_SYNC WRITE, two sent one after the other, two sent together, or two
sent UNSTABLE, against 45144 reads for 45664 WRITEs with no shared-page
handling, and the DONTCACHE writeback kick does not run at all for the
FILE_SYNC WRITEs.

On a four-server pNFS flexfiles rig (x86_64, 4 KiB logical blocks), three
clients writing 47008-byte records for 240 s against 640 nfsd threads per
server, keeping the shared page took device reads from 0.014-0.015 per
record to 0.003, page-cache growth over the write phase from about
11 GiB to 2.9 GiB, and write throughput up by 2.4% to 4.9%, with read
throughput unchanged.  Keeping every boundary page cached instead, with
direct_misaligned_dontcache=N, grows the page cache by about 630 GiB over
the same runs.

Reported-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 17 ++++
 fs/nfsd/vfs.c                                 | 99 ++++++++++++++++---
 2 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0e69b5fdd675..9c663ce97c48 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -167,6 +167,23 @@ Misaligned WRITE:
     above. Set it to N for a workload that reads back or rewrites what
     it just wrote.
 
+    The page holding a start or end segment is shared with the
+    neighbouring WRITE, which may arrive before, after or at the same
+    time, from any client. So that the second WRITE to such a page does
+    not have to read it back from disk, the page cache keeps a page an
+    uncached write covers only partly, unmarked, for the write that
+    completes it. NFSD asks, immediately before writing a start or end
+    segment, whether the neighbouring WRITE has already written its
+    part; if it has, NFSD marks the page DONTCACHE once its own WRITE,
+    including its fsync, is complete, and the page is dropped. A page
+    whose neighbouring WRITE never arrives, or arrives at the same time,
+    stays cached until it is reclaimed. The first and last pages of a
+    WRITE that is not split are handled the same way.
+
+    None of this applies when the start and end segments are normal
+    buffered IO, or for a filesystem that does not use iomap for
+    buffered writes.
+
 Tracing:
     The nfsd_read_direct trace event marks a READ that NFSD issues as
     O_DIRECT. It records the offset and length the client requested.
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9219f8eb386d..3605ddf1ad1e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1387,6 +1387,7 @@ static int wait_for_concurrent_writes(struct file *file)
 struct nfsd_write_dio_seg {
 	struct iov_iter			iter;
 	int				flags;
+	bool				claim;		/* completes shared pages */
 };
 
 static unsigned long
@@ -1406,6 +1407,65 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 		iov_iter_advance(&segment->iter, start);
 	iov_iter_truncate(&segment->iter, len);
 	segment->flags = iocb->ki_flags;
+	segment->claim = false;
+}
+
+/* The shared pages a segment completes, and how much of it was written. */
+struct nfsd_write_dio_hold {
+	loff_t	first, last;
+	bool	complete_first, complete_last;
+	size_t	written;
+};
+
+/*
+ * A page that a buffered DONTCACHE segment covers only partly is shared with
+ * the neighbouring WRITE.  The page cache keeps it, unmarked, for the write
+ * that completes it; the segment is issued IOCB_DONTCACHE_DEFER so that this
+ * WRITE, not the page cache, marks it, once the whole WRITE, its fsync
+ * included, is complete.  Ask whether the neighbour has already written its
+ * part immediately before writing @seg: asking earlier gives the neighbour
+ * time to write its part and find this WRITE's part missing.
+ */
+static void
+nfsd_write_dio_seg_hold(struct file *file, const struct nfsd_write_dio_seg *seg,
+			loff_t pos, size_t len, struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	hold->first = pos;
+	hold->last = pos + len - 1;
+	hold->complete_first = false;
+	hold->complete_last = false;
+	hold->written = 0;
+	if (seg->claim && len) {
+		bool one_page = (hold->first >> PAGE_SHIFT) ==
+				(hold->last >> PAGE_SHIFT);
+		bool head = hold->first & ~PAGE_MASK;
+		bool tail = (hold->last + 1) & ~PAGE_MASK;
+
+		/* Only a page the segment covers partly is shared. */
+		if (head || (one_page && tail))
+			hold->complete_first =
+				filemap_dontcache_edge_completes(mapping, hold->first);
+		if (!one_page && tail)
+			hold->complete_last =
+				filemap_dontcache_edge_completes(mapping, hold->last);
+	}
+}
+
+/* Drop the shared pages this WRITE was the second of two to write. */
+static void
+nfsd_write_dio_seg_release(struct file *file,
+			   const struct nfsd_write_dio_hold *hold)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (hold->complete_first && hold->written)
+		filemap_dontcache_edge_complete(mapping, hold->first);
+	/* A short write did not reach the last page. */
+	if (hold->complete_last &&
+	    hold->written == hold->last - hold->first + 1)
+		filemap_dontcache_edge_complete(mapping, hold->last);
 }
 
 static unsigned int
@@ -1428,7 +1488,9 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (nf->nf_file->f_op->fop_flags & FOP_DONTCACHE)
 		dontcache_flags = IOCB_DONTCACHE;
-	buffered_flags = nfsd_direct_misaligned_dontcache ? dontcache_flags : 0;
+	/* NFSD marks their shared pages itself, see nfsd_write_dio_seg_hold() */
+	buffered_flags = nfsd_direct_misaligned_dontcache && dontcache_flags ?
+			 dontcache_flags | IOCB_DONTCACHE_DEFER : 0;
 
 	/*
 	 * Check if direct I/O is feasible for this write request.
@@ -1483,7 +1545,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
 					nvecs, total, 0, prefix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 
 	nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs,
@@ -1516,7 +1579,8 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
-		segments[nsegs++].flags |= buffered_flags;
+		segments[nsegs].flags |= buffered_flags;
+		segments[nsegs++].claim = !!buffered_flags;
 	}
 	return nsegs;
 
@@ -1525,6 +1589,7 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	nfsd_write_dio_seg_init(&segments[0], bvec, nvecs, total, 0,
 				total, iocb);
 	segments[0].flags |= buffered_flags;
+	segments[0].claim = !!buffered_flags;
 	return 1;
 }
 
@@ -1533,12 +1598,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct nfsd_file *nf, unsigned int nvecs,
 		  unsigned long *cnt, struct kiocb *kiocb)
 {
+	struct nfsd_write_dio_hold holds[3];
 	struct nfsd_write_dio_seg segments[3];
 	struct file *file = nf->nf_file;
 	loff_t start = kiocb->ki_pos;
-	unsigned int nsegs, i;
+	unsigned int nsegs, nheld = 0, i;
+	ssize_t host_err = 0;
 	int sync_flags;
-	ssize_t host_err;
 	size_t expected;
 
 	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
@@ -1567,23 +1633,32 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					kiocb->ki_flags);
 
 		expected = iov_iter_count(&segments[i].iter);
-
+		nfsd_write_dio_seg_hold(file, &segments[i], kiocb->ki_pos,
+					expected, &holds[nheld]);
 		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
 		if (host_err < 0)
-			return host_err;
+			break;
+		holds[nheld++].written = host_err;
 		*cnt += host_err;
 		if (host_err < (ssize_t)expected)
 			break;	/* partial write */
 	}
 
-	if (sync_flags && *cnt) {
+	if (host_err >= 0 && sync_flags && *cnt)
 		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
 					   !(sync_flags & IOCB_SYNC));
-		if (host_err < 0)
-			return host_err;
-	}
 
-	return 0;
+	/*
+	 * Mark the pages this WRITE shares with its neighbours for dropping
+	 * only once the WRITE is complete, including its fsync if it has one.
+	 * A page marked while still dirty is counted as DONTCACHE dirty and
+	 * wakes the DONTCACHE writeback kick; a page marked once clean is
+	 * simply dropped.
+	 */
+	for (i = 0; i < nheld; i++)
+		nfsd_write_dio_seg_release(file, &holds[i]);
+
+	return host_err < 0 ? host_err : 0;
 }
 
 /**
-- 
2.52.0

