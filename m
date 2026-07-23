Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 950A936C0AB
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 18:20:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784830859; cv=none; b=BY8LVYK2G4+vXbTZhI8XZbzkWXwqUtpizocKJswOAJUE8imKkCOsL5LbzYsljvXq+TG0gCKL/z3OhGlbZ0A1yHXVz3pU5GWoBliOkeBj/B2bjpHB4mQf5w21pffcBC42GB8xpGQfVktTJL3AN1U9jOn72pzRmbEelKlX3XsnLbY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784830859; c=relaxed/simple;
	bh=gCvCNHB3HUX1z5tepxzIrMqlZoLV+lau2tgE/q4bL3o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DLnmmR3raTcct3QiQbwlPkAzwq+pXvhfKgOyDAhe7qiq5Y5w5Q2ccN45sGMm3Zeh2+nUUqPmwybmNa/kM7yUCM7nsv6L2TGw9/7II/HsSbXr8PM2CzC4DTPLKvZAUOnVr/DDjnMthEepfJhOi7MgaSjw2DBXf+ClyhHr9r5wiyc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74F971F00A3A;
	Thu, 23 Jul 2026 18:20:45 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFS: Move definition of enum nfs3_stable_how
Date: Thu, 23 Jul 2026 14:20:42 -0400
Message-ID: <20260723182043.990391-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260723182043.990391-1-cel@kernel.org>
References: <20260723182043.990391-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: enum nfs3_stable_how was introduced in NFSv3. NFSv2 has no
stable_how on the wire; its write path passes NFS_FILE_SYNC only as
a placeholder that the protocol ignores. The stable_how constants
describe an NFSv3 wire value, so they belong in linux/nfs3.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfs.h      | 9 ---------
 include/linux/nfs3.h     | 8 ++++++++
 include/trace/misc/nfs.h | 1 +
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 0e2a0b1e3061..0e2b210c103b 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -22,13 +22,4 @@
 #define LOCALIOPROC_NULL		0
 #define LOCALIOPROC_UUID_IS_LOCAL	1
 
-enum nfs3_stable_how {
-	NFS_UNSTABLE = 0,
-	NFS_DATA_SYNC = 1,
-	NFS_FILE_SYNC = 2,
-
-	/* used by direct.c to mark verf as invalid */
-	NFS_INVALID_STABLE_HOW = -1
-};
-
 #endif /* _LINUX_NFS_H */
diff --git a/include/linux/nfs3.h b/include/linux/nfs3.h
index 404b8f724fc9..1d18da0860d5 100644
--- a/include/linux/nfs3.h
+++ b/include/linux/nfs3.h
@@ -7,6 +7,14 @@
 
 #include <uapi/linux/nfs3.h>
 
+enum nfs3_stable_how {
+	NFS_UNSTABLE = 0,
+	NFS_DATA_SYNC = 1,
+	NFS_FILE_SYNC = 2,
+
+	/* used to mark verf as invalid */
+	NFS_INVALID_STABLE_HOW = -1
+};
 
 /* Number of 32bit words in post_op_attr */
 #define NFS3_POST_OP_ATTR_WORDS		22
diff --git a/include/trace/misc/nfs.h b/include/trace/misc/nfs.h
index a394b4d38e18..b5fb77d7954b 100644
--- a/include/trace/misc/nfs.h
+++ b/include/trace/misc/nfs.h
@@ -8,6 +8,7 @@
  */
 
 #include <linux/nfs.h>
+#include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <uapi/linux/nfs.h>
 
-- 
2.54.0

