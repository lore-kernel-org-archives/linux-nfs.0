Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11A39420E89
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:36:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792150605; cv=none; b=j5poCqvZfY5Qfos2hDVfkdfso2YnLCgFg6BSeXKqcrULHAwAgkMGmH03OxOAv6n9pKWG33hIz1XPy6aA+Hq6tR5kSZfbAcfzHdO6dFb1QUtE3bkRAzfUSKVGcnj5WHXH1LvVItHItW2UmQFqFcyHUQPvzaOvSFiuhKPsmVLMK5s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792150605; c=relaxed/simple;
	bh=Vb6aD9bQFnPfXnHt878+up9ID9SoYdiZg7owkyeI0MA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DkDwkNEOpI/Dxwn7h+odDqHvxRn6JlmsnaG13tHHGyfAiijZER/ntJzdhEzXOgJkGXhvSWryac3CxsH4FWMNkyKDwf+2hAxXlkjSmVkAFjyevOLU+26uzH2r2roh7J0SQwvxDGPY24iz4ORu/YUG2LxEWre5TwlgIkcpVBol8BU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=BenPguDh; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BenPguDh"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-4f6dcc0e8ccso678468b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 04:36:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792150603; x=1792755403; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=AW6KD6Rk6VKOBIFb1iMfVb2L5qjK6OHR176SliwVSkI=;
        b=BenPguDhRSldBULGv1ygaUvQtj+LkstIFFMwDXOOXGPbLJ4mGIMwJmU/InmIOdvE2K
         yIkidQzBjUFfw/04yhBlbLTz3Pj5vq2+b0Y5D2rf9Y6J6WixhrqdcTu4/4E4RFESPHHn
         AP4IQ+f86BAvVuI35K89qarsJ2a2eZ6UHNwYc4UOOgljoosd3kAH8RDwkieZHMIOXb3B
         MFh0vaV47QZ6gknoGwzP/z84TDz2GOnudK+TK9FYyhCw39iBFUdOnxgt3mM+vv9x3+mr
         fRnX878VzC5/dCqYLWAu2bLrw6dOlOai3hi2pEWps04eXEXk2pwfSEE43eAXMTYVGDiJ
         VRUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792150603; x=1792755403;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AW6KD6Rk6VKOBIFb1iMfVb2L5qjK6OHR176SliwVSkI=;
        b=O9JnwJDu8kFI/VIROkoBU57NhrNomwFYUAFXcATzhwUWAxgatygMgTNb0TVBdBo7c2
         6AXYDLen1836+L+Ahxy7jpwk5iS7o8u7J95Kz7UnJfDhxd5LfpguXvRx+WCHU+zgq+xg
         eh9RnPzmEQAKkL55lAqDuiZzeAts0YL6cFUvHglirzpuUSrkmfYeHAeUmCk8tlyFTSaQ
         cZcytj8tFXtg9c1d0h3RTS0o2wNVO7aYAt/CAVFUxahUNm+WRosPRDFszJAY791RMPQQ
         Ugs6Aiq8FdWPde/ni6Sym5TQLjLwTrOMiRS+NSfWaZd3yktYJxyc0EY3QYEuWEoe+S2A
         oyKQ==
X-Gm-Message-State: AFq9FYLCPC2xlw30PSTHKiaQE/p9xaj9/ZNAvw2c2NcWMl2sAbC+BMFe
	dp/ZFk+pA9rmPOYhVrG09EF2BuUndS56tmMQtC7gyandRaNjGa9TNmKLKlBlWUCitpI=
X-Gm-Gg: AYBFou37AxzI+pOxjTBt2K5Jjl3AxPKkWN5E6fFg1dNDjbW1Xt1tv6mrOaRg7GZ/fyJ
	RG5etw4azxstqGQgrd6PcCmrJ1wJiltKsJ/Zf0ahHiQlMX/oqEY5+oEN5FA6Gugnpt3eKsIPGCW
	PLWmDxqNb8g7kNyW6gvAfOai13oX6PgQey/RmQ6BK8AEyFMvfoPs5kXKBe3Baf6SXfhMTmXL/kB
	+E80mT07YNhbxSMwLnLEWrisLc4c+5xHlj/PZtuoUFalY87mtfgTmHS0RJzzMQtNr+2pKtUVS/K
	1+FvPZFYG7wucOt1i6WOB7d0q9CzqNyyui70YeBGjIBORnAlHzW0xFbDiefWvKooMp2A2CnAQGR
	2yR91NNQa+ZiSTDQdikapi+z9ZXXuVQ1J071en5txiDQQt9+YsWoPuuvMgRg8JUhiChdzWJvo3d
	jEwh5IeqC0YrkAcFTGLSr7EtxngYIyNSW16csOJR75u1Oowf5YSNCROqI0Q4eZooO0DaxWNzqLO
	oOFQJS/KfyLJLlBhuTa13u2eowzlpBDGwdyql9Kvw==
X-Received: by 2002:a05:6808:690c:b0:4ec:1bf1:fa82 with SMTP id 5614622812f47-53702bea09fmr1808556b6e.46.1792150602427;
        Fri, 16 Oct 2026 04:36:42 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388f3eb6c1sm1269694b6e.15.2026.10.16.04.36.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 04:36:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH 0/2] pnfs/blocklayout: report LAYOUTCOMMIT failures
Date: Fri, 16 Oct 2026 07:36:37 -0400
Message-ID: <cover.1792097970.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

Data a block or SCSI layout client writes into unwritten extents becomes
file data only when a LAYOUTCOMMIT succeeds.  A server that has revoked
the layout answers NFS4ERR_BADLAYOUT, nfs4_layoutcommit_done() ignores
it, and fsync() and close() return 0 for data that reads back as
zeroes.  nfsd reaches this through its recall failure path today, and
the layout recall series [1] makes it more likely.

Patch 1 keeps the extents uncommitted when the LAYOUTCOMMIT fails before
its result is decoded.  Patch 2 records a writeback error when extents go
uncommitted and returns it from the block/SCSI ->sync.  The files and
flexfiles layouts are unchanged.

NB: these are compile-tested only; I don't have a setup handy that can
revoke the layout..

[1] https://lore.kernel.org/linux-nfs/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com/

Benjamin Coddington (2):
  pnfs/blocklayout: don't mark extents committed after a failed
    LAYOUTCOMMIT
  pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT

 fs/nfs/blocklayout/blocklayout.c |  3 ++-
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/pnfs.c                    |  8 +++++++-
 3 files changed, 20 insertions(+), 5 deletions(-)


base-commit: a90ee4305c4a5df72c11b31dacfdc76e00fcf78a
-- 
2.53.0

