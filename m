Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DAC44E9C06
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610882; cv=none; b=J0SIsc6TfqCPH8+pV/HYvQEHqnxRg+KRFRXcBlEwWomKq8WPLApnU8B+mLZAQBhF/dPizkMUQVbs+iY6dcT5t3SuSLQthlQRE5iOvTz28X7CrwG+PyXNB3r9o/o8Cudwt8ZiIQmMDT3FnYLS+XM8++gGH4vhhSDnQSb1C9D06L8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610882; c=relaxed/simple;
	bh=/o3Pp9nSWnIecPFJuUudRIBng+qP+7CIUm/oxxIilUE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pGqQpckgL2YJqQiwFkAoCrsUeNr/2CSM4Jf/FUyx+nukgtRSKiA/vdZTab/HcAZwuEWmQ36U1wt7LKEiQfg4Uj4fwgiP+JmUULb1L44H/uusSmjgLMIplA6sDDPqniZ+ihZEaHiSq45gq2fZuehNR6P/gXS/LbZJFCP0X5tXQNk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dWPH94S0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dWPH94S0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE3EB1F00898;
	Mon, 28 Sep 2026 15:54:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610877;
	bh=1JVy/afSnIAmx7saxyZHXezrxYVWVulKVvX1R+ljPMY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dWPH94S0tr2ygP8UzcxEP360IaGjhG/PsW8GKEVNTMK9JgmeOnhfSKX36UA0RxMVr
	 QFaXr4HEaUbsVsJpeOAoASJksVTSvtf6x3eu8TFTwsIOdtvk/RmZ6m0qFYq5t0Q2db
	 SER82ESVHh0um5fRMrCRAnagD92MtqKjDuOAz3u+IBRYb6ILrDEna8jIcBGviD+atT
	 tO2oRuRz07FrU4votVJc0n9UiZUa578DcqjL8t6if1NU/shxg8zm0L4FWEGdTwb6ir
	 p4ep7fgleOuxp9a5yXo/9rE5pjQwT297fH4hV5B10phGQyduVg911wur0nahp/7p/h
	 2T33zaXlwenfw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] pNFS/flexfiles: don't read through MDS when previous layout forbid it
Date: Mon, 28 Sep 2026 11:54:29 -0400
Message-ID: <20260928155430.95985-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260928155430.95985-1-snitzer@kernel.org>
References: <20260928155430.95985-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ff_layout_pg_init_read() falls back to the MDS whenever
pnfs_update_layout() returns no segment and no error: a bulk
CB_LAYOUTRECALL (FSID, DEVICEID or ALL), LAYOUTGETs blocked behind a
layout being returned, or a LAYOUTGET refused with
NFS4ERR_LAYOUTUNAVAILABLE or NFS4ERR_TOOSMALL, which set the per-iomode
fail bit for PNFS_LAYOUTGET_RETRY_TIMEOUT.  That is the read-side twin
of the write path fixed by commit 1d62e659c0bf ("NFSv4/flexfiles:
honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write"), and it
is reached in exactly the situation that matters most: the file had a
valid layout, the layout had to go back, and the next one has not
arrived yet.

The write side could answer -EAGAIN because writeback owns the retry and
redirties the page.  A read has no such owner, so -EAGAIN here would
surface as an I/O error to the application.  Wait for a layout instead,
on the same terms the function already uses when the layout lookup
itself returns -EAGAIN: sleep a second and retry, bounded by
pg_maxretrans, which ff_layout_pg_init_read() sets only for soft and
softerr mounts.  A hard mount therefore waits, which is what a hard
mount is for, and matches what the FF_FLAGS_NO_IO_THRU_MDS check on the
data server selection a few lines above already does.  That includes
waiting out NFS4ERR_LAYOUTUNAVAILABLE: a file that was given a layout
with this flag must not be read off the MDS, whatever the server says
afterwards.

The test asks the inode (NFS_INO_NO_IO_THRU_MDS) rather than the layout
hdr, because in this path there is no segment, and the hdr that carried
the flag may already have been destroyed.  Where a segment is in hand -
the data server selection above, ff_layout_read_pagelist() - the
existing per-segment ff_layout_no_fallback_to_mds() test stays, since it
is the more precise question.

Fixes: 260074cd8413 ("pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS")
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 38 ++++++++++++++++++--------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7d45401ee5b11..84d22f715653d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1073,19 +1073,33 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	if (pgio->pg_error < 0) {
 		if (pgio->pg_error != -EAGAIN)
 			return;
-		/* Retry getting layout segment if lower layer returned -EAGAIN */
-		if (pgio->pg_maxretrans && req->wb_nio++ > pgio->pg_maxretrans) {
-			if (NFS_SERVER(pgio->pg_inode)->flags & NFS_MOUNT_SOFTERR)
-				pgio->pg_error = -ETIMEDOUT;
-			else
-				pgio->pg_error = -EIO;
-			return;
-		}
-		pgio->pg_error = 0;
-		/* Sleep for 1 second before retrying */
-		ssleep(1);
-		goto retry;
+		goto retry_nolseg;
 	}
+	/*
+	 * No segment, and no error to report either: pnfs_update_layout()
+	 * simply has nothing to give (NFS_LAYOUT_BULK_RECALL, a failed
+	 * pnfs_layout_io_test, blocked LAYOUTGETs, a layout being
+	 * returned).  If the server forbids reading this file through the
+	 * MDS there is no fallback to take, so wait for a layout on the
+	 * same terms as the -EAGAIN above.  The layout hdr that carried
+	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
+	 * this asks the inode and not the hdr.
+	 */
+	if (!nfs_no_io_thru_mds(pgio->pg_inode))
+		goto out_mds;
+retry_nolseg:
+	/* Retry getting layout segment if lower layer returned -EAGAIN */
+	if (pgio->pg_maxretrans && req->wb_nio++ > pgio->pg_maxretrans) {
+		if (NFS_SERVER(pgio->pg_inode)->flags & NFS_MOUNT_SOFTERR)
+			pgio->pg_error = -ETIMEDOUT;
+		else
+			pgio->pg_error = -EIO;
+		return;
+	}
+	pgio->pg_error = 0;
+	/* Sleep for 1 second before retrying */
+	ssleep(1);
+	goto retry;
 out_mds:
 	trace_pnfs_mds_fallback_pg_init_read(pgio->pg_inode,
 			0, NFS4_MAX_UINT64, IOMODE_READ,
-- 
2.44.0

