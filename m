Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49B083932F7
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257957; cv=none; b=P1Q9ve92CqqfTRLmyuxntfTRtSClD8xrEC3pMZb2a4gmvN/UrLDr5TgNdPahUTJ6VR1iJLFofJCxyd14dv+xWbNSPxOXqPt60WIr/6L1bD3NZFpfOUo1TMw8KKh8JJrSZmtv0aNzpDFZQSU0hlZEpHT4OY3wFEDtdAyBugNNC1w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257957; c=relaxed/simple;
	bh=rKt/vZO5IU4MOn7gFchQsKV7znKYeyi7aj8Y9GyU6Ig=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=c+ItRuwHS+gfKFoVWFr6Fd1iEhQRQfr2i5qQt91rYD/bb8cqjh+cOOuVnzOnSSy9tF4g6ZMpDIX4l5VpbGF1peZLuMkSHg1WnUa0DcH1g689W34m9xbuOrDTUwjtiOrBIbJqb+7UbwhjAgqIFbAC9Pm3j/y6PZQ0Cev/jl8fi6Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NT7lZC8q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NT7lZC8q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5341E1F00A3F;
	Tue, 28 Jul 2026 16:59:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257955;
	bh=W+UdcdA1sbgsLgWKw+8nyFK0GBzzpxyQmJNPhShlzk8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NT7lZC8q5vhUQVRct8pT2BEiLLmrWdP7dcmLbx3nP4bMdPsGtp6/ohyCeScTeao+3
	 WxmfAtvBQ1zJkdZCqbKba9aOJ2aS9XLBCoHGQXcABI7IScCkDtkqiucfjzSdkxXe9M
	 Ed7fbs6Q8waVcho+juhzLPhHaCVnQAdLjI4PsIywqoM6A8rs3Gv+Ly85NPYTNP3phF
	 VI2obGz5Eiw62pJXCVA4LCokEbZLlQYmVC6eH1FNq4vJs75K+UboSga4TddpnJ/W0v
	 yp32+xXwrrdv6mlm0vCMWnQeJ3X6tUjMDcKeJV3BPROvkOlS9Mp6R89+6yN1vM+7++
	 3axxc1zLY6nVg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3/5] NFSD: Tighten header includes in localio.c
Date: Tue, 28 Jul 2026 12:59:09 -0400
Message-ID: <20260728165911.462534-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260728165911.462534-1-cel@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
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

