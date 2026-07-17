Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4569F38B122
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313678; cv=none; b=aHp0KNYQmBOO3YRIcrSCbk+7J+R8vQ5L2nEn/9wqNdXOmCRhdGHTwcmormiPJRIYiP8gkPfAn4FFoqksSy7ErRHb6wBQzfWsg7Da6ymOH/F7FoDymVK7xtotfRpzZapEBsjlSZfa3SSGpEaTrqtKfNJh6W/miDyFpS+aiHPKJp8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313678; c=relaxed/simple;
	bh=/c53hWTgQYE8lSL+gjbJqGM541FzGiBVwbZ63n29dco=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=biuglCPX5GLB4DD4GAHmS5eW1IP1TmiKGM/0L9KmqwuFAIvbd0zJmiEHK1UvjB1pbJSA/LVAt6LKx0oAPn5CcD2BoR3nVRlUbplrOreJXDHdQmPAeEl1nnQdwGpuY0TUb/sj1632+byKc5iH/pafj35D97xK8x76H2W04BWacaU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ng7lmhZY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ng7lmhZY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5BA9F1F00A3E;
	Fri, 17 Jul 2026 18:41:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313675;
	bh=J4jYaI3yQsUS+FBAxxkuZZoNQSyY0SluxWLcnPfEFiI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ng7lmhZYm0A3OfsZm0RX8ZctJg/9JHFIFCFt+jI321W8T3IbCVRpkIfNifeDeGdd1
	 JqG0IciKd5+b+yYpi54lr3ZOr2sgicpVScb/ozYimq5JXo+a/jXXVvTNufu2YFIv5n
	 xWAcIxDiBuy8QRsWATYEWblDg5+QA2zx8cVicSMZW2M4DoOoMvpXIw6hOfpTRxPupf
	 hPDiVTdAnFn1dZTtPIK2f3y9i/kKHTV9fNNC6//YAFlhSlS7twi2wLtlNr6WRIgTeH
	 Y5Q4Z/U/wmymO72PqIqwih6Ofq0R8QmNal0rn3/aVPdL5Dyf7XbXNr/0dv9UsDY5PG
	 WTKF0A9Tx0mwg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/6] NFSD: Move pre-xdr'ed status codes out of nfsd.h
Date: Fri, 17 Jul 2026 14:41:08 -0400
Message-ID: <20260717184112.507548-3-cel@kernel.org>
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

nfsd.h is included by nearly every NFSD translation unit, so its
include of <linux/nfs4.h> reaches all of them, whether or not they
touch NFSv4. That include existed solely for the block of pre-xdr'ed
nfserr_* values at the end of the file: several of those values,
such as nfserr_delay and nfserr_admin_revoked, are built from
NFS4ERR_* constants defined in nfs4.h. The NFSD-internal error enum
that follows the block (NFSERR_EOF and friends) is anchored at an
impossible nfsstat4 value, thus it also needs nothing from nfs4.h.
But these codes are used by all NFS versions, so their new home must
be version-neutral.

Move the pre-xdr'ed value block and the internal error enum into a
new fs/nfsd/nfserr.h, which includes nfs4.h itself, and drop the
nfs4.h include from nfsd.h. Include nfserr.h directly from each
translation unit that references the pre-xdr'ed values or the
internal error codes, rather than carrying it in a widely-included
header.

A translation unit that includes nfsd.h without using the error
block no longer pulls in nfs4.h. The ones that reference the block
can still reach it through nfserr.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayout.c        |   1 +
 fs/nfsd/blocklayoutxdr.c     |   1 +
 fs/nfsd/export.c             |   1 +
 fs/nfsd/filecache.c          |   1 +
 fs/nfsd/flexfilelayout.c     |   1 +
 fs/nfsd/flexfilelayoutxdr.c  |   1 +
 fs/nfsd/lockd.c              |   1 +
 fs/nfsd/nfs2acl.c            |   1 +
 fs/nfsd/nfs3acl.c            |   1 +
 fs/nfsd/nfs3proc.c           |   1 +
 fs/nfsd/nfs3xdr.c            |   1 +
 fs/nfsd/nfs4acl.c            |   1 +
 fs/nfsd/nfs4callback.c       |   1 +
 fs/nfsd/nfs4idmap.c          |   1 +
 fs/nfsd/nfs4layouts.c        |   1 +
 fs/nfsd/nfs4proc.c           |   1 +
 fs/nfsd/nfs4state.c          |   1 +
 fs/nfsd/nfs4xdr.c            |   1 +
 fs/nfsd/nfscache.c           |   1 +
 fs/nfsd/nfsctl.c             |   1 +
 fs/nfsd/nfsd.h               | 143 --------------------
 fs/nfsd/{nfsd.h => nfserr.h} | 248 +----------------------------------
 fs/nfsd/nfsfh.c              |   1 +
 fs/nfsd/nfsproc.c            |   1 +
 fs/nfsd/nfssvc.c             |   2 +
 fs/nfsd/nfsxdr.c             |   1 +
 fs/nfsd/vfs.c                |   1 +
 27 files changed, 33 insertions(+), 384 deletions(-)
 copy fs/nfsd/{nfsd.h => nfserr.h} (50%)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 5be7721c22c2..df02cf746479 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -9,6 +9,7 @@
 
 #include <linux/nfsd/debug.h>
 
+#include "nfserr.h"
 #include "blocklayoutxdr.h"
 #include "pnfs.h"
 #include "filecache.h"
diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index 51cc2a07d7b3..a6589f5c878a 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -8,6 +8,7 @@
 #include <linux/nfs4.h>
 
 #include "nfsd.h"
+#include "nfserr.h"
 #include "blocklayoutxdr.h"
 #include "vfs.h"
 
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5aefb388cc27..f18de5f66ce6 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -21,6 +21,7 @@
 #include <uapi/linux/nfsd_netlink.h>
 
 #include "nfsd.h"
+#include "nfserr.h"
 #include "nfsfh.h"
 #include "netns.h"
 #include "pnfs.h"
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index b9548eb17c77..3539149cc75f 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -43,6 +43,7 @@
 
 #include "vfs.h"
 #include "nfsd.h"
+#include "nfserr.h"
 #include "nfsfh.h"
 #include "netns.h"
 #include "filecache.h"
diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index 6d531285ab43..9f532418cac8 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -13,6 +13,7 @@
 
 #include <linux/sunrpc/addr.h>
 
+#include "nfserr.h"
 #include "flexfilelayoutxdr.h"
 #include "pnfs.h"
 #include "vfs.h"
diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
index 374e52d3064a..97d8a28dd3a0 100644
--- a/fs/nfsd/flexfilelayoutxdr.c
+++ b/fs/nfsd/flexfilelayoutxdr.c
@@ -6,6 +6,7 @@
 #include <linux/nfs4.h>
 
 #include "nfsd.h"
+#include "nfserr.h"
 #include "flexfilelayoutxdr.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_PNFS
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 72a5b499839d..f5a4f352f8ab 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -10,6 +10,7 @@
 #include <linux/file.h>
 #include <linux/lockd/bind.h>
 #include "nfsd.h"
+#include "nfserr.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_LOCKD
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 190f5a001900..aba69dd278a1 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -6,6 +6,7 @@
  */
 
 #include "nfsd.h"
+#include "nfserr.h"
 /* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
 #include <linux/gfp.h>
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 6b6b289db636..7183995182ab 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -6,6 +6,7 @@
  */
 
 #include "nfsd.h"
+#include "nfserr.h"
 /* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
 #include <linux/gfp.h>
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 1df3c719e0da..4b3075c05b97 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -13,6 +13,7 @@
 #include "cache.h"
 #include "xdr3.h"
 #include "vfs.h"
+#include "nfserr.h"
 #include "filecache.h"
 #include "trace.h"
 
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e481804bb120..196bcc6edebb 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -13,6 +13,7 @@
 #include "auth.h"
 #include "netns.h"
 #include "vfs.h"
+#include "nfserr.h"
 
 /*
  * Force construction of an empty post-op attr
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 2c2f2fd89e87..94f6ad381ebe 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -40,6 +40,7 @@
 
 #include "nfsfh.h"
 #include "nfsd.h"
+#include "nfserr.h"
 #include "acl.h"
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a901bbe67e03..509195d488c9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -37,6 +37,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/slab.h>
 #include "nfsd.h"
+#include "nfserr.h"
 #include "state.h"
 #include "netns.h"
 #include "stats.h"
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index e9faf8b78f74..4e5297593963 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -41,6 +41,7 @@
 #include "auth.h"
 #include "idmap.h"
 #include "nfsd.h"
+#include "nfserr.h"
 #include "netns.h"
 #include "vfs.h"
 
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 22bcb6d09f70..4187202f9acc 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -9,6 +9,7 @@
 #include <linux/sched.h>
 #include <linux/sunrpc/addr.h>
 
+#include "nfserr.h"
 #include "pnfs.h"
 #include "netns.h"
 #include "trace.h"
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d4e9010308a4..2aef7f7202b3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -51,6 +51,7 @@
 #include "netns.h"
 #include "acl.h"
 #include "pnfs.h"
+#include "nfserr.h"
 #include "trace.h"
 
 static bool inter_copy_offload_enable;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 18e17232cf94..a3bfcefa7bc9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -52,6 +52,7 @@
 #include "vfs.h"
 #include "current_stateid.h"
 #include "stats.h"
+#include "nfserr.h"
 
 #include "netns.h"
 #include "pnfs.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 05d64733094b..7ccc7c897b00 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -54,6 +54,7 @@
 #include "xdr4.h"
 #include "vfs.h"
 #include "state.h"
+#include "nfserr.h"
 #include "cache.h"
 #include "netns.h"
 #include "pnfs.h"
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index c7db532c8523..80364b91331a 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -19,6 +19,7 @@
 #include <net/checksum.h>
 
 #include "nfsd.h"
+#include "nfserr.h"
 #include "netns.h"
 #include "stats.h"
 #include "cache.h"
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index adb032b7311a..8521b648a970 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -23,6 +23,7 @@
 
 #include "idmap.h"
 #include "nfsd.h"
+#include "nfserr.h"
 #include "netns.h"
 #include "stats.h"
 #include "cache.h"
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 76a69d9a4e73..384a2498b6a2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -15,7 +15,6 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs3.h>
-#include <linux/nfs4.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
 
@@ -198,148 +197,6 @@ void		nfsd_lockd_init(void);
 void		nfsd_lockd_shutdown(void);
 
 
-/*
- * These macros provide pre-xdr'ed values for faster operation.
- */
-#define	nfs_ok			cpu_to_be32(NFS_OK)
-#define	nfserr_perm		cpu_to_be32(NFSERR_PERM)
-#define	nfserr_noent		cpu_to_be32(NFSERR_NOENT)
-#define	nfserr_io		cpu_to_be32(NFSERR_IO)
-#define	nfserr_nxio		cpu_to_be32(NFSERR_NXIO)
-#define	nfserr_acces		cpu_to_be32(NFSERR_ACCES)
-#define	nfserr_exist		cpu_to_be32(NFSERR_EXIST)
-#define	nfserr_xdev		cpu_to_be32(NFSERR_XDEV)
-#define	nfserr_nodev		cpu_to_be32(NFSERR_NODEV)
-#define	nfserr_notdir		cpu_to_be32(NFSERR_NOTDIR)
-#define	nfserr_isdir		cpu_to_be32(NFSERR_ISDIR)
-#define	nfserr_inval		cpu_to_be32(NFSERR_INVAL)
-#define	nfserr_fbig		cpu_to_be32(NFSERR_FBIG)
-#define	nfserr_nospc		cpu_to_be32(NFSERR_NOSPC)
-#define	nfserr_rofs		cpu_to_be32(NFSERR_ROFS)
-#define	nfserr_mlink		cpu_to_be32(NFSERR_MLINK)
-#define	nfserr_nametoolong	cpu_to_be32(NFSERR_NAMETOOLONG)
-#define	nfserr_notempty		cpu_to_be32(NFSERR_NOTEMPTY)
-#define	nfserr_dquot		cpu_to_be32(NFSERR_DQUOT)
-#define	nfserr_stale		cpu_to_be32(NFSERR_STALE)
-#define	nfserr_remote		cpu_to_be32(NFSERR_REMOTE)
-#define	nfserr_wflush		cpu_to_be32(NFSERR_WFLUSH)
-#define	nfserr_badhandle	cpu_to_be32(NFSERR_BADHANDLE)
-#define	nfserr_notsync		cpu_to_be32(NFSERR_NOT_SYNC)
-#define	nfserr_badcookie	cpu_to_be32(NFSERR_BAD_COOKIE)
-#define	nfserr_notsupp		cpu_to_be32(NFSERR_NOTSUPP)
-#define	nfserr_toosmall		cpu_to_be32(NFSERR_TOOSMALL)
-#define	nfserr_serverfault	cpu_to_be32(NFSERR_SERVERFAULT)
-#define	nfserr_badtype		cpu_to_be32(NFSERR_BADTYPE)
-#define	nfserr_jukebox		cpu_to_be32(NFSERR_JUKEBOX)
-#define	nfserr_denied		cpu_to_be32(NFSERR_DENIED)
-#define	nfserr_deadlock		cpu_to_be32(NFSERR_DEADLOCK)
-#define nfserr_expired          cpu_to_be32(NFSERR_EXPIRED)
-#define	nfserr_bad_cookie	cpu_to_be32(NFSERR_BAD_COOKIE)
-#define	nfserr_same		cpu_to_be32(NFSERR_SAME)
-#define	nfserr_clid_inuse	cpu_to_be32(NFSERR_CLID_INUSE)
-#define	nfserr_stale_clientid	cpu_to_be32(NFSERR_STALE_CLIENTID)
-#define	nfserr_resource		cpu_to_be32(NFSERR_RESOURCE)
-#define	nfserr_moved		cpu_to_be32(NFSERR_MOVED)
-#define	nfserr_nofilehandle	cpu_to_be32(NFSERR_NOFILEHANDLE)
-#define	nfserr_minor_vers_mismatch	cpu_to_be32(NFSERR_MINOR_VERS_MISMATCH)
-#define nfserr_share_denied	cpu_to_be32(NFSERR_SHARE_DENIED)
-#define nfserr_stale_stateid	cpu_to_be32(NFSERR_STALE_STATEID)
-#define nfserr_old_stateid	cpu_to_be32(NFSERR_OLD_STATEID)
-#define nfserr_bad_stateid	cpu_to_be32(NFSERR_BAD_STATEID)
-#define nfserr_bad_seqid	cpu_to_be32(NFSERR_BAD_SEQID)
-#define	nfserr_symlink		cpu_to_be32(NFSERR_SYMLINK)
-#define	nfserr_not_same		cpu_to_be32(NFSERR_NOT_SAME)
-#define nfserr_lock_range	cpu_to_be32(NFSERR_LOCK_RANGE)
-#define	nfserr_restorefh	cpu_to_be32(NFSERR_RESTOREFH)
-#define	nfserr_attrnotsupp	cpu_to_be32(NFSERR_ATTRNOTSUPP)
-#define	nfserr_bad_xdr		cpu_to_be32(NFSERR_BAD_XDR)
-#define	nfserr_openmode		cpu_to_be32(NFSERR_OPENMODE)
-#define	nfserr_badowner		cpu_to_be32(NFSERR_BADOWNER)
-#define	nfserr_locks_held	cpu_to_be32(NFSERR_LOCKS_HELD)
-#define	nfserr_op_illegal	cpu_to_be32(NFSERR_OP_ILLEGAL)
-#define	nfserr_grace		cpu_to_be32(NFSERR_GRACE)
-#define	nfserr_no_grace		cpu_to_be32(NFSERR_NO_GRACE)
-#define	nfserr_reclaim_bad	cpu_to_be32(NFSERR_RECLAIM_BAD)
-#define	nfserr_badname		cpu_to_be32(NFSERR_BADNAME)
-#define	nfserr_admin_revoked	cpu_to_be32(NFS4ERR_ADMIN_REVOKED)
-#define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
-#define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
-#define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
-#define nfserr_delay			cpu_to_be32(NFS4ERR_DELAY)
-#define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
-#define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
-#define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
-#define nfserr_badsession		cpu_to_be32(NFS4ERR_BADSESSION)
-#define nfserr_badslot			cpu_to_be32(NFS4ERR_BADSLOT)
-#define nfserr_complete_already		cpu_to_be32(NFS4ERR_COMPLETE_ALREADY)
-#define nfserr_conn_not_bound_to_session cpu_to_be32(NFS4ERR_CONN_NOT_BOUND_TO_SESSION)
-#define nfserr_deleg_already_wanted	cpu_to_be32(NFS4ERR_DELEG_ALREADY_WANTED)
-#define nfserr_back_chan_busy		cpu_to_be32(NFS4ERR_BACK_CHAN_BUSY)
-#define nfserr_layouttrylater		cpu_to_be32(NFS4ERR_LAYOUTTRYLATER)
-#define nfserr_layoutunavailable	cpu_to_be32(NFS4ERR_LAYOUTUNAVAILABLE)
-#define nfserr_nomatching_layout	cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT)
-#define nfserr_recallconflict		cpu_to_be32(NFS4ERR_RECALLCONFLICT)
-#define nfserr_unknown_layouttype	cpu_to_be32(NFS4ERR_UNKNOWN_LAYOUTTYPE)
-#define nfserr_seq_misordered		cpu_to_be32(NFS4ERR_SEQ_MISORDERED)
-#define nfserr_sequence_pos		cpu_to_be32(NFS4ERR_SEQUENCE_POS)
-#define nfserr_req_too_big		cpu_to_be32(NFS4ERR_REQ_TOO_BIG)
-#define nfserr_rep_too_big		cpu_to_be32(NFS4ERR_REP_TOO_BIG)
-#define nfserr_rep_too_big_to_cache	cpu_to_be32(NFS4ERR_REP_TOO_BIG_TO_CACHE)
-#define nfserr_retry_uncached_rep	cpu_to_be32(NFS4ERR_RETRY_UNCACHED_REP)
-#define nfserr_unsafe_compound		cpu_to_be32(NFS4ERR_UNSAFE_COMPOUND)
-#define nfserr_too_many_ops		cpu_to_be32(NFS4ERR_TOO_MANY_OPS)
-#define nfserr_op_not_in_session	cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION)
-#define nfserr_hash_alg_unsupp		cpu_to_be32(NFS4ERR_HASH_ALG_UNSUPP)
-#define nfserr_clientid_busy		cpu_to_be32(NFS4ERR_CLIENTID_BUSY)
-#define nfserr_pnfs_io_hole		cpu_to_be32(NFS4ERR_PNFS_IO_HOLE)
-#define nfserr_seq_false_retry		cpu_to_be32(NFS4ERR_SEQ_FALSE_RETRY)
-#define nfserr_bad_high_slot		cpu_to_be32(NFS4ERR_BAD_HIGH_SLOT)
-#define nfserr_deadsession		cpu_to_be32(NFS4ERR_DEADSESSION)
-#define nfserr_encr_alg_unsupp		cpu_to_be32(NFS4ERR_ENCR_ALG_UNSUPP)
-#define nfserr_pnfs_no_layout		cpu_to_be32(NFS4ERR_PNFS_NO_LAYOUT)
-#define nfserr_not_only_op		cpu_to_be32(NFS4ERR_NOT_ONLY_OP)
-#define nfserr_wrong_cred		cpu_to_be32(NFS4ERR_WRONG_CRED)
-#define nfserr_wrong_type		cpu_to_be32(NFS4ERR_WRONG_TYPE)
-#define nfserr_dirdeleg_unavail		cpu_to_be32(NFS4ERR_DIRDELEG_UNAVAIL)
-#define nfserr_reject_deleg		cpu_to_be32(NFS4ERR_REJECT_DELEG)
-#define nfserr_returnconflict		cpu_to_be32(NFS4ERR_RETURNCONFLICT)
-#define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
-#define nfserr_partner_notsupp		cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
-#define nfserr_partner_no_auth		cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
-#define nfserr_union_notsupp		cpu_to_be32(NFS4ERR_UNION_NOTSUPP)
-#define nfserr_offload_denied		cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
-#define nfserr_wrong_lfs		cpu_to_be32(NFS4ERR_WRONG_LFS)
-#define nfserr_badlabel			cpu_to_be32(NFS4ERR_BADLABEL)
-#define nfserr_file_open		cpu_to_be32(NFS4ERR_FILE_OPEN)
-#define nfserr_xattr2big		cpu_to_be32(NFS4ERR_XATTR2BIG)
-#define nfserr_noxattr			cpu_to_be32(NFS4ERR_NOXATTR)
-
-/*
- * Error codes for internal use.  These are based at an impossible
- * nfsstat4 value so that, once converted to be32, they cannot conflict
- * with any value defined by the protocol (compare the nlm__int__* codes
- * in fs/lockd/lockd.h).
- */
-enum {
-/* end-of-file indicator in readdir */
-	NFSERR_EOF = 30000,
-#define	nfserr_eof		cpu_to_be32(NFSERR_EOF)
-
-/* replay detected */
-	NFSERR_REPLAY_ME,
-#define	nfserr_replay_me	cpu_to_be32(NFSERR_REPLAY_ME)
-
-/* nfs41 replay detected */
-	NFSERR_REPLAY_CACHE,
-#define	nfserr_replay_cache	cpu_to_be32(NFSERR_REPLAY_CACHE)
-
-/* symlink found where dir expected - handled differently to
- * other symlink found errors by NFSv3.
- */
-	NFSERR_SYMLINK_NOT_DIR,
-#define	nfserr_symlink_not_dir	cpu_to_be32(NFSERR_SYMLINK_NOT_DIR)
-};
-
 #ifdef CONFIG_NFSD_V4
 
 /* before processing a COMPOUND operation, we have to check that there
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfserr.h
similarity index 50%
copy from fs/nfsd/nfsd.h
copy to fs/nfsd/nfserr.h
index 76a69d9a4e73..9b9df7aab220 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfserr.h
@@ -1,202 +1,17 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /*
- * Hodge-podge collection of knfsd-related stuff.
- * I will sort this out later.
+ * Pre-xdr'ed nfsd error values and nfsd-internal error codes.
  *
- * Copyright (C) 1995-1997 Olaf Kirch <okir@monad.swb.de>
+ * Separated from nfsd.h so that nfsd.h itself does not have to pull
+ * in <linux/nfs4.h>: the NFS4ERR_* values used below are the only
+ * reason that include was needed.
  */
 
-#ifndef LINUX_NFSD_NFSD_H
-#define LINUX_NFSD_NFSD_H
-
-#include <linux/types.h>
-#include <linux/mount.h>
+#ifndef LINUX_NFSD_NFSERR_H
+#define LINUX_NFSD_NFSERR_H
 
 #include <linux/nfs.h>
-#include <linux/nfs2.h>
-#include <linux/nfs3.h>
 #include <linux/nfs4.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/sunrpc/svc_xprt.h>
-
-#include <uapi/linux/nfsd/debug.h>
-
-#undef ifdebug
-#ifdef CONFIG_SUNRPC_DEBUG
-# define ifdebug(flag)		if (nfsd_debug & NFSDDBG_##flag)
-#else
-# define ifdebug(flag)		if (0)
-#endif
-
-/*
- * nfsd version
- */
-#define NFSD_MINVERS			2
-#define	NFSD_MAXVERS			4
-#define NFSD_SUPPORTED_MINOR_VERSION	2
-bool nfsd_support_version(int vers);
-
-/*
- * Default and maximum payload size (NFS READ or WRITE), in bytes.
- * The maximum is an implementation limit.
- */
-enum {
-	NFSSVC_DEFBLKSIZE       = 4 * 1024 * 1024,
-	NFSSVC_MAXBLKSIZE       = RPCSVC_MAXPAYLOAD,
-};
-
-/* Maximum number of operations per session compound */
-#define NFSD_MAX_OPS_PER_COMPOUND	200
-
-extern struct svc_program	nfsd_programs[];
-extern const struct svc_version	nfsd_version2, nfsd_version3, nfsd_version4;
-extern struct mutex		nfsd_mutex;
-extern atomic_t			nfsd_th_cnt;		/* number of available threads */
-
-extern const struct seq_operations nfs_exports_op;
-
-struct nfsd_thread_local_info {
-	struct nfs4_client	**ntli_lease_breaker;
-	int			ntli_cachetype;
-};
-
-/*
- * Common void argument and result helpers
- */
-struct nfsd_voidargs { };
-struct nfsd_voidres { };
-bool		nfssvc_decode_voidarg(struct svc_rqst *rqstp,
-				      struct xdr_stream *xdr);
-bool		nfssvc_encode_voidres(struct svc_rqst *rqstp,
-				      struct xdr_stream *xdr);
-
-/*
- * Function prototypes.
- */
-int		nfsd_svc(int n, int *nservers, struct net *net,
-			 const struct cred *cred, const char *scope);
-int		nfsd_dispatch(struct svc_rqst *rqstp);
-
-int		nfsd_nrthreads(struct net *);
-int		nfsd_nrpools(struct net *);
-int		nfsd_get_nrthreads(int n, int *, struct net *);
-int		nfsd_set_nrthreads(int n, int *, struct net *);
-void		nfsd_shutdown_threads(struct net *net);
-
-struct svc_rqst *nfsd_current_rqst(void);
-
-struct nfsdfs_client {
-	struct kref cl_ref;
-	void (*cl_release)(struct kref *kref);
-};
-
-struct nfsd_net;
-
-struct nfsdfs_client *get_nfsdfs_client(struct inode *);
-struct dentry *nfsd_client_mkdir(struct nfsd_net *nn,
-				 struct nfsdfs_client *ncl, u32 id,
-				 const struct tree_descr *,
-				 struct dentry **fdentries);
-void nfsd_client_rmdir(struct dentry *dentry);
-int nfsd_cache_notify(struct cache_detail *cd, struct cache_head *h, u32 cache_type);
-
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-#ifdef CONFIG_NFSD_V2_ACL
-extern const struct svc_version nfsd_acl_version2;
-#else
-#define nfsd_acl_version2 NULL
-#endif
-#ifdef CONFIG_NFSD_V3_ACL
-extern const struct svc_version nfsd_acl_version3;
-#else
-#define nfsd_acl_version3 NULL
-#endif
-#endif
-
-#if IS_ENABLED(CONFIG_NFS_LOCALIO)
-extern const struct svc_version localio_version1;
-#endif
-
-enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
-int nfsd_vers(struct nfsd_net *nn, int vers, enum vers_op change);
-int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change);
-void nfsd_reset_versions(struct nfsd_net *nn);
-int nfsd_create_serv(struct net *net);
-void nfsd_destroy_serv(struct net *net);
-
-#ifdef CONFIG_DEBUG_FS
-void nfsd_debugfs_init(void);
-void nfsd_debugfs_exit(void);
-#else
-static inline void nfsd_debugfs_init(void) {}
-static inline void nfsd_debugfs_exit(void) {}
-#endif
-
-extern bool nfsd_disable_splice_read __read_mostly;
-extern bool nfsd_delegts_enabled __read_mostly;
-
-enum {
-	/* Any new NFSD_IO enum value must be added at the end */
-	NFSD_IO_BUFFERED,
-	NFSD_IO_DONTCACHE,
-	NFSD_IO_DIRECT,
-};
-
-extern u64 nfsd_io_cache_read __read_mostly;
-extern u64 nfsd_io_cache_write __read_mostly;
-
-extern int nfsd_max_blksize;
-
-static inline int nfsd_v4client(struct svc_rqst *rq)
-{
-	return rq && rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
-}
-
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
-/*
- * lockd binding
- */
-void		nfsd_lockd_init(void);
-void		nfsd_lockd_shutdown(void);
-
 
 /*
  * These macros provide pre-xdr'ed values for faster operation.
@@ -340,53 +155,4 @@ enum {
 #define	nfserr_symlink_not_dir	cpu_to_be32(NFSERR_SYMLINK_NOT_DIR)
 };
 
-#ifdef CONFIG_NFSD_V4
-
-/* before processing a COMPOUND operation, we have to check that there
- * is enough space in the buffer for XDR encode to succeed.  otherwise,
- * we might process an operation with side effects, and be unable to
- * tell the client that the operation succeeded.
- *
- * COMPOUND_SLACK_SPACE - this is the minimum bytes of buffer space
- * needed to encode an "ordinary" _successful_ operation.  (GETATTR,
- * READ, READDIR, and READLINK have their own buffer checks.)  if we
- * fall below this level, we fail the next operation with NFS4ERR_RESOURCE.
- *
- * COMPOUND_ERR_SLACK_SPACE - this is the minimum bytes of buffer space
- * needed to encode an operation which has failed with NFS4ERR_RESOURCE.
- * care is taken to ensure that we never fall below this level for any
- * reason.
- */
-#define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
-#define COMPOUND_ERR_SLACK_SPACE	16     /* OP_SETATTR */
-
-#define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
-#define	NFSD_COURTESY_CLIENT_TIMEOUT	(24 * 60 * 60)	/* seconds */
-#define	NFSD_CLIENT_MAX_TRIM_PER_RUN	128
-#define	NFS4_CLIENTS_PER_GB		1024
-#define NFSD_DELEGRETURN_TIMEOUT	(HZ / 34)	/* 30ms */
-#define	NFSD_CB_GETATTR_TIMEOUT		NFSD_DELEGRETURN_TIMEOUT
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
-#endif /* LINUX_NFSD_NFSD_H */
+#endif /* LINUX_NFSD_NFSERR_H */
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index c0a46784d525..fd721a5a6b37 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -13,6 +13,7 @@
 #include <linux/sunrpc/svcauth_gss.h>
 #include <crypto/utils.h>
 #include "nfsd.h"
+#include "nfserr.h"
 #include "netns.h"
 #include "stats.h"
 #include "vfs.h"
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 2a82fa64e478..919acfba356a 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -10,6 +10,7 @@
 #include "cache.h"
 #include "xdr.h"
 #include "vfs.h"
+#include "nfserr.h"
 #include "trace.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2edf716ea022..7f6ffbe7be28 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -25,7 +25,9 @@
 #include <net/addrconf.h>
 #include <net/ipv6.h>
 #include <net/net_namespace.h>
+
 #include "nfsd.h"
+#include "nfserr.h"
 #include "cache.h"
 #include "vfs.h"
 #include "netns.h"
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 019f0cc971a7..0961c13d6ab1 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -8,6 +8,7 @@
 #include <linux/filelock.h>
 
 #include "vfs.h"
+#include "nfserr.h"
 #include "xdr.h"
 #include "auth.h"
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ef1881f520f6..25417bd94e71 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -43,6 +43,7 @@
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
+#include "nfserr.h"
 #include "netns.h"
 #include "stats.h"
 #include "vfs.h"
-- 
2.54.0

