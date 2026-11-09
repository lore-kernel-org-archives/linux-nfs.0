Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794239206;
	b=xrpoiGiv0w/WTzjnZRdQ8pWEOVm7NLUt2f8y2YjM2fyyiLUvMy8jTm0Dt0m9hhiEapyV
	 +0RLTMizCHY/d84irrmR7jWSgtzu4EaPeT5kZIezCBHznordLpBYyKD9q7FzZkZg/nZ5E
	 ZvLAw7Ccg1Pr4RNOh8XJFwNI/7SvZxt3lRnBedvdaMxAx/e3oMPpF0TDY8HSmKU99B287
	 1b23bIruVtXJsLO5J5/UxSATslFiRZicHYxwyDmEMAZdOBedRu/NC+daSAyvdUGqGaksU
	 NZnS3WbY2hWh3ySDXKie1RWoGhXe9d4SmaW8byTJZ2bBnAm0UpPNmazO/uHDBA2T82Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794239206;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=9Y0vZkRlNckuDFsxSKp+K9KqcD52agRAgRMV3KSAYIA=;
	b=ywve1IV75VSmDFWat/eQEx1r+sllUJEYLNnTBDqyMZ8UrXrdekHaRd/OuHhDjqEg6zs9
	 xnSVAuePivKxg8XJRmNpS5Sqv9vYuvDWo8uFCSqxeZn6xUosdtIDIoAYq1Hzk9gvILJWZ
	 kocaTzw8wanL1RhTIH7QUDjZRxF/2gPB3uOaeIHKAqnJZimfN9hJ8ZxDoCjpvFDYzVLKn
	 da0xUjgczfEE2d1TTOtkPWkUJdYyJri8i7Ch5Kk8YT24WYJL66FXOxdh1t70WfGtUAoPs
	 ZFA5pCfQLQuw7wRo1oLIxJhZcNpsLo/Rez2bniIDWFcES8QPNrgy+zJ4ESfXnJL3e6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=VoR10VEK;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE340606A325
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:46:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EE340606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=VoR10VEK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794239205;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=9Y0vZkRlNckuDFsxSKp+K9KqcD52agRAgRMV3KSAYIA=;
	b=VoR10VEKoXa09QGXR9Mc+rlvRS+b1ZRrTvVa5NuX3mdEJwM81YGLz+j4Keq/Udx7Fz2KOS
	B6Pm8Yj22924qp3MWfIxHc5r4cW+IaSTiMCQn2lAJnrWRObYNGpb0Mo8VG2NvCU60D496x
	B+JMfErBiUGBg2PTBnUJqmcJQ9PzX+Q=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-219-NcBLLbY_MTKGj4sW8fl6cA-1; Mon,
 09 Nov 2026 10:46:43 -0500
X-MC-Unique: NcBLLbY_MTKGj4sW8fl6cA-1
X-Mimecast-MFC-AGG-ID: NcBLLbY_MTKGj4sW8fl6cA_1794239202
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 887F11800550
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:46:42 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.80.36])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EAE6A30000E5;
	Mon,  9 Nov 2026 15:46:41 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] libtirpc: add missing boundary restriction to xdr_rpc_gss_unwrap_data
Date: Mon,  9 Nov 2026 10:46:41 -0500
Message-ID: <20261109154641.55252-1-okorniev@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Add a boundary restriction to the xdr_rpc_gss_buf() call for the RPCSEC_GSS_SVC_PRIVACY case.

Fixes: 65d27459fe56 ("libtirpc: Bound maxsize in xdr_rpc_gss_unwrap_data() decode calls"
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 src/authgss_prot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index c7de1fd..620b294 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -254,7 +254,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 	}
 	else if (svc == RPCSEC_GSS_SVC_PRIVACY) {
 		/* Decode databody_priv. */
-		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
+		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, RPCSEC_GSS_MAX_UNWRAP)) {
 			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_priv failed"));
 			return (FALSE);
 		}
-- 
2.52.0

