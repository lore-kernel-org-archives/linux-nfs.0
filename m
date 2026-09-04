Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B7433D1AA6
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788514757; cv=none; b=Vvag38byRJHMMGWp2vtME0WFxCubUSc9fih6U9szUgwRwRebfM2yQllyU7jE0SdmfhX1SJPgUVCDW7pU+8yZX/5DcuRIycVkKV0HMskPeRGAAODqfC/8OYE0n2uniOFYTzCZLfG1N7F/boEHlQl1SrwlHN7z/0j146rey1UgjBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788514757; c=relaxed/simple;
	bh=57RKGrkddAsIdTUIe7pr1pJj0OWQX89LCbxFhB7lzHw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YDDNMLLjHN/FEWEHcq+GBRdT27PTMYRIXy6faRO25wf8rb2lw7/rYSFBxvOy+NGtsaUJCKqDbV6nJnpJlVZE31e2fEOpvaTRWcTVBEaN9MATHnmpeoIRhPkMsk9pwRsdwJ32b9I0/Q/gKEwGmP+H0LkMB4KUlmUnVZzMqmXm4BY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WAaEsIBv; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WAaEsIBv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788514754;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=YS/dmskY4YKT1HBwMYRBeoZ8Nq/PmEk7XLf13jMCHek=;
	b=WAaEsIBvqnF1qTyDjClk+vfANzVGxXe9MTOcUmdC3arbziM8/zDBadNI2mvOXXttA2Nj3T
	TMaO+D9X+dJqVP2aphvBkZXTWmzaLg5KxlgvUMsNcqqZX35Gi2OB8wZKNZzBs4IxARSZfc
	rMcdznd55L4Xyt2RvLHHEda1gKjz50g=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-670-5Qt4eR8wPH20kyiNqmFNrQ-1; Fri,
 04 Sep 2026 05:39:13 -0400
X-MC-Unique: 5Qt4eR8wPH20kyiNqmFNrQ-1
X-Mimecast-MFC-AGG-ID: 5Qt4eR8wPH20kyiNqmFNrQ_1788514752
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 28B541955D5E
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:12 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id BD3111955F01;
	Fri,  4 Sep 2026 09:39:11 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs4-acl-tools PATCH 2/3] libnfs4acl: fix various bound checkings against NFS4_MAX_PRINCIPALSIZE
Date: Fri,  4 Sep 2026 05:39:08 -0400
Message-ID: <20260904093909.2881028-3-rbergant@redhat.com>
In-Reply-To: <20260904093909.2881028-1-rbergant@redhat.com>
References: <20260904093909.2881028-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

We have some missing bound checkings against NFS4_MAX_PRINCIPALSIZE
around wholen/who field from payload that may cause oob or off-by-one
read/writes. Add/fix these bound checks.

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 libnfs4acl/acl_nfs4_set_who.c     | 2 +-
 libnfs4acl/acl_nfs4_xattr_load.c  | 2 +-
 libnfs4acl/nfs4_ace_from_string.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libnfs4acl/acl_nfs4_set_who.c b/libnfs4acl/acl_nfs4_set_who.c
index 07b73de..53ec343 100644
--- a/libnfs4acl/acl_nfs4_set_who.c
+++ b/libnfs4acl/acl_nfs4_set_who.c
@@ -72,7 +72,7 @@ int acl_nfs4_set_who(struct nfs4_ace* ace, int type, char* who)
 	}
 
 	wholen = strlen(iwho);
-	if (wholen < 1)
+	if (wholen < 1 || wholen >= NFS4_MAX_PRINCIPALSIZE)
 		goto inval_failed;
 
 	memset(ace->who, '\0', NFS4_MAX_PRINCIPALSIZE);
diff --git a/libnfs4acl/acl_nfs4_xattr_load.c b/libnfs4acl/acl_nfs4_xattr_load.c
index c747e8d..638b9e2 100644
--- a/libnfs4acl/acl_nfs4_xattr_load.c
+++ b/libnfs4acl/acl_nfs4_xattr_load.c
@@ -141,7 +141,7 @@ struct nfs4_acl *acl_nfs41_xattr_load(char *xattr_v, int xattr_size, u32 is_dir,
 		bufs -= d_ptr;
 
 		/* Get the who string */
-		if (bufs <= 0) {
+		if (bufs <= 0 || wholen > (u32)bufs || wholen >= NFS4_MAX_PRINCIPALSIZE) {
 			errno = EINVAL;
 			goto err1;
 		}
diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
index 7f13154..8e0e887 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -158,7 +158,7 @@ struct nfs4_ace * nfs4_ace_from_string(char *ace_buf, int is_dir)
 	if (ret < 0) {
 		fprintf(stderr,"Scanning ACE string '%s' failed.\n", ace_buf);
 		goto out;
-	} else if (strlen(fields[WHO_INDEX]) > NFS4_MAX_PRINCIPALSIZE) {
+	} else if (strlen(fields[WHO_INDEX]) >= NFS4_MAX_PRINCIPALSIZE) {
 		fprintf(stderr,"Principal \'%s\' is too large.\n",fields[WHO_INDEX]);
 		goto out_free;
 	}
-- 
2.55.0

