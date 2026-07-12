Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84BBD34F255
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 20:46:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783889162; cv=none; b=suDflhwSvDCBf0HzDcRbCw10rhHd4NphXYhGtFPuGm969DwqJ2aOXunsG2s4M2cHAgJ0mRErGDoI+V2naEfQ17vmr73A6f91cfQ3APFwMH+hw+0mEupvJ7khl/gWCvSxhpkxr2zmIqecuBbC1q0PCawcdK9Q3czKwkeRLgZo6qk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783889162; c=relaxed/simple;
	bh=DD/PI8n4Bgrc2qvjXb0F/mGsk2W+jSHd+CqgUMamLj4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OQ7iMUDSdeyo4LqhW3NsdoglTGhK9IdtID1Xr/mufPAtw1z4kPt1ms9lri5HW1nDB/y09+8rQB1qCK01Y+xPUffNkhK8u0nskjXEth7aQ2HEExiG3GKTbdkIxlHYwc4026Anxcxgy+mxRm6H73pwwmElCfJ42sewFSUzZHrZ6kM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JZ/AliPX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JZ/AliPX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E54E81F000E9;
	Sun, 12 Jul 2026 20:46:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783889161;
	bh=5SmQEDJZ9TjqEGQqSCNZFs8lwiBWPcN/Bxk9RVnE5zw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JZ/AliPXd85wl3v50sYknlmE64SORoONLrCUf4jymbZ6GhQDHhx4ZyhpHB6/cdjMH
	 +OUvZAN6ehbj9xJ7+wqfODS+ctSeswNrdxhwqHczqPOC/4EdkKbZiO3HvoNdIdMeIx
	 wt1aDGkr/nZJSklMrshEL+L5hioZv4AANeoBOoJupCnVOxrqJjGv084JMtvnII0eFD
	 B1VodLwTWMXiPAJ0irfe8UM/NIKcxE5RCzDjcuiWaI5+ENPQAxqCEbBKcQCPxL1ZZ2
	 Fa01Mexqm0xPwwfSWJ5b54bAfYHJoP1ZTOSZHovC6QjGAx3MjgLei2RMpGwY44GbJJ
	 mQbqlOMVWL1hQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 7/9] NFSD: Relocate nfsd_user_namespace()
Date: Sun, 12 Jul 2026 16:45:52 -0400
Message-ID: <20260712204554.125308-8-cel@kernel.org>
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

Refactor: nfsd_user_namespace() currently lives in nfsd.h, so every
caller must pull in nfsd.h -- directly or transitively via state.h --
and with it the NFS protocol definitions from uapi/linux/nfs.h and
friends, even when the caller uses nothing else from nfsd.h.

Since nfsd_user_namespace() is an auth-related function, move it
to fs/nfsd/auth.c in preparation for removing '#include "nfsd.h"'
from a few places.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/auth.c      | 18 ++++++++++++++++++
 fs/nfsd/auth.h      |  6 ++++++
 fs/nfsd/nfs4idmap.c |  1 +
 fs/nfsd/nfs4xdr.c   |  1 +
 fs/nfsd/nfsd.h      |  6 ------
 5 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index e3b4a35caac6..5ef9a0466eda 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -88,3 +88,21 @@ int nfsd_setuser(struct svc_cred *cred, struct svc_export *exp)
 	return -ENOMEM;
 }
 
+/**
+ * nfsd_user_namespace - Get user_namespace in effect for an RPC request
+ * @rqstp: RPC execution context
+ *
+ * xpt_cred is set once at transport creation and never modified. The
+ * transport itself is reference-counted during request processing, so
+ * no explicit reference on the namespace is necessary.
+ *
+ * Return: the user_namespace from the transport credential, or
+ * init_user_ns if no credential was set. The returned namespace pointer
+ * is valid for the duration of the RPC request.
+ */
+struct user_namespace *nfsd_user_namespace(const struct svc_rqst *rqstp)
+{
+	const struct cred *cred = rqstp->rq_xprt->xpt_cred;
+
+	return cred ? cred->user_ns : &init_user_ns;
+}
diff --git a/fs/nfsd/auth.h b/fs/nfsd/auth.h
index 8c5031bbbcee..832bc957980d 100644
--- a/fs/nfsd/auth.h
+++ b/fs/nfsd/auth.h
@@ -8,10 +8,16 @@
 #ifndef LINUX_NFSD_AUTH_H
 #define LINUX_NFSD_AUTH_H
 
+struct user_namespace;
+struct svc_export;
+struct svc_rqst;
+
 /*
  * Set the current process's fsuid/fsgid etc to those of the NFS
  * client user
  */
 int nfsd_setuser(struct svc_cred *cred, struct svc_export *exp);
 
+struct user_namespace *nfsd_user_namespace(const struct svc_rqst *rqstp);
+
 #endif /* LINUX_NFSD_AUTH_H */
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 71ba61b5d0a3..e9faf8b78f74 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <net/net_namespace.h>
+#include "auth.h"
 #include "idmap.h"
 #include "nfsd.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index aef48fb0fac2..cba2e72d616c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -47,6 +47,7 @@
 
 #include <uapi/linux/xattr.h>
 
+#include "auth.h"
 #include "idmap.h"
 #include "acl.h"
 #include "xdr4.h"
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 0503ee0e1bbe..81312b11b5c2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -153,12 +153,6 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
 {
 	return rq && rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
 }
-static inline struct user_namespace *
-nfsd_user_namespace(const struct svc_rqst *rqstp)
-{
-	const struct cred *cred = rqstp->rq_xprt->xpt_cred;
-	return cred ? cred->user_ns : &init_user_ns;
-}
 
 /* 
  * NFSv4 State
-- 
2.54.0

