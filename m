Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 416BD3B42F8
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:45:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783889160; cv=none; b=I5q446mVDkZUB9cRNshTBEq3PGECyeHN5rSviYhV5wm8pazn6yEY1nQHLLY3i/ghFX8oUYHa8+EnRwe3vFYhZ8fJZvEQZyojSVWo3sIsJ1UWGjBDDl0z62nvbyUaTQkqtP6c4H8G2PZFtdR8/nceBBS8TAF5ukxV/Er1P+XsE6A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783889160; c=relaxed/simple;
	bh=t2IFeyc3it4UWSltH9c5H4wB05MkGVD86AxEfbUo4Ko=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FmoUwRW5DVmGN5OYBxhgGJqtrsxVHqZ+KnKn0O05/87fn7SD46U3IA0AgEN2GxTGWOu1clW6ennIVpgAij1294myQaObjcjyrZnJLofLVgdiy6BVyecca+gvh1xdnzZbwXYN+x4jJc4NzvjLPPikZND4OCl4ZxnLGHbi9VUO720=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jyod3Qez; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jyod3Qez"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BE1A1F00A3D;
	Sun, 12 Jul 2026 20:45:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783889159;
	bh=31ZQc39LBPeJ9niGOAVJ0mHO0NN0s8qc3GkM2PHCjtE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jyod3QezKHeLeHYAIkCSYiHG13zNSwnXRzrz887HPRT6btdeFcnt29US1Swq/Wp58
	 FAdCjGBaMNzq43GtOa4rskbu1rjOHbLk2w/BflabA1n+fvp3w2/guJCe6wyIXwuV30
	 YLHavUg1iH7u7EL32pXEuXqBklAQrcNA7I/qeUW7+B5R3bSaErL+taEF1v/kjm2tLf
	 cLb7lL8/Q7/aIX77OW43Ci1DNuyNDFLqa92/EZ35gCkouSaKf1xYGAni42wmNiglz/
	 XKT/jG3Mk1bMKLUjBxXllmCes6Y9pv8QiQ53vpQ9Znu4PjjyvJb83SKQnQdrqkX5Th
	 /kS6WQQVeimIw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/9] NFSD: Remove '#include "nfsd.h"' from fs/nfsd/cache.h
Date: Sun, 12 Jul 2026 16:45:49 -0400
Message-ID: <20260712204554.125308-5-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260712204554.125308-1-cel@kernel.org>
References: <20260712204554.125308-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: cache.h does not need the full definition of struct
nfsd_net. A forward declaration suffices.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index bb7addef4a31..3bc4856e34b8 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -10,7 +10,8 @@
 #define NFSCACHE_H
 
 #include <linux/sunrpc/svc.h>
-#include "nfsd.h"
+
+struct nfsd_net;
 
 /*
  * Representation of a reply cache entry.
-- 
2.54.0

