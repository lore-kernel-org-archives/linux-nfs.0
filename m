Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2A0D4A2070
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 15:29:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790263751; cv=none; b=H8GaP0ou4tZCLc4uUhSW1XicKfe5uO604enEz/+PrfazbHYwl5rGIOdWHaOfNRDtit8rTvjW+3fXszVI0ztmOtLT3x/+KnkixNL34nTBSlME9hNfcFHrZWzr2bItd3+0ThzuPYfeMAVbSuczrDguUy36boEI+tch4kyz4txKtto=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790263751; c=relaxed/simple;
	bh=UtQnkBsrOX8LW2/Ori1OJkwu16forj5zgTbp5+glvGk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LDUYOb780YmJTFoxvc+fUrPPR1zpNiG7IG98UJho8jbKIfxqfvfV4wteB4J+5s0NjxrQE1+4RK485GktBp1S32lsV1Fgf/cOVmQwr6qrASJ5VSRG8aN9vMGopSBdhkFinJlEge/VPEPehyZ+wVR6WFpWPSSoqzpB8cpoK59YpYY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ffblYCRg; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ffblYCRg"
Received: by mail-oi2-f12.google.com with SMTP id 46e09a7af769-7f4f0d37dc4so1483627a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 08:29:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790263747; x=1790868547; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jNygcrs3H4RmUooXemo80t9hSCgF0lV2AB/NXV3J2OE=;
        b=ffblYCRgaPdgTwouhGH58ghyLJwmAFDbsTFJu7TdtVq345VpZLMC19HsQ4rd8dItm0
         IFR4ajOPYzDz4Ppm4f/yUDftCYDxmAd7BibJM7PraplCYfA8aGTLGhwMgr4aQFUXHJZZ
         72L6VN0ab8n6ubuxq9OGRuSr6o6/GOTgSQT1M1W3TaPwI7oErd1Zt1f1kw6lCkTnnlgk
         Qau//0ZMnOSiYnWKZJ5Z0KmL9NBzOKlWj/KIcD3ru6RrEQhAMkLST44PL2FeB7ycxxe7
         97gmC8gQfQnxSnZz5TzK3PC+8Je0WfZHktmROscFUalA+F/4Y0IS7QkZe3W6QnQgrtFp
         r4Xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790263747; x=1790868547;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jNygcrs3H4RmUooXemo80t9hSCgF0lV2AB/NXV3J2OE=;
        b=gO2F1Q2bgfE1DNrS2IBTCfBiHlIVCA0USIYbXcrQIZ5rzMcpF3PUEqaqEURycnaDA6
         1fZMHWsYGI04LeS8PsJfzyGokycNlsHLX11M1ZD6jv4f23xj97UxRXxw4rriQowMx7RB
         D8n6NEBDQM9s44oGwDDjrQWzrNjMJLh53Kr5VUonDvpibQ+kj1oep7hBiOIZnCeNleoF
         HILISHBfidHMfLWYTUlNeqb7vdkidPvbY/8psvpPLM+a0VBM9RV2fgRwk3KMxFKIP7BQ
         kElH5qcmmiAGVCw86aOu5dK6ttN0ACfgg8NvV4vV7jbnx/+o+DlehvLDmTVvdI1G+xMY
         S3ew==
X-Gm-Message-State: AFuF++m/p8TrbVAOZpQfq74OjVAz9+eP+RsEwmGi4tITwzm4R5oFlCgz
	JT2A0Lk3SjihSJKFVWjc2+wiotvzd/Cc2eqrE5Y42EumPndIp9hMotQ0K12/zZ5O7V2BFXJ44Xr
	0Oe0L
X-Gm-Gg: AYBFou0s63KJIsOCiUT3Se7dHgar/ES/YYrZ1n6jyvxi9PyZc6fbpNKeZeg8K40B80t
	UB0gykAPaKCC0gElk1GT6TYM6xw2HUe/PGi55jZqBc/bFdxQS65L5f6ycexttwMvi7jADO8fvnj
	wrDyvh0TwUp9azkVkFi6VUnQOyxIvmdl5IkfNdIK6F5CJpeBTuxQCNbnfTJbIZNusO/sMErxxlE
	6f/c/9XVSImD8nB4M/zBPz80PnFHYLZK40ME6VByGDHco0eEYQyiok4PfRx9RFOWQ+IUK4SFRlb
	65vXUDXD9PW6CcUuGDS0pLoOJhmSPprOkyU7lsxYf1D4MDvqRCiJq65Tc5Lj6gQJS8emX5PzwG9
	6C4fuospM4EMgLvzKFAaJYyKhtSd+BLOYp6eJNlPqfJK1dA/zlarqlGOdReRU8mKrEpLgV+z3zo
	YpzCydw00hKNkTCLbxritNFCC0LlzzdEgjml0ag2SUEi9mbFnZ2nCN9261Da3sDRnSByyeoq2y4
	OhmAswQ2OxGEsllWPrsWaj+accy1s37uw==
X-Received: by 2002:a05:6830:83b0:b0:7fc:ae19:17ec with SMTP id 46e09a7af769-81783e88241mr3013429a34.29.1790263747503;
        Thu, 24 Sep 2026 08:29:07 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-81603ad2b19sm6551506a34.4.2026.09.24.08.29.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 08:29:07 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] mountd: stop exiting from a signal handler
Date: Thu, 24 Sep 2026 11:29:02 -0400
Message-ID: <20fec8c5b5668f67a002240c240d27a21f6e7e5c.1790263469.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1790263469.git.bcodding@hammerspace.com>
References: <cover.1790263469.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Use cache_block_signals() instead of installing killer() and sig_hup().
my_svc_run() returns once a stop signal is seen and main() calls
killer() from normal context.  The worker handling in killer() is gone;
cache_fork_workers() does that now.

Assisted-by: LLM
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 utils/mountd/mountd.c  | 25 ++++++-------------------
 utils/mountd/svc_run.c |  2 ++
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 92d8c4690efc..bdbff1dda0b7 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -124,17 +124,13 @@ cleanup_lockfiles (void)
 }
 
 /*
- * Signal handler.
+ * Called from main() once my_svc_run() has seen SIGINT or SIGTERM,
+ * never from a signal handler: see cache_block_signals().
  */
 static void
 killer (int sig)
 {
 	unregister_services();
-	if (num_threads > 1) {
-		/* play Kronos and eat our children */
-		kill(0, SIGTERM);
-		cache_wait_for_workers("mountd");
-	}
 	cleanup_lockfiles();
 	free_state_path_names(&etab);
 	free_state_path_names(&rmtab);
@@ -142,14 +138,6 @@ killer (int sig)
 	exit(0);
 }
 
-static void
-sig_hup (int UNUSED(sig))
-{
-	/* don't exit on SIGHUP */
-	xlog (L_NOTICE, "Received SIGHUP... Ignoring.\n");
-	return;
-}
-
 bool_t
 mount_null_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
 	void *UNUSED(resp))
@@ -883,11 +871,7 @@ main(int argc, char **argv)
 	if (version23() && listeners == 0)
 		xlog(L_WARNING, "mountd: No V2 or V3 listeners created!");
 
-	sa.sa_handler = killer;
-	sigaction(SIGINT, &sa, NULL);
-	sigaction(SIGTERM, &sa, NULL);
-	sa.sa_handler = sig_hup;
-	sigaction(SIGHUP, &sa, NULL);
+	cache_block_signals();
 
 	if (!foreground) {
 		/* We first fork off a child. */
@@ -939,6 +923,9 @@ main(int argc, char **argv)
 	xlog(L_NOTICE, "Version " VERSION " starting");
 	my_svc_run();
 
+	if (cache_stop_signal())
+		killer(cache_stop_signal());
+
 	xlog(L_ERROR, "RPC service loop terminated unexpectedly. Exiting...\n");
 	unregister_services();
 	free_state_path_names(&etab);
diff --git a/utils/mountd/svc_run.c b/utils/mountd/svc_run.c
index 2aaf3756bbb1..259d03b2f031 100644
--- a/utils/mountd/svc_run.c
+++ b/utils/mountd/svc_run.c
@@ -105,5 +105,7 @@ my_svc_run(void)
 		}
 		if (selret)
 			svc_getreqset(&readfds);
+		if (cache_stop_signal())
+			return;
 	}
 }
-- 
2.53.0

