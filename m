Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C313CD8B8
	for <linux-nfs@vger.kernel.org>; Fri,  1 May 2026 19:59:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777665544; cv=none; b=MqTAsm1MjV1zCX9xYlE6HwbuZ0NnqO2nmiVfudPq8iC4HXFIPRBOE8xsbR5Inyie8jljvi4GaPEOJWzDdNRSL1UbYawYfthQpbNJTmkWtdmwMPJoup5t1ZPEoAsAjkWBcLhx5rG0RzYaUZ2JwIm1cEtTId6r2T9jVbi6pPU/grw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777665544; c=relaxed/simple;
	bh=1mWJSsID2YSUijZQT071UHX0dDNaAtHiZPAcum8irnU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sImB9rkmpygUGWi9aIeCWy/UmflcY+a9mrr2zZQz9dVbNrA/c4MBDUbdmxYN/OE3POOLHkX8qrhmVuS5IWWWN/hcEJKG0FzCP/RKduAC7A8RDQp/Grklv1N2D7TQID7tjFVmVG7kl3/FoHhIIH3npDYoz4pIuJ0v9uqXnpEF5EE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iZkhA3T/; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iZkhA3T/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1777665542;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=NVYv6m0GrxArP9ElfUKQQBJ27a0BUg9cEegybZghGck=;
	b=iZkhA3T/yageP/DGFF8dwC+E3KJUinocpVVbVci6T+Ry5KUzl5kr5sbel1lgzcV2JR+MO6
	fT3xB7YkNMWAt5Id6n1aU1txvQvYEGkIRs/35MI5eyDLL13WdXvKcThCcqAMJzhsdt0kIK
	/X13CsPdIPqRyfnlq8DuZPIzlF/tQLA=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-237-a-Pi8IAtM_eck7wARDecsQ-1; Fri,
 01 May 2026 15:59:01 -0400
X-MC-Unique: a-Pi8IAtM_eck7wARDecsQ-1
X-Mimecast-MFC-AGG-ID: a-Pi8IAtM_eck7wARDecsQ_1777665539
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id C815F18003FC;
	Fri,  1 May 2026 19:58:58 +0000 (UTC)
Received: from aion.redhat.com (unknown [10.22.80.84])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 82D59180154B;
	Fri,  1 May 2026 19:58:58 +0000 (UTC)
Received: from aion.redhat.com (localhost [IPv6:::1])
	by aion.redhat.com (Postfix) with ESMTP id E24207C9FAE;
	Fri, 01 May 2026 15:58:56 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: cel@kernel.org,
	sagi@grimberg.me
Cc: linux-nfs@vger.kernel.org,
	kernel-tls-handshake@lists.linux.dev
Subject: [PATCH] tlshd: fix keyring cert retrieval
Date: Fri,  1 May 2026 15:58:56 -0400
Message-ID: <20260501195856.1126025-1-smayhew@redhat.com>
In-Reply-To: <92a53963-1e4b-42eb-af81-6be9f63f9e43@app.fastmail.com>
References: <92a53963-1e4b-42eb-af81-6be9f63f9e43@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

The code that gets certs from keyrings currently only gets RSA certs, so
we need to zero out the PQ certs length fields when a keyring is used.
Otherwise the retrieval callback will look in the wrong offset in the
tlshd_certs list.

Reported-by: Sagi Grimberg <sagi@grimberg.me>
Fixes: facd084 ("tlshd: Client-side dual certificate support")
Fixes: 14f5349 ("tlshd: Server-side dual certificate support")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/tlshd/client.c | 4 +++-
 src/tlshd/server.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/src/tlshd/client.c b/src/tlshd/client.c
index 2664ffb..f291ee5 100644
--- a/src/tlshd/client.c
+++ b/src/tlshd/client.c
@@ -195,9 +195,11 @@ static gnutls_pk_algorithm_t tlshd_pq_pkalg = GNUTLS_PK_UNKNOWN;
  */
 static bool tlshd_x509_client_get_certs(struct tlshd_handshake_parms *parms)
 {
-	if (parms->x509_cert != TLS_NO_CERT)
+	if (parms->x509_cert != TLS_NO_CERT) {
+		tlshd_pq_certs_len = 0;
 		return tlshd_keyring_get_certs(parms->x509_cert, tlshd_certs,
 					       &tlshd_certs_len);
+	}
 	return tlshd_config_get_certs(PEER_TYPE_CLIENT, tlshd_certs,
 				      &tlshd_pq_certs_len, &tlshd_certs_len,
 				      &tlshd_pq_pkalg);
diff --git a/src/tlshd/server.c b/src/tlshd/server.c
index 8e0f192..e8fe5c8 100644
--- a/src/tlshd/server.c
+++ b/src/tlshd/server.c
@@ -92,10 +92,12 @@ static gnutls_pk_algorithm_t tlshd_server_pq_pkalg = GNUTLS_PK_UNKNOWN;
  */
 static bool tlshd_x509_server_get_certs(struct tlshd_handshake_parms *parms)
 {
-	if (parms->x509_cert != TLS_NO_CERT)
+	if (parms->x509_cert != TLS_NO_CERT) {
+		tlshd_server_pq_certs_len = 0;
 		return tlshd_keyring_get_certs(parms->x509_cert,
 					       tlshd_server_certs,
 					       &tlshd_server_certs_len);
+	}
 	return tlshd_config_get_certs(PEER_TYPE_SERVER, tlshd_server_certs,
 				      &tlshd_server_pq_certs_len,
 				      &tlshd_server_certs_len,
-- 
2.54.0

