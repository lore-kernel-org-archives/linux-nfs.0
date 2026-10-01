Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79F6036DA0D
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 04:55:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790830515; cv=none; b=GPVnUVQcS0TYzrdF975Kv42yZZn2FsgiOJ6Ke/c53K0Iac/sxdDqLXLbheal6UzXnGnQQED8+mZOrZmL5obE5oHQ5UgSumucpq2Wsdi8mCsaTpfZ9xz2amU5GHNwimAdDYE875u/oXsODf6ieV06qArMlHam7H5nTaD/tGX83V0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790830515; c=relaxed/simple;
	bh=mSOkim1J0hKs6LWcWxv5zWHQ5QXvY3s7i3gZoPcojzo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AWT61LuBbvl1XUsce2LOvVkUCQZZTT2hQB1650qKMPFS5PbJwIgNPtaJ6MrhrU8fwVuJ5WJFu4ot2XbehSzJXUTVqGVJeMOsDlNBpj6JK0bcmACkVUG1M0boQVxbV4dtDDR00kWJ3+xjmg/1CTR3pFbnCb+HMLdLDxk9l7v8BV0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j5G4irIm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j5G4irIm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FD5B1F00898;
	Thu,  1 Oct 2026 04:55:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790830514;
	bh=E+3/YpferOmfVDGf6DCZBB09VS+faYWnHhwFQuQFuio=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=j5G4irImZnyXaynpSQS8ivW5f0nOXnXgo1corAD4XPJBlPip7gATRRTRQfAqiCmUD
	 2VJfenBiSK7OvmkDYKvt+WLiSnNqsjymzMN41CIakxDJji8gjzoXmBjudgc/jsxiFo
	 MpxpspxeqnKR2XGSAev7dzvPXaGl+xoD1jCmSWiwASSNQoYyH/bbLUwBiOg7toGoA7
	 sHQZjHXnyPad0qtq1QaW/nfSTn6bZgcZnJMELkBRTRvSkIJMcJHtVtORq2q4/kn8Uy
	 XoHxqt/op11K/7FkWNQgFXskeVrnJ8mz+7W6VQ6Q5oXLSPmFJTzok86IRYSHiJ+d09
	 KZpL3j15MN3Qg==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: hch@lst.de,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 9/9] NFSD: add direct-mode WRITE settings that persist each WRITE
Date: Thu,  1 Oct 2026 00:55:02 -0400
Message-ID: <20261001045502.48381-10-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261001045502.48381-1-snitzer@kernel.org>
References: <20261001045502.48381-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Under NFSD_IO_DIRECT an UNSTABLE WRITE is issued O_DIRECT without
IOCB_DSYNC and answered UNSTABLE.  The data is not yet durable: the
device cache is not flushed, and block allocation, unwritten extent
conversion and the size update are not committed.  The client's COMMIT
is what makes it so.  This patch does not change NFSD_IO_DIRECT.

Add two io_cache_write modes that issue direct I/O like NFSD_IO_DIRECT
but persist every WRITE before replying, to at least a floor, and
report the stability achieved:

  NFSD_IO_DIRECT_WRITE_DATA_SYNC (3): at least NFS_DATA_SYNC
  NFSD_IO_DIRECT_WRITE_FILE_SYNC (4): at least NFS_FILE_SYNC

A client that asked for more is left alone.  A client told FILE_SYNC
sends no COMMIT.

The cost is a flush and log force on every WRITE, where NFSD_IO_DIRECT
has one per COMMIT, so these are opt-in.  They cost more than
NFSD_IO_DIRECT when one COMMIT covers many WRITEs.  They cost the same
flushes, and save the COMMIT RPCs, when each COMMIT covers about one
WRITE.  That is the case on a pNFS flexfiles share where a client's
writes straddle two data servers, so that each data server receives
one WRITE and one COMMIT per write.  Measured there, with identical
WRITE counts and flush counts, the COMMIT RPCs cost NFSD_IO_DIRECT 31%
more server CPU and 42% more client CPU for the same bytes.  Where only
one write in 22 was split, there was no resolvable difference.

A Linux client change that sends FILE_SYNC for a WRITE that is alone
in its flush to a given server would remove those COMMITs without a
server setting, for clients that have it.

Mode 3 promises only the data, leaving a client that needs metadata
durability to COMMIT for it.  Both modes are inert for READ and for a
WRITE the client already marked FILE_SYNC.

Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 15 ++++++--
 fs/nfsd/debugfs.c                             |  5 +++
 fs/nfsd/nfsd.h                                |  2 ++
 fs/nfsd/vfs.c                                 | 35 ++++++++++++++++---
 4 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 11938caee14ca..87266e43e4d1c 100644
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
@@ -38,6 +40,15 @@ corresponding IO operation's debugfs interface, e.g.::
   cat /sys/kernel/debug/nfsd/io_cache_read
   cat /sys/kernel/debug/nfsd/io_cache_write
 
+NFSD_IO_DIRECT leaves an UNSTABLE WRITE for the client's COMMIT to
+persist. The two NFSD_IO_DIRECT_WRITE_*_SYNC modes instead persist every
+WRITE before replying, to at least NFS_DATA_SYNC or NFS_FILE_SYNC, and
+report that stable_how to the client; a client that asked for more is
+left alone. With NFSD_IO_DIRECT_WRITE_FILE_SYNC the client sends no
+COMMIT. This costs a flush on every WRITE: more than NFSD_IO_DIRECT
+when one COMMIT covers many WRITEs, about the same, without the COMMIT
+RPCs, when each COMMIT covers about one.
+
 If you experiment with NFSD's IO modes on a recent kernel and have
 interesting results, please report them to linux-nfs@vger.kernel.org
 
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index d5b714dd0fbc6..bd8ceb5eb2879 100644
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
index 1c17f96012523..913860ab3eb20 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -141,6 +141,8 @@ enum {
 	NFSD_IO_BUFFERED,
 	NFSD_IO_DONTCACHE,
 	NFSD_IO_DIRECT,
+	NFSD_IO_DIRECT_WRITE_DATA_SYNC,
+	NFSD_IO_DIRECT_WRITE_FILE_SYNC,
 };
 
 extern u64 nfsd_io_cache_read __read_mostly;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a8e15193b2160..af05ef942c5d9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1450,12 +1450,25 @@ nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return nsegs;
 }
 
+/* Raise this WRITE to at least @floor_iocb_flags, and report that. */
+static void
+nfsd_write_raise_stability(int floor_iocb_flags, struct kiocb *kiocb,
+			   int *iocb_flags)
+{
+	if ((*iocb_flags & floor_iocb_flags) == floor_iocb_flags)
+		return;
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
 	loff_t start = kiocb->ki_pos, seg_pos, seg_last;
 	bool sync, datasync, complete_first, complete_last;
@@ -1463,6 +1476,14 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
 	/* Persist a synchronous WRITE once, after all of its segments. */
 	sync = kiocb->ki_flags & IOCB_DSYNC;
 	datasync = !(kiocb->ki_flags & IOCB_SYNC);
@@ -1538,7 +1559,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
  * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
- *             stability; OUT: the stability to report to the client
+ *             stability; OUT: the stability to report to the client,
+ *             which may be raised
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
@@ -1606,8 +1628,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
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
@@ -1725,7 +1749,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  * @payload: xdr_buf containing the write payload
  * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
  * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
- *             stability; OUT: the stability to report to the client
+ *             stability; OUT: the stability to report to the client,
+ *             which may be raised
  * @verf: NFS WRITE verifier
  *
  * Upon return, caller must invoke fh_put on @fhp.
-- 
2.52.0

