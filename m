Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A1AC4E0202
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 15:54:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790610873; cv=none; b=SePgkcxGEmU3cgJGoeG++LNAUJMbXYoDEoOuETWEP5M3/i2iKxSP1iKw+UTlGhBL/fLN5WEI0MCenLRBh1zEtorosiWcudP7+2FXK5CIIXZa+KCY69jvOrpLlw2hwIEIeEv4ctlSM+DMx3p1plXbncy7EPcrNafy4CelrvMGCQE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790610873; c=relaxed/simple;
	bh=GD39rD1Zm5VwCGRBkTgaxbqo0z9lqPBXpZnUpjAGF9s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BOCs1rsA0b0vjmfYgMeJHPio2NAPt4Og40USWwEFUUJvgEbXl8CDAypGr5m1dpElqfV6E80d3vIj84LagvDbzWPshn5qlMyxQzbkfprikQAeLcLJggC8KEazzB4sws08Jv9VD6xTTr3MtJDIeC/85XWlqmIRdyy/U2RExCid1DA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aAacAuo0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aAacAuo0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7828E1F000FF;
	Mon, 28 Sep 2026 15:54:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790610871;
	bh=//fgc273iFP5fHb+LqodTODPVnBDsMzjq7io7KNG8EE=;
	h=From:To:Cc:Subject:Date;
	b=aAacAuo0zznOq+ZestcnJh2bWZtsKPxy56kDdGA1TgCSXzpF7N6DX+FwxlWRh76lG
	 gBSP7PdFM0vQsZGn3Yl69rE+Sv2vu0nX/QYlXIUd+Q8MfVuixUeoB1e2ttGOgYhxrr
	 z5R2S4q82APxIZH2u75JiDYfj/HysTbpDnFqOjTVN/o6SzzaZALBf201jo6NUxt2kF
	 ew7gaZ23gzBaQ8N0l5ZzzbjMkEyDziI7Cm778rODoLGJt82mQYYDYDNptFbY6c2LIX
	 6VvEGCwul6eDFc8jGhS/+ploSRRAxM7i97rE8bfnYlAGotjVnnu4bFk+wYaSoIiNkd
	 WsxFwAQRTllxw==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] NFS: LOCALIO fixes and FF_FLAGS_NO_IO_THRU_MDS fixes
Date: Mon, 28 Sep 2026 11:54:24 -0400
Message-ID: <20260928155430.95985-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

The first LOCALIO tracing fix is pretty old, just reposting it.  The
other 2 LOCALIO fixes fell out as a side-effect of other NFSD/LOCALIO
work I was doing.

The FF_FLAGS_NO_IO_THRU_MDS fixes focus on the cases where a previous
layout set FF_FLAGS_NO_IO_THRU_MDS but that layout was returned and
there was no recourse unless that context to prefer not issuing IO
back to the MDS is saved in-core and consulted if/when no layout
available.

All review appreciated, thanks.
Mike

Mike Snitzer (6):
  NFS/localio: fix nfs_local_dio_misaligned tracepoint
  NFS/localio: detect a short read or write before the iterator has moved
  NFS/localio: report the stability a DIO WRITE actually has
  pNFS/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS over the mdsthreshold hint
  pNFS/flexfiles: don't read through MDS when previous layout forbid it
  pNFS/flexfiles: don't reset to MDS for v4 error when previous layout forbid it

 fs/nfs/flexfilelayout/flexfilelayout.c | 60 ++++++++++++++++++++------
 fs/nfs/internal.h                      | 29 +++++++++++++
 fs/nfs/localio.c                       | 31 ++++++++++---
 fs/nfs/nfstrace.h                      |  5 ++-
 fs/nfs/pnfs.c                          | 12 +++++-
 5 files changed, 115 insertions(+), 22 deletions(-)

-- 
2.44.0

