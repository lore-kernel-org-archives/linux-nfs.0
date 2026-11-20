Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191000;
	b=FdcxzrW4s6xhPPBf+WVELkhqCPVlFtvId7Jwt7BHqUAxNeOuewc++QXcknDsYOJJdEWr
	 28RpeQEuMd1Funf6rvc6e0f6ssPEgyrCmMpQ2kD8G2J/tRP7UQwF1kCBbWcQLbVNM1x7P
	 FKpRcPpJL0vVIdmX3KMYA9fhNwXMr2GuMUXDHc7CjXdqRQkXUcweaWngZH73nG4MYExoe
	 2EsYrdA4/TsDNI3pmMx3gzAyn/2sAMkZoRFMDioIoOoYVdOKRyUi6DQSmSizL4OthGB1v
	 Ov9e0A4xQMv22vBxYLtO0olBHdRoEih1b04LggXV81XK71dwcoiwE3WncE6CoK7Pn7w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191000;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=kYlcCsFrxQ96d4UApfYpFv8IgnjvdMtq2KOAExmlIz4=;
	b=qdHZmaSwgdTXqYKCmDjsHOrHvd1ElzY9ULi/nEMOCGrwfKPhe+B8AqxnEA8NHmIhw8Sx
	 STiVNBtslKLhjB7wCOScpdKtQTkgkxHjsxoWWYf9DVv2ILhafNSvuZm363G+N8guC0UlK
	 Hxh2ggniP+ngEUtVt+P7fZvT9Z1985jE8Q+gHVqKA3IKnRfnJXZtkdt6L39KZ1dOQdX5Q
	 mcbLiNLsE2v+6NOZeYRRPQixGoswvIV3+cIbC4/fuo35J/uf16DY0Qq4rpCYKgk31RxWh
	 X753fy+WqTdAXDzMXntiFUc+KfSupZb5W/z4mLiKf9Y5fp4JvRTiqSAiJ7ACo3IV7MA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=R0xzR3Fl;
	arc=none smtp.remote-ip=209.85.161.43
Received: from mail-oo1-f43.google.com (mail-oo1-f43.google.com [209.85.161.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20AE760A2600
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:09:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 20AE760A2600
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=R0xzR3Fl
Received: by mail-oo1-f43.google.com with SMTP id 006d021491bc7-71aed54d4c5so759869eaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:09:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795190999; x=1795795799; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=kYlcCsFrxQ96d4UApfYpFv8IgnjvdMtq2KOAExmlIz4=;
        b=R0xzR3FlQ7uumx821xP1guV4SSD8W8GDv0soWchFzOYgfu+vi5LCpUJAb0+i0ZNyv4
         dvbfFrLnxi/ugXLPXZS2k3BY+u2sdYIs+hpre4g/vji4sbpEsYoTL/xckS0MPC52H70z
         /dpoFDwxeYU604OsLpocBFCRGgTygMUBoA0S+6U3g8E+3dRXu1m70qVfRmsifeYZ6Pbe
         ggZnMAUyv8i5mRf30uPauHDg72O3y9gv/wHq8rMdkQemMRbax/k8bG2cPIMymfRg2cnM
         3p4IxhhU7Xjegqa7FOyEUmEq5iM8QOCROw5D0T97YjKAwszRZ51KXOZQpULCPQhd9Lb2
         lxKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795190999; x=1795795799;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kYlcCsFrxQ96d4UApfYpFv8IgnjvdMtq2KOAExmlIz4=;
        b=opoViGWq4W1Neu+OslAPkFhar4D+rqQmEBNq7KvngFyq2RXNLaU4hfPo1jPrbNsUet
         Y9REvnwTQKThlBKVmYdI/9JiTCndC9Y5thcLaYRbSkSEkbfSlap/AreripwfWbUWHYHy
         mtxid3Hkz9C5VzxdasYGvDuPoIyDqekmTNWPZnN6B0PxFzwmWodN3bwW7ohwRIJfOwF3
         pqzq6lKvOgMrV6kdTLu5xWvjyzJ13ue3DvbWwfpkmyYsjayuj/ToIbOyxIWSosK7ceWk
         LyU9kWMZU9At+0crkbK9K56z98aEvJ/HY34hwvyU29HpMvj1SRaP+o9qRbHij1wPEp0f
         Wprg==
X-Gm-Message-State: APuU4Z/SlXhzWih76Ey3vRj6UJ0/HYMDtYm1ZK0Tu4grLSpthCNKKcxl
	R6C0ebZWYJ7OJJNuM83XkmkkyKZlw5IgXu1GeRuypo0ucT5zVAwRAJKjKLreBps2nm0=
X-Gm-Gg: AYBFou1jWoVQoiYzAIikqQjezyWk5L62TPiL6r9G0iufsRHdpSON83V9UOt3S4sxrE8
	NNEvA6c6tA0++XBcTrCTmeIIGVKby8x0k9a2SYh90m73O2sRi7wcwNq1qg6HJqMrUaSWDPUvB39
	uX5bWDlij4JibwgewxQE6fI5m51OTl1NOpgpsEGGdTZtBvcEfbRZsZCtjGBQeysisvxabEuGI9B
	bJi9QceQM58uXd+fKaPopandp5vNMp30fY+K0+ScNjbg2yCc+3QEsOnNkb4Kn19t3pYIuUBQkuv
	Gg7+Vef3UWRGwevc8DkezSpKPJzBk/6CZ1qbONet9X74/5g5CaowpyQ+660oi2UTDdXvS3rcAy7
	qt0KXLV7ypXTPAgJClUu3tlNY8TrzrU9WljmBI1qRyf0mlppQ+1g9wfvYAD4Q8A4ENRlFkU3sEL
	CGI4sO6zVlZZTrd0WFa+R9+yAYUg7nRQ2ZJ4dw7A1cJcBWzfNblxUevt5oJ0q2Ir1JhzJRd1E+m
	m+zs8ktYYuTEsPVdcVOUVmm57RdzaS0V1SZgoMRU7ICSVa3z1HvRgPren+PBH0OUqQmVRNba0bq
	boRrbpfzBKShEqkEGGn10KUVJARVny1YyaqTHfRVX8G9K7+lBO3LE01d9Y7HrLeVWzzQD3AsRM4
	zNX3BHRtMFaZ9Fd4/tAC7sy0qTGN7U6EGdpjS69PfpH55608DuJVQ
X-Received: by 2002:a05:6820:570c:10b0:71a:df61:2f5 with SMTP id 006d021491bc7-71b395213bdmr1903229eaf.20.1795190998659;
        Fri, 20 Nov 2026 08:09:58 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.09.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:09:58 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] pNFS/flexfiles: I/O without a layout under FF_FLAGS_NO_IO_THRU_MDS
Date: Fri, 20 Nov 2026 11:09:51 -0500
Message-ID: <cover.1795122899.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
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

From: Benjamin Coddington <bcodding@hammerspace.com>

When a file's flexfiles layouts carry FF_FLAGS_NO_IO_THRU_MDS, the client
keeps reads and writes off the MDS when it has no layout segment for
them.  Reads and writes handle that differently:

 - Reads test the inode's NFS_INO_NO_IO_THRU_MDS bit, wait a second
   between attempts, and honour io_maxretrans on soft mounts.

 - Writes test a bit on the layout header and return -EAGAIN.
   nfs_writepages() and the O_DIRECT reschedule path resend at once, so
   writers spin for as long as there is no layout.  nfs_wb_folio()
   returns the -EAGAIN, so a read(2) or write(2) that has to flush a
   folio another open context dirtied fails with EAGAIN.  Once the
   header is freed the bit is gone and writes go through the MDS, and
   ff_layout_pg_init_write() sends them there whenever
   pnfs_generic_pg_check_layout() drops an invalidated segment.

Neither direction uses the MDS when the server has said there is no
layout to give.  After NFS4ERR_LAYOUTUNAVAILABLE, RFC 8435 says the I/O
is to go to the MDS (section 5.1.1), and the flag is a hint (section
5.1.2).  Instead, reads wait and writes spin until the 120 second fail
bit expires, then send a LAYOUTGET that can fail the same way.

Patch 1 sends writeback of a single locked folio (nfs_wb_folio(),
reclaim, migration) through the MDS instead of refusing it.  Resending
with the folio locked could deadlock against a bulk recall, which can't
complete while nfs_writepages() holds a layout segment, and
nfs_writepages() would be waiting for that folio.  Patch 2 makes the
O_DIRECT write work a delayed_work.  Patch 3 has the remaining writes
test the inode bit.  After the folios and requests of a refused pass
are unlocked, data-integrity nfs_writepages() waits a second before it
resends, and the O_DIRECT reschedule queues its next pass a second
later; other writeback leaves the folios dirty.  Patch 4 removes the
header bit, which nothing tests after patch 3.  Patch 5 sends reads,
writes and the resend after a data server error through the MDS while
the fail bit for their iomode is set.

That last change is also the path for a data server the client can't
use, such as a version mismatch: the client reports the failure with
LAYOUTERROR or LAYOUTRETURN, and the server decides whether to answer
the next LAYOUTGET with NFS4ERR_LAYOUTUNAVAILABLE.  The missing-nfsv3
case is covered separately by Roberto's "NFSv4/flexfiles: couple back
with NFSv3".

These patches are independent of the series "pNFS: don't reply
NOMATCHING to a layout recall with I/O in flight", but both change
ff_layout_pg_get_mirror_count_write(), so whichever goes second will
need a small rebase.

Tested against a reffs MDS and DS with a six-way mirrored layout,
injecting LAYOUTGET errors after a file recall.  With
NFS4ERR_LAYOUTUNAVAILABLE, reads and writes go through the MDS at once,
and the data written through the MDS is on every mirror.  With a
retryable error (NFS4ERR_SERVERFAULT) held for 6 to 8 seconds, fsync
and the O_DIRECT reschedule retry once a second with no I/O to the MDS,
SIGKILL ends a writer blocked in fsync or an O_DIRECT write,
sync_file_range(SYNC_FILE_RANGE_WRITE) returns 0, and a soft mount with
io_maxretrans=3 returns EIO after about 3 seconds.  During the hold, a
read of a folio that another open context had dirtied flushes it
through the MDS and returns without EAGAIN.

The series is based on v7.4-rc3 with three flexfiles fixes that were
posted separately for stable:

  pNFS/flexfiles: read the layout hdr under i_lock in pg_get_mirror_count_write
  https://lore.kernel.org/linux-nfs/23435d398481f51ce2680053cd3a151fe673f91c.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: don't delay or restart an rpc_task that LOCALIO never ran
  https://lore.kernel.org/linux-nfs/9c46fda0f2cd6d3843b198dac304b4722514b8e3.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: restart a write that the DS error handler retries
  https://lore.kernel.org/linux-nfs/8ee107c9d0c68b6d0ee7305605ff7edbe0ffa160.1795108832.git.bcodding@hammerspace.com/

Patch 3 replaces the header bit test that the first of these fixes.

Changes since v2:
https://lore.kernel.org/linux-nfs/cover.1795117974.git.bcodding@hammerspace.com/
 - Patch 3: on a soft mount, fail the refused write once the next pass
   would exceed io_maxretrans, instead of waiting a second for a pass
   that fails anyway.  The first O_DIRECT pass queues its reschedule a
   second later too, instead of at once (sashiko).

Changes since v1:
https://lore.kernel.org/linux-nfs/cover.1795024981.git.bcodding@hammerspace.com/
 - Rebased onto the three fixes above.
 - Patch 1: shorter pg_allow_mds comment; the nfs_wb_folio() comment
   says the refused folio was redirtied (Anna).
 - New patch 2, so that patch 3 no longer sleeps on nfsiod.
 - Patch 3 (was 2): only data-integrity nfs_writepages() waits, and a
   fatal signal ends the wait; other writeback returns 0 instead of
   waiting a second per folio.  The O_DIRECT reschedule requeues after a
   second instead of sleeping.  The tracepoints that read the layout
   header without an lseg are emitted under i_lock.

Benjamin Coddington (5):
  pNFS/flexfiles: use the MDS for locked-folio writeback without a
    layout
  NFS: make the O_DIRECT write work a delayed_work
  pNFS/flexfiles: pace writes that have no layout and can't use the MDS
  pNFS/flexfiles: remove the layout-header NO_IO_THRU_MDS bit
  pNFS/flexfiles: use the MDS when the server has no layout to give

 fs/nfs/direct.c                        |  13 ++-
 fs/nfs/flexfilelayout/flexfilelayout.c | 138 ++++++++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayout.h |  16 ---
 fs/nfs/internal.h                      |  14 +--
 fs/nfs/nfs4trace.c                     |   1 +
 fs/nfs/nfs4trace.h                     |   1 +
 fs/nfs/pagelist.c                      |   2 +
 fs/nfs/pnfs.c                          |  22 ++++
 fs/nfs/pnfs.h                          |   1 +
 fs/nfs/write.c                         |  31 +++++-
 include/linux/nfs_page.h               |   2 +
 11 files changed, 164 insertions(+), 77 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
prerequisite-patch-id: 71097d575f7ba74684462ab64b028ff8815dff63
prerequisite-patch-id: 5a73a1fb9d47a31d4ec337ec0264eadbcaa9fd4e
prerequisite-patch-id: 2663ab8e1949d6a11d957cc2784161bf2816cac2
-- 
2.53.0

