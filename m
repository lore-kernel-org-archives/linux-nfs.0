Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B84C51E1029
	for <linux-nfs@vger.kernel.org>; Fri,  8 Nov 2024 22:13:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731103987; cv=none; b=kPsXsvVz8yOY9gMGW89tbHmahwbfeLiHXr8LqjB23ojZVTbotkeLE42RJQPxrI6cS9gh/jQDMPMvzaQ2ApBhNLdcdWgUYiMQEPsIlXk4tmBav8KFKJFlcuPT0wzgEvzRB6y0uVyf/oKVIytzIbfgccqv7R1JUv/PGyte7R5uY0w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731103987; c=relaxed/simple;
	bh=WXVa7uAuXPGVkoVbcuOvTxPf/QbjdCKmKGjb3XETjw0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aO0dUXNmmteb0yIcIgTu0JJapjbauodjowLYAs21zUWE9IQsN2t2O/D3LavqM8C20x/bBrl/ltzG4XNms/VqcWt76ID0LM5WcmFqDMyjCUWsE1gD0G63fCwNiWoCn+6FO31qtkNf7roudgLDlwpom54Lat0LJpgxKam7FJ/+Ex0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YUGHrrzQ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YUGHrrzQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16DC1C4CECD;
	Fri,  8 Nov 2024 22:13:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1731103987;
	bh=WXVa7uAuXPGVkoVbcuOvTxPf/QbjdCKmKGjb3XETjw0=;
	h=From:To:Cc:Subject:Date:From;
	b=YUGHrrzQjCyPGNLAQTZ7Zqx4QKrK5i0/gLquU8TS45yUnhgyXpI0fUVH5Nnt00yLH
	 fWaKxuJ9/Jgn9A52SXZLS7iO68KQSJSWfx/RnwWF+r1cmwbindQL3pJElMFo7iC45+
	 TI7ken9dSKInxsjZ5JsdjefKIhL7jNGpY1gsUrb4jqz54QioeiArAryAcqdzQjPaCb
	 cPmbxPNxzb7gaIIvjqKg+zYMtLTBY4G9kHpd0tuflMb8TX7rWtaqhsuO9zvD/6qQmA
	 PPMzK/+i0onUZaliBekdr9m8oho8Ikf0q4qGZ9Mk2rgvWmb2nFKJHtslgLnqBhmNEt
	 4iyVXGd1Ru9jA==
From: trondmy@kernel.org
To: Yang Erkun <yangerkun@huawei.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.0: Fix the wake up of the next waiter in nfs_release_seqid()
Date: Fri,  8 Nov 2024 17:13:04 -0500
Message-ID: <5527548df9be8ce76ed31ad0ea6520908533b4fe.1731103952.git.trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.47.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Trond Myklebust <trond.myklebust@hammerspace.com>

There is no need to wake up another waiter on the seqid list unless the
seqid being removed is at the head of the list, and so is relinquishing
control of the sequence counter to the next entry.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4state.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index dafd61186557..9a9f60a2291b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1083,14 +1083,12 @@ void nfs_release_seqid(struct nfs_seqid *seqid)
 		return;
 	sequence = seqid->sequence;
 	spin_lock(&sequence->lock);
-	list_del_init(&seqid->list);
-	if (!list_empty(&sequence->list)) {
-		struct nfs_seqid *next;
-
-		next = list_first_entry(&sequence->list,
-				struct nfs_seqid, list);
+	if (list_is_first(&seqid->list, &sequence->list) &&
+	    !list_is_singular(&sequence->list)) {
+		struct nfs_seqid *next = list_next_entry(seqid, list);
 		rpc_wake_up_queued_task(&sequence->wait, next->task);
 	}
+	list_del_init(&seqid->list);
 	spin_unlock(&sequence->lock);
 }
 
-- 
2.47.0

