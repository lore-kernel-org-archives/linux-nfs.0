Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1B573AB480
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 13:04:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785157455; cv=none; b=SAhtFngEBCh6dYTUbEy5vZVCbpmLt5rEVMXpgvzzE/dX3tABzUN30HivcNLqFAw7XcueL/mjkJj5o5XGpl4/ifGzB8GRd5gh9RykYQqXuDyR0DiBfmlAE4KJCvrEiJmHZMuchwGn71BDhysS7W0ZefT6zQtmT0+YXXgB6l88aXg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785157455; c=relaxed/simple;
	bh=rKt/vZO5IU4MOn7gFchQsKV7znKYeyi7aj8Y9GyU6Ig=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fJDYa03kFA+AavQBYXNks7/6OCe1moBXEZdwwz7o8it1AY0jPjzsljz8mZRsPoerQozv+JSJwAj2RduB4PL0HgPJFZ+i2Dbw0sakSbI3SS9O2ZVFDJhCUROX/jaWheriX46KTJOT5ZKqwTC3m4smHaN2lqZuBiV1hIXSItX8OVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SRh6q5+6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SRh6q5+6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 299871F000E9;
	Mon, 27 Jul 2026 13:04:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785157454;
	bh=W+UdcdA1sbgsLgWKw+8nyFK0GBzzpxyQmJNPhShlzk8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SRh6q5+6HhBRGEAGWJJp226sN+jlTcjIF3qCivXRV7/SQI3FD89kJZgG4L6yUKcwk
	 Nm+Z+Mp+jIILfh2K38liFnYQbpz6b8YgBgQ7ZqlbxjFBP57CYeIb0c19zASeM+w0iW
	 vw4V3F6WVgrWe7xoIkAbQjfuBBZqlPRKsjrTyyMv9mNG7rEN9nL8LNak2SVSd8cZyJ
	 k8xXzJ/+D5N0lZPAR8zemu4glY6lexXh9udhZyvtWyIMBHKyy1bF3aWH4n2Dp/8Rnp
	 JfB3qU8AhvLEBojXbwTGWf/SaVhssKb4k5rz7NsvevRR6XtCQl2AqAAf5FTzdbpYE0
	 JAuhgUWxCLcKw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] NFSD: Tighten header includes in localio.c
Date: Mon, 27 Jul 2026 09:04:10 -0400
Message-ID: <20260727130410.14887-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260727130410.14887-1-cel@kernel.org>
References: <20260727130410.14887-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

As a prerequisite to converting NFSD to use xdrgen more broadly,
NFSD source files should not depend on NFS client headers.
fs/nfsd/localio.c is server-side LOCALIO code, yet it pulled in
three of them: <linux/nfs_fs.h>, the client inode header (struct
nfs_inode, NFS_I(), writeback helpers), which server code never
uses; <linux/nfs_xdr.h>, whose only referenced symbol is
decode_opaque_fixed(), a static inline that exists to remap the
error return to -EIO for client call sites; and the catch-all
<linux/nfs.h>.

Convert the UUID decoder to call the canonical SUNRPC primitive
xdr_stream_decode_opaque_fixed() directly. It is shared by client
and server, performs the identical bounds check, and is already
reachable through <linux/sunrpc/clnt.h>. With the wrapper gone,
localio.c references no symbol from <linux/nfs_xdr.h>, and with
that header gone, none of the NFSv3 definitions its structs embed
are needed here.

Drop all three client includes and add what the file actually
uses: struct nfs_fh comes from <linux/nfs_fh.h>, included directly
rather than through nfslocalio.h's conditional re-export, and
NFS4_FHSIZE from <linux/nfs4.h>. enum nfs_stat and
nfs_stat_to_errno continue to come from the already-included
<linux/nfs_common.h>.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/localio.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/localio.c b/fs/nfsd/localio.c
index c458c01e9478..4110be02b750 100644
--- a/fs/nfsd/localio.c
+++ b/fs/nfsd/localio.c
@@ -11,11 +11,10 @@
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/nfs.h>
+#include <linux/nfs4.h>
 #include <linux/nfs_common.h>
+#include <linux/nfs_fh.h>
 #include <linux/nfslocalio.h>
-#include <linux/nfs_fs.h>
-#include <linux/nfs_xdr.h>
 #include <linux/string.h>
 
 #include "nfsd.h"
@@ -179,7 +178,7 @@ static bool localio_decode_uuidarg(struct svc_rqst *rqstp,
 	struct localio_uuidarg *argp = rqstp->rq_argp;
 	u8 uuid[UUID_SIZE];
 
-	if (decode_opaque_fixed(xdr, uuid, UUID_SIZE))
+	if (xdr_stream_decode_opaque_fixed(xdr, uuid, UUID_SIZE) < 0)
 		return false;
 	import_uuid(&argp->uuid, uuid);
 
-- 
2.54.0

