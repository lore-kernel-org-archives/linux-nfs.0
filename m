Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B968936C0C1;
	Wed, 18 Mar 2026 21:14:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773868489; cv=none; b=m6spni+UCQuKs5j+DruPujypNB4WO5u41KMCbLSVQ4qjWciBkKv3ZDejwc4DqvL6H83zBXZ2GaoBWH1q8RVIa01JAF24Hrv/SIo9rmMezDzrvPCbIwuYgV9F/psjDjXZChUIRN4yDThbA0AZPZkCGSV7RFJuISPtqUgfPBoecMQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773868489; c=relaxed/simple;
	bh=4CCwqcasUhr2QEsIQHsdysJgYvmowaLGpDhHiD/iN4k=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eDocOmqu0fz3Upb+F1TMrHCzvbedb7zRF6sds4LLRu1ZqyBtiwHHmWW3eZsJdUyL2wCjVjTK6dzgaNnLOIPXTEELRakRMhz41MgK1yx2geAXol5S4oqahTR+qhNjsUwGj/1gkzJHI763FOHUhgeR190McX9u+oTU26LtKO+VozU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=q0FKX6WB; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="q0FKX6WB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F4118C19421;
	Wed, 18 Mar 2026 21:14:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773868489;
	bh=4CCwqcasUhr2QEsIQHsdysJgYvmowaLGpDhHiD/iN4k=;
	h=From:To:Cc:Subject:Date:From;
	b=q0FKX6WB4gjk98lf6vbyagi9II3lkuHiYQEieFE3SQ3ekfLZ/mwTnqse53P6RH/m4
	 bzl3Wm8aCZZyYq0nlxTsXFfxq2q/i64Qp/Sob1zP+Dmj4/kMvFvFxxn6sQVKZRw8x3
	 XlJiAscuhJ8K80DA1GAY+Ibu2yKSAUFUSIfqvjAkwex+yroLXYDXQKXd+F5XsjxVSV
	 KEPVkP6wHMWCBSwn8ZvwgY3iWR1lCnHRmASdiwkm7S7DTzNIq0Y06NpvZWiiQ9A9Ll
	 EluXsuLFiv2FpHlMtj+K+oAhCd9K4brQ8mNh22n5d++7cHSnrHceyI0AP7EeYQNp3q
	 Ou6mKnkp67/Vw==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [GIT PULL] Second round of NFSD fixes for v7.0-rc
Date: Wed, 18 Mar 2026 17:14:47 -0400
Message-ID: <20260318211447.1808-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit 364410170ab33f6e7ef0eb2afb12bf89b0feb3a6:

  nfsd: report the requested maximum number of threads instead of number running (2026-02-24 10:27:51 -0500)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.0-2

for you to fetch changes up to 5133b61aaf437e5f25b1b396b14242a6bb0508e2:

  nfsd: fix heap overflow in NFSv4.0 LOCK replay cache (2026-03-16 16:58:01 -0400)

----------------------------------------------------------------
nfsd-7.0 fixes:

Issues that need expedient stable backports:
- Fix cache_request leak in cache_release()
- Fix heap overflow in the NFSv4.0 LOCK replay cache
- Hold net reference for the lifetime of /proc/fs/nfs/exports fd
- Defer sub-object cleanup in export "put" callbacks

----------------------------------------------------------------
Chuck Lever (2):
      NFSD: Defer sub-object cleanup in export put callbacks
      NFSD: Hold net reference for the lifetime of /proc/fs/nfs/exports fd

Jeff Layton (2):
      sunrpc: fix cache_request leak in cache_release
      nfsd: fix heap overflow in NFSv4.0 LOCK replay cache

 fs/nfsd/export.c   | 63 ++++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/export.h   |  7 ++++--
 fs/nfsd/nfs4xdr.c  |  9 ++++++--
 fs/nfsd/nfsctl.c   | 22 ++++++++++++++++---
 fs/nfsd/state.h    | 17 ++++++++++-----
 net/sunrpc/cache.c | 26 +++++++++++++++++-----
 6 files changed, 118 insertions(+), 26 deletions(-)
