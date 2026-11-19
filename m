Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120052;
	b=O6VHbsPevr1PAu8JXNO1klIP7iYndjGNN5Z1tt77qvgwGn4bhfm1Er/+K1EM6a3qwQdy
	 8gg4v+UoJi+dV8MV8kDUKJaRjjNJ8GfztaeErKgvN9ZowBr265ISp0SJj1SBLmOAJX5+i
	 EIIZBqJJXA8YFQ0wdaGaQRWrp2RPluKinlOJQ+P8NrXxpoBAwFifI8F8Flgc7T3b8cWg3
	 N5pIWDZbhpo0pKMuc5TKjVPk9uGbA94aTynYHyzj0pplREduXaSuiLs15J9oc/eZcJo7c
	 nhC0jnhRf0tjXAfosE4tPrZf4esoUpCXEmpU7EeGxJ1p7osqlHnv1bVG6ot+ykNPC5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120052;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=q/5v9dmY+OyMSM6Rv0jMLzz6Ra47zbs6j4Fa+K2iRJo=;
	b=RUFwBuWtEI2EbKgpxOpEXvQTXj8NtkKSevX/kBcZcRDrVcpQeR+ll0+jTFdyjIQC1U+Q
	 VqnbRGIqE0atnKhDEpOovpuE80pYFO/p6e7Whno4zX3yKiyTGBOeZxnZhvmMjcYuhBGQO
	 EDBWcAewM9Cj82/OBdz78/yHGcsJ8Ov3cXSylV6/ULxyoy/jQKeoHvmVBibVybB5qd/8v
	 iNn3aWFZ+jFcZWZ4tMbI6iY017AWahXdsFB+i22U+VwoDB12AbBXLw6mfl2eIfcAB5JkE
	 NSmtM0dsFL2kJtNlvrCItY1j9FWhM9BAs0sYOZRknlpkqv6gxOiETSALv+GQGT4CL4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ppTzvs87;
	arc=none smtp.remote-ip=209.85.210.54
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com [209.85.210.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2247B606A324
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2247B606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ppTzvs87
Received: by mail-ot1-f54.google.com with SMTP id 46e09a7af769-862b9c2e78aso113071a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120051; x=1795724851; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=q/5v9dmY+OyMSM6Rv0jMLzz6Ra47zbs6j4Fa+K2iRJo=;
        b=ppTzvs87c02PT06evi0I8S21UoOCmNEahHAVjOmxUGlgwXEMibs0lLWSMOQZUx/fg4
         5OV5ubkh5cz+H8nIqSo20mS5sB5kxc6ebdPz8nO8wgnavpKLNpoYEHcOroQd7FAsD/H/
         6VIYah5bj8MNuRNdtu2+nezx6GdZqgvP9xD/BCXgyV+26xFtxMivlxI13QZ9KHwNkSgk
         FA/f1wdVgFqfmdQP5KlFRggV0/l4ao3AKPuA4BxBV/NPHTmJNPXWHtFui/qKJZ3aHOYD
         C/mpqJBPt3sHuvaXQYtLTeX6ZSJS226zCABq1JYwUbPp2xSp+XXZBUujgJtD7INH+Nwl
         p8LQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120051; x=1795724851;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=q/5v9dmY+OyMSM6Rv0jMLzz6Ra47zbs6j4Fa+K2iRJo=;
        b=EEwiUbJellO1RAawRgR1v4jhrjYdPBbKRNZ7Xi5+UQM4Nppk8IIvUpYGnqH+2InbRI
         z62M608F0GJAVh6n6IFTmizfYj8QtRwpejILR3ERs4fTfYu5/QkvdV8za0d1CaTcYeyN
         vjNu1NPIIn3L1BhDQuW6D1Rt8iD4thJvAbaSS7u6XDkXzPm/YEeBQoyYFn951wR/X5zh
         v7cJ/iZ/Sw9OUJZxdH1OJEsYZHlRMT1uAPHOZt9uPSZzBnj5r4/hcfd76boFTJbiJeTM
         OfoTpfZw/Hu7DdwgyP2I6SnhIc+raqoaXEI3mFAz6F6VOIzPLRva6JpAwn5fS8CRgdIU
         afMg==
X-Gm-Message-State: APuU4Z8+UweqT1U4/jtY82Ydx+11YZJ40cd/yuNgHCLoi1u3zPs4Ca1u
	NL9rd2pheb37mbWMlfxRk1uQQ56fFL50ksYnmRDRIIGBLxDSzYapNdEi3sED3qvWVspVd3RHqtU
	eTUAY
X-Gm-Gg: AYBFou3uU/FpVljmybFOsGDud9bKPU8C96+LgajLRPJP1+M7BEO1+jCUxW/UGGCPuVx
	gVpe6AyoXezHz0sK6A4KikYgYeV6tY3yj1n6I25xhnOmW4NatrT1NCyt7c9q157rFeVA4Jp72VL
	/OMGXOQXSKe8gZ9o+8zwHY+cO7I3Lo+fkgW1XH74Nzr6iWVO0qO2338tajXjemirEgWjDEvHNlU
	73CzkcqCcYbqRVAnKQsxNk8aS4tRaPcHLpq/ewMw+IMhMCzSpvR3x4JJkgdKyaPgQVOduCHARLv
	s9bADDQ6PAPLLScxU7F3QkxP2mfOkhymdApdTxjTJjw2yfclCH3xVZIXjRLXb92WRfGuXyYFxId
	bK+1BHYuaiymfd5XlR6RGN3yYpAQUDgdnOS1aTtZ34nVxUAyhEvXBtP1n3HXGESLtSdPWXkkQff
	e5rmQoXXNbuAeBcYkgfer9EEbM1aNl0bnkLU3lmpb4ceDuPjKvpyD+mVnoXPuO92tAk1QckBaXq
	/U8Y2hr7D50sdXKmN5rV2lGqM8b/MD0jHUVJRRFgnYjF1UbXMsqSLr7Vupzn+Q1UCEicXQghT+D
	916E358T0u9ntRn4KeDIFEqaL+yE8Q3fzHfd4ULkZN7ztGqTixwd07PG2D6HvVQ+5hv0aN+ubgd
	k
X-Received: by 2002:a05:6830:3e03:b0:862:af57:78e with SMTP id 46e09a7af769-863157ca302mr1327838a34.6.1795120050818;
        Thu, 19 Nov 2026 12:27:30 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:30 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] pNFS/flexfiles: I/O without a layout under FF_FLAGS_NO_IO_THRU_MDS
Date: Thu, 19 Nov 2026 15:27:23 -0500
Message-ID: <cover.1795117974.git.bcodding@hammerspace.com>
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

Patch 3 replaces the header bit test that the first of them fixes.
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
io_maxretrans=3 returns EIO after about 4 seconds.  During the hold, a
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

 fs/nfs/direct.c                        |  11 +-
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
 11 files changed, 162 insertions(+), 77 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
prerequisite-patch-id: 71097d575f7ba74684462ab64b028ff8815dff63
prerequisite-patch-id: 5a73a1fb9d47a31d4ec337ec0264eadbcaa9fd4e
prerequisite-patch-id: 2663ab8e1949d6a11d957cc2784161bf2816cac2
-- 
2.53.0

