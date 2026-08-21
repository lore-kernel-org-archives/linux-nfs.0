Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A13C036F90A
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 14:58:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787324306; cv=none; b=qev3975YRX2aiW7E5GnON9+Ql1OQuKNO8y+kK848prcT1O4hwj6zaK9SivXlMzMTvRVxXWHTy7/52lnb/eWkekt7z8n3cNVvB9K5tZ1s1BuRbpKH+XaD5Wr7WRwEjEiKGqVpwkv5dEA1lC4PxSvTat5n3hagUXWpATkgbrXzDTc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787324306; c=relaxed/simple;
	bh=wclBeuuW/dUp1dqeiUB8kzZhGrx9bO0h6Xmt4dlH0ag=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=bwDmJKH8Jay4S9d7ntEEbu5NHoJo0T3CH0wYSI1SLdRAml+8bKOUdN7ly88Y2YxWuyoKuXIuOdQ84dm64XuYsVU4uzH0ukpOzW9K+qnEQwTs3tj4LAgoflmLlvgF5vhDq07vyX2JQjVKDIvVPLyBt+CV7DyEmZjT78WtjgHsp58=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iGrMwH9E; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iGrMwH9E"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787324303;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=hCjqBZwKf81arh37By1KT96NHe1xjZh1NErwwMpfrFU=;
	b=iGrMwH9EXq4ogdaKZsqSftcvdmSEaRtg3ybH206eNG5y2P32Lhedt2Rh5vWQGrgkjRjJDK
	FD+UGcufQkNfjqxAU6eGeOHsl0/8IAzWcMbyIXzHZ/bSAqveqXcICuz+AHYtu/aOCKmz8o
	/FoBpZBySUm/0boj63zFXKvoVV/MXuU=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-128--qff0emKOzqauMubp7D4NA-1; Fri,
 21 Aug 2026 10:58:16 -0400
X-MC-Unique: -qff0emKOzqauMubp7D4NA-1
X-Mimecast-MFC-AGG-ID: -qff0emKOzqauMubp7D4NA_1787324295
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 337E71801322
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 14:58:15 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.198])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9F6C11955F09;
	Fri, 21 Aug 2026 14:58:14 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] libtirpc: fix rpc_gss_get_principal_name to allocate memory correctly
Date: Fri, 21 Aug 2026 10:58:13 -0400
Message-ID: <20260821145813.27891-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

The calculation for `namebuf.length` correctly accounts for the separator
characters ("/" and "@") via the +1 in `nodelen` and `secdomlen`, but does
NOT include space for the C string NUL terminator. The subsequent
`strcpy()` and `strcat()` calls write a NUL terminator that overflows the
buffer by exactly 1 byte in all cases:

- **node=NULL, secdomain=NULL:** allocates `strlen(user_name)`, writes
  `strlen(user_name) + 1` bytes. Overflow: 1 byte.
- **node="host", secdomain=NULL:** allocates
  `strlen(user_name) + strlen(node) + 1`, writes
  `strlen(user_name) + 1 + strlen(node) + 1` bytes. Overflow: 1 byte.
- **Both non-NULL:** same pattern, always 1 byte short.

The `namebuf.length` value is intentionally the *payload* length (without
NUL) for the subsequent `gss_import_name()` call, so the bug is specifically
in the allocation size, not in the length field itself. The proposed fix
correctly introduces a separate `alloclen = namebuf.length + 1` for the
allocation while preserving `namebuf.length` semantics.

Fixes: dec8d9775ded ("Finish server-side rpc_gss_*() APIs")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 src/svc_auth_gss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
index de2993f..dd7db56 100644
--- a/src/svc_auth_gss.c
+++ b/src/svc_auth_gss.c
@@ -1117,7 +1117,7 @@ rpc_gss_get_principal_name(rpc_gss_principal_t *principal, char *mechanism,
 {
 	OM_uint32 maj_stat, min_stat;
 	rpc_gss_principal_t result;
-	size_t nodelen, secdomlen;
+	size_t nodelen, secdomlen, alloclen;
 	gss_name_t name, mechname;
 	gss_buffer_desc namebuf;
 	rpc_gss_OID oid;
@@ -1135,7 +1135,8 @@ rpc_gss_get_principal_name(rpc_gss_principal_t *principal, char *mechanism,
 	if (secdomain != NULL)
 		secdomlen = strlen(secdomain) + 1;
 	namebuf.length = strlen(user_name) + nodelen + secdomlen;
-	namebuf.value = calloc(1, namebuf.length);
+	alloclen = namebuf.length + 1; /* include terminating NULL for C-string ops */
+	namebuf.value = calloc(1, alloclen);
 	if (namebuf.value == NULL)
 		return FALSE;
 	(void)strcpy(namebuf.value, user_name);
-- 
2.52.0

