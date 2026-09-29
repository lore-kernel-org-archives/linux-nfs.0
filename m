Received: from mail-qk2-f40.google.com (mail-qk2-f40.google.com [74.125.230.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3372D54A7C8
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703267; cv=none; b=rVAMF+kmHuX2nmAk4e6Tv3S8jFZXPN0DCshDiU7337QMwV0jaqmmlZHnJtLxyXOjpOsQRJ78GpBI7zEIpYrRnVe+npP9JihwGoMxVLI2yBjAeO30yy8IvV2tCgGGmZkcSQX8B00cQIdLCrjgTzxxmY33YiwuR6VTw6XIH8ugVog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703267; c=relaxed/simple;
	bh=bkpTD4V6Te/a2gRSUS1H/Em6wBdTTxIWPKjRWO2v1tI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tjark0r1gSNBFF7c7M2YMI6wvuboHFMGpk2axXJmVxtNOWXuMdU1rZgL662luHENuV/g5OHYGfH4shGdNQKd2vYx9qvRPwAlygk+8nqscgEr9W+SKEsA7MB6Yah9H+LTlpPUv8NAPh3tnjvLcsA6iyewlf3VNXXjk2bZLG7sAuQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=QsGA4ZBm; arc=none smtp.client-ip=74.125.230.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="QsGA4ZBm"
Received: by mail-qk2-f40.google.com with SMTP id d75a77b69052e-5332b967eb4so30297151cf.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703265; x=1791308065; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=jBqrktBq4+xPguXBP1OY7BZaCL2N1srBiRzRsianNDM=;
        b=QsGA4ZBmfYlnQRFxFq0fh4e6tHGtx/B0tkw3iHNFTncnvnKJDaqq27k/hGC60Leg7P
         YkSrZ5MmPjY7NY0/JM328IYi+MjK4xbzI/W1/GHDnR6cAROCETshe8cbqt/WpgKhmnoY
         gHX5MpDibqktpRldj6xiqJJzp8X40eJAMWI0xL2JfsmDkPdv9f1BTA7Sr/v76LaCbSPW
         NMBwST6JsuYhs5K3ESvu3QkdNJHR7daNLh28TBe6jcpstUlnRba9As8oatuqzK26k1zC
         NMIxe5yOaToWZa6o8vmJhTCvadUrJrNE7eDvVzj+3bXfIOXA5PWdEp2fS+A5PAkTV3G/
         iCVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703265; x=1791308065;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jBqrktBq4+xPguXBP1OY7BZaCL2N1srBiRzRsianNDM=;
        b=tScurmTy5/7YGvCzY5uxoptucXo/feAfqFyQsRYl6Efe1oEHK8WRVCAsehS3Znw8n9
         JYjDVvTVt+36HAFghZwF+k2L4kkffUMrlkWODTt8v+lXBSB7klYGMBFdRoS+Yf8qHkok
         KCLXwWiA1mD9mv0pQevxUgqIPGRlwNlRjOfG0mumUPTyxLQ9mqrbM6j3XafNll1mcGYr
         BNyRBXuEzmZJl2QQlRfd/1tlhB/8ej52ieTSIL589R/Wca/0V9WoDlB3nqWoleo6AuXa
         1EE0Qpj+QzLbtIOU7Hoss/QrPJcUSp/TLbUr/UJkkeSvK3IByfBft/DKVjUQV4VF2BPt
         VYhg==
X-Gm-Message-State: AFuF++min8CiZoErfVSg5n68VDcviwhy0WZ0CpM5mL2wouTAjwcHS8TN
	v4VEhJ79Iugm9B74zj9ZQQNt5+XW1vJzpRW6Nzkv9UUbQQbshueLkG8OVHO3lErjKoaos4rryy8
	Gp0mO
X-Gm-Gg: AYBFou0vuaaXhnDuUa6/CIQcFf91UtftF3aigV9LMqPNSiM6JbsyO/E7lvNs7QZiPwK
	drVkEho/5ura7LZ8yN4+N0arTJC5hCU1bn5At3X5u+hvXjWkIUvrGJizjAyNioEiyqzLWt+CZGF
	mT15v8oyZCpOFRCiKWe7DoZ7DWu+qzo9ptV0aRcAW3RD4C8rAyfDV5INDu+tTz7qeTAOaRbHAAm
	BqZV/sL7rPsk46MjlQE8gB+kMIy8oIMNB4f+9SOCrZ3iWLV2tKHubd26GwZW+lRglmSr5ww2iol
	4VFq3Z/OVD1pMZrDStbZ4l7oEFroaZuj+Uy+J6KMhyg/Bc/kWsk/d2ymiiiwxURIJzmgr36RTpd
	3ZSFq04KhMLWuyNw5fDkafXDZlfnOkBIGqeZZugx6bTpvFcLa4OleKIOHUJCjXWO6D5ry/ecOLa
	uiyGLbtbPH0Zu1n7LU+sBs5uCRmBgbZLqWXzqzALZjVuYQbMpC34yfD3bZQE3vmOcyZgM3BgF9N
	2GRGajyMWH/2mUlTCm7Xd05LhkLgT2J5ElZ6MsCQnk1JBh+jyud6h0Y26CViN7Flck+dHRE1g==
X-Received: by 2002:a05:622a:306:b0:533:438a:2aab with SMTP id d75a77b69052e-533438a2ee7mr141886211cf.4.1790703264737;
        Tue, 29 Sep 2026 10:34:24 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-53369af9260sm582531cf.8.2026.09.29.10.34.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:24 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/10] NFSD: keep direct-mode I/O out of the page cache and elide COMMITs
Date: Tue, 29 Sep 2026 13:34:13 -0400
Message-ID: <20260929173423.16149-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

This series builds on NFSD_IO_DIRECT.  When a READ or WRITE in a direct
mode cannot be direct I/O it now falls back to DONTCACHE rather than to
cached buffered I/O, a direct-mode WRITE can report the stability it
actually has so the client skips its COMMIT, and new tracepoints show
which path each request took.

Patch 1 interlocks io_cache_read and io_cache_write so READ and WRITE
are never left on opposite sides of the buffered/direct divide.

Patches 2-4 cover what cannot or should not be direct: the direct
middle of a split WRITE is also marked IOCB_DONTCACHE, for when XFS
falls back to buffered I/O (-ENOTBLK); a WRITE is split only when that
buys a worthwhile direct middle (direct_misaligned_num_pages, default
2); and a READ smaller than its alignment no longer costs a full
aligned device read.

Patch 5 is Chuck's "Enable return of an updated stable_how to NFS
clients", reworked onto the @iocb_flags argument nfsd_write() now takes
in nfsd-next.  The Reviewed-by tags from its first posting are dropped
because the argument changed.

Patch 6 adds io_cache_write modes 3 and 4, which issue direct I/O like
NFSD_IO_DIRECT and raise the reply's stable_how to at least DATA_SYNC
or FILE_SYNC.  On a pNFS flexfiles share where every write is split
across two data servers, the COMMITs alone cost NFSD_IO_DIRECT 31% more
server CPU and 42% more client CPU for the same bytes.

Patch 7 persists a synchronous direct-mode WRITE once, after all of its
segments, instead of up to three fsyncs per WRITE.

Patch 8 keeps the page that two misaligned WRITEs share in the page
cache until both have written it, so the second one no longer has to
read it back from disk: with 32 interleaved writers, 704 device reads
for 42895 WRITEs where there were 45144 for 45664.

Patch 9 (Jonathan) adds the direct_misaligned_dontcache debugfs knob,
default Y; set to N, the parts of a direct-mode WRITE that cannot be
direct use cached buffered I/O instead of DONTCACHE.

Patch 10 adds tracepoints for how each direct-mode READ and WRITE was
serviced, including why a WRITE was not direct.

Documentation/filesystems/nfs/nfsd-io-modes.rst is updated throughout.
The series applies to cel/nfsd-next (ac04dab23b5f) and each patch
builds cleanly with W=1.

All review appreciated, thanks.
Mike

Chuck Lever (1):
  NFSD: Enable return of an updated stable_how to NFS clients

Jonathan Flynn (1):
  NFSD: add direct_misaligned_dontcache debugfs knob

Mike Snitzer (8):
  NFSD: interlock the use of NFSD_IO_DIRECT for NFS READ and WRITE
  NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
  NFSD: only split a direct-mode WRITE for a worthwhile direct middle
  NFSD: do not use direct I/O for a READ smaller than its alignment
  NFSD: let a direct-mode WRITE raise stable_how and elide the client's COMMIT
  NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
  NFSD: keep boundary page of a split direct-mode WRITE until both writers complete
  NFSD: add tracing for how direct-mode READ and WRITE are serviced

 .../filesystems/nfs/nfsd-io-modes.rst         | 164 ++++++++-
 fs/nfsd/debugfs.c                             |  94 +++++-
 fs/nfsd/nfs3proc.c                            |  16 +-
 fs/nfsd/nfs4proc.c                            |  15 +-
 fs/nfsd/nfsd.h                                |   4 +
 fs/nfsd/nfsproc.c                             |   3 +-
 fs/nfsd/trace.h                               |  90 +++++
 fs/nfsd/vfs.c                                 | 318 +++++++++++++++---
 fs/nfsd/vfs.h                                 |  26 +-
 fs/nfsd/xdr3.h                                |   2 +-
 10 files changed, 665 insertions(+), 67 deletions(-)

-- 
2.52.0

