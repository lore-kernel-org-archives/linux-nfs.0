Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87BED44390;
	Tue, 28 Nov 2023 21:58:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P/SJZnKp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D881DC433C8;
	Tue, 28 Nov 2023 21:58:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1701208709;
	bh=BZcsOnpseq2BxUhXsipGk+vTl+/VRCernHgeK+y2XZM=;
	h=Subject:From:To:Cc:Date:From;
	b=P/SJZnKpxUvNTmy6WwvPgDAbZ0i3l8SMjxwhr7Hl2IZTCrHHZUyQpO9bCO+YblB9s
	 w0RmqvnsEXuLTgcDmC30KRCnITiEWH1zH4ASZRLN3e0pw5MG4Bm/fBZZrX/bMpV+02
	 r9edrRh4ezyIvsNfIY1ad/03kmLBmfyG+J9akKZnecyTJOPGOPSc28IeO107pQLCvc
	 dHEM2ANKEHWejsUjLe4MGtasbvRee5XziiLAd8FGcRBfOoe+jNiyv5vmFkEpBtBCyr
	 2Lf237zPAb2cVW0Dp+0V8UeAY8I5X/RvxrxHCHDf30dfAYRstLdtFliyDTULBawKsA
	 bAJ+rXs2YI57A==
Subject: [PATCH 0/2] nfsd fixes for 6.6.y
From: Chuck Lever <cel@kernel.org>
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 28 Nov 2023 16:58:27 -0500
Message-ID: 
 <170120862772.1376.15036820033774301160.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

Backport of upstream fixes to NFSD's duplicate reply cache. These
have been hand-applied and tested with the same reproducer as was
used to create the upstream fixes.

---

Chuck Lever (2):
      NFSD: Fix "start of NFS reply" pointer passed to nfsd_cache_update()
      NFSD: Fix checksum mismatches in the duplicate reply cache


 fs/nfsd/cache.h    |  4 +--
 fs/nfsd/nfscache.c | 64 +++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfssvc.c   | 14 ++++++++--
 3 files changed, 57 insertions(+), 25 deletions(-)

--
Chuck Lever

