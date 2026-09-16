Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5A9E5540A8
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576147; cv=none; b=hKCkq0byxRjSH2ff7UTJbBmlbcdRKfq8VwoV1HH2xNzcbtx0HJiMqKgkr0kqJIqPDjHcsNjr6YwYVMVfXAcchMrcHcokrPkjEVd29sh2mI2cmSz+LJlMgU8z552IzNldxWZBkfK6v6i3fcDRgNbKzbnk0ON955sH6hVdrbUPg14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576147; c=relaxed/simple;
	bh=VvlnV11GnZPTc+FU7/93ONQYqiaH+x5OW3SOLCSCTHc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=J3PQAZdJ5ttnesXDRvcSkBx8yGZhBHtsKe8qnguVFvW6rkdcFnU6aXtPFrL9p1fQAtao3+7jja/O69xslTC3xtF23mVc0Jzm5/pLT9dLODDO3sUT6wZzvWecGecrassJ/rZkGNrWQW5P1yto986XQoLHu3ufoRlyyVod3yVAsUg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lOTfwHPx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lOTfwHPx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B2BA41F00893;
	Wed, 16 Sep 2026 16:29:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576145;
	bh=8l2qV2s/EnKHb+j6h8VSG3FFZhj+FrCT4p6RN5k72Do=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lOTfwHPxEApzdaGoUeP8XLj0oL3n5DOOnB3e3Po+VSafMWW2JBbbA0uEX0oGxrI3r
	 6Lv11G6U4xdM6u7qI04I+rQT92kkvQTCVHPSFSAHRgYgCi41JuFGyBjXb2BcmSTb3C
	 qPv83ZaFfaCGSozQvaSUMdoRL+tsTZE6qSVoJ/bK9/K9BRvNw1V6UX2E5zU/KYRRLf
	 Am9tw/eHDyCAiAdCgN4zggZvFsUwgvJeBd8R/UAESDi0E5PY5um65kK4Vwc9Zv5PjX
	 /JIuoG/UcY9lBair6nrZdbsYIiWDi8k52OZ0ly+/1elKBS7VhyO/7V5xlT+pyX/8YH
	 L9ZqzBEg8IlBA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 04/27] NFSD: Remove '#include "xdr.h"' from fs/nfsd/xdr3.h
Date: Wed, 16 Sep 2026 12:28:35 -0400
Message-ID: <20260916162859.2051-7-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Separate the dependencies between fs/nfsd/xdr3.h and fs/nfsd/xdr.h
so that NFSD's NFSv2 and NFSv3 implementations can be converted
independently to use xdrgen.

The only reason xdr3.h includes xdr.h is to pick up the definition
of struct nfsd_fhandle. xdr3.h does not name the structure itself;
its consumers nfs3proc.c and nfs3xdr.c do, reaching the definition
through xdr3.h. That structure wraps a single struct svc_fh, which
is defined in nfsfh.h, a header both xdr.h and xdr3.h already include
via vfs.h. Move struct nfsd_fhandle next to svc_fh in nfsfh.h so the
two XDR headers share one definition and xdr3.h no longer depends on
xdr.h. nfs2acl.c, which includes both headers, then sees that single
definition instead of a clashing pair.

Stripping xdr.h to its own dependencies also removes the
transitive route by which nfsxdr.c and nfs3xdr.c reached nfsd.h.
Both expand the nfserr_* and nfs_ok status-code macros that
nfsd.h defines, so each gains a direct #include of nfsd.h in
place of the one xdr.h used to supply.

As a clean-up, the #includes at the top of both header files are
made the same.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 2 +-
 fs/nfsd/nfs3xdr.c | 2 ++
 fs/nfsd/nfsfh.h   | 5 +++++
 fs/nfsd/xdr.h     | 7 +------
 fs/nfsd/xdr3.h    | 3 ++-
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 0673e83b6666..eada1ab51415 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -10,8 +10,8 @@
 /* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
 #include <linux/gfp.h>
-#include <linux/nfs3.h>
 #include "cache.h"
+#include "xdr.h"
 #include "xdr3.h"
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index a14e829e1c41..f0895f5e32f6 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -10,6 +10,8 @@
 #include <linux/namei.h>
 #include <linux/nfs3.h>
 #include <linux/sunrpc/svc_xprt.h>
+
+#include "nfsd.h"
 #include "xdr3.h"
 #include "auth.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 7d8e3f015307..aa3ff3086406 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -111,6 +111,11 @@ typedef struct svc_fh {
 	struct kstat		fh_post_attr;	/* full attrs after operation */
 	u64			fh_post_change; /* nfsv4 change; see above */
 } svc_fh;
+
+struct nfsd_fhandle {
+	struct svc_fh		fh;
+};
+
 #define NFSD4_FH_FOREIGN (1<<0)
 #define SET_FH_FLAG(c, f) ((c)->fh_flags |= (f))
 #define HAS_FH_FLAG(c, f) ((c)->fh_flags & (f))
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 52660b9f8dde..a2a3b2f58a1d 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -5,13 +5,8 @@
 #define _LINUX_NFSD_XDR_H
 
 #include <linux/vfs.h>
-#include "nfsd.h"
-#include "nfsfh.h"
-#include "vfs.h"
 
-struct nfsd_fhandle {
-	struct svc_fh		fh;
-};
+#include "vfs.h"
 
 struct nfsd_sattrargs {
 	struct svc_fh		fh;
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index cad875d14231..22272695e451 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -8,7 +8,8 @@
 #ifndef _LINUX_NFSD_XDR3_H
 #define _LINUX_NFSD_XDR3_H
 
-#include "xdr.h"
+#include <linux/vfs.h>
+
 #include "vfs.h"
 
 struct nfsd3_sattrargs {
-- 
2.55.0

