Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97EFE331EB4;
	Fri, 10 Jul 2026 14:00:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783692029; cv=none; b=bW3Cq9yHC72QP1Frh/Kc9jg8UulOzOzCXgkkIMzqfJEbtoajaEHnfHXIfc48OC1tweGLw5mpWz1t0SikxwmLRdZuyuG7YvYWu9TJINVJ6PpjEpWDDzAgQwnfbWCJ/t0B4hnW/oMM551S4TWjZcphxUNISAXy7qFWt6haDmkUG90=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783692029; c=relaxed/simple;
	bh=O3zVjYJlD31VOeO1zO2OJGMu5IB5oxpMhkms1vAy4hM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GQwyt3KRzkMmuCntUbmgWMLjxPyTE2Nw3xL7wksZTGUajWYWuOyKB4SM4VBilQgrag0p+tNyEEb/dmfDRYZvrOkl6ioHmYIUfMV4p7ztpoRSlaAowty1G7b37DAA5gO1rqc7/s1fZqvfCTpQjBSiLBa6h+jfon5mGsesFtGe3F8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VHyxpJ+s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VHyxpJ+s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D199F1F00A3D;
	Fri, 10 Jul 2026 14:00:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783692028;
	bh=P2UK8iZxhZqTJ9EVtaztQjWJ1DGz1mVZItAmwDsX5Eg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VHyxpJ+sGcLFnIBwNWISHqpfITwIJYWrLA3gw3fys6JlkqYYPKtuZqNxibXu6+naj
	 Bf8EbIPkPdEUv+RQ2ofJmb6uxmhO9z4ypJLYyKLGoxkcla6FS1V8tzPQUXOebq2BC1
	 Zqy9iQHtGyT+/YMXo7Cd7Y7jdaxfkib3bcntG6eaahCpQOGTxmWMAnvqz+V1NjS7B9
	 geuEBaEl2di8tG3PTO5Ovw3bdsKmMFeDRFHRR/UTfb3Ges6M+M/1UocrVVjkgqW+2E
	 Xu+EJ4dpS4EUwxMqUwDTSMoOgLAMY5wp2yXwn+zrziIPCM5h7UQhQ52LbABDVY1Us1
	 4zqlN4QQclQYw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 10 Jul 2026 10:00:11 -0400
Subject: [PATCH v3 07/10] nfsd: return NFS4ERR_NOTSUPP for unsupported
 netloc4 types
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260710-nfsd-testing-v3-7-a0ff7db6aa3e@kernel.org>
References: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
In-Reply-To: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1681; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=O3zVjYJlD31VOeO1zO2OJGMu5IB5oxpMhkms1vAy4hM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqUPr0x4mVvwjU4N0vMSkma9Aor7NtgQZ6XIdoL
 +gJt8NP3lGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCalD69AAKCRAADmhBGVaC
 FSY7D/0WM+tx8BdxyF5VDDz6ze9OsezLOEazZjH5lMNWwr2bn1HDS7j/3qNBQTbjmI2fuvftLAB
 aKmgHKPgKCWVD6AquGzZzbYh2PJ7Bk3GXOy3x4HmRWmN2dnt0NpGRQp85jVDhURCQCcyvZhx7Uo
 GKU5wkyebqTDlnUmaJq66y1UhUquaaR3+uv2P+1+cYqVJUGsEjnK12JGYIgh3PCvKqsz/hoBikY
 OOgNLFnV11Hb2kDoFj7Aly2EmrdbGikjIQs0ra/mqx1QuLNKwlYWpDUZRX4SbXvbjPz6E1G3IOB
 b42AZCayVrwnjTsrWIgw+EeFwIs1gjRZoRyGNXmCQ8Gu2+Iy+AIzWf61eB/5IvA75EWdrK0VBm2
 F+QuRDq/zkBxyXqFn87unBKj2OIO5uwX4SpnPTRLUO6OecUfQY5PGRELqFgy6VvSHQUGOaif1zP
 kGuvmnYxeaP/PI39/O1hE4R3PJhU45O3Tv5RUpInbRdcaAA7f4kN5dk3H17s/kDW6fdeZDl03F/
 /qV3Ki8jyKjyyU9ollC+CrPTv0hftRXSNJ8XN+VHzQvBRXztxm138H/V7ENhXzSdhRrqXYBvkA0
 VVkY/yE91YmFYtcOLLFLRGIcrPYxKyjC+0W8rRWH7RSIuxU8TczYzKOwwT8jQdbEAxr8Mbyc/34
 0JshRa1mMJcz2RA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_decode_nl4_server() handled only NL4_NETADDR and returned
nfserr_bad_xdr for NL4_NAME and NL4_URL. Those forms are well-formed XDR,
so BADXDR is misleading -- the request is unsupported, not malformed.

Decode and discard the utf8str_cis for NL4_NAME and NL4_URL to keep the
stream consistent, and return nfserr_notsupp. nfsd4_proc_compound() honors
a decode-time op->status, so the op fails without executing.

Fixes: 84e1b21d5ec4 ("NFSD add ca_source_server<> to COPY")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index aef48fb0fac2..3873d037a763 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2123,6 +2123,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
 {
 	struct nfs42_netaddr *naddr;
 	__be32 *p;
+	u32 str_len;
 
 	if (xdr_stream_decode_u32(argp->xdr, &ns->nl4_type) < 0)
 		return nfserr_bad_xdr;
@@ -2152,6 +2153,18 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
 			return nfserr_bad_xdr;
 		memcpy(naddr->addr, p, naddr->addr_len);
 		break;
+	case NL4_NAME:
+	case NL4_URL:
+		/*
+		 * Well-formed XDR, but only NL4_NETADDR is supported. Consume
+		 * the utf8str_cis to keep the stream aligned, then return
+		 * NFS4ERR_NOTSUPP rather than the misleading NFS4ERR_BADXDR.
+		 */
+		if (xdr_stream_decode_u32(argp->xdr, &str_len) < 0)
+			return nfserr_bad_xdr;
+		if (!xdr_inline_decode(argp->xdr, str_len))
+			return nfserr_bad_xdr;
+		return nfserr_notsupp;
 	default:
 		return nfserr_bad_xdr;
 	}

-- 
2.55.0

