Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7A5454CF5C
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576146; cv=none; b=M/CU9MVgDELrT/ZX+4UmxvOcdD1EVPWL3m9w/VYyQUkcVNTOYBNOco15P9mi32RZyfKks/sf0gpxc4xf/gIFmmlEh97KdFXpk1nDzA/3mcKV1q0Vo+HzRDoINjqRE/bTRhdVjhXwTo5PXyEV67jHiAL0YVTqSn/Wd9C1tsdCqus=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576146; c=relaxed/simple;
	bh=inBQ5NdRhrRw3kpis18U1chCenm2yWlSpj58PMGGwPE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PEKyNJo9qaLb9Uq7cEYMYEhEAQT1cL6+0dNza/Q0jfpHbPfUz7k3XuMfxzFnRRcRgMBfp8GgXuTfUyvBYjwwNMLHU5I//CnjzlTv7HJLZGmB+lYmpoyOm/k6PYeBI4oxvdjJGvCfw1rmm09X3W93KKeiRM8vt+A4dRKwX26pNAA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SgnmDZgJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SgnmDZgJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F13191F000FF;
	Wed, 16 Sep 2026 16:29:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576144;
	bh=U/m2Sn86JwK0zrwE71ZEzvQD5r+YCuoxMvJX82euqMM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SgnmDZgJ5i4rWaarYhwg64LM2bIIbhgXkjYXnrm53XctALd7CHCE6JjvyKm8/vh66
	 dAwQ2OulPZ2aSTgnmF2LQorlQ3mhAriRqEg1A85YtV3//t2pvQwv/NAwMWYlV46wQ0
	 gaJb6LtwkDzTQtJPw2TcATrgrgWIYTZozFh5shYQVvHbglrR1PdckN2TwDkFjuWY0J
	 isbyi2BEl5/C8UlKrtDo9bgKgS6hwtH8HBXI5iYUXEpE5DqIOFLPkJdY2M5IP8ZSFW
	 qi3+yNEFx63YFEXmcdFPad0IrMphZxyUZQnvv2vjlCMxNvqu+moDi38Zaqeao+z9qg
	 CM5Jj4oYDCS/g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 03/27] NFSD: Use xdrgen-generated NFSv2 protocol definitions
Date: Wed, 16 Sep 2026 12:28:34 -0400
Message-ID: <20260916162859.2051-6-cel@kernel.org>
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

Switch the server's NFSv2 implementation to use the machine-
generated protocol definitions.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/common.c     | 5 +++--
 fs/nfsd/nfsd.h             | 2 --
 fs/nfsd/nfserr.h           | 2 +-
 fs/nfsd/nfsproc.c          | 2 ++
 fs/nfsd/nfsxdr.c           | 9 ++++++++-
 include/linux/nfs_common.h | 4 ++--
 6 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs_common/common.c b/fs/nfs_common/common.c
index 0778743ae2c2..a05f2ace31ec 100644
--- a/fs/nfs_common/common.c
+++ b/fs/nfs_common/common.c
@@ -1,6 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0-only
 
 #include <linux/module.h>
+#include <uapi/linux/nfs.h>
 #include <linux/nfs_common.h>
 #include <linux/nfs4.h>
 
@@ -53,12 +54,12 @@ static const struct {
  * Returns a local errno value, or -EIO if the NFS status code is
  * not recognized.  This function is used jointly by NFSv2 and NFSv3.
  */
-int nfs_stat_to_errno(enum nfs_stat status)
+int nfs_stat_to_errno(int status)
 {
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(nfs_errtbl); i++) {
-		if (nfs_errtbl[i].stat == (int)status)
+		if (nfs_errtbl[i].stat == status)
 			return nfs_errtbl[i].errno;
 	}
 	return -EIO;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 69e3e92b3ec1..d1e413d21e76 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -12,8 +12,6 @@
 #include <linux/types.h>
 #include <linux/mount.h>
 
-#include <linux/nfs.h>
-#include <linux/nfs2.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
 
diff --git a/fs/nfsd/nfserr.h b/fs/nfsd/nfserr.h
index d1c434b834b2..35debf1141a3 100644
--- a/fs/nfsd/nfserr.h
+++ b/fs/nfsd/nfserr.h
@@ -10,7 +10,7 @@
 #ifndef LINUX_NFSD_NFSERR_H
 #define LINUX_NFSD_NFSERR_H
 
-#include <linux/nfs.h>
+#include <linux/sunrpc/xdrgen/nfs2.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 09d360839825..1ce75779312b 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -6,7 +6,9 @@
  */
 
 #include <linux/namei.h>
+#include <linux/sunrpc/svc.h>
 
+#include "nfs2xdr_gen.h"
 #include "cache.h"
 #include "xdr.h"
 #include "vfs.h"
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 0961c13d6ab1..d55e7d6414a0 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -22,6 +22,13 @@
  */
 #define NFS2_SATTR_SET_TO_SERVER_TIME	(1000000)
 
+/*
+ * Linux-internal ftype values for socket and unknown inodes, not
+ * in RFC 1094's wire enum; values match enum nfs_ftype.
+ */
+#define NFBAD	(7)
+#define NFSOCK	(6)
+
 /*
  * Mapping of S_IF* types to NFS file types
  */
@@ -599,7 +606,7 @@ svcxdr_encode_entry_common(struct nfsd_readdirres *resp, const char *name,
 	if (xdr_stream_encode_u32(xdr, (u32)ino) < 0)
 		return false;
 	/* name */
-	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS2_MAXNAMLEN)) < 0)
+	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS_MAXNAMLEN)) < 0)
 		return false;
 	/* cookie */
 	resp->cookie_offset = dirlist->len;
diff --git a/include/linux/nfs_common.h b/include/linux/nfs_common.h
index a541c3a02887..88dccd8564cf 100644
--- a/include/linux/nfs_common.h
+++ b/include/linux/nfs_common.h
@@ -6,11 +6,11 @@
 #define _LINUX_NFS_COMMON_H
 
 #include <linux/errno.h>
-#include <uapi/linux/nfs.h>
+#include <linux/types.h>
 
 /* Mapping from NFS error code to "errno" error code. */
 
-int nfs_stat_to_errno(enum nfs_stat status);
+int nfs_stat_to_errno(int status);
 int nfs4_stat_to_errno(int stat);
 
 __u32 nfs_localio_errno_to_nfs4_stat(int errno);
-- 
2.55.0

