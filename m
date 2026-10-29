Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793302466;
	b=hnvKpCyRicy7xFI/5qSV1fZHWccN+mV+PyKTsBHfRXO3IkA0/UiV4PpQM4d1Zt+c6PZp
	 HPmbDU6cYEkBlT5786iGSXddQczX6qnHeeNhMfRmXKebve+Mx+kMfTqIcgJ4ninHOBL5n
	 Xvgv8E3aDmNHINTvUFMByt41XwxJp+Qfva/uCTK0RQOsmFA0KGOMsz5yoofaLaQA4d8q5
	 pqtRjMw3WS5qzI/M1ju6JfxNDPPch80gsHaKLlY5MUjVWhAKK4gdSJa8WA597PT8HrOs4
	 E0kavaZ2GAsfPcBXZ3talV4/XH/rdTZ7sHkYbDLT8zqZNgDUOyM0Y0nz5IwB40ipnog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793302466;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=fauD8znFMTkVqjjqMFIvMqtJPnnOkXyJ+qThBkzKDAA=;
	b=MY8SDBqpJgpgdyv4iT95lhtKjytbeIpJMduCh3A+GbeIaZRkIVdqRmdchw5SaVge3IX7
	 4nrSkDLXkIEp8UtnQyIG1gD4wGdpDmUlQQB6PADScyvTVaivofyBpP6EdhqWpdhyDWa/j
	 YKqqQZhdO58KGo4s2vMgysN72S+gbsp0bfGxBMQ07V5rDmfyxKdj265h6a7cGp4szH1Tk
	 nyLRzN5IyqZelYiSkhuTjMgHpgDRQjgCo8ZCpeL4b2Oq6bTjEzIGhv/MQ6UoVDxacZrEA
	 7eGacK0LZsRELiU6kJVsV2udDqIb5n7Akk91E25LB6rmF5voGYffMo9QYezb1B4AAJw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=R7m2ygrs;
	arc=none smtp.remote-ip=209.85.210.44
Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D993606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 19:34:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9D993606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=R7m2ygrs
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-7f84a55e31aso22830a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:34:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793302464; x=1793907264; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=fauD8znFMTkVqjjqMFIvMqtJPnnOkXyJ+qThBkzKDAA=;
        b=R7m2ygrsv9dM75CLJ4RMKrAt202VDsJdEIT0XxuSvrzW6++p5cONSYlje/fZ5DI3hP
         9P1iUYy/pmCWUDn4fHL5Yi3KcrMxhJg0b6BsBzFBckuCbenuwZK6z00R+eKy169PE/Wh
         h0ys55mBpnrgi7asidGzK7Usaa0N65blQDuqLMdnFflQ4x6iwuAVMFZtAzTIdgJMks/D
         aKHvS+SsMhdeq7eS2DXyAi9qUo9iCxInWlt8azej7N9y6WBBmMJdOHa6wSc/r81n/GpB
         IhBPJSOweGYczr4V1rewKszPzGqxTkWbEfhNSFh6eGfzHyJuE44zskRCZnVvi/syIJlP
         vksw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793302464; x=1793907264;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fauD8znFMTkVqjjqMFIvMqtJPnnOkXyJ+qThBkzKDAA=;
        b=Ne/HhbmopSt5NrOM7OeS4kF00Iz+ps8ctjkJ6P1DIjQwEUBK8l1tLbjbQwLhRS8kmK
         IFeikocMii+HKDapEkLORz0pl3bBF3C2LLWNQExVLMzCMVeAauU5MptE6mA48Ss3yKj6
         qht7e0cnkZHCsc/JGz4f+r5oFool/OKINAYXNrhDFubCX3mN9ZKGLGisaOWyERFsUs4R
         B/HGpSz5ADW8OiKo4tsKg4cMLgOWESAJqiB88NtDHoKaBQuX7cEHqI0E1A918brPdq8Q
         mDfn9vMux+zDtMPkY7N1AlsZzGXGRgd2g5eiVu0+Mq6YUwvfyVbeJwRzmZnQsGiauRsU
         tpzA==
X-Gm-Message-State: AFq9FYKRbUvJoE4kKOJ5eWDDp8ryu+aRw/UpIc7+qm1qiDrXwujWNbEw
	EP4RXmTE9EJj5+BAqsfiVph26sqP0GoWKmYBE0NaShvUi1pFZP642sLl1+Zisam7m1BQWKGFR8X
	H/oe3
X-Gm-Gg: AYBFou2d9NjK3qKfX5PQGn9E7npRY/IBFbaXrwL1YDL5s0Qdhi9+J52pxU1HtzkhwWT
	ekLjkPVaG5mjhkiJvY2cP6za3M799+iJzLdccCm8i4RVp+Gr55yg5GK45xsV8N37dtHQm3k2Umr
	Og557Ej+8FwKoWodTjxIHiq8I35VmQAhPc5wnuI4Q8mXphZ6rsYcu84nC1JEFX/++/Snh4ZkJwE
	Hjq7YUd42+eNAT646D+WEzoKUSrhw4wXQqFTBummzghMH8wxlQ/FYS2rFhyw/+04hj1DmzX48GP
	jKvi5fOCp0myVvPZAzogE6uHRyvfucb1Tm3XohYRFXpT3eBSWFUGuFtPqKTtZ5jZwYOj6XUB0yU
	nv3wuXrFaWf9a4tJAcZ+8cl5OyI6m682CWOy3hwYnKW48pLW+5ClY3PfuJ98gAxhMOAtGQ9l4DL
	EjoxjCkvwBqDaSHoQRP1iiKuWfXZHaFTpTxMXr6+KaN8uwkksKpGx/1xWC5Bma6dmBmbTDTuDzY
	Pw4+rr8m3Is8DcRJVIcvzV7cuJ1uCnvtYQrv2UEKY2JMz7izY8lDTCnxpr8puX8oR9H/SQVfDXZ
	+mtdX6ENF5VGoSWZ+PSR1yKoW134A3aqwZjexSshX1KTI+NQO5lxtQOKH5LK9OvWbZYMANtsktW
	S
X-Received: by 2002:a05:6808:c40a:b0:53b:87e5:8c95 with SMTP id 5614622812f47-5640ddbe9e1mr163289b6e.37.1793302464361;
        Thu, 29 Oct 2026 12:34:24 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e37d046sm107380b6e.15.2026.10.29.12.34.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 12:34:23 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v3 0/2] pnfs/blocklayout: report LAYOUTCOMMIT failures
Date: Thu, 29 Oct 2026 15:34:19 -0400
Message-ID: <cover.1793302358.git.bcodding@hammerspace.com>
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
uncommitted, and has fsync() check for it after the LAYOUTCOMMIT.

Daejun tested the patch 2 approach on v2 in VMs, against an nfsd that
answers a LAYOUTCOMMIT with NFS4ERR_BADLAYOUT; I've only compile-tested
v3.

Changes since v2:
- Patch 1: add Reviewed-by tags.
- Patch 2: leave ->sync alone and check the file's writeback error in
  nfs_file_fsync() after pnfs_sync_inode(), so each fd reports the error
  once and stat() never returns it (Daejun).  This drops the bl_sync()
  move and the raw wb_err read, and Christoph's v2 Reviewed-by.

v2: https://lore.kernel.org/linux-nfs/cover.1792157092.git.bcodding@hammerspace.com/
v1: https://lore.kernel.org/linux-nfs/cover.1792097970.git.bcodding@hammerspace.com/
[1] https://lore.kernel.org/linux-nfs/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com/

Benjamin Coddington (2):
  pnfs/blocklayout: don't mark extents committed after a failed
    LAYOUTCOMMIT
  pnfs/blocklayout: report data lost to a failed LAYOUTCOMMIT

 fs/nfs/blocklayout/blocklayout.c |  3 ++-
 fs/nfs/blocklayout/extent_tree.c | 14 +++++++++++---
 fs/nfs/file.c                    |  3 +++
 3 files changed, 16 insertions(+), 4 deletions(-)


base-commit: a90ee4305c4a5df72c11b31dacfdc76e00fcf78a
-- 
2.53.0

