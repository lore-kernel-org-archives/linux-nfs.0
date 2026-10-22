Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677226;
	b=yODVZ9i/0B/wcDeOnoFssWuM86Zuw5794R9hekVJBzlNEbSJeTtJU9uZveEZQAmCz/Xe
	 iTmkcCPy+3HD7LmSP6yfAcHqozJnTCLLqDbYaR2CXjPYR7xI+5Qm0TwO3OyikY7kBeGSr
	 PhCLenqPy+paB9AxwnEMET4GqsGuSvoMSepAYkPQgDhj5J/67jWZavkxMq00rjJdKDjwz
	 hXS+64ucKmUneQI0F0EZCULfQoZdDPd9ntsO1xwGM/s/7MghqFuRPwoh9PTRa7mBRuYYC
	 qtQTdFvvdiWYG/L3o48NzN9auWgrHEVBhLLV6Krg5dkbL/cadNrSCsxoxw9/HRpu9pw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677226;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=akwOOTosmC2eP6fiyLD75mFFMeCxu+VMGFUFLqdQOuE=;
	b=zxZoB14Z93ryEdJ6IRye+Te+nhVabP2qsIFrnBE7TD7IwNvwaLbO+tNxrTiVZpLYcNWk
	 s/e8AiNam9Ytthg0fgqO0WRFYNVH8/4/6w1VZhd+ibuKhJptMMmOJMhGLK7I/AlCusIsr
	 Dgdd1wKqMOI5Zb3yo5N93DhhF2vizPjhuaceVeYrX25wCnqPUUPIPwYzUkXP+1dWwCjc6
	 TMhN3oAxiHIm03OvGFTC+x7jRKFcsNMTw9tWiFHsMQ9MC/J7FWWq3xrYLQf51Rbz88BHd
	 x6ghMhQuUqwma/JOSsBkXhSQQnR0n2Tn+a5sQimgjvVfAQBvM5CuxReW6M9I2+P89Pw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SJ+bwhPQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87F9860A3811
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SJ+bwhPQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D894D1F000CB;
	Thu, 22 Oct 2026 13:53:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677226;
	bh=akwOOTosmC2eP6fiyLD75mFFMeCxu+VMGFUFLqdQOuE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SJ+bwhPQ3YOw8OlWHVC2/zBNchchCoCBQ7ttqccVKnovoKOIwOgQFfC0rwDUKkat7
	 kntIXzXhRrO/oMYwyRdtp5ah9xx8LOO4M+IpG0Loj5gAsrExDPk+fk6RXjaeVOjiF0
	 d0+DzPsy3LjsEpK72gcuHs1RKDujAJYaajdqFQN95w/bO7560r9bzZ8hhUrnhznETX
	 /tPXselBJbKjpCjC6osM7JzzVQv5KcpNgcIiNcbuCE+lEV/EdavGF4amVTnxqV2k4Q
	 +6QvZEFCuwfQ30KBkyIbFeVag3y3y9F8A9GgocVFj0aeqprvEbBrtblazdc9zo0ndA
	 n9+QLQcV6VAoQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 05/17] NFSD: Move the definition of NFS_ACL_MAX_ENTRIES
Date: Thu, 22 Oct 2026 09:53:29 -0400
Message-ID: <20261022135341.14265-6-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Separate the inclusion of protocol-defined items from forward
declarations for internal functions. This makes it easier to
convert single source files to use the xdrgen-built headers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/nfs3acl.c            | 1 +
 fs/nfs/nfs3client.c         | 1 +
 fs/nfs/nfs3xdr.c            | 1 +
 fs/nfs_common/nfsacl.c      | 2 ++
 fs/nfsd/nfs2acl.c           | 3 ++-
 fs/nfsd/nfs3acl.c           | 4 +++-
 fs/nfsd/nfs4xdr.c           | 1 +
 fs/nfsd/nfssvc.c            | 1 +
 include/linux/nfsacl.h      | 5 -----
 include/uapi/linux/nfsacl.h | 2 ++
 10 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index a126eb31f62f..e9b9ee7cc354 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -6,6 +6,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/posix_acl_xattr.h>
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 
 #include "internal.h"
 #include "nfs3_fs.h"
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 5d97c1d38bb6..eeb86c8a4a04 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -3,6 +3,7 @@
 #include <linux/nfs_mount.h>
 #include <linux/sunrpc/addr.h>
 #include <net/handshake.h>
+#include <uapi/linux/nfsacl.h>
 #include "internal.h"
 #include "nfs3_fs.h"
 #include "netns.h"
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index e745e78faab0..3251c1434e71 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -21,6 +21,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 #include <linux/nfs_common.h>
 
 #include "internal.h"
diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 09d941303d16..a66294fcfb6e 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -29,6 +29,8 @@
 #include <linux/nfs3.h>
 #include <linux/sort.h>
 
+#include <uapi/linux/nfsacl.h>
+
 MODULE_DESCRIPTION("NFS ACL support");
 MODULE_LICENSE("GPL");
 
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 14f637d87685..93224144105e 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -7,8 +7,9 @@
 
 #include "nfsd.h"
 #include "nfserr.h"
-/* FIXME: nfsacl.h is a broken header */
+
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 #include <linux/gfp.h>
 #include "cache.h"
 #include "xdr.h"
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 324cfdd7b262..58f1297c88f9 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -7,9 +7,11 @@
 
 #include "nfsd.h"
 #include "nfserr.h"
-/* FIXME: nfsacl.h is a broken header */
+
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 #include <linux/gfp.h>
+
 #include "cache.h"
 #include "xdr3.h"
 #include "vfs.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c4fd840da4d9..f08b87d3f469 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -44,6 +44,7 @@
 #include <linux/xattr.h>
 #include <linux/vmalloc.h>
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 
 #include <uapi/linux/xattr.h>
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 067543da3ca0..2d719e9ab152 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -19,6 +19,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
+#include <uapi/linux/nfsacl.h>
 #include <linux/nfslocalio.h>
 #include <linux/seq_file.h>
 #include <linux/inetdevice.h>
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index fc00280e67b1..403f5f5144e3 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -7,13 +7,8 @@
 #ifndef __LINUX_NFSACL_H
 #define __LINUX_NFSACL_H
 
-
 #include <linux/posix_acl.h>
 #include <linux/sunrpc/xdr.h>
-#include <uapi/linux/nfsacl.h>
-
-/* Maximum number of ACL entries over NFS */
-#define NFS_ACL_MAX_ENTRIES	1024
 
 #define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
 				 >> PAGE_SHIFT)
diff --git a/include/uapi/linux/nfsacl.h b/include/uapi/linux/nfsacl.h
index 2c2ad204d3b0..8db7ad6d1dfe 100644
--- a/include/uapi/linux/nfsacl.h
+++ b/include/uapi/linux/nfsacl.h
@@ -19,6 +19,8 @@
 #define ACLPROC3_GETACL		1
 #define ACLPROC3_SETACL		2
 
+/* Maximum number of ACL entries over NFS */
+#define NFS_ACL_MAX_ENTRIES	1024
 
 /* Flags for the getacl/setacl mode */
 #define NFS_ACL			0x0001
-- 
2.56.0

