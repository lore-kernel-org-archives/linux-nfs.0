Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AA4A40FDB9
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 20:59:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785877198; cv=none; b=q+xF8ZuBTuOuvm1kyTq+SyeMSz3CWUeVcnDqAHevZ5bPG1ME8lIPYmR06ApSRMihQUHH2j77uJAQvZt+u7UKdkxD2oCmnNNQa7XlGu41K938IJTZqN8a8tAhYXPfjPZWUo1za8UdRRySFCaWxnnXxkP4qgBjEMdmYhyH2xE7YdM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785877198; c=relaxed/simple;
	bh=Lb2rh/ERJHko+3lUQ55KZ60vdpNyMaUMZlmFAuRsgMg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=lVWfWoVfsIK2g1Bh8X/Xi1CRjuDgYsPN1/idqu6Uij+VzrCq1e/dTQSq2n1kk/j6dSRs8+yKU0Qo0g4aeJp+clOxchpkEndAlfCY/k0Yn9Uw0g7gWu/7nvN72dSxttfwYZCFmGIA6KISbJKaVa7F4G5xXQX/T8izNTxoupKxNkc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nwCGaZdC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nwCGaZdC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5B46B1F000E9;
	Tue,  4 Aug 2026 20:59:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785877196;
	bh=coZF2kypGYY5PPSgxsMG6/cAb39it9x/2IHWFAc0Lr4=;
	h=From:To:Cc:Subject:Date;
	b=nwCGaZdCjW4wDz1m+Iww7J24wwFkny60vI57pHKHCJgzerJgbilsuhXTDNvnnzKRe
	 6ZFdAsxlvkT1RByqPTMY16AAVZw0uTkyRdMTUdwkwioeWs3/KPwIRvb2RtdDLl3Lby
	 Mlx9MrNxm49wLaV7vdyFTYpFU42Yz9cB5zUIiK/z0iUBSAjbcPUgX2+k15bgJ2OyKO
	 iiiRCp/7T694Cpk50Tf3WL5DOBE4dXhXPunmFzdZ3b3Ghr+Wmliro6ShnlRf5CZCag
	 RslfEFB+i/7QJg1TMJCIQ0Wfl85Nle8z6ie31VJbyFUjzdHM4MRCUDRexi0VAmpmkc
	 XxffQQbdgqzTQ==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 0/4] NFS: Add directory delegation support for CB_NOTIFY
Date: Tue,  4 Aug 2026 16:59:51 -0400
Message-ID: <20260804205955.625772-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

These patches add support for the CB_NOTIFY callback operation from NFS
servers. Editing directory order or placement in our caches isn't easy
or practical the way things are structured now. Instead, I use CB_NOTIFY
as an indication that the client needs to refresh its view of the
directory.

Thoughts?
Anna


Anna Schumaker (4):
  NFS: Add an outline for the CB_NOTIFY operation
  NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
  NFS: Add support for CB_NOTIFY4_ADD_ENTRY
  NFS: Add support for CB_NOTIFY4_RENAME_ENTRY

 fs/nfs/callback.h      |  51 ++++++++++++
 fs/nfs/callback_proc.c | 143 ++++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  | 172 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h       |   2 +
 fs/nfs/nfs4xdr.c       |  31 +++++++-
 include/linux/nfs4.h   |   6 ++
 6 files changed, 400 insertions(+), 5 deletions(-)

-- 
2.55.0

