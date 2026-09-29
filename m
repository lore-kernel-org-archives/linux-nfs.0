Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32F024E50CA
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723618; cv=none; b=vAddvee5L8kTu5W0v0qO1OGSMro3bcJK2cdbYFqT48/pZFInBmhVApuEM0drXT/WFDMte7dG/JeqBN8moMH+22uwUQlBW5cZJAbo3r6h734aMiVs0us1tb2k7ECdmvgVPDsy9yyWq0JR1cAFNSlrrQsc9WRsjHQfYVm19VnPRKs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723618; c=relaxed/simple;
	bh=las4jaBOKoLmkvx40qw7BzYQeXoMmb4vEnt+i/yOBso=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=e3uRo/UJIetBsT0YS0aXjLgF71WWQ1s2SvrFStbCuZmJ6fYYVFvX5k3LCSxOF4CQcEXClkxt8SbOajXTieT2rN1/kpkK+yG9aWX7nG36SeHdZNngwXxbs1BUxCQoOHnHPD+6j81Uygxl6gWdjlkWrgNfnTUHqci8Ph7z8YTe++M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cZAM8SPX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cZAM8SPX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB7AE1F000FF;
	Tue, 29 Sep 2026 23:13:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723617;
	bh=PcQsLUhPjX2bXxL6afrE3OxsTnZ0nXse5csij8FfbFI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cZAM8SPX61OnLrGZQ2HZRjFkW5uHm/yQ2OuWocjNvo2q7FpVPnBu0f5GAO7StVroW
	 ZYYCkrttSlJmD/NBp/QgilHis84Bp0jr/ltUQtAY1Aw8MHLVMufypLO+ZCJcHP3rH1
	 SqeM3xxnpsdbQ82zeVEQ4zJW5rrlpwsibZDSWpoNyxarcwQFjq/8n++lmx4B27YnoF
	 TWDSUe+/aN2nWUMqEPhU3P9y3qsvZ/WoOhx+HSSqZ5gHZTHljaRxKC6BcMNMI4hOmQ
	 5pY3wvfrcDHjie8j9wPrLMXlSKdtilIOnu8e2cT3X38w8EHgsmeOumf2o3n4qoEWXi
	 f/LcX7aYqzx8A==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/9] NFSD: let a direct-mode WRITE raise stable_how and elide the client's COMMIT
Date: Tue, 29 Sep 2026 19:13:25 -0400
Message-ID: <20260929231329.22018-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929231329.22018-1-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A WRITE serviced in a direct mode is already persistent when NFSD
replies: the aligned middle is O_DIRECT, and a synchronous WRITE fsyncs
whatever was buffered before the reply is sent.  The reply still says
UNSTABLE, so the client dutifully sends a COMMIT for data that is
already on stable storage, and NFSD answers it with an fsync that has
nothing left to write.

Add two io_cache_write modes that issue direct I/O exactly like
NFSD_IO_DIRECT and raise the stable_how of the reply to a floor:

  NFSD_IO_DIRECT_WRITE_DATA_SYNC (3): at least NFS_DATA_SYNC
  NFSD_IO_DIRECT_WRITE_FILE_SYNC (4): at least NFS_FILE_SYNC

A client that asked for more is left alone, and the WRITE is persisted
to the level the reply reports before that reply is sent.  A client told
FILE_SYNC has no reason to COMMIT and sends none.

What this removes is the COMMIT traffic, and it is worth most where a
client's writes are carved into several WRITE RPCs, because each piece
is then committed separately.  Measured on a pNFS flexfiles share where
every write straddles two data servers, so every write becomes two WRITE
RPCs and, under NFSD_IO_DIRECT, two COMMITs: the two modes do identical
durability work, one fsync per COMMIT against one fsync per WRITE on
identical WRITE counts, and the COMMIT RPCs alone cost NFSD_IO_DIRECT
31% more server CPU and 42% more client CPU for the same bytes, about
20 us of server CPU per COMMIT plus a client cost that grows with the
range committed.  Where only one write in 22 is split the same effect
is a couple of cores on each side and no resolvable throughput
difference, and writes that fit a single RPC send no COMMIT in either
mode.

Choose 4 when the export services WRITEs in a direct mode and clients
split their writes; choose 3 to promise only the data, leaving a client
that needs metadata durability to COMMIT for it.  Both are inert for
READ, and for a WRITE the client already marked FILE_SYNC.

Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 17 ++++++++--
 fs/nfsd/debugfs.c                             |  5 +++
 fs/nfsd/nfsd.h                                |  2 ++
 fs/nfsd/vfs.c                                 | 33 +++++++++++++++++--
 4 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index d6ebb82f10b48..9ee94cfa546d8 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -25,12 +25,14 @@ Based on the configured settings, NFSD's IO will either be:
 - cached using page cache (NFSD_IO_BUFFERED=0)
 - cached but removed from page cache on completion (NFSD_IO_DONTCACHE=1)
 - not cached stable_how=NFS_UNSTABLE (NFSD_IO_DIRECT=2)
+- not cached stable_how=NFS_DATA_SYNC (NFSD_IO_DIRECT_WRITE_DATA_SYNC=3)
+- not cached stable_how=NFS_FILE_SYNC (NFSD_IO_DIRECT_WRITE_FILE_SYNC=4)
 
-To set an NFSD IO mode, write a supported value (0 - 2) to the
+To set an NFSD IO mode, write a supported value (0 - 4) to the
 corresponding IO operation's debugfs interface, e.g.::
 
   echo 2 > /sys/kernel/debug/nfsd/io_cache_read
-  echo 2 > /sys/kernel/debug/nfsd/io_cache_write
+  echo 4 > /sys/kernel/debug/nfsd/io_cache_write
 
 To check which IO mode NFSD is using for READ or WRITE, simply read the
 corresponding IO operation's debugfs interface, e.g.::
@@ -38,6 +40,17 @@ corresponding IO operation's debugfs interface, e.g.::
   cat /sys/kernel/debug/nfsd/io_cache_read
   cat /sys/kernel/debug/nfsd/io_cache_write
 
+The two NFSD_IO_DIRECT_WRITE_*_SYNC modes raise the stable_how of every
+WRITE to at least NFS_DATA_SYNC or NFS_FILE_SYNC, persist the WRITE
+accordingly before replying, and return the raised value to the client;
+a client that asked for a higher stable_how is left alone. With
+NFSD_IO_DIRECT_WRITE_FILE_SYNC the client sends no COMMIT. Against
+NFSD_IO_DIRECT the durability work is the same, one fsync per WRITE
+instead of one per COMMIT; what NFSD_IO_DIRECT adds is the COMMIT RPCs
+themselves, tens of microseconds of server CPU each plus a client cost
+that grows with the range committed, which matters in proportion to how
+many of a client's WRITEs need a COMMIT.
+
 If you experiment with NFSD's IO modes on a recent kernel and have
 interesting results, please report them to linux-nfs@vger.kernel.org
 
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 398e400d64038..279e341a81ec1 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -90,6 +90,9 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_io_cache_read_fops, nfsd_io_cache_read_get,
  * Contents:
  *   %0: NFS WRITE will use buffered IO
  *   %1: NFS WRITE will use dontcache (buffered IO w/ dropbehind)
+ *   %2: NFS WRITE will use direct IO with stable_how=NFS_UNSTABLE
+ *   %3: NFS WRITE will use direct IO with stable_how=NFS_DATA_SYNC
+ *   %4: NFS WRITE will use direct IO with stable_how=NFS_FILE_SYNC
  *
  * This setting takes immediate effect for all NFS versions,
  * all exports, and in all NFSD net namespaces.
@@ -109,6 +112,8 @@ static int nfsd_io_cache_write_set(void *data, u64 val)
 	case NFSD_IO_BUFFERED:
 	case NFSD_IO_DONTCACHE:
 	case NFSD_IO_DIRECT:
+	case NFSD_IO_DIRECT_WRITE_DATA_SYNC:
+	case NFSD_IO_DIRECT_WRITE_FILE_SYNC:
 		nfsd_io_cache_write = val;
 		break;
 	default:
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index a2d72434160af..135e319e378d4 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -138,6 +138,8 @@ enum {
 	NFSD_IO_BUFFERED,
 	NFSD_IO_DONTCACHE,
 	NFSD_IO_DIRECT,
+	NFSD_IO_DIRECT_WRITE_DATA_SYNC,
+	NFSD_IO_DIRECT_WRITE_FILE_SYNC,
 };
 
 extern u64 nfsd_io_cache_read __read_mostly;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 82eba97656c4e..924c5992dc32e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1399,17 +1399,42 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	return 1;
 }
 
+/*
+ * Raise the stability of this WRITE to at least @floor_iocb_flags, and
+ * record what was achieved in @iocb_flags so the reply can report it.
+ * A client that asked for more is left alone.
+ */
+static void
+nfsd_write_raise_stability(int floor_iocb_flags, struct kiocb *kiocb,
+			   int *iocb_flags)
+{
+	if ((*iocb_flags & floor_iocb_flags) == floor_iocb_flags)
+		return; /* already at or above the floor */
+
+	*iocb_flags |= floor_iocb_flags;
+	kiocb->ki_flags |= floor_iocb_flags;
+}
+
 static noinline_for_stack int
 nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		  struct nfsd_file *nf, unsigned int nvecs,
+		  struct nfsd_file *nf, int *iocb_flags, unsigned int nvecs,
 		  unsigned long *cnt, struct kiocb *kiocb)
 {
 	struct nfsd_write_dio_seg segments[3];
+	int floor_iocb_flags = 0;
 	struct file *file = nf->nf_file;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
 
+	if (nfsd_io_cache_write == NFSD_IO_DIRECT_WRITE_FILE_SYNC)
+		floor_iocb_flags = IOCB_DSYNC | IOCB_SYNC;
+	else if (nfsd_io_cache_write == NFSD_IO_DIRECT_WRITE_DATA_SYNC)
+		floor_iocb_flags = IOCB_DSYNC;
+	if (floor_iocb_flags)
+		nfsd_write_raise_stability(floor_iocb_flags, kiocb,
+					   iocb_flags);
+
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
 					  kiocb, *cnt, segments);
 
@@ -1513,8 +1538,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	switch (nfsd_io_cache_write) {
 	case NFSD_IO_DIRECT:
-		host_err = nfsd_direct_write(rqstp, fhp, nf, nvecs,
-					     cnt, &kiocb);
+	case NFSD_IO_DIRECT_WRITE_DATA_SYNC:
+	case NFSD_IO_DIRECT_WRITE_FILE_SYNC:
+		host_err = nfsd_direct_write(rqstp, fhp, nf, iocb_flags,
+					     nvecs, cnt, &kiocb);
 		break;
 	case NFSD_IO_DONTCACHE:
 		if (file->f_op->fop_flags & FOP_DONTCACHE)
-- 
2.52.0

