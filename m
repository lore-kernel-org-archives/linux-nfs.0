Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26B4B4FC8E9
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457999; cv=none; b=oqobM4LNT5Awbo7oABg+PbVXhzYo60GGNchJ5TIu4rupoUvdMUnm8GwCg4L9noKc32VicR/HBvwItMXMb8yeM4orZy4UxwcbYqO/Mr2Ko5CD1zd3II/NYsg9JNvj1fs8p9zqbTzBVWdJEp18E0rylNpAKv34tYzHonixgBT+dQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457999; c=relaxed/simple;
	bh=XzT6PgUvGL8EJnboWVaggTWlrN+rBBawhQWqDYsQfPU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Fk2En0LhiXFhUAE4fTy9MbhAMlO5h8NICdIv2DeFYrHQA7rXcp1QWvbokNcbM8RmXcu36oNmV1MPIboq64pKaoQbIZQXE2wpM7AhkFU9IqhRfB7ba1TUj0phCcsNpHaMF+W8cPTbMqFZ0zHYGPpiMMpEAT+LM13xxGh0fSpzbV8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KK4m6COo; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KK4m6COo"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457997;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=XPf67LBMZk788g7iKP8jnvMpRUPI/u17DWYboDS26Fw=;
	b=KK4m6COoA7oC6fS5YNOQJbz1PL4O29T0NHsO41V2vxLX5pkh7HIrrH/QIkVham1xrJu7Rp
	gnuSaGhRjWoR/zTRompODBF1A7WyVaI4vm7cwrwhvY9v1wQrumnIbAGL3V2sYaVhGjq6jk
	nCC8WkGMtagg+mfFIjLPVhsQQnnzs4o=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-564-uEFtMbh_MbOwIV6UJBn_WQ-1; Thu,
 03 Sep 2026 13:53:15 -0400
X-MC-Unique: uEFtMbh_MbOwIV6UJBn_WQ-1
X-Mimecast-MFC-AGG-ID: uEFtMbh_MbOwIV6UJBn_WQ_1788457995
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F3D2319091C2
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:14 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D084E195608A;
	Thu,  3 Sep 2026 17:53:14 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 359595345B8F;
	Thu, 03 Sep 2026 13:53:14 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 1/2] junction: fix buffer over-read in junction_parse_xml_read()
Date: Thu,  3 Sep 2026 13:53:12 -0400
Message-ID: <20260903175313.1214070-2-smayhew@redhat.com>
In-Reply-To: <20260903175313.1214070-1-smayhew@redhat.com>
References: <20260903175313.1214070-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

junction_get_xattr() returns an opaque buffer, but
junction_parse_xml_read() treats it as a string by passing it to xlog().
Fix it by allocating an extra byte and null-terminating the buffer in
junction_get_xattr().

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/junction/junction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/support/junction/junction.c b/support/junction/junction.c
index c1ec8ff8..04a8ebf1 100644
--- a/support/junction/junction.c
+++ b/support/junction/junction.c
@@ -293,7 +293,7 @@ junction_get_xattr(int fd, const char *path, const char *name, void **contents,
 		return FEDFS_ERR_ACCESS;
 	}
 
-	xattrbuf = malloc((size_t)len);
+	xattrbuf = malloc((size_t)len + 1);
 	if (xattrbuf == NULL) {
 		xlog(D_GENERAL, "%s: failed to get buffer for xattr %s on %s",
 			__func__, name, path);
@@ -307,6 +307,7 @@ junction_get_xattr(int fd, const char *path, const char *name, void **contents,
 		return FEDFS_ERR_ACCESS;
 	}
 
+	((char *) xattrbuf)[len] = '\0';
 	xlog(D_CALL, "%s: read xattr %s from path %s",
 			__func__, name, path);
 	*contents = xattrbuf;
-- 
2.55.0

