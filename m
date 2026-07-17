Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32BE938911F
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313679; cv=none; b=N/f6SN+VlhdSiM8TggERSPSNDowPkGvY4HGW9puHayalr5OqrUVsWZ2J2ny1TOMGwn7vA3gYGZvpKcZ6KmmQar2oUmjGREAJQEhgfPZFx3cGI+2QJRcsMZev0D33tXNgU2wju3eq3gmnAN4VRE/D6Khtk7UTnL6lKj8o++2o5O4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313679; c=relaxed/simple;
	bh=QTqWMn0eMTKpfV+1S5qd3RSik7XHN/itApnVZvBdhGw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BAJzFMr1GoLKOxO7V+XwWrvOQHu17M5DIgZ4Udyfr7Ac+iqzLw7IzFofH8qXKn0FSJBAVcrR1aK5jRFgKrI4OdJG9h95Y+xrhA7OCo3Tr6liIelaS0YflnbshtP2CVrzKKjE6WqhtGZeqpv6zBHTxNx1GEpbkr5FngwX8h+S/xs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GjinOIIb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GjinOIIb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 962381F00A3A;
	Fri, 17 Jul 2026 18:41:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313678;
	bh=MAJfAPQheZPS0sMtzJKVIA0JPKaHotqlkn3hHy/fBvo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GjinOIIbhO1PNt95hWtZV1WqJ2H7cpSukX+wcASmO4Hx1XRib/E4of73ttddoKO8Q
	 wfQIw8ypww2L+nKst8TjyTo88kVkQlwBswUaSvP1F3IBPgRMnvCdbg+CW5Rz+R8BxZ
	 Fqqf27TZR3nh0apeYRc0GtUGptWLrblrQzpglUaOZVdMqB5f/4ThOT2kpjdLypMSkH
	 by8rqVwrl9qDvqR9wkNEPKj2u860y+xWJOTXJ3DGLmyZF3D0JHDZslfFDcI8FXNBr9
	 9JasumVUkoiLfOFkWxpZsJS+DIv+S1f4mmgdm8gOPu0dortYfn3PHlVTLir4s5ZRWV
	 IVDgEA/VXh46A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/6] NFSD: Evacuate NFSv4 entry-point prototypes from nfsd.h
Date: Fri, 17 Jul 2026 14:41:11 -0400
Message-ID: <20260717184112.507548-6-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717184112.507548-1-cel@kernel.org>
References: <20260717184112.507548-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd.h is included by nearly every NFSD translation unit, yet the
two blocks of NFSv4 lifecycle and control prototypes it carries are
referenced by only seven of them (out of over two dozen). The
remaining consumers, including the NFSv2 and NFSv3 ACL and XDR
paths, parse these declarations for no benefit.

The declarations cannot simply move into an NFSv4-only header such as
state.h: nfssvc.c, nfsctl.c, vfs.c, and export.c call the routines
unconditionally and rely on the CONFIG_NFSD_V4=n stubs, and pulling
the heavy state.h types into those lean translation units to obtain a
handful of prototypes would trade one form of coupling for a worse
one.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c      |  1 +
 fs/nfsd/nfs4ctl.h     | 83 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4proc.c    |  1 +
 fs/nfsd/nfs4recover.c |  1 +
 fs/nfsd/nfs4state.c   |  1 +
 fs/nfsd/nfsctl.c      |  1 +
 fs/nfsd/nfsd.h        | 63 --------------------------------
 fs/nfsd/nfssvc.c      |  1 +
 fs/nfsd/vfs.c         |  1 +
 9 files changed, 90 insertions(+), 63 deletions(-)
 create mode 100644 fs/nfsd/nfs4ctl.h

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f18de5f66ce6..961d660e2c62 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -22,6 +22,7 @@
 
 #include "nfsd.h"
 #include "nfserr.h"
+#include "nfs4ctl.h"
 #include "nfsfh.h"
 #include "netns.h"
 #include "pnfs.h"
diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
new file mode 100644
index 000000000000..bcec4c4ef1d5
--- /dev/null
+++ b/fs/nfsd/nfs4ctl.h
@@ -0,0 +1,83 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Entry points by which the knfsd core drives the optional NFSv4
+ * subsystem: state lifecycle, the laundromat workqueue, the recovery
+ * directory, junctions, the CLD notifier, and leases-net setup.
+ *
+ * Separated from nfsd.h so that the many translation units that
+ * include nfsd.h but call none of these -- among them the NFSv2 and
+ * NFSv3 paths -- do not have to parse them. The CONFIG_NFSD_V4=n
+ * stubs let the version-agnostic callers invoke the routines
+ * unconditionally.
+ */
+
+#ifndef LINUX_NFSD_NFS4CTL_H
+#define LINUX_NFSD_NFS4CTL_H
+
+#include <linux/stddef.h>
+#include <linux/types.h>
+
+struct net;
+struct inode;
+struct dentry;
+struct svc_rqst;
+struct nfsd_net;
+
+#ifdef CONFIG_NFSD_V4
+extern unsigned long max_delegations;
+int nfsd4_init_slabs(void);
+void nfsd4_free_slabs(void);
+int nfs4_state_start(void);
+int nfs4_state_start_net(struct net *net);
+void nfs4_state_shutdown(void);
+void nfs4_state_shutdown_net(struct net *net);
+int nfs4_reset_recoverydir(char *recdir);
+char * nfs4_recoverydir(void);
+bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
+int nfsd4_create_laundry_wq(void);
+void nfsd4_destroy_laundry_wq(void);
+bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
+
+extern int nfsd4_is_junction(struct dentry *dentry);
+extern int register_cld_notifier(void);
+extern void unregister_cld_notifier(void);
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+extern void nfsd4_ssc_init_umount_work(struct nfsd_net *nn);
+#endif
+
+extern void nfsd4_init_leases_net(struct nfsd_net *nn);
+
+#else /* CONFIG_NFSD_V4 */
+static inline int nfsd4_init_slabs(void) { return 0; }
+static inline void nfsd4_free_slabs(void) { }
+static inline int nfs4_state_start(void) { return 0; }
+static inline int nfs4_state_start_net(struct net *net) { return 0; }
+static inline void nfs4_state_shutdown(void) { }
+static inline void nfs4_state_shutdown_net(struct net *net) { }
+static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
+static inline char * nfs4_recoverydir(void) {return NULL; }
+static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
+{
+	return false;
+}
+static inline int nfsd4_create_laundry_wq(void) { return 0; };
+static inline void nfsd4_destroy_laundry_wq(void) {};
+static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
+					      struct inode *inode)
+{
+	return false;
+}
+
+static inline int nfsd4_is_junction(struct dentry *dentry)
+{
+	return 0;
+}
+
+static inline void nfsd4_init_leases_net(struct nfsd_net *nn) { };
+
+#define register_cld_notifier() 0
+#define unregister_cld_notifier() do { } while(0)
+
+#endif /* CONFIG_NFSD_V4 */
+
+#endif /* LINUX_NFSD_NFS4CTL_H */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2aef7f7202b3..b7d745020fd1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -46,6 +46,7 @@
 #include "idmap.h"
 #include "cache.h"
 #include "xdr4.h"
+#include "nfs4ctl.h"
 #include "vfs.h"
 #include "current_stateid.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d513971fb119..aee3a0b22d1c 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -47,6 +47,7 @@
 #include <linux/nfsd/cld.h>
 
 #include "nfsd.h"
+#include "nfs4ctl.h"
 #include "state.h"
 #include "vfs.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a3bfcefa7bc9..e78d4fe5fbfb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -48,6 +48,7 @@
 #include <linux/nfs_ssc.h>
 
 #include "xdr4.h"
+#include "nfs4ctl.h"
 #include "xdr4cb.h"
 #include "vfs.h"
 #include "current_stateid.h"
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 8521b648a970..4e5e083d8477 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -24,6 +24,7 @@
 #include "idmap.h"
 #include "nfsd.h"
 #include "nfserr.h"
+#include "nfs4ctl.h"
 #include "netns.h"
 #include "stats.h"
 #include "cache.h"
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 1886f6d42929..1cccf5a3c034 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -151,45 +151,6 @@ static inline int nfsd_v4client(struct svc_rqst *rq)
 	return rq && rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
 }
 
-/* 
- * NFSv4 State
- */
-#ifdef CONFIG_NFSD_V4
-extern unsigned long max_delegations;
-int nfsd4_init_slabs(void);
-void nfsd4_free_slabs(void);
-int nfs4_state_start(void);
-int nfs4_state_start_net(struct net *net);
-void nfs4_state_shutdown(void);
-void nfs4_state_shutdown_net(struct net *net);
-int nfs4_reset_recoverydir(char *recdir);
-char * nfs4_recoverydir(void);
-bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
-int nfsd4_create_laundry_wq(void);
-void nfsd4_destroy_laundry_wq(void);
-bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode);
-#else
-static inline int nfsd4_init_slabs(void) { return 0; }
-static inline void nfsd4_free_slabs(void) { }
-static inline int nfs4_state_start(void) { return 0; }
-static inline int nfs4_state_start_net(struct net *net) { return 0; }
-static inline void nfs4_state_shutdown(void) { }
-static inline void nfs4_state_shutdown_net(struct net *net) { }
-static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
-static inline char * nfs4_recoverydir(void) {return NULL; }
-static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
-{
-	return false;
-}
-static inline int nfsd4_create_laundry_wq(void) { return 0; };
-static inline void nfsd4_destroy_laundry_wq(void) {};
-static inline bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp,
-					      struct inode *inode)
-{
-	return false;
-}
-#endif
-
 /*
  * lockd binding
  */
@@ -197,28 +158,4 @@ void		nfsd_lockd_init(void);
 void		nfsd_lockd_shutdown(void);
 
 
-#ifdef CONFIG_NFSD_V4
-
-extern int nfsd4_is_junction(struct dentry *dentry);
-extern int register_cld_notifier(void);
-extern void unregister_cld_notifier(void);
-#ifdef CONFIG_NFSD_V4_2_INTER_SSC
-extern void nfsd4_ssc_init_umount_work(struct nfsd_net *nn);
-#endif
-
-extern void nfsd4_init_leases_net(struct nfsd_net *nn);
-
-#else /* CONFIG_NFSD_V4 */
-static inline int nfsd4_is_junction(struct dentry *dentry)
-{
-	return 0;
-}
-
-static inline void nfsd4_init_leases_net(struct nfsd_net *nn) { };
-
-#define register_cld_notifier() 0
-#define unregister_cld_notifier() do { } while(0)
-
-#endif /* CONFIG_NFSD_V4 */
-
 #endif /* LINUX_NFSD_NFSD_H */
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 7f6ffbe7be28..9cc8489978a3 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -28,6 +28,7 @@
 
 #include "nfsd.h"
 #include "nfserr.h"
+#include "nfs4ctl.h"
 #include "cache.h"
 #include "vfs.h"
 #include "netns.h"
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 25417bd94e71..fdfcd95971db 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -44,6 +44,7 @@
 
 #include "nfsd.h"
 #include "nfserr.h"
+#include "nfs4ctl.h"
 #include "netns.h"
 #include "stats.h"
 #include "vfs.h"
-- 
2.54.0

