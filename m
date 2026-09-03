Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D70D743901F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457371; cv=none; b=CUlxsQ7nXV7Of9WQ4ka7frDZXgEMzi5RSHMESIW/bzpoveVrKrfxS6Jpj7y7DL7XZnJN6r5aV3ZJ2UJS7omxtDUDWtxU/pOoKUJXzxFAMFVbm/OTUL+jrDLCAC8UFr4nX0gj4drSy+qgi0x0+0ENZ9uFeLERx6iYYv2RgD9q7DE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457371; c=relaxed/simple;
	bh=fJxQBcyxyyaZqP/LfDmgqmZOEeXcucuiw6anDFWmE1M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ouDrSX+pos/qhB+ZAA/FomRvE9R7ILl7kP+/UYNEsxlV+n74nN6r6Rurf1JDdcjam51fHTssV0eAbfJwA7queE2g++/5fQxA6bHEONsE4XS8z7pXySjVG8p/tU0uBputOr64kBwttNo2JHiFfSMFjn7XQjrsJPw3MDrZWvDq8uA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IhNjfy2W; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IhNjfy2W"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457368;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=84N2gE8Ng4E66l3IN5Rk6rp9+yyWH5UWjGGDipKoYXY=;
	b=IhNjfy2W3NKHkzsGOIJcJ0dptV4fcye+wTPum6pdom1TZwWtlBsmN7UaB55iMD9SVk49Jb
	QTrLtEiALgVEJqBcUp5tRlAIe/vA8I+K9/IjG9++NM3sI9AKDFR8/6Tq2zyzqA1pi4Qq7V
	li6nmvoGH2A2wDy8aSA40gCaQ69snhM=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-517-S-lavy0APSWeozbs8Vij2g-1; Thu,
 03 Sep 2026 13:42:47 -0400
X-MC-Unique: S-lavy0APSWeozbs8Vij2g-1
X-Mimecast-MFC-AGG-ID: S-lavy0APSWeozbs8Vij2g_1788457366
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id B7ACB19540DE
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9401A1800765;
	Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 04A9853458D4;
	Thu, 03 Sep 2026 13:42:46 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 4/6] rpcbind: restrict RPCBPROC_GETSTAT to loopback callers
Date: Thu,  3 Sep 2026 13:42:43 -0400
Message-ID: <20260903174245.1213147-5-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

There's no reason to allow remote machines to query the local machine's
rpcbind statistics.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/security.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/security.c b/src/security.c
index 6bd22fd..3b55151 100644
--- a/src/security.c
+++ b/src/security.c
@@ -87,6 +87,7 @@ check_access(SVCXPRT *xprt, rpcproc_t proc, rpcprog_t prog, unsigned int rpcbver
 	switch (proc) {
 	case RPCBPROC_SET:
 	case RPCBPROC_UNSET:
+	case RPCBPROC_GETSTAT:
 		if (!insecure && !is_loopback(caller)) {
 #ifdef RPCBIND_DEBUG
 			  if (debugging)
@@ -109,7 +110,6 @@ check_access(SVCXPRT *xprt, rpcproc_t proc, rpcprog_t prog, unsigned int rpcbver
 	case RPCBPROC_TADDR2UADDR:
 	case RPCBPROC_GETVERSADDR:
 	case RPCBPROC_GETADDRLIST:
-	case RPCBPROC_GETSTAT:
 	default:
 		break;
 	}
-- 
2.55.0

