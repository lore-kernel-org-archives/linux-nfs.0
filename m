Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FF8225C71F
	for <linux-nfs@vger.kernel.org>; Tue, 25 Mar 2025 16:17:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742919466; cv=none; b=VmZgOQIibMFJJM90O09dboiBWVHEeQ2++uM4K+ElhrC/nUnp+2i/XiqQK4kbf7R/zYS7KOJzMomiZg+qm9Ui8zBSy2HQW0rGOgYYoBwtAw76l3p5BSvKegwT9BzamZLsypJfw6wUSqPkiNQ0lJQ0Yyd0rQ0oW2QXlcQjPVnBVHE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742919466; c=relaxed/simple;
	bh=QsZDdBnkTuGhUWBCzg983UNPUZZmhi66LsCjLD4iZ1s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qMX0Ho/PG9vv/w44MO4eHG8YTeWYosUvsGmc4jY0MkR50lkEW3Y88iHZxiJqH4eOpsS01q6/3ufCMZ6QDhiKaALWpEVDpwGizvqpoCjgPY8GjjcpB7S0yDV1c5cPQ+iKyPgWSYIRkmk9RF00eVvJTCawj2KpKaWuj5t5YoVZaFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nTgT9Ctm; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nTgT9Ctm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6565EC4CEED;
	Tue, 25 Mar 2025 16:17:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1742919465;
	bh=QsZDdBnkTuGhUWBCzg983UNPUZZmhi66LsCjLD4iZ1s=;
	h=From:To:Cc:Subject:Date:From;
	b=nTgT9CtmVe60ITrKJ9RE3le65cYzbfJVkJxhnmXUT3BG6iCfMCKBvfB2eG6dlVexD
	 atxiNGN7o/XDr/g2GBsc4oWcTtHxL6inYMqeiGs0oYs9T6NRMzdUZCU2wAFlX3D+LI
	 Uwh+PxzPSUcdk5e2mPDC/Qf1HC+ZLp9BgCFmluEJxGoEL0lJrD6jgQcN1lxQX/dx+v
	 TVZuJNaIYY18UD747QZZGFfmy1VVOmkSOBeV8HwM/qdQsaHLpeY8MoCaipW+oVqidO
	 zcAcngH3IXGVDLfmNbHrCPfiBtTMu64COKOFkWfMfdPmm2JVCmRpFH1EPwJFd8yRfs
	 tSQGZBRdKFyYg==
From: trondmy@kernel.org
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@kernel.org>,
	Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 0/4] Ensure that ENETUNREACH terminates state recovery
Date: Tue, 25 Mar 2025 12:17:40 -0400
Message-ID: <cover.1742919341.git.trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.49.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Trond Myklebust <trond.myklebust@hammerspace.com>

With the recent patch series that caused containerised mounts which
return ENETUNREACH or ENETDOWN errors to report fatal errors, we also
want to ensure that the state manager thread also triggers fatal errors
in the processes or threads that are waiting for recovery to complete.

---
v2:
 - Return EIO instead of ENETUNREACH in nfs4_wait_clnt_recover()

Trond Myklebust (4):
  SUNRPC: rpcbind should never reset the port to the value '0'
  SUNRPC: rpc_clnt_set_transport() must not change the autobind setting
  NFSv4: clp->cl_cons_state < 0 signifies an invalid nfs_client
  NFSv4: Treat ENETUNREACH errors as fatal for state recovery

 fs/nfs/nfs4state.c     | 14 +++++++++++---
 net/sunrpc/clnt.c      |  3 ---
 net/sunrpc/rpcb_clnt.c |  5 +++--
 3 files changed, 14 insertions(+), 8 deletions(-)

-- 
2.49.0

