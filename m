Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 869193314B7;
	Mon,  1 Jun 2026 17:54:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780336460; cv=none; b=fCdmKDB3NH7jTH+iiKqo3IAWGF4QFOFloLQ4AS1S62g39nJiRVOjiQ+mGWW0fNQW8e2nuaEjmQ3xemWfAj8iWf73cVt9KmCzWEqHV1RwVhWcKFJb6Nzt+NeNQumcpf7Z0hBCN+3jjzqlmRaIe4CA5Y/mv3e8907hfncjDz5Rp8w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780336460; c=relaxed/simple;
	bh=Df+fYzQqMI1GeA45P6JsTCTJmOrcAu4SR0z2gpGCea4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FsFmH9WXaTw33x7IC6c9ijL+raNmQDiQGTzouhpnqsH1nU8EvPBydvKKQol7rHWydeurlQIJiF6KJzWJKi3MS0YHTFv/fZFhQYdO56AcweDBO3/1cZOWmqlVrFABR2T4SHHVo8ziGEMapIJUq31Szd1tBCg8t63lVriREfOJkzs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d0LJcgbl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d0LJcgbl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 04EED1F00893;
	Mon,  1 Jun 2026 17:54:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780336459;
	bh=n67+QMBasbqZL2nolv5f53FlukG25uE1k5+NU1mtaHI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=d0LJcgblHKikjbLANLFLreCi5bYhQywXj6XO6lQQRkFyOI63GepCJ8ilJxvlYBV0y
	 jr2FTJIa0b5BUAOTzRNiGfl/kNP+g7ROKF0y1R55/BlE3tbGOcXgGA0NpBVTt0Be7m
	 /Y61s34g8CumOQI+pKG9tV67D24CNdLKPcJxWfPCldRmHdqgA8tczlpbmvQ7jUEX83
	 it4nPnMlqdykyTP7UJPqf5toxNZeyvRrbafVgQOvNrsoxhRjML5OXf6QzyIkrugO9b
	 0HQVw3EDLGV54tjmaJ0Xv2gnDhkm+psZPKmuMdIAEv6cEH/lh5ZaGF9lH0qEMILXxt
	 mMMIgH56vaZDQ==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] xprtrdma: Remove tautological I2 assertion in rpcrdma_reply_put
Date: Mon,  1 Jun 2026 13:54:13 -0400
Message-ID: <20260601175413.29544-3-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260601175413.29544-1-cel@kernel.org>
References: <20260601175413.29544-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

rpcrdma_reply_put() sets req->rl_reply to NULL when it is
non-NULL, and skips the block when it is already NULL.  The
WARN_ON_ONCE(req->rl_reply) that follows can never fire
because both paths leave rl_reply NULL.

Remove the dead assertion and its comment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index da2c6fa44154..92c691d2521f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1259,10 +1259,6 @@ void rpcrdma_reply_put(struct rpcrdma_buffer *buffers, struct rpcrdma_req *req)
 		req->rl_reply = NULL;
 		rpcrdma_rep_put(buffers, rep);
 	}
-	/* I2: rl_reply NULL after the put closes the
-	 * 'rep on rb_free_reps still referenced by req' window.
-	 */
-	WARN_ON_ONCE(req->rl_reply);
 }
 
 /**
-- 
2.54.0

