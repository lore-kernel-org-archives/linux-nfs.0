Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85EAD3C5523
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690288; cv=none; b=EmneO4ceHJqTElAbUoDO9l5I9hjKjDfNCKJv5ZQUJIdB4Ta7/q75zLkBNRjzTzd/gDXgwvNFftORdKzU/mgS+UZE9N9efIdMWPc5BgJzxPygKBFGF/KIIWAqHXeVx7K6t+yUzc8tx3VoupVq4J0AbZSb66yzZNATJ7Tf/x50L4w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690288; c=relaxed/simple;
	bh=OrlzxCaVqNVR93hNsRaF7E0dTsDt0q7LEMHF6bd6ROI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=i7NO4tfqgnslAGMePG8TyAVTZuKwe35ONMwVRhwY8hZlD2Mtj5zJzYbx4Myp2mEtvnkA8fElXjYdXYc4ciJzNblSe4qSrcMD4oVAWTbIw+hdnNRdu4ormToSCVmMNJkwrelrfqGcOg/Ftn08WRZ3VxO6y2/yl9yOCrv++rjiBtA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FWoZ1MTX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FWoZ1MTX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D65071F000E9;
	Sun,  2 Aug 2026 17:04:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690286;
	bh=RDCPJCQbghAg73It4NQJib9oDGwVZdsPRAfg+pMdc2s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FWoZ1MTX2YniJvkNXOqwRBb0Kulyy+Lw1zv4+nzPpky2VXf2q6UDtXBPL7pdJHH96
	 jym8KWmdqo4sJsSSJvq5a6qcdbgAItc7ndl3IKncIgl5K5KsU+qViqUAvs7ZvLTjwC
	 ux6Y3vcBzJVgFfmx0nuVijhGRfD+7E4NXWkDsQfxCWUEPm9gL9L9OGDtX+x8V1Xrw1
	 AGP95rTWQJJecyfcRAZNxdEyJGU0CaGwor0LtghPkrlcOLYgTTbsahOroAjpWln8d3
	 f28b2Tlm3Ho1sEV4FwqQr5dIV/x05Ba2t42LWqM6Yg0DFWDlciGjf+9k2Jun0258lx
	 tAd22Jygeo3NQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:31 -0400
Subject: [PATCH 4/9] NFSD: Budget the CB_OFFLOAD opcode
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-4-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=908; i=cel@kernel.org;
 h=from:subject:message-id; bh=OrlzxCaVqNVR93hNsRaF7E0dTsDt0q7LEMHF6bd6ROI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iq9dsqcFf2SHbQUhtNW6uCZD7lu4Hq6PEDJ
 B2Cj3hU6meJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l+S0EACVCOUxE4N4pgpHJRRxFjfiwDQqv4cEP+3C63BgDe+1IwHYsNqI0otTdCsiSsEUqvqARJg
 Rsv7pWxubUwtmH2SyAPsWbR11RfS27bWJ/hSz6EbvShpsWcbiq2TQRodhQXXHCV/7pnFNPYsfa7
 pm9PK4T0amkY3YQaqiSl/MMwr4iHzvg17dvBcAQ/VRECCaWuGCJaY1CBzbddAAqiUzECDhSZPQ7
 aQvGvc86VTTTsXULL0LodYFV0HfHGdTpFKKWFYmtRL98qx5kr/WhX31GRdiVu1gXmjzZXnYYBRl
 2H3b4sRqJLx4sZhs+fHmvvrBqe03GjKTrkYtIxFeYph7haAsH/23BZBLBLknwnK4abluf1UZ2Pr
 a1aOa0wHbXs5cwdqJlk6flDaHEYPmzF0MejSNNxZfngHfAidp1wkb2I5qMHUPpWKq3oz+F2OJeF
 UYvHfjp+DxI7y1OB2doFegFPBcpbWVOL3w9767yC3XYnzV6GSX6J6nrgKiVYD5mK1wSGtMg/BoU
 uhWmqO2d8ThTuvy5U6XGIRhu5AJD84Sqo4KEx/6GQQBZiEtwXSmJ1Qt1bBefZg0Nrit/WBa3nwO
 BjpJqxi25FJ1sMN8nCI0kTwAbntI+roXVcjw+LIC9FVPAh3j19UfH033DsLJkgNhUb6fs4AkkbX
 BRyLa6ZnPzoPi0A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFS4_enc_cb_offload_sz counts the file handle, the stateid, and the
offload information. encode_cb_offload4args() emits an opcode ahead
of all three, so the macro falls one XDR word short.

This macro sizes p_arglen and nothing else. rq_callsize pads that
with two credential slacks, so the shortfall has never reached
the send buffer. No backport is needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index 5285934b3a54..21d8280edead 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -58,6 +58,7 @@
 					XDR_QUADLEN(NFS4_VERIFIER_SIZE))
 #define NFS4_enc_cb_offload_sz		(cb_compound_enc_hdr_sz +       \
 					cb_sequence_enc_sz +            \
+					op_enc_sz +			\
 					enc_nfs4_fh_sz +		\
 					enc_stateid_sz +		\
 					enc_cb_offload_info_sz)

-- 
2.54.0

