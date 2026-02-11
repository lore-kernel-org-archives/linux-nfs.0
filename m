Received: from mailout3.samsung.com (mailout3.samsung.com [203.254.224.33])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAE9F34DCFF
	for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2026 07:05:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.33
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770793545; cv=none; b=Qtxg95XymYjngBu2GsXhjKxZmbu2HfpcIERZDqkLKhhSEA89e0OcbhWvRRnd0UXkcxt6nehChLw5mfOYQNSh3rbYz6vmJe+xu16tfhZL1EsAxyPv8oufY2dxd31g1GHbp8w2RICLcgSp+0Hf2pZYa+ni52JEZ2/22z3pfg6puOg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770793545; c=relaxed/simple;
	bh=uVAKEwtU1G55Z4Bp2ldph7O3I7Ul3PgNncCHoMYMB+A=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version:Content-Type:
	 References; b=r9w53jt+WzksnhAzouAsJeaaUAUoe2vbbCKsjCK26Z/qCAslQP5iuBzuUqDSuvcDcG9SK+aLdinfJBK7T1zIZrak1hUxKVVvkKiTwAJM1nVCgKMX2J+AhFOD+Zt6zmZ8KmxiA152xTDd+6IhPfFsp+04AzZZvGOrLyNQ3lU+VRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=Z8MWF8cF; arc=none smtp.client-ip=203.254.224.33
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="Z8MWF8cF"
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20260211070536epoutp036df259acf41d711269bd0e8abda2bdf9~TH1bTDrxb2859428594epoutp03h
	for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2026 07:05:36 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout3.samsung.com 20260211070536epoutp036df259acf41d711269bd0e8abda2bdf9~TH1bTDrxb2859428594epoutp03h
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1770793536;
	bh=Sww2nmNF0f2l1AROtDDtiK9pmxid95q9qnlr0mGjEL8=;
	h=From:To:Cc:Subject:Date:References:From;
	b=Z8MWF8cFBdc+Lk5PdQvEI9KQUH4su6ltWppZLVMVlHWVpzEcNtF525FrcOkq2KLAV
	 ZnauzpyDNdgVbybNLl/eZQSsbQFOkLpOW3I+XZEdRwwVxLisQmLWX/2XhOrsIvxzBa
	 Ov3yoz01Qr5qYA9/nY4gYe+1MRS1uOT4Z9wSEiDU=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas5p2.samsung.com (KnoxPortal) with ESMTPS id
	20260211070535epcas5p284044f7b5912b7b17a0c0c72cdd9cbc9~TH1ai1tUF2597925979epcas5p2I;
	Wed, 11 Feb 2026 07:05:35 +0000 (GMT)
Received: from epcas5p2.samsung.com (unknown [182.195.38.86]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4f9qFp4J6Jz2SSKY; Wed, 11 Feb
	2026 07:05:34 +0000 (GMT)
Received: from epsmtip2.samsung.com (unknown [182.195.34.31]) by
	epcas5p3.samsung.com (KnoxPortal) with ESMTPA id
	20260211070533epcas5p32f50f317b20250bb61b1b5a0b3a2a5d9~TH1ZECz8e3259532595epcas5p3y;
	Wed, 11 Feb 2026 07:05:33 +0000 (GMT)
Received: from localhost.localdomain (unknown [107.99.41.245]) by
	epsmtip2.samsung.com (KnoxPortal) with ESMTPA id
	20260211070531epsmtip27bd9061c934eb98c7caa294df028332b~TH1Wa7Jqk0204902049epsmtip2F;
	Wed, 11 Feb 2026 07:05:30 +0000 (GMT)
From: Kundan Kumar <kundan.kumar@samsung.com>
To: jaegeuk@kernel.org, chao@kernel.org, agruenba@redhat.com,
	trondmy@kernel.org, anna@kernel.org, hch@lst.de, brauner@kernel.org,
	jack@suse.cz, viro@zeniv.linux.org.uk, djwong@kernel.org,
	pankaj.raghav@linux.dev
Cc: linux-f2fs-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	gfs2@lists.linux.dev, linux-nfs@vger.kernel.org, gost.dev@samsung.com,
	anuj20.g@samsung.com, vishak.g@samsung.com, joshi.k@samsung.com,
	mcgrof@kernel.org, Kundan Kumar <kundan.kumar@samsung.com>
Subject: [PATCH 0/4] Avoid filesystem references to writeback internals
Date: Wed, 11 Feb 2026 12:30:53 +0530
Message-Id: <20260211070057.22001-1-kundan.kumar@samsung.com>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CMS-MailID: 20260211070533epcas5p32f50f317b20250bb61b1b5a0b3a2a5d9
X-Msg-Generator: CA
Content-Type: text/plain; charset="utf-8"
CMS-TYPE: 105P
cpgsPolicy: CPGSC10-542,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20260211070533epcas5p32f50f317b20250bb61b1b5a0b3a2a5d9
References: <CGME20260211070533epcas5p32f50f317b20250bb61b1b5a0b3a2a5d9@epcas5p3.samsung.com>

The series introduces writeback helper APIs and converts f2fs, gfs2
and nfs to stop accessing writeback internals directly.

As suggested by Christoph [1], filesystem code that directly accesses
writeback internals is split out:
[1] https://lore.kernel.org/all/20251015072912.GA11294@lst.de/

No functional changes intended

Kundan Kumar (4):
  writeback: prep helpers for dirty-limit and writeback accounting
  f2fs: stop using writeback internals for dirty_exceeded checks
  gfs2: stop using writeback internals for dirty_exceeded check
  nfs: stop using writeback internals for WB_WRITEBACK accounting

 fs/f2fs/node.c              |  4 ++--
 fs/f2fs/segment.h           |  2 +-
 fs/gfs2/super.c             |  2 +-
 fs/nfs/internal.h           |  2 +-
 fs/nfs/write.c              |  4 ++--
 include/linux/backing-dev.h | 11 +++++++++++
 6 files changed, 18 insertions(+), 7 deletions(-)


base-commit: 05f7e89ab9731565d8a62e3b5d1ec206485eeb0b
-- 
2.25.1

