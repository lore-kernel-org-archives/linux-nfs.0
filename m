Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B1724D37C1
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:13:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723620; cv=none; b=TtOmn81kl0apEBROBuL3r7MRQ3jSMEMQ5U8qDg/g49uBG7HUQ4XRTaMK0rSX2AmB5rrdzhgrbE7fwrTwrXptpvQf/64DiXIQORVmyh0Yk4Yv8J2YUJJg9qR/Mnto3MZX0eSbY9XvFMLmK6P8pz8MmDUxpPn8MFSoJP0qvPLlyGw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723620; c=relaxed/simple;
	bh=YPmaVkaVbZEQXJYJ++HHdrhiiTev1Og/Gtt9iEYK9vc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JvAJ8ejamGD6BVOPw3EhUK9HIgOKAq1RQa4XNmX8JkGmxkPPOzhD2rNKiRr6OfeKA+q5DScDA8uQLHbNmZIjnt6oRTsM1vdsH6K7sEdwq7HDORnwLAOhOmS2VyuTJuSvLOPxyTxSawbIKPmzv5TAhWybNJ8ESUn54od5gqD1k2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Lcy678S9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Lcy678S9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1F52D1F00893;
	Tue, 29 Sep 2026 23:13:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723618;
	bh=iC16thcb3BG4vOnw+Ss5xDB8R4C9yo9t2bvS7Al26o0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Lcy678S9D7NnClL6cqsYvCaw2iRJr1GUSbGz49Nx3r/bRhKd7rqzdvPiSCPm1/4wj
	 xuJUaTvPlmO+67zfOYfhS6aqinJBylPzKbXIo82Cd5v3yFPNE1Yc6PsjQ54d03kleF
	 a5Z3S/KgdOcW+lKQSYqD2avGldOpVfLrBJ6+0vBpuYEBLDPGs3hvd/QbVbkYk9jobh
	 ZaEpxIjKADwLMRrtRCDXpFuKdpmttuhzIGd1s1daq6N1xyRy5L44+SMqUOLQ4yNwM/
	 upvaHCOdHmraD5Liru2vuPhn7JdnkSvfXzZ81HLlsc7SewVLxkxQt9//QEIkbDN6B9
	 3kEzfe2OWU0RQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/9] NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
Date: Tue, 29 Sep 2026 19:13:26 -0400
Message-ID: <20260929231329.22018-7-snitzer@kernel.org>
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

nfsd_direct_write() may issue a WRITE as up to three segments: a
buffered prefix, a direct middle and a buffered suffix.  For a
FILE_SYNC or DATA_SYNC WRITE (from the client, or as the floor imposed
by NFSD_IO_DIRECT_WRITE_{DATA,FILE}_SYNC) the kiocb carries IOCB_DSYNC
and every segment inherits it, so generic_write_sync() runs a range
fsync after each segment: up to three cache flushes and log forces per
WRITE, and each one writes back and drops the boundary page it just
touched.

Strip IOCB_DSYNC and IOCB_SYNC from the per-segment flags and persist
the WRITE once with vfs_fsync_range() over the bytes actually written,
after the last segment.  Durability is unchanged: the reply is not sent
until the fsync completes, and datasync mirrors the previous per-segment
choice (IOCB_SYNC present means metadata too).  An fsync failure is
returned like a write failure.

Besides the fewer flushes, this puts the sync under NFSD's control,
which the next change uses to keep the boundary pages of a split WRITE
cached until the partner WRITE completes them.

Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/vfs.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 924c5992dc32e..827dfe0b5dac7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1423,6 +1423,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_write_dio_seg segments[3];
 	int floor_iocb_flags = 0;
 	struct file *file = nf->nf_file;
+	loff_t start = kiocb->ki_pos;
+	bool sync, datasync;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
@@ -1435,12 +1437,21 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		nfsd_write_raise_stability(floor_iocb_flags, kiocb,
 					   iocb_flags);
 
+	/*
+	 * A synchronous WRITE (client FILE_SYNC/DATA_SYNC, or a floor set by
+	 * the IO mode) is persisted once, after all of its segments, rather
+	 * than by generic_write_sync() after each segment: one cache flush
+	 * and log force instead of up to three.
+	 */
+	sync = kiocb->ki_flags & IOCB_DSYNC;
+	datasync = !(kiocb->ki_flags & IOCB_SYNC);
+
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
 					  kiocb, *cnt, segments);
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
-		kiocb->ki_flags = segments[i].flags;
+		kiocb->ki_flags = segments[i].flags & ~(IOCB_DSYNC | IOCB_SYNC);
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
@@ -1458,6 +1469,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;	/* partial write */
 	}
 
+	if (sync && *cnt) {
+		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
+					   datasync);
+		if (host_err < 0)
+			return host_err;
+	}
+
 	return 0;
 }
 
-- 
2.52.0

