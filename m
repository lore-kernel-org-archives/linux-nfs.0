Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F27D343901F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457373; cv=none; b=mSShfpVMKhxVlDtr8i1G+3+E+zzaMVhshWIcZMe0KIThvNLGE6USWHcmAeuDXeyZts4NYeyrYovI7LfZZkUYQOnxwQjX9ewr4G7wcJ+rNIjp8RPer+Q+USmAuduEhj8imIKXeiZAZ/T4inmDxD8lB5IBhbpI7Dj6A4fnGNKPCM0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457373; c=relaxed/simple;
	bh=NovdJMHqXBklcUj3VEjj4gSNemEo8HboXgxs137lM7Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FxfaLV3SuwsmV3di6pPIFZWu2JuXmmtW5023ZyoVTX+7AtAt4cWxkGMSOYC9kHRu9k/CRUbFtq8kQVSYQL0ElWV64XGzjVCD0e9MjzeBiwty/GznF7/iyqKT5ksD0wWZcSY+M06xDrPEEMvu9dhTpXJdIjGJ9TxlR/tVU/fduxI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Ux0lACWV; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ux0lACWV"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457370;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=twuhpKc7RDQQkWWa+ZOlOb50kWeF5X4FR5EKWWkm8hk=;
	b=Ux0lACWV0BTvJP9u8cuOKiVSXobcwCvFrMCCDRfpdnylbPqT8sSEmE7qvc8nIRY6YkbSr7
	IQPqeQCsU9cMnDyfVVfh4pubzwOo8Vywt+GnNc+GDPp3pLkNzLTA9aAE5N5yjlLb0cpnu/
	WW+cH7yYtlADx8jaJEdKLkgFxZkvsV8=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-504-lcJ-lqA5OHKGjhQpmP4ZrQ-1; Thu,
 03 Sep 2026 13:42:47 -0400
X-MC-Unique: lcJ-lqA5OHKGjhQpmP4ZrQ-1
X-Mimecast-MFC-AGG-ID: lcJ-lqA5OHKGjhQpmP4ZrQ_1788457366
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A37E4185511C
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 7C1231956056;
	Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id CD5D453458C7;
	Thu, 03 Sep 2026 13:42:45 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 1/6] rpcbind: only log failures in check_callit() if connection logging is enabled
Date: Thu,  3 Sep 2026 13:42:40 -0400
Message-ID: <20260903174245.1213147-2-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

logit() forks a child process to call syslog().  A client can spam
CALLIT/BROADCAST/INDIRECT requests, leading to CPU, scheduler, and PID
pressure.  It's better to only log failures from check_callit() if
rpcbind is running with the '-l' option (connection logging).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/security.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/src/security.c b/src/security.c
index 38967dd..02651d7 100644
--- a/src/security.c
+++ b/src/security.c
@@ -343,11 +343,13 @@ check_callit(SVCXPRT *xprt, struct r_rmtcall_args *args, int versnum /*__unused*
 	return 1;
 deny:
 #ifdef LIBWRAP
-	logit(deny_severity, sa, args->rmt_proc, args->rmt_prog,
-	    ": indirect call not allowed");
+	if (verboselog)
+		logit(deny_severity, sa, args->rmt_proc, args->rmt_prog,
+		      ": indirect call not allowed");
 #else
-	logit(LOG_AUTH|LOG_WARNING, sa, args->rmt_proc, args->rmt_prog,
-	    ": indirect call not allowed");
+	if (verboselog)
+		logit(LOG_AUTH|LOG_WARNING, sa, args->rmt_proc, args->rmt_prog,
+		      ": indirect call not allowed");
 #endif
 	return 0;
 }
-- 
2.55.0

