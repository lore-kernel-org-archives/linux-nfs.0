Received: from mail-qv2-f43.google.com (mail-qv2-f43.google.com [74.125.230.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82C785540A1
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703275; cv=none; b=IK2QcsuA6QQa50uShP0EWEqzwYCQc2BMBbgmCc+wOVtaxmE4llU1xb3M7lETmmGumsKq14uFJp6qUBV0gNLwga0IK8gDD4OA6DZLTH2tDL4E02nBThR+YtaP1u+9XT4v2h15s+fd0/VksyjfuELY+UHnmGcWQluHGa+0vtvJfeo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703275; c=relaxed/simple;
	bh=AcRxKTh2Ouxi57n89SgYYOmTteBNk0AfEz0HWCwMmgQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=S/fbtxnfD51/3Khj/+0UtNPjWQTSDan4Za6EA5NFd1IfFE8yvRsSiBDcTo4JxB8TNNEe5jbznkG8YyGiZHj6+dFdbfpqVYj0eNoMU6vN07EFIp+ABibMW0WV/hK6X9U8o1eKCgPFr654FOmvdouOMY2dSrUqQuKAwzzWA4o2OHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=F+NC09v5; arc=none smtp.client-ip=74.125.230.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="F+NC09v5"
Received: by mail-qv2-f43.google.com with SMTP id 6a1803df08f44-914274b9bfaso2725876d6.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703272; x=1791308072; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=g6MbwMvwBbT6W8LDXAqZITibwCXPPORA+2zUaauU6YE=;
        b=F+NC09v5l3v2JypWA+rRDRk8jbAkZxtCssV2S3uL/I3g4EYrwzZlPl2BqpdGO4OnYE
         Vh7XDck4cyR2MX+TVgCiK8SAyxT8Irw3mFYcDPj8RkWr0D/g+U+Zc0DdJ3kEnJochQE9
         8e3CBhgEUxMUHL81PaytP3ubSqrq+jPZgR7CJoLUKGFG4Y1Nraa9gl/BFWxL3Tulpe7u
         hG52dhiqbfx/E5iREqhK+oETuYOCXvTifFhwKyzScZKY5625YC2KEQtt0ehznzssmIjp
         ItqhK8DNRduSPCjKIqM03obrU71lTumd444tAlnChlAV5oqNoT+6Ce2oyjmFqgALGBKp
         37kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703272; x=1791308072;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=g6MbwMvwBbT6W8LDXAqZITibwCXPPORA+2zUaauU6YE=;
        b=Ilz6VHCIWR8vKKg2ep7dqyDmG5uyB5pY8b+aljLqE6Imf3/24mAHWGuuLsnycHCgJb
         dYpHsgsMJ4QRqB6XjfLWTMlOIUbXAD0hv2ja0GR6NFPHjKj7U3f5vikKf+boj22gKQLm
         UkcsIRtFbO2VyHFuUwE+LXEO5Wfvobn2HlaMrIHEU1ExZiTX/jz1LesRVf6ijLPu2Ahu
         m0q40HOUnNT1UENi53f6UGRp1hvpqqc94KJ2b1Zzv8o2ev7lig7O0muD6OFjYPPpDkOs
         GAZ2Xg9gsBpazdIO8h603YNNp6GGz1PUjy4pRGOymzq2pTzfrroH4xxdWXTlO17aZJSA
         mHcw==
X-Gm-Message-State: AFq9FYLRxAbluBHwio7ZuB1GAJAkINbWJjZgGQtcYordFy7rMHAYp7sl
	06UaTEQyO/x2PlAdcKpihO8ebhiBvv02zJ+8YLZ60fe3fCYmDX+iruai5fjVka0I9hMtaqjifsJ
	+3QfA
X-Gm-Gg: AYBFou0srdpTi2OiM2ebDHXiYOs0nYeTxsHfQQO35P33wOr7ur1wKfoYtOJPFIDcFkC
	vY3W92C1Y2h6XqorSXApnnagQNm0Az8b6HIejwAT+Oi5WXdve728HsVs/RpD4o6oIT7149UAErx
	mE8P/tzGfMdgjB6EkJZnFYp6fOooY0wyP2yn2JtaKKuwJTO7e9wDZGERVLX11aD8lKNhwHFTyeF
	xUJQk9RxDIzJl7YA01If7Jt6KQ9NxO6qalQqfya2lFpay/bp78clxI7oW1u2BLk6OZmWyv6XeBH
	wc5pMs6Ly9XC9A1DE3omrkdlzjepMNGsralDkEMksHb6GJ4ivPbUhaBLnQHkvETgoMfLSSSFTAR
	dBV2Lns4QVG8i2QtCPpE9d0QWcIKVsoKWa7U0MCK1L9LgW1HnPf9NolYPo3Y0J6GLr14ISu8BI7
	+2hqMKdcDpj3JClLigW2NNGWOCS2lEjBfT83+sQEP/wV1ghkqZuli8C1dudylPhaaLX2EhCn3w7
	eK8tukXlwDUCLxzgAgN4cniMbwI4vOGkOfk4oZOkTD+3qHtxul6KsUdHL/7vBD3A3n52b9B4m4C
	IYoZT7ss
X-Received: by 2002:a05:6214:b66:b0:914:4bd3:d98a with SMTP id 6a1803df08f44-9144bd3dc36mr202822976d6.14.1790703272036;
        Tue, 29 Sep 2026 10:34:32 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-917987a5880sm526786d6.14.2026.09.29.10.34.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:31 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] NFSD: let a direct-mode WRITE raise stable_how and elide the client's COMMIT
Date: Tue, 29 Sep 2026 13:34:19 -0400
Message-ID: <20260929173423.16149-7-snitzer@kernel.org>
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
index bc1c0f1a7b7ca..548eca7cdb518 100644
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
index afa41bf2d8189..603a608b03c54 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -113,6 +113,9 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_io_cache_read_fops, nfsd_io_cache_read_get,
  * Contents:
  *   %0: NFS WRITE will use buffered IO
  *   %1: NFS WRITE will use dontcache (buffered IO w/ dropbehind)
+ *   %2: NFS WRITE will use direct IO with stable_how=NFS_UNSTABLE
+ *   %3: NFS WRITE will use direct IO with stable_how=NFS_DATA_SYNC
+ *   %4: NFS WRITE will use direct IO with stable_how=NFS_FILE_SYNC
  *
  * This setting takes immediate effect for all NFS versions,
  * all exports, and in all NFSD net namespaces.
@@ -132,6 +135,8 @@ static int nfsd_io_cache_write_set(void *data, u64 val)
 	case NFSD_IO_BUFFERED:
 	case NFSD_IO_DONTCACHE:
 	case NFSD_IO_DIRECT:
+	case NFSD_IO_DIRECT_WRITE_DATA_SYNC:
+	case NFSD_IO_DIRECT_WRITE_FILE_SYNC:
 		nfsd_io_cache_write = val;
 		/*
 		 * Adjust nfsd_io_cache_{read,write} to avoid
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

