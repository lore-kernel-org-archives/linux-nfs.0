Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B67CEC8EB;
	Mon,  2 Mar 2026 14:11:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772460691; cv=none; b=AgflpCCKsNfyLis3EwAuYOGHc5i6mAOIQshEVnCDWGzExAFUzMyZn3XXQkHTJFRl3oBDoltjr5JAc6rf28kgxpWoa/938QZqvc1FutZwoTcROlJfuGpyv+jexA7gIlSvw87+Ws3TZl8w3M49Dj0ACnGAA+mixaKH/PgIi9O1oEU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772460691; c=relaxed/simple;
	bh=MDftjcC1mSgCSd2IuUj1q3+4aSGvqwrNZNcMgNWygWs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pNpiEohY9/3WqladBOzbriik6CjewL7AeMniDVaMtgos5WkWgtNXgEYOfQeE0AbJe88j7/dhfcK4AjMI4jKEI1giwkK6K9RnQj3j+o6C5kVslIfs46s1RrZaM6sARYZlOe0jmAZEAoT5YSoJMttoOlOa8mRVMkgvUaNcrLSMJpI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mI1Z5QaF; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mI1Z5QaF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 064DAC19423;
	Mon,  2 Mar 2026 14:11:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772460691;
	bh=MDftjcC1mSgCSd2IuUj1q3+4aSGvqwrNZNcMgNWygWs=;
	h=From:To:Cc:Subject:Date:From;
	b=mI1Z5QaFAyKNDFwSibI6KgA/4Rj3xuss0tq8TUZ4iFLeHer9W8RMVH4Xg1evu8O8S
	 umMZ2bj5B6QLQ7wLYW6mJWRDeoeAtmdMs7HGGnVVEhyzdiOdawE8dYcIKmRTFszUN5
	 yiv12h2KPIF1qxw3sauIISxtJQWj7uVBIwGyY+Et/U39ZAR897BWDN5HwRyB4xmHth
	 SZwh8tLyn781HgbED1/LnUTTdhmpxVOadZRBFWa/cB+RcCYNT1TnI/PAnAo1FVIk2y
	 5SSU75H1h8gZpGhMOeL0G9KdYPrGy49r6Q4FsfZJYdTprtr9kthZH1w/riM9RmEtMj
	 ozDyLH+6lswcQ==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [GIT PULL] First round of NFSD fixes for v7.0
Date: Mon,  2 Mar 2026 09:11:29 -0500
Message-ID: <20260302141130.9098-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit e939bd675634fd52d559b90e2cf58333e16afea8:

  NFSD: Add POSIX ACL file attributes to SUPPATTR bitmasks (2026-01-29 09:48:33 -0500)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.0-1

for you to fetch changes up to 364410170ab33f6e7ef0eb2afb12bf89b0feb3a6:

  nfsd: report the requested maximum number of threads instead of number running (2026-02-24 10:27:51 -0500)

----------------------------------------------------------------
nfsd-7.0 fixes:

NFSD fixes that arrived too late for the 7.0 merge window.

Fixes for commits merged in 7.0:
- Restore previous nfsd thread count reporting behavior

Issues that need expedient stable backports:
- Fix credential reference leaks in the NFSD netlink admin protocol

----------------------------------------------------------------
Jeff Layton (1):
      nfsd: report the requested maximum number of threads instead of number running

Kuniyuki Iwashima (2):
      nfsd: Fix cred ref leak in nfsd_nl_threads_set_doit().
      nfsd: Fix cred ref leak in nfsd_nl_listener_set_doit().

 Documentation/netlink/specs/nfsd.yaml |  4 ++--
 fs/nfsd/nfsctl.c                      | 22 +++++++++++-----------
 fs/nfsd/nfssvc.c                      |  7 ++++---
 3 files changed, 17 insertions(+), 16 deletions(-)
