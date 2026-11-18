Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795027018;
	b=AJ7ine8jBddc44ZeR2CdYpTTBXFi111p9d16arcjYp6WaxD0Xzr8IzE9EFkerkAsRAUW
	 gkhhxOyrYd8iZCo04TBmVMc/uUa9B6j+J6zHy20Gf47s3NrTMRRO++dinP/4ousW8gS3e
	 3yrZ8TVEyqK383q5ipZ1w6PiHDvl7yjlxSRGJ/HnDQIMJxrZ+Qxh9zpwZAyFhpGnKzrMO
	 WosycNWFav9Y/MN2VbsiK/VTSGsm9F28K7bkWsBtlFIoxTBCYCki8W1JiAJeQx1JHbwuH
	 c95xR1JaxdCzpOfZ3ISs/NEaNn09o2m75SaCFqsw/k6isDKFeQiXijj6FCwdhodRtEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795027018;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=J/vURV5wWOTznt9bm2urzPjsi0DqR1BeSpyd3mTrssA=;
	b=R6hNQJ37nFzOBGM6BY4EK171rrECEOOzRkm09Rc3YjESJMlqx3yPfmP2DOfxmRW+4yk+
	 Lk13bDj0nrJyDziyalJA4Q4fIcfJptbLY8Myq5yHYC+cp2nGrmklNv+MUXr3DgYPcFciG
	 2W7s6ylbMr1/QTh5vNJdjY9Kl+RAz4ClynaLF4vI6EUjs/baW6eT/hnShVY/jehclqQ7b
	 ul3HpzdDCCFUNVXUT1SB81AaMHQWFpmlDE7EXc27CM50t25aCaTV7efyf2hN5jaJrPFtS
	 ZIG91vpoo35ISPSSCf5nA0dFj/VH/63k6nWtue1ILZ8J0PMaNvbC4RMGN8+xrwMxjNA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Vu84x6R2;
	arc=none smtp.remote-ip=209.85.161.47
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13979606A325
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 18:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 13979606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Vu84x6R2
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-6b1afdf5196so532091eaf.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 10:36:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795027017; x=1795631817; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=J/vURV5wWOTznt9bm2urzPjsi0DqR1BeSpyd3mTrssA=;
        b=Vu84x6R2JpML+VbrmlBvt7Q4I5FgWdiLfdYEVUPw0a/T1sGgs/va8gCWXiVOnoPGmn
         PUePxfy7+MLrxmjoQ4z69ThkMMRs8sC7KWc4rCWWO5HOPEJN0UkS/qo9NSQdK09uQEXC
         0BtecWKx+pyb87fTbu3qxrGPluI97KtPsMDNx4TY7Cz8rovqC1wFjJFCh830vvrjrWzc
         ZJMsXrZK9troqGg+gZkFDDcDW0AjJNpe5NVlV3vQvC3zqcbOorxBFyatTY/7RzrBaGuS
         dT/x8R7B4ZuH4chZf6FlIR5AYK/KpOiCQCeDAkkrMOPYlRXWJQ6Ha7/N8UcsKiSUU+HK
         nejw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795027017; x=1795631817;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=J/vURV5wWOTznt9bm2urzPjsi0DqR1BeSpyd3mTrssA=;
        b=cbsRBijqNy9wcrJxfcjXtmxhbNQCSjJRNOIHLO8IXj5/GqwsOMEkc3kcg6taB1/5L0
         jqiymaPOH3f68D9PXpyMDAK73uYRnMeCm03ftOCP8zBY18pOPEJXzJRqNlsXbYosaafF
         zM1/raEf9PjVOGDnF1pcMLiqGUxZYTeqPvbZAJnFcQeaOyb9GKDnCz9OCKMZUM7cpQsO
         owwIewvK+KqdspQBwgWSbUB9/MzxiziWszkzB/Cg1wuP7aniUX6OYE7YknU5HQGQfnqT
         TMoBy5PQ4BLYaqYUHcst5htLfzKLBDLA5jp2uulKI5paEiqLj9GTzGDdxYkWoVvLMyg2
         fYHg==
X-Gm-Message-State: APuU4Z+GZJlYCHu9eicwu08Ewr+/lD+4yUWpekMxYafjQyi9R0N7qprL
	HggF11qCPs7yov71/dCqN/7GPP8lKktjpWS7Q2SdOnX6URyYmXxjdx9vFb9we04y0kPizrItGE+
	YcLcc
X-Gm-Gg: AYBFou1CNHolUrQ0c0HpO82ywPjkaYKMZz1ceArKmctn+pdOvnjY05imtLZYYXQOz1P
	fltjh3YDwCeRSwHpHwfA0sNMmlxcaUntI3WUCLdZFyc7x9buUaUAD82QwR/hH/S4zmMnBO/rVuD
	Xe6einl/eoLRN9zODl5xybGSjrJ0aWtzspUmXpHFBH7cPrHFbLlHxCrqnYS6/3kNCP/UNl5fzW4
	O5MW9oZ/040+pls0Eo0HdtjW968K3XJMMW07sNiQEse8H/2zpEJs4vApCFnvkkJ8C3IB92857wO
	PX6IKsoEe8Zu44IF1Ogynzqnx6XRrwSDDq0r55AA7iWak8RD9P8w8u0gwE4fYTBnvcWorUA/Yw/
	sMculiyggCr+WsZrkDbuc4TxN03ww0+GeJvMW3g/dnIhoYMnye6XF6SNqpbF8SuPfAdKrx9do4C
	bReDNpRJRO+G1Ujsj7tZEp3edvDWSCjyajW+lXX/8RouHkfcovqwEBrElWzEhRJGrEIzcYjLGLh
	Ir3GN2+BDjKJo/CIulKb/g8x8niuDpyVZjPmFdmZ8lqg8l7Pxd9YfAKFMHMDfio+LC/Hr3GrdHk
	fA+3ihG7sjaIGQTewAR6UopvB1kABYrbx/T/ZdfeKxUDAExg7ynyKi71ptJ0NYI/9jN03j8RK4G
	Oiw==
X-Received: by 2002:a05:6808:16a4:b0:4d6:90d4:6bd with SMTP id 5614622812f47-57741d1f2e9mr3233653b6e.47.1795027016774;
        Wed, 18 Nov 2026 10:36:56 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5777a8a6af8sm2341713b6e.9.2026.11.18.10.36.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 10:36:56 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] pNFS/flexfiles: I/O without a layout under FF_FLAGS_NO_IO_THRU_MDS
Date: Wed, 18 Nov 2026 13:36:50 -0500
Message-ID: <cover.1795024981.git.bcodding@hammerspace.com>
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
nfs_writepages() would be waiting for that folio.  Patch 2 has the
remaining writes test the inode bit, and has nfs_writepages() and the
O_DIRECT reschedule path wait a second before resending a refused
write, after their folios and requests are unlocked.  Patch 3 removes
the header bit, which nothing tests after patch 2.  Patch 4 sends
reads, writes and the resend after a data server error through the MDS
while the fail bit for their iomode is set.

That last change is also the path for a data server the client can't
use, such as a version mismatch: the client reports the failure with
LAYOUTERROR or LAYOUTRETURN, and the server decides whether to answer
the next LAYOUTGET with NFS4ERR_LAYOUTUNAVAILABLE.  The missing-nfsv3
case is covered separately by Roberto's "NFSv4/flexfiles: couple back
with NFSv3".

These patches are independent of the series "pNFS: don't reply
NOMATCHING to a layout recall with I/O in flight", but both change
ff_layout_pg_get_mirror_count_write(), so whichever goes second will
need a small rebase.  The series is based on Anna's linux-next.

Tested against a reffs MDS and DS, injecting LAYOUTGET errors after a
file recall.  With NFS4ERR_LAYOUTUNAVAILABLE, reads and writes go through
the MDS at once.  With a retryable error (NFS4ERR_SERVERFAULT) held for
8 seconds, writeback sends one LAYOUTGET a second and no I/O to the MDS,
SIGKILL ends a writer blocked in fsync, and a soft mount with
io_maxretrans=3 returns EIO after about 4 seconds.  During the hold, a
read of a folio that another open context had dirtied flushes it
through the MDS and returns without EAGAIN.

Benjamin Coddington (4):
  pNFS/flexfiles: use the MDS for locked-folio writeback without a
    layout
  pNFS/flexfiles: pace writes that have no layout and can't use the MDS
  pNFS/flexfiles: remove the layout-header NO_IO_THRU_MDS bit
  pNFS/flexfiles: use the MDS when the server has no layout to give

 fs/nfs/direct.c                        |   2 +
 fs/nfs/flexfilelayout/flexfilelayout.c | 113 +++++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h |  16 ----
 fs/nfs/internal.h                      |  11 +--
 fs/nfs/nfs4trace.c                     |   1 +
 fs/nfs/nfs4trace.h                     |   1 +
 fs/nfs/pagelist.c                      |   2 +
 fs/nfs/pnfs.c                          |  22 +++++
 fs/nfs/pnfs.h                          |   1 +
 fs/nfs/write.c                         |  21 ++++-
 include/linux/nfs_page.h               |  10 +++
 11 files changed, 139 insertions(+), 61 deletions(-)

-- 
2.53.0

