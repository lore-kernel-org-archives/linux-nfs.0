Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B391391E74
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257960; cv=none; b=qo2AAJuDNh7hBsIuBAdunm3vRZZRmv213v5ovF4P+Q+goB0McPIT+eirunPH89S3mHnGsLObjnhaJhwGmnwlAVWNidUM+x/zpNnHX1f1A50QdWTefYE4bB8jcuBLm3fREf+yQMWEAsg06KVb48MEzt/gizFH6aTq1xD+u9TSxXU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257960; c=relaxed/simple;
	bh=9Ypsum1dIVY8tfej2pPQRZVuLdBF8/u6r72L0Pb5ijI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lt122Kv9Y6Lcls/S+hvpsZl0tqY+2RcFjFQNuOwixS1jKrjfb/cb0OblVVl5UnqximXq6eK7Hd7y6WqCLyQkhfcnPEhZ7V7MPSigYTcuoJrq4nR5FEMVBMq7t96kTne5Ib/KVPeuNhQjgMNc+t37gqNyeW+05NXPzhm1egFxEi8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cyifd0kC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cyifd0kC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C28C11F000E9;
	Tue, 28 Jul 2026 16:59:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257959;
	bh=G80AHMIO/Qcez6cVGM3ILTIltsfsm4Y42150pnJlzfI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cyifd0kCG3yRiL8PW6UXhw7/FlL/VtCnjRpRnBLupIEr+StXEBjSWcjMQ7kDtS5sy
	 W8B+WpDW8Pa4oKN+hN69QFVzwiLuyOyPJQ6o+uJreYOAWZBU1ZmHTxY2kiv0+Nv2ju
	 YEgUQbdzWcY1GQup3otnplkpcnMnmn1s4MU1wz1381PqbTwsbc3M9ISOMtWj/Wzcp+
	 0AJIhhA1B4hblh+ThK4iQZg9vd9etUgU0KVE2wpdIps8SLXxsl4Pl2f+/d3UvVV1jV
	 KSOUBfver186ysd2C8b/NXRAhebnbuBT+0pF7Gi40PSB0g+ePmyRxZ7LaZermuyTOx
	 RU7CQtV0Brt7Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 5/5] NFSD: Don't apply NFS version-specific behavior to LOCALIO requests
Date: Tue, 28 Jul 2026 12:59:11 -0400
Message-ID: <20260728165911.462534-6-cel@kernel.org>
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

LOCALIO serves NFS clients of every version through one entry point,
so no protocol version is associated with such a request.
nfsd_set_fh_dentry() selects version-specific behavior anyway: its
switch keys off fh_maxsize, and nfsd_open_local_fh() passes
NFS4_FHSIZE because that is the size of the buffer it copies into, so
LOCALIO lands in the NFSv4 arm. fh_getattr() keys off fh_maxsize too
and does run on a LOCALIO open, adding STATX_BTIME and
STATX_CHANGE_COOKIE to the mask it requests: work on filesystems that
compute them for a caller that never reads them.

nfsd_open_local_fh() only verifies a handle it received, so it has no
maximum size to state. Pass NFSD_FHSIZE_UNSPEC as nlm_fopen() already
does, which selects the switch arm that applies no version-specific
behavior, and state the bound on the copy out of struct nfs_fh as
NFS_MAXFHSIZE.

Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/localio.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/localio.c b/fs/nfsd/localio.c
index 4110be02b750..33b56d1b3f44 100644
--- a/fs/nfsd/localio.c
+++ b/fs/nfsd/localio.c
@@ -11,7 +11,6 @@
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/clnt.h>
-#include <linux/nfs4.h>
 #include <linux/nfs_common.h>
 #include <linux/nfs_fh.h>
 #include <linux/nfslocalio.h>
@@ -54,7 +53,7 @@ nfsd_open_local_fh(struct net *net, struct auth_domain *dom,
 	struct nfsd_file *localio;
 	__be32 beres;
 
-	if (nfs_fh->size > NFS4_FHSIZE)
+	if (nfs_fh->size > NFS_MAXFHSIZE)
 		return ERR_PTR(-EINVAL);
 
 	if (!nfsd_net_try_get(net))
@@ -67,7 +66,7 @@ nfsd_open_local_fh(struct net *net, struct auth_domain *dom,
 		return localio;
 
 	/* nfs_fh -> svc_fh */
-	fh_init(&fh, NFS4_FHSIZE);
+	fh_init(&fh, NFSD_FHSIZE_UNSPEC);
 	fh.fh_handle.fh_size = nfs_fh->size;
 	memcpy(fh.fh_handle.fh_raw, nfs_fh->data, nfs_fh->size);
 
-- 
2.54.0

