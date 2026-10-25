Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050580;
	b=qiuM/wkvgtbLum+MmBnHWqrT6eHt6dwCszmlmCKN9OllvueXMzdbNQDiTVOi5AAl1IgY
	 c1MMx4UrnGOYLqZM5QNsVjYFHXWLyFdqWM0djmd8eV7r4g+6dtUjrLVL0LXNoHSMcu217
	 yWFdRQYhFmWsoB+hDfo3k5J7PQYXg4P5wagV8NTPJbHw+6+X4/49L0z9IrPA4qjtff/p6
	 kSlKqKEgXyZF1CWhNr/3G6N4Rbva5FI6IMxZsb8l+Az2onkEqSDowsZXhCmh5nfmBNDBZ
	 vqVDYpRh/qho1PvCLCfZG354iTCT9KD9i/r2F61eQPMwfxE0LDkd6f2/U+9pwiMJ8Ug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050580;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=63IS4DB2iXjcvNrhjilbnwS7KfRRBf3fM7/bHHi/8rk=;
	b=wiQpE1YkG8/4844zNSWMg+SHwxMU4r84xYZhJOQo7JK3MOe01wuUusgagX6XJy2Qj+VO
	 NGz909BwyUrzuJJR0R3n9KcG+IkDQ8P8pczzIQP7Hv4eiSJMh/UzcyoA01nONnspsax6X
	 d4RaoEH9pxPqOrFZ+aAJPh47aC9ljvaLXv6+u/ZxpulOa/PaXKHzDp2oXPOf1rXSPIqYI
	 l6nSoQAZMplQEBR99btPaPIsoNYuKT13PYXFZsNWwBfnGiO1Q9rZ5UWTcqbpSyPW/tuyd
	 h4+ruuYT8lXbl07VXyqSTfvyO/7rzrpBiCb54QjFSKvhVHz1YviYoUv0ZxTqvEPO9Gw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="LhjABvO/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 891AE606A31D
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LhjABvO/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 78D801F031E1;
	Mon, 26 Oct 2026 21:36:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050580;
	bh=63IS4DB2iXjcvNrhjilbnwS7KfRRBf3fM7/bHHi/8rk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LhjABvO/uMf42qjTixijYyHbeywpTkxq7ZIn4EXCRjS5ER0x3Ly3e5KGqapGBaTQa
	 An89+7z7DElobXJ6860XHMCkXDqIJTTxDtdyNWx0Vrn0S5qeTPBfjYJ5STFparNqRi
	 0pxPWsXkkhF9NY3x6I9CeRJTipi3bTWACT+pvopLt3oYEWMmoYkfZTN7amstbQNV49
	 gzESo4eBZ8QiTBowTXhZBLjx8TzqoxE3rMkcdzW0JYCRRm5Okm+qZTlUIlQKDGOoLR
	 jLsZNy8flr7l2OP3UWcNtr+JlSrtzTtCDvlyRDHsH6w3jX/NClYgcoWrqZu5bnlosZ
	 V4BQMlakvypvw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 03/13] NFSD: Remove '#include "xdr3.h"' from nfs3acl.c
Date: Sun, 25 Oct 2026 11:16:12 -0400
Message-ID: <20261025151622.141025-4-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
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

Begin the process of converting nfs3acl.c to use xdrgen by removing
the xdr3.h header from nfs3acl.c. Eventually nfs3acl.c will use
only NFS_ACLv3 headers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 58f1297c88f9..98de13b44a80 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -13,9 +13,41 @@
 #include <linux/gfp.h>
 
 #include "cache.h"
-#include "xdr3.h"
 #include "vfs.h"
 
+struct nfsd3_getaclargs {
+	struct svc_fh		fh;
+	__u32			mask;
+};
+
+struct nfsd3_getaclres {
+	__be32			status;
+	struct svc_fh		fh;
+	int			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+	struct kstat		stat;
+};
+
+struct nfsd3_setaclargs {
+	struct svc_fh		fh;
+	__u32			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+};
+
+struct nfsd3_attrstat {
+	__be32			status;
+	struct svc_fh		fh;
+	struct kstat            stat;
+};
+
+/* Helper functions for NFSv3 ACL code */
+bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
+bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
+bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
+				const struct svc_fh *fhp);
+
 static __be32 nfsd3_map_status(__be32 status)
 {
 	switch (status) {
-- 
2.56.0

