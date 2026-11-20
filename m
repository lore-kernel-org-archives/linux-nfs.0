Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191066;
	b=MsAF948mk3IaNehAbclIGQkW1d0VOp0gPjBSkxGEUiKU08lwgxp2wUUK3vhIVxHh5726
	 KlL+I3yxRuflSYKiMGUuMVyfdgN9qDZGpci9IV6GH5h3elHWQL1qp8fggd4rmENw4WOYG
	 F8gerHIXlh+W+JTMRcSpY2DCWOv5DYXWDg3m8T+j3JEptcnesUjq618lv28F8nYouEEkP
	 dkgpcVTJXff+sVTiaLCzortv1uX42h50M1VG+d1vxGeNCPAwTdK/c6I4QJNrfpTvJacZi
	 TDNwLxkbBEMb8OFj7Kuw6tMZkJOvoz1ZdrxV/SF7mKSOS4Fx78FDyBHtnQm7CRlUQBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191066;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=ELC6uXE0V4ef9Lk4P1eqHpXew1sE+uHoF6dr1ed1Qp0=;
	b=ayoLiqRIVSss4YDPqBmhFncMr/sxDsCEQNbIlI92xbMSFEHPyV5XxKPuwDQ/AOO4nY42
	 1cp9vollxI9aR7N9wt+sSgrhGqlHbXjh/95MFxKG/twExBZFKezDrFZoIRyVnbPbEalcT
	 m4opwAEjvrDNhHzbjrWQt4MzAD6xCdk665KLZZP0ufmI3UCNdI+To4v2OURT5fWLR4eHw
	 9JLlftVQ3hZBN5lwpxUQ+cs8HVU2/C6TdNhc61LlMXb/5vyRnF0NqOHbDWfFGij02U2yB
	 Ycz5hyuYQeoPN/JPrXJ95GwZIL/pvzdE3KOxaax5/doMaiSWFhQt1H4QcoAZwib3T1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="ds/+u10I";
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95669606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:11:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 95669606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ds/+u10I
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-862b76e3c8cso482957a34.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:11:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191064; x=1795795864; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ELC6uXE0V4ef9Lk4P1eqHpXew1sE+uHoF6dr1ed1Qp0=;
        b=ds/+u10IjRDSWWYs/kMufl0ycklXRmfyhU/behDF3p+daup+3EM/5XgVFmNFDH+ypd
         KzLjrnxeOLw8cIqlAWl3+PW25f4Wq1+ZflrTs88rloqHAtR9RXTCVdBNLKoBUpoITAIq
         ox1GBV0gLoz5u5kdW95IvL1hMFa5L5wlKt8hD+1V1KI8x1KiS75tE8RXX9Pyy2RkAd7r
         zauC8YCpoeBsSe9yPLvGuCQDqMsnI5ORdw9gSBRrQr7v3oVheidi0+EOUFb//D3ppcO0
         mkl6qDCOJG4HPpwjVLOklnWeyatpX/pqKXyH4qc8jStcH9zJsi2YRi54iwzpMr52blu+
         6U+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191064; x=1795795864;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ELC6uXE0V4ef9Lk4P1eqHpXew1sE+uHoF6dr1ed1Qp0=;
        b=PhFN93BDsH/Iuy31avizczFXBpsf3AhIgOjIgjz4KpFbSJcGw0SODHxYuSIDZqGVPP
         HumXcQKx6oh2E4/3Yhl7YBy+fVTeAtnwz+1A+1oxY5ROX5OSnP55yfXNsc+6oAy3Uppt
         ta90nD9uXpzE0ereouhOy2nMSRSVURz/SNqO9PDyXVSuEZRFdig/8KTdaGUiBa31p98C
         PRFoucl6i69WZ/Yp7yclQ6tXArFl2lb5wD4Al/HlUgSJlTE61mXbCjw4Gw25woZiZhlG
         I+1/dyf9sVf03dgK+vCb9+Lt839+rGJNaS52qMcEHlHYMqQLoYPPEdU8VKBF4J2K0Zr5
         hTbA==
X-Gm-Message-State: APuU4Z8VodF2Tln5TgRqexQY60AQ6+ir5AHyV8ZFD4jlFF1zDWh16PBN
	wf5UeSpeptB1hBviSOib30V5+INwdOUfvaAVOGOFnh4pOf74YTgfxcLSgIG1wRIvGDItdRMLHtZ
	8UHg1
X-Gm-Gg: AYBFou3o9BYZCepw4ZLrs8bj6+qZGPjGsK2GvOTTo4tzoitxJ0x7LhIr/pS7Qwn9pwH
	7T4pOuVMLtyzXBs2vs9ZuYbB+I/i47tFlGqpFuzOiKhlsw/durVUMdBAvbeoLKtu6FPdOisiPdO
	fUiJv7/5auejjbt5KnaYZwUhTlDXUkmPs2s3MbUiwfo2KtqBwz5Ciz1P0l+/LtL9gDz+b1gLbNO
	pEWeVUdFxZlAqJUsWo9XTe+HDQTLhKOrPseHEyH/E4H5brNj1dqIPyFXdIL9ajEFSh36ksd4RHA
	eg1Ma9aaF0CbRxjFt8XLPHV77Y9b90dV8f7r86HC+djOXbSVfDgYbr1VaFjuNvHSRzbD4Wbq7sF
	ODbCQb94c4/7xvg5QrA/tmudpa9vIuXDcnHn9cwUnv8bt/R/8xKEXVgtBYMcj5l/BuZ039BKHtx
	IMAqfbK54ukGNwuxj1ANJLRVcuMitbtoAHkrUvW0bp/NS6w77iYtIrvBnxezkQoyqlUB/6yUySS
	xrIMPoFcsDGS9yQZG3HJBVfQYyJoGzdF1v3R7eBLMrhySvD5OUVsLdr4h8sYTSGFa5fLxdCP/oR
	AcCg/EtSqHajS+sKbRzldAOzXqgyGqhsHunAG70BAWV5KQJZlmRkDjK+UcCIj46lvRmMsYI4nXH
	Ta6RCtPU5Nk1pHgSgpuxl989i6mJNkF4=
X-Received: by 2002:a05:6830:314e:b0:81c:ebf4:9ff8 with SMTP id 46e09a7af769-8631596517dmr4768913a34.30.1795191064252;
        Fri, 20 Nov 2026 08:11:04 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631690fd36sm2441034a34.20.2026.11.20.08.10.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:11:03 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] pNFS/flexfiles: mirrored writes that fall back to the MDS
Date: Fri, 20 Nov 2026 11:10:46 -0500
Message-ID: <cover.1795148523.git.bcodding@hammerspace.com>
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

ff_layout_pg_init_write() can fall back to the MDS from a pg_init in the
middle of a mirrored descriptor: when pnfs_generic_pg_check_layout() drops
the layout segment, or when a mirror's DS can't be prepared.  pg_init runs
for each mirror whenever that mirror's list is empty, so by then the other
mirrors can already hold requests.  nfs_pageio_reset_write_mds() replaces
pg_ops with nfs_pgio_rw_ops before it completes the descriptor, and
nfs_pgio_rw_ops has no pg_get_mirror, so the completion sees only mirror 0.
The requests on the other mirrors are never sent or cleaned up, the mirror
array they are linked on is freed, and their folios never leave writeback:
the next fsync hangs in folio_wait_writeback().  nfs_do_recoalesce() and
pnfs_write_through_mds() also write to the freed array.

Patch 4 keeps a mirrored descriptor that still holds requests off the MDS:
pg_init returns -EAGAIN, as it does for a mirror count change, and error
cleanup redirties or requeues the requests with the flexfiles ops still in
place.  The next pg_init starts from an empty descriptor and can switch
safely.  When a mirror's DS fails in ff_layout_write_pagelist(), it no
longer returns PNFS_NOT_ATTEMPTED for a mirrored layout.  Instead it
returns the layout with the failing device and retries with a new one,
as RFC 8435 section 7 asks and as FF_FLAGS_NO_IO_THRU_MDS already does;
section 8.2.3 leaves it to the server to decide, in that layout, whether
the errant mirror stays.  The write goes to the MDS only if the server
has no layout to give, or the DS can't be prepared again.

Patches 1 to 3 fix the generic code that path goes through.  O_DIRECT
error cleanup releases -EAGAIN requests without writing them, so an
O_DIRECT write would report success with some mirrors left holding the
old data; patch 1 requeues them for the reschedule instead.  Patch 2 makes
nfs_do_recoalesce() look its mirror up again after pg_init, and stops
nfs_pageio_complete() from sending the next mirror after a failed pg_init
released the layout segment.  Patch 3 sends every mirror when one of them
can take no more, so the mirrors stay in step and the pg_init for the
next request, for example past the end of a layout segment, finds the
descriptor empty.

Sashiko found the bug while reviewing the FF_FLAGS_NO_IO_THRU_MDS series:
https://lore.kernel.org/linux-nfs/cover.1795024981.git.bcodding@hammerspace.com/
These patches don't depend on that series, and the two apply in either
order.

Tested against a reffs MDS and DS with a six-way mirrored layout, on a
KASAN kernel, with client fault injection that fails a mirror's pg_init
while other mirrors hold requests, fails the pg_init that a retry runs
during completion, fails a mirror's DS setup in write_pagelist, and ends
the layout segment partway through a write.  Without the series, fsync
hangs in folio_wait_writeback() and KASAN reports use-after-free in
nfs_do_recoalesce() and pnfs_write_through_mds().  Without patch 1, an
O_DIRECT write returns success while five of the six mirrors keep the old
data.  With v1 of the series, a write that crosses the end of a layout
segment loops in writeback.  With this version, buffered and O_DIRECT
writes complete, a DS failure in write_pagelist is followed by a
LAYOUTRETURN and a new LAYOUTGET instead of an MDS write, the data is on
all six mirrors, and KASAN reports nothing.

The series is based on v7.4-rc3 with three flexfiles fixes that were
posted separately for stable, and also applies to v7.4-rc3 alone:

  pNFS/flexfiles: read the layout hdr under i_lock in pg_get_mirror_count_write
  https://lore.kernel.org/linux-nfs/23435d398481f51ce2680053cd3a151fe673f91c.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: don't delay or restart an rpc_task that LOCALIO never ran
  https://lore.kernel.org/linux-nfs/9c46fda0f2cd6d3843b198dac304b4722514b8e3.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: restart a write that the DS error handler retries
  https://lore.kernel.org/linux-nfs/8ee107c9d0c68b6d0ee7305605ff7edbe0ffa160.1795108832.git.bcodding@hammerspace.com/

Changes since v1:
https://lore.kernel.org/linux-nfs/cover.1795136323.git.bcodding@hammerspace.com/
 - New patch 3: send every mirror when one of them can take no more.
   With v1, a write crossing the end of a layout segment, where the next
   range has no layout, looped: the busy check redirtied the previous
   request every pass (sashiko).
 - Patch 4 (was 3): a DS failure in write_pagelist returns the layout and
   retries with a new one instead of marking the deviceid unavailable and
   falling back to the MDS; pg_init no longer checks for an unavailable
   DS.  The mark affected every file on the client, and a marked device
   made each new descriptor fail its first request until the mark expired
   (sashiko).  A fatal error from preparing the DS retries without
   returning the layout.
 - Patch 2: Fixes tag 862f35c94730, which made the free reachable, instead
   of 03d5eb65b538.
 - Patch 1: the changelog lists the other -EAGAIN cleanups that now
   requeue.

Benjamin Coddington (4):
  NFS: resend O_DIRECT write requests that error cleanup gets with
    -EAGAIN
  NFS: don't use a mirror after pg_init can free it
  NFS: send every mirror when one of them can take no more
  pNFS/flexfiles: don't switch a busy mirrored write descriptor to the
    MDS

 fs/nfs/direct.c                        | 48 +++++++++++++++----------
 fs/nfs/flexfilelayout/flexfilelayout.c | 39 +++++++++++++++++---
 fs/nfs/pagelist.c                      | 49 +++++++++++++++++++++++---
 fs/nfs/read.c                          |  3 +-
 fs/nfs/write.c                         |  5 +--
 include/linux/nfs_xdr.h                |  3 +-
 6 files changed, 115 insertions(+), 32 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
prerequisite-patch-id: 71097d575f7ba74684462ab64b028ff8815dff63
prerequisite-patch-id: 5a73a1fb9d47a31d4ec337ec0264eadbcaa9fd4e
prerequisite-patch-id: 2663ab8e1949d6a11d957cc2784161bf2816cac2
-- 
2.53.0

