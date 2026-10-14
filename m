Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA8C640963A;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791962999; cv=none; b=JJyXvLgUI0pTJJ+qt39FyicPK8RE8JYQqLFh3i3/0V7u/bpEKJbW1vvwUjep0cU6VhYxorBR9yuSnvxHAwdOpDmwpZj0ejqARRlUyYmDW/BIt6jR06WqeXnXg3vld87peNwkSTbNyjgFD2NmZ/BlKQsjN9j+qNtzTiFkoAsCQ7k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791962999; c=relaxed/simple;
	bh=DP2/cxrAK2WqR8CSu2SmEp4uyLUTYSSY4unD+j1VXiU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KVC2TfW/PSYwuBap8i8CBf2byG0/rbvyZrY5dj8F4bAneFBeT9DpkyI6tZYJ/H7uL7HaOBmC63cdIMabqN704xxzgR2NTb90MMBj06WqSDmjD/dcsHwqShS3wbX/WMQ9FsSBOH2IfciOIQuLhFYElAITvobxFwGvaYXCENtXC2s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZtoGnKTE; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZtoGnKTE"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 56732C32786;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791962999;
	bh=DP2/cxrAK2WqR8CSu2SmEp4uyLUTYSSY4unD+j1VXiU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=ZtoGnKTEgwKAIk/m0cuvrJTIxXYcw+m13ACLjhknL9M314x1uSyENotk7udamW1Bz
	 3SXBlnxrsqZGr1bpTTIznVMKh8uXvjUSIK0eBpQR9mRTpgTUwYGj3a/+Jrgi2EeYv/
	 mJFNEEjTuhLsIl/MAe6gx9nCSv6AJWvxvmen30GDUG5sw1lnK5ro9AB0CSpZSjeIRf
	 QPEamBiqViFO0zITWswg7ui0f16OAsA0a2l9l2cJmEIR69NcUaX7hby3EH36bWd68a
	 McEBbQ+/3NWkjLbvmqPKQrlgyrghFnE8HgG7freJ/nGwH5mp4V9QWhdPYbitxIrYWm
	 WUmaNja/IWi7A==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40B36CC6B29;
	Wed, 14 Oct 2026 07:29:59 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 14 Oct 2026 16:30:03 +0900
Subject: [PATCH v2 7/7] nfsd: do not fence a client for a layout recall
 with no layouts left
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261014-nfsd-layout-recall-v2-7-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
In-Reply-To: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791962996; l=1852;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=fJWkfHrjhyvPcMpES15/0yb8WW8jmYTA1ewdCgCzzTI=;
 b=EVCcY+Aufz3R/M09NJGKhiZcGv6CotWf/kaFW46PiG4BakFaPacdpRYdum2FJdh9A14R0qJyz
 dKdaYrYzOskCKt7jHZ5WfkjtU04aqlQ/rJjjL3RqHNI5w0wEUsOzCaf
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_cb_layout_done() fences the client for any answer to a
CB_LAYOUTRECALL that it does not handle, without looking at whether the
layout stateid still has layouts. A LAYOUTRETURN can return the last
layout while the recall is still out. The Linux client answers
NFS4ERR_NOMATCHING_LAYOUT then, which RFC 8881 section 20.3.3 allows
for a client that holds no layouts for the file. A client that answers
NFS4ERR_BAD_STATEID is right too, since section 12.5.3 makes a layout
stateid invalid once the client has no layouts for the file, but it is
fenced for nothing.

Check for layouts before fencing, as the polls already do before their
time limit, and end the recall when none are left. This does not depend
on the earlier patches in this series.

A pynfs client that returns its layout on the recall and then answers
it NFS4ERR_BAD_STATEID: without this patch, nfsd logged "failed to
respond to layout recall" and ran the fence for it; with it, the recall
ended without either.

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index f54515e7f6..e7a4eae51e 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -931,6 +931,15 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		}
 		fallthrough;
 	default:
+		/*
+		 * Nothing to fence for once the layouts are gone: a
+		 * LAYOUTRETURN can return the last one while the recall is
+		 * still out.
+		 */
+		if (list_empty(&ls->ls_layouts)) {
+			trace_nfsd_layout_recall_done(&ls->ls_stid.sc_stateid);
+			return 1;
+		}
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
 		 */

-- 
2.43.0


