Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3671443AB8
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788514757; cv=none; b=eXxgRgB+3jjmWnKvxQgyHgw74Dnz0LGaXlRub4EYyuh/YpMIGpJlJoX7CAo/DaYqFLOT6Ut0pDf/psLmu53Z/C6HsJun1sAs2u/u6HeCQQJsz3zhZwAtoJFAdpro4mGAZq0uest12e4iz/4yp9+R4UYABVgXtVyLzffVVfmEwc4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788514757; c=relaxed/simple;
	bh=zmI+WziJ1VyK0y3wBmBMHboKX8wzF2D42vQGF+cawXw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=p8jcNMwAPp2gGdc4Y1zMEXt24zgrAe+shKbvQgt2S5TC7Tr4Q+jqT0pRb8aQtONRW/RMDz073jprvej/xwkjOeqtMxUFbUEBPfdHNlrYIjtcwdL8MqhTkKg/QmOUTw1t2yXGym4qvHzBhv9+7ivS2yprh6OHhq3AikV06rYUSTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=GvxzvtR5; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="GvxzvtR5"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788514754;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=D46Z61HMooq2v8mhRm4jvILAJyQ6E4yUY2NkG6rq+2c=;
	b=GvxzvtR578LVDzbfp54/FjpeYIqrxSZnl9tJ2Bo5GYF3ElOShndg94+i7YIY3TJZK8WOZD
	kGPd/vZYFFjeudx/VYRqsGtHK5u75F54+BamoVys366DYvWv3eLvgGENNlVAEEo/aqIv4c
	4oaVJws4BLsHivRGBMvayWiA5w+vwBQ=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-345-3Y8ZAWQmM82Z5d_qQvXKfA-1; Fri,
 04 Sep 2026 05:39:13 -0400
X-MC-Unique: 3Y8ZAWQmM82Z5d_qQvXKfA-1
X-Mimecast-MFC-AGG-ID: 3Y8ZAWQmM82Z5d_qQvXKfA_1788514752
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BA7C818CC49F
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:12 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 51CB91955F70;
	Fri,  4 Sep 2026 09:39:12 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs4-acl-tools PATCH 3/3] nfs4_setacl: do not follow symlinks on do_apply_action/nfs4_setacl_byname
Date: Fri,  4 Sep 2026 05:39:09 -0400
Message-ID: <20260904093909.2881028-4-rbergant@redhat.com>
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

We use nftw+FTW_PHYS on nfs4_setacl to avoid following symlinks, however
during do_apply_action/nfs4_setacl_byname we use setxattr that may
follow symlinks. As a consequence, there is a race window where if a
file turned into a symlink we may end up applying, during recursive walks,
an ACL to an unintended part of the tree.

Use lsetxattr instead of setxattr on nfs4_setacl_byname to avoid this
chance.

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 libnfs4acl/nfs4_setacl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libnfs4acl/nfs4_setacl.c b/libnfs4acl/nfs4_setacl.c
index d684502..8a6cae2 100644
--- a/libnfs4acl/nfs4_setacl.c
+++ b/libnfs4acl/nfs4_setacl.c
@@ -30,7 +30,7 @@ static int nfs4_setacl_byname(const char *path, const char *xattr_name,
 
 	ret = acl_nfs41_xattr_pack(acl, &xdrbuf, type);
 	if (ret != -1)
-		ret = setxattr(path, xattr_name, xdrbuf, ret, XATTR_REPLACE);
+		ret = lsetxattr(path, xattr_name, xdrbuf, ret, XATTR_REPLACE);
 	free(xdrbuf);
 	return ret;
 }
-- 
2.55.0

