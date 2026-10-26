Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793057273;
	b=OsscJYCW832fjN7PRqCX+vcBMblp/4EtuVyAbre64V5zmIqaPBPIvaEsplg5+acO3gfb
	 sTGxbVtGaGDnRJB7mBjGwMJS1OxxYGq8U1ubLZoNg8d4neXk2ZVHwVzE/EwP6eezFRLdy
	 W1+4dnQZ2jFp59BqYSDhgLXsN7p218Ta8KUno2QgzzOAZhUD0oQojUTkfucGeJBI1VjJz
	 VHafKrqxGHzyS316y4F0ebqtLcIU/bg/Ln+ILWKVam1ihdnogfMs8+PxW7T0GuDhYpjqu
	 IFOEAUNZwZIccToOuwoQ7xLF0G6cq1nvQYPcPWWQs1mMYzlAR+omyq0LvYCm6CbzbHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793057273;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=qTUbE4gUNOmuR+M/OTh3wI21D46ahF64ycqlKwwOWwA=;
	b=3REDeFK3vuM4gy8kVaBUW8pN0hLiy7eZvw6vJNWMH39mLIgEIWiggIVwy/72Ghq9wuxX
	 2w4Sh+Fzsp9IhmBUxS2XuhQEqZEPxc2kfaVq2lTdzChYDRos7AWjPwAYE7wzw4mCe60XS
	 ZogCb2kx6Xh8upVQf6cKbYOhMAjHxjxIwL4ENJN+xIFPFDzT4CKfC1by8ECfCwxEBx8Fx
	 oWzzQrowO6EtguMmlB6C9rB3ukhxnoJB+aWF3lerjA1E4+Wq6f7T/h1JrCab+VmtayP0k
	 ZTPQBIczGKIvcpHrEjjfVGaymsJBUhsdtGAkRM50F7Adw2RnGcmdT7IDk632EyRj6bA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=lW64BrJ6;
	arc=none smtp.remote-ip=209.85.210.43
Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 082A7606A31B
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:27:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 082A7606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=lW64BrJ6
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-854b6e2e41fso767520a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:27:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793057272; x=1793662072; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=qTUbE4gUNOmuR+M/OTh3wI21D46ahF64ycqlKwwOWwA=;
        b=lW64BrJ6VSygY1PD7mpm68rUToXMXgT/LthTubDk8cyTsz9xeuegWKmi61rK48zeS9
         Qq8XyNZXxXmC4wRYedSBSDglw40eBHmV4JU3+3hM9h/My7hUr/lOJaFuPcSOnWBe+jbU
         vFE9NBBYwC7BsrYSgJjvnXou6u3e/c+7mVJluoKAfJvTbWMaFSz3FZjhS+t4xBIY2C/8
         AbIT3CYCGKMlQyjVQI40Fl1QWQ4kr/S/VSOb2Nfl6h+ky1igLybwYf91F8yL4SmpJ0gG
         agP1r4HK48R0EPwyqLYTkdqw74bAFXdMscjaF7hF/r20rVMJBBKLmbpOpr8ycpI6xAuW
         Hxjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793057272; x=1793662072;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=qTUbE4gUNOmuR+M/OTh3wI21D46ahF64ycqlKwwOWwA=;
        b=IyJisqfywkkgygYkSXU5tiflcjyg4jdErnJLhajdzRPmINf49vvXhM9kbkWEzxmeAf
         S2aGkUHMheSj4zvfPjW7QMmNCprVUu4m9uiQtjPjmvLSybT460oXoay2CcSBoyMee6FI
         gkRsTilpwWCWY/VwUxbmzhHkOFLuAXFLfDTR5R1alkEGWvQka2KCZYGbeIAsztfC4zTf
         axs2g/7X4gKNiTtf+KNPRqeII3TbxBTMKyLIpDr5TfAcbRhrMC5t9dnqQtjv7FYEfvTR
         LHxBDlRFInS3KqOd+49wp9YIyqjvfuBMSCrAkCVhlDWgAOVGTrCUsOGfUlgS05OcGdJI
         wVOw==
X-Gm-Message-State: AFq9FYJ1zoymHB/Vu0Paw4GJ8JZmM7vFT2TB+yTrFq5ujQWtuO4kNc6b
	tlGag0It2+73QZd9XUjBeQfCTE2TmSsdLGERy/9ZnCdbtUd4PD1V5ocg094E0g2qn7E=
X-Gm-Gg: AYBFou1lpwu/zDcLkKD3R2i1YDjKh6LMYOjHgdVI+r4hoU8zGusEeR9aky/YoFOhay5
	2WbzpcQuMxoB2l/PpybFEP2bfsHPL/zvM70D6DvFQIpP3TpESvD4/fYHP6JbnE1sCjaugE9aJhM
	cZGDgwBKmzuRz2En2mMMTjzthTmm+hpXtYuXB3PgWvIugLyGvz+CrWpfjvMQqQI2GexioShBYef
	rZUY0deeXPpgWpOxi9UarpJ3H4mP19RKVJkRI/QEXDrvh5/m3rnUx2fiXkPZFZuah/QoW8gbXtR
	UwLL54eUeT4NkN1iyzIa0hfkKZe6HPkuVO7UjIDMfPZztrRb4H5fBYOB00/DIlJbypz6b4tQ+x8
	h9rhKtnrjJNxLeaeSxKO6/IUxf6jLo7HrmKPdi+KIS1I9lRKQ1GIibJaC8qysc8F8xF5AKzHdyh
	C+BGfqrIoWLyj0K+38uorLsbPzhDiWzHePgfP9vGJy5BbPsV+FdPA2HyFKpJ4yQixjc9H57EaTi
	HzSw3BkdpGzzooF0fq6sTQzWQ/DY4l5bNSqrU57kokfiD++0z9q8jHl20HjWZzDEeGA7WbMiocG
	OBhC0KXMX7rSf5PoqgkOw7XbNveJ+CvpJPc3wMuahxxRvJaH
X-Received: by 2002:a05:6830:43a8:b0:814:57a9:4243 with SMTP id 46e09a7af769-850feac96e2mr6086294a34.17.1793057271624;
        Mon, 26 Oct 2026 16:27:51 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-850fc002444sm9060774a34.23.2026.10.26.16.27.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:27:51 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v2 0/2] pnfs/blocklayout: report LAYOUTCOMMIT failures
Date: Mon, 26 Oct 2026 19:27:47 -0400
Message-ID: <cover.1792157092.git.bcodding@hammerspace.com>
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

Changes since v1:
- Patch 2: replace pnfs_generic_sync() with bl_sync() in the block
  layout driver (Christoph).
- Patch 2: check the raw wb_err value instead of a sample, so ->sync
  from inode revalidation no longer returns an older unseen writeback
  error from every stat() (sashiko).

v1: https://lore.kernel.org/linux-nfs/cover.1792097970.git.bcodding@hammerspace.com/
[1] https://lore.kernel.org/linux-nfs/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com/

Benjamin Coddington (2):
  pnfs/blocklayout: don't mark extents committed after a failed
    LAYOUTCOMMIT
  pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT

 fs/nfs/blocklayout/blocklayout.c | 20 +++++++++++++++++---
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/pnfs.c                    |  7 -------
 fs/nfs/pnfs.h                    |  1 -
 4 files changed, 28 insertions(+), 14 deletions(-)


base-commit: a90ee4305c4a5df72c11b31dacfdc76e00fcf78a
-- 
2.53.0

