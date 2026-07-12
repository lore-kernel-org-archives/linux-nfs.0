Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7D83369981
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:45:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783889158; cv=none; b=hQEs/P48RfLLmv3ADfVBgsY6VbN4XEJZuRzGX/FT0hYvEASqROj3RYMX+X4+XS2g0O4XvXgr9OZ1ubS83rWN3DoaqJdMfG+NjGrPcQ0hAioLL7netLkcFn1Ur+ObqC4fgsF61afZl0AWT6YJp4b+p9qPPIaBbvrGH74S27vNoAk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783889158; c=relaxed/simple;
	bh=irGGB/Cza501D4Fz3CbzM0c0YwmrgT2D0pRP6+r4zxw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rCMPPj4z9tmWHtkb9uWSHdLdZNLfXcyYnOFuyiZ10w4uMC4SMYxJAYmeYZ1FU8AV/jyyQWIM198NgqC5rTryrZFSeWiTtuH1oZk76xAmyfFRUYYzxCOur/8QQUHUVfhpfwWJaTULI7A1FopC2buq3p8oFCvE5RBX3uVVYY7BSPI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Maqk5fMI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Maqk5fMI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A67D1F00A3A;
	Sun, 12 Jul 2026 20:45:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783889157;
	bh=E+tDwoHTRWe3vzx6WGXxhJwYxU9SmvxQS9Yo2zRBx2s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Maqk5fMITu+egkl3kpEuBjaYXdpzG9C5R3ZCUBIipzUSIFM0yFBGBp611FcwpnEZq
	 WJCfbY3F54mVS2XGV0ZZ2vfq6KAAajuYtqTuaUw4cV6g11uYc4Vq7fhWIBN0eoHWbX
	 6y1AZPpXA20QQS3HGAv14m7skW8o6j8qNd5Tn3oDgPPsxbziAZdX9PaV3ASvWYBHCU
	 RDfr3XdIiB8e2aTvd5b0BIKJjgDRnSKes+h4jkdCInITfco+pQe2yrWD5kz5OZhq5R
	 PVga+KcwujXvQ1FCEuBaVKPvBzfUW+Udbko1ckA1zTUFVK0GxhYw+vOvNQP+ZQZoQW
	 f2+Uw7Yn71GIQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/9] NFSD: Explicitly include "stats.h"
Date: Sun, 12 Jul 2026 16:45:47 -0400
Message-ID: <20260712204554.125308-3-cel@kernel.org>
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

Nothing in fs/nfsd/nfsd.h needs what is defined in "stats.h", so that
header can be moved out to the six translation units that actually
need it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 1 +
 fs/nfsd/nfscache.c  | 1 +
 fs/nfsd/nfsctl.c    | 1 +
 fs/nfsd/nfsd.h      | 1 -
 fs/nfsd/nfsfh.c     | 1 +
 fs/nfsd/stats.c     | 1 +
 fs/nfsd/vfs.c       | 1 +
 7 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5559dac9e7f4..7de4b913b0a2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -51,6 +51,7 @@
 #include "xdr4cb.h"
 #include "vfs.h"
 #include "current_stateid.h"
+#include "stats.h"
 
 #include "netns.h"
 #include "pnfs.h"
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 18f8556d33dd..bdf92ec00e7e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -19,6 +19,7 @@
 #include <net/checksum.h>
 
 #include "nfsd.h"
+#include "stats.h"
 #include "cache.h"
 #include "trace.h"
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0543e5bb842f..4de0a8dc7ebe 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -23,6 +23,7 @@
 
 #include "idmap.h"
 #include "nfsd.h"
+#include "stats.h"
 #include "cache.h"
 #include "state.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 4c5d915225df..0b225eb3ef3f 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -41,7 +41,6 @@
 bool nfsd_support_version(int vers);
 
 #include "netns.h"
-#include "stats.h"
 
 /*
  * Default and maximum payload size (NFS READ or WRITE), in bytes.
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 8b1a95e1d058..c23ae31f60e0 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -13,6 +13,7 @@
 #include <linux/sunrpc/svcauth_gss.h>
 #include <crypto/utils.h>
 #include "nfsd.h"
+#include "stats.h"
 #include "vfs.h"
 #include "auth.h"
 #include "trace.h"
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index f7eaf95e20fc..d7edbda260f0 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -26,6 +26,7 @@
 #include <net/net_namespace.h>
 
 #include "nfsd.h"
+#include "stats.h"
 
 static int nfsd_show(struct seq_file *seq, void *v)
 {
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9e05c3949cc1..0a1e7bfea3c8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -43,6 +43,7 @@
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
+#include "stats.h"
 #include "vfs.h"
 #include "filecache.h"
 #include "trace.h"
-- 
2.54.0

