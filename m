Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC8A7883F
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788743617; cv=none; b=EADhFUcg2Q5Cq2AgxG4NqF+geKjV5RLTYHpmr3FZozP+VN9vHPLTMuijwb4zlK5MR/y60Cz0oSDZtOLLuveDmcN9tlw1625LHAcjn768YZ5DiE/BDaBK9zzmb6BdOsRskZKpc0kvkb2EUiLV+SklrwOP5+1WBTE0p1K4toAmI74=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788743617; c=relaxed/simple;
	bh=g31ZInTdHDZLO84ci5WQoBL2J0PXpijScbiUuNOazEA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cBhoeVYKXMqAU3bcMah/K/WGiGZlol0IhBe5vrLl/VP2z0tn1+DUyKmJhDBys+QPqhKBV28Mtuje7RbaURWMFCui8tJfPmXL3+vMzCIDFaUV3BfCfgYmY6avBgT5dWgP02QobtH/eR+S8RmZ303/ci298PFvFwmU56d86B7eOC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gvz69IyA; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gvz69IyA"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788743614;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=eoiY86Mj9rVzqv4qy3tMM7Lm5F5VIwfqJYRWSxgfX1g=;
	b=gvz69IyAPjdu5jYTyv/OC22Cs5a8vNRh6CfBZI3jJxvyDVCuPEn2TJBLszYX3rn+CleDL4
	cJCD18+ks/L1ijEms2YUAkbggwLLpo8SNiQz5D9bU4IJiwLBtxS4YZWrkMpQI71x8xGXlf
	LhYNXXe6v5wBD7Fz5hG+Ah7trhzzGsA=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-163-OYtGPxh1ObW3PzAXoYZIDg-1; Sun,
 06 Sep 2026 21:13:33 -0400
X-MC-Unique: OYtGPxh1ObW3PzAXoYZIDg-1
X-Mimecast-MFC-AGG-ID: OYtGPxh1ObW3PzAXoYZIDg_1788743612
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7F58F1954228
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 01:13:32 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.31])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E1F7D1800348;
	Mon,  7 Sep 2026 01:13:31 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] libtirpc: Bound maxsize in xdr_rpc_gss_unwrap_data() decode calls
Date: Sun,  6 Sep 2026 21:13:28 -0400
Message-ID: <20260907011328.21425-4-okorniev@redhat.com>
In-Reply-To: <20260907011328.21425-1-okorniev@redhat.com>
References: <20260907011328.21425-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

xdr_rpc_gss_unwrap_data() passes (u_int)-1 as maxsize to
xdr_rpc_gss_buf() for all three decode calls (databody_integ,
checksum, databody_priv). This disables the length check in
xdr_bytes(), allowing a fabricated length field in a small RPC
message to trigger a multi-GB allocation before GSS verification.

Replace (u_int)-1 with RPCSEC_GSS_MAX_UNWRAP (16 MB). The encode
path already uses bounded values (wrapbuf.length + RPC_SLACK_SPACE).

Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 src/authgss_prot.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index c2b25db..c7de1fd 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -51,6 +51,9 @@
 /* additional space needed for encoding */
 #define RPC_SLACK_SPACE 1024
 
+/* upper bound on decoded RPCSEC_GSS wrapped payload (16 MB) */
+#define RPCSEC_GSS_MAX_UNWRAP (16U * 1024U * 1024U)
+
 bool_t
 xdr_rpc_gss_buf(XDR *xdrs, gss_buffer_t buf, u_int maxsize)
 {
@@ -227,12 +230,12 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 
 	if (svc == RPCSEC_GSS_SVC_INTEGRITY) {
 		/* Decode databody_integ. */
-		if (!xdr_rpc_gss_buf(xdrs, &databuf, (u_int)-1)) {
+		if (!xdr_rpc_gss_buf(xdrs, &databuf, RPCSEC_GSS_MAX_UNWRAP)) {
 			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_integ failed"));
 			return (FALSE);
 		}
 		/* Decode checksum. */
-		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
+		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, RPCSEC_GSS_MAX_UNWRAP)) {
 			gss_release_buffer(&min_stat, &databuf);
 			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode checksum failed"));
 			return (FALSE);
-- 
2.52.0

