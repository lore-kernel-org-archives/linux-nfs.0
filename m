Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4A062F7EF8
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 21:19:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782422341; cv=none; b=IQzGibRWU5kWt10t3rTLPZO9prs09JSdRgYxM3LsP0P4wA5HT0ndcsByGJuVU0o+cQFxScBEB4XPCdnwUuIuuV2PiDO7JvZX6d9LxEZJC+7UKSOtZx+AEID5uOnzoujeZ7Vr71wNSSBuPyj/40VwAuQU7FTOXnt1iAc8FOS1BS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782422341; c=relaxed/simple;
	bh=z15VvCqyN/YWCcDCbhxNtYJguCs21TenEFk1JMBNIys=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Kgz8S6pxik0M5zJkrfH4oUOGCMLWrJsjIUNqapq6abTD60wii9bWZ62OTtdQQJ3I0l63puVsGiI8XyP5Dqp8/KnBmW3JaR9SMCx+eCpMcH+OfqPuPc83gOtpidUSNGi70HR7Mp6aVBv0zmCobTo7ZyAr9Dp8BBn0Wo72tlDt2Nc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ckmwFfEU; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ckmwFfEU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1782422339;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=MVG6ftV9/i/914h5jGhpHyXPvzG5x7ecJSXQcFt3JCE=;
	b=ckmwFfEUZYpVN24Mgq/LxxOCWt2PCuz+q/pDtc0azdmITaqIzUKbGl3+Fd2ynQGn8F6csT
	x55sDBYC3j8yk6MGSb3n0oK3akpB/77kCxL58g9LgvD3dK9+K2qndznV2sCD0XPaAdUgHH
	8o5C5inYCZs9dLGZMEvAIwZwFdq9S/Y=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-169-BYiVwYZOPGaYTk2zwvrv1A-1; Thu,
 25 Jun 2026 17:18:55 -0400
X-MC-Unique: BYiVwYZOPGaYTk2zwvrv1A-1
X-Mimecast-MFC-AGG-ID: BYiVwYZOPGaYTk2zwvrv1A_1782422334
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5D0021873C33;
	Thu, 25 Jun 2026 21:18:54 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.66.8])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3CFC4195604A;
	Thu, 25 Jun 2026 21:18:53 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: chuck.lever@oracle.com,
	jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org,
	neilb@brown.name,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Subject: [PATCH 1/1] lockd: fix GRANTED_MSG handling
Date: Thu, 25 Jun 2026 17:18:52 -0400
Message-ID: <20260625211852.31972-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

GRANTED_MSG is a server-to-client callback, so it runs on the client,
where nfsd never registers nlmsvc_ops. The nlm4svc_lookup_host()/
nlm3svc_lookup_host() helpers are for the server-side request handlers
(TEST/LOCK/CANCEL/UNLOCK), which reach nlmsvc_ops->fopen and must
reject requests when nfsd isn't running. GRANTED_MSG only calls
nlmclnt_grant(). Instead, of calling nlm4svc_lookup_host()/
nlm3svc_lookup_host() (which results in a client failing a GRANTED_MSG
call) call nlmsvc_lookup_host.

Fixes: 62721885e861 ("lockd: Use xdrgen XDR functions for the NLMv4 GRANTED_MSG procedure")
Fixes: 6c534ad999b6 ("lockd: Use xdrgen XDR functions for the NLMv3 GRANTED_MSG procedure")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
---
 fs/lockd/svc4proc.c | 3 ++-
 fs/lockd/svcproc.c  | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 080dffce9d8e..b73004a7987e 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -872,7 +872,8 @@ static __be32 nlm4svc_proc_granted_msg(struct svc_rqst *rqstp)
 	struct nlm4_testargs_wrapper *argp = rqstp->rq_argp;
 	struct nlm_host *host;
 
-	host = nlm4svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
+	host = nlmsvc_lookup_host(rqstp, argp->xdrgen.alock.caller_name.data,
+				  argp->xdrgen.alock.caller_name.len);
 	if (!host)
 		return rpc_system_err;
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index dce6f6e3fd40..d410b8c69893 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -901,7 +901,8 @@ static __be32 nlmsvc_proc_granted_msg(struct svc_rqst *rqstp)
 	if (argp->xdrgen.cookie.len > NLM_MAXCOOKIELEN)
 		return rpc_garbage_args;
 
-	host = nlm3svc_lookup_host(rqstp, argp->xdrgen.alock.caller_name, false);
+	host = nlmsvc_lookup_host(rqstp, argp->xdrgen.alock.caller_name.data,
+				  argp->xdrgen.alock.caller_name.len);
 	if (!host)
 		return rpc_system_err;
 
-- 
2.52.0

