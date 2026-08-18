Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDB06306775
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 14:00:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787061638; cv=none; b=WRhXENTxIDtKTdv93E5VRXNT9U/mF2pgMpF1GQcJWS8BAcDed6J8lgSttQjId7dLCFmNpTtWFhv8kPz2AlloZXN16Xpc4oAZd7lkpDTLKpFJT+0wiOBjKFgJmWYRlnRC1GN944ryUN3TNYqJ8frrqluR6NQxRsc8gJQ0yK66HAQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787061638; c=relaxed/simple;
	bh=MWWjENIO5YE/TXlVy5TU5Htk3feTJ3o1rRGlxQ2c6Pk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=i+0DIxOk+WqBwPHki2HKgvHmE6y634M4SeScpniaplBisG6Pih52FFxKI8KY2wDp8H6VQMpWL415ZkfLej/1vvMJbBn8pL3lQ7INUuHQROuF5iWYMZJBCwx+nkqJ87W0mC2KDRwKBttnFOj09kyHSatSuRO+ls+G7fKuYVv8YFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KYo+8rbV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KYo+8rbV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C52DB1F000E9;
	Tue, 18 Aug 2026 14:00:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787061637;
	bh=fSUvRH9aG/OetgAlz4i9ccXl3NAzC/EEYhUmaMehhtk=;
	h=From:To:Cc:Subject:Date;
	b=KYo+8rbVfFUzxJ9e4yUSZmjJTE+tXDQX5VvfnuYsQF1H80wmF2CNk/sJ0fjzS1gPP
	 biJEMrRl45yGg0OWTRJ69oLPe7uYVIFAQiW8eq1GAGleVQ6Bk+2pby2FgIkTo8h1eV
	 BVBrsK5L0Uq274Z+bB8KxHpc/PkHa9Gjsmsl75b8Yes6YcD4Z1qcr1if2b0ll1X784
	 Pjbo/vwKIKkg+VEmR3Kf9rYIgLAOnKhptWqx2NcBsr9Is+7oUkPqOd+ShYDdxcavLK
	 UQQgIJZFrid70cyUjmlFXvveTbj7TR2N2B3xW44bYO+5465CSSDgQlVIcB1bpAAMr2
	 GET6rF43KSHig==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFSD: Move the nfs3.h include out of nfsd.h
Date: Tue, 18 Aug 2026 10:00:33 -0400
Message-ID: <20260818140035.12740-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fs/nfsd/nfsd.h is included throughout the server, yet it uses no
NFSv3 protocol definition of its own. The <linux/nfs3.h> include
there served only to make those definitions reach the few source
files that need them, by way of nfsd.h itself or the xdr.h chain
that pulls it in.

Give each consumer its own include and drop the one in nfsd.h, so
the header no longer carries a dependency unrelated to its
contents. nfsfh.c, nfsctl.c, nfs3xdr.c, nfs3proc.c, and nfs2acl.c
reference NFS3_* definitions directly; add <linux/nfs3.h> to each.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c  | 1 +
 fs/nfsd/nfs3proc.c | 1 +
 fs/nfsd/nfs3xdr.c  | 1 +
 fs/nfsd/nfsctl.c   | 1 +
 fs/nfsd/nfsd.h     | 1 -
 fs/nfsd/nfsfh.c    | 1 +
 6 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 33610deda3b0..0a5c444fef99 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -10,6 +10,7 @@
 /* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
 #include <linux/gfp.h>
+#include <linux/nfs3.h>
 #include "cache.h"
 #include "xdr3.h"
 #include "vfs.h"
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 17bbe5d13f18..60cd01b6a37d 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -9,6 +9,7 @@
 #include <linux/ext2_fs.h>
 #include <linux/magic.h>
 #include <linux/namei.h>
+#include <linux/nfs3.h>
 
 #include "cache.h"
 #include "xdr3.h"
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 090cea8e545d..a14e829e1c41 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/namei.h>
+#include <linux/nfs3.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include "xdr3.h"
 #include "auth.h"
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4e5e083d8477..0117b89ba538 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/fsnotify.h>
 #include <linux/nfslocalio.h>
+#include <linux/nfs3.h>
 
 #include "idmap.h"
 #include "nfsd.h"
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 64315890eef5..a145294c59c8 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -14,7 +14,6 @@
 
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
-#include <linux/nfs3.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index b1f3c22af525..2bd6907f443f 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/exportfs.h>
+#include <linux/nfs3.h>
 
 #include <linux/sunrpc/svcauth_gss.h>
 #include <crypto/utils.h>
-- 
2.54.0

