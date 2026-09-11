Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 910974AC167
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 17:48:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789148939; cv=none; b=cqbgBrjQqGpE5vwhyoIDLYVwF3hE7Htdjcfrq+GDUpp/ZgVXcxPcMkdZGTJ0F+Zynuvf7PYEcE8m9SI2Y9MThLz5CrOzYmiZIeR62VY+oFwNEOJgukQmgw+6doMqSiibvUr3zinrCou3c1Fx1IZMAttLLvp3yGKJrLFiYecNUAA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789148939; c=relaxed/simple;
	bh=ChkVAwuqaSErWo4uwAL3APsGM8cS0ZcxXj70qiPp1dM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kjPq1+dLx6oXq1i/8A97HXECoWMFFt9/qXHbtgOVEUX+Rf13SgIAn9jO2hP32mJ7cNumZsZtX5flG/rCwI5z8o+vT2q/KS9PG61mvTR/At/JxlXkjxE7jVD0WkJQ/mXe4XqAKMaUTesbFpYmfhBtTgCnU7neTMVitg+rQ9z01i4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VnX+SEk/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VnX+SEk/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2CCAC1F000FF;
	Fri, 11 Sep 2026 17:48:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789148937;
	bh=RH1C6EZi93x8UwSNjgijPmMTfBbVwZ/xNZBGAVE6iUw=;
	h=From:To:Cc:Subject:Date;
	b=VnX+SEk/utachyzCyodZqcXGBItEIvPrDPm+KNextsuObuVvkOjF27KCF3jTK5GzM
	 sQ5QqLEuETqIqcbnHKeKzbimTEm9f4cL/XSJQW9ntwHCNenuXO4RR7UebJ5GOm/eVV
	 Og2psY+q1fldC82DEPI+olU4DoIAI05BSRydakvgvKn7CTXNC+7G5FgYg/IBZumB53
	 +daLF5hxRJ8KoTSn+frCCO5YhB0OKCVpmtLY/Td1JpV4EcbNL1LUEtYnDdurfKkxb5
	 H4lnn36aC5F8aP2eIilPywKBL1L+q5L65jTJhiaRteXRyebwS7CvdAcLgVQ2AdeskR
	 RKSuRMCLQ8oPw==
From: Trond Myklebust <trondmy@kernel.org>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] NFSv4: Fix a regression in the handling of CB_RECALL_ANY
Date: Fri, 11 Sep 2026 13:46:36 -0400
Message-ID: <115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When the flag NFS_DELEGATION_RETURN was replaced by the
server->delegations_return list, the test in
nfs_mark_return_if_closed_delegation() was replaced by one that stops
all further marking of delegations for return when closed as soon as the
server->delegations_return list is non-empty, breaking CB_RECALL_ANY
behaviour.

While the intention at the time was probably to check if
delegation->entry was non-empty in order to emulate the effect of the
NFS_DELEGATION_RETURN test, that is no longer an option, since
delegation->entry is also used for the LRU list.

By just removing the offending check altogether, the patch can end up
moving delegations from the server->delegations_delayed list
prematurely, triggering an early retry. However that should be mostly
harmless behaviour.

Fixes: 0ebe655bd033 ("NFS: add a separate delegation return list")
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ab3e441464a6..ad774316f716 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -934,8 +934,7 @@ nfs_mark_return_if_closed_delegation(struct nfs_server *server,
 {
 	struct inode *inode;
 
-	if (!list_empty_careful(&server->delegations_return) ||
-	    test_bit(NFS_DELEGATION_RETURN_IF_CLOSED, &delegation->flags))
+	if (test_bit(NFS_DELEGATION_RETURN_IF_CLOSED, &delegation->flags))
 		return;
 	spin_lock(&delegation->lock);
 	inode = delegation->inode;
-- 
2.55.0

