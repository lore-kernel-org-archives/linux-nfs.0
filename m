Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C69D94A2638
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 15:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790263751; cv=none; b=hbNCFLiNT6bxGkk6OTSLVkN1yqZPieEcVHPvOqS8lXv9bCrH3ViuvqU/D69eTCXNyVstvoQjTjyISnGxlSsbVE3Jz8cxj58VH54zuEdD4/YuAZdKL6s6ZNPygCLw1U99RhvUfKW/B56Ilke5XbcPFA9Pt9x2kx9+SJtfGSK8ec4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790263751; c=relaxed/simple;
	bh=b8Vrfa1gksEUabZrX8qfJ4PR7LQWiIgTfPD02gWp2/A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dgwb6TEVlCbbWofLi6VKxz9u7If6VggEaZD89XtZhuGe7Cf/qsAeJ8PWqcexOethT5MkOEVyhr/yr4G6a18HFLLqKu4uZk1NhWrYvL+qy42PLd3ry7SFXweVdCUUKyo8t3adutgFrLVq3xRdzxToipwbOqENV5rM9/V7xvZKFIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=W+GxBzkZ; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="W+GxBzkZ"
Received: by mail-oi2-f12.google.com with SMTP id 46e09a7af769-7f4f0c89e33so1347645a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 08:29:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790263748; x=1790868548; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LEbyg7CKiEM5Y+PH4FmcXsI0nVh3tU69PmDVbCDNouA=;
        b=W+GxBzkZ3S5EY9k2V7w1oUEYgIOd55ohwkrCJiGjda20ocH4XIQYdBuLpE9C+ahH3V
         nhPX6TzRu3ohGUBqND6sipZL3uPNEusGc4kVom1qBC7khYELpibcMGr1JgdN/8rokYvY
         /FaSv1DFm8/LpqsKRx5B5huOIZq1eFA0Zt0c5yc3vOKDVu/+tGBkRsDVOSTJ+qdqUHxp
         ZXSQnpGdbXvEfPfrg5VB87krcbePay0fH11vvJas1J7dSgg0qgbziPK1y6zQqAc4T/NR
         hR2D8s7Hiu6ibth1Yl8eQxHeBtql5UZYCKFgbDflQlpcjoXjc1LhEEtFEx0SLmQPpARW
         oGvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790263748; x=1790868548;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=LEbyg7CKiEM5Y+PH4FmcXsI0nVh3tU69PmDVbCDNouA=;
        b=fg7vAn2EsiO0lz9HfNHs8MgrB2DqKRupiRYNaGiIe4f0yPS7BuE2B0NDwQhvJsf+V0
         5p45+j8KQ2viFrqHT0Wfy9TC9/pbEJaUwtpHqiN4STFWySJY9rv5RBks/Mc5LbhPUL05
         BAv6IHy5EfMKXmWQ8260+9nYCShv/+XxbQDKMiF5k07Go460fSj9qTsaa2gSI2SDXrqT
         DPYfxrA8lLbJfiOqezSedf0V/BecGD5BVt39pcceDusloaRiKztv8IIZHgzfZC46gP9e
         s16o0zwOw56aGm1BBDMgBc5qhDUqsya4j0RTjOmj0xX0Y/iPBwNZS8jA21auTBJpKvqZ
         KOxA==
X-Gm-Message-State: AFuF++k6afq+i/ixZTHyc+hx/o4O0soxF2SQZJIqtrOivrbL1cwh33mS
	KstLnH1GlWc8I+Tha4I+GILeBakzN6Dx388Nv0wt+nbV4tMdVkflhvmKCdlyjzOUggc=
X-Gm-Gg: AYBFou0/kByVAKhwitVbUcHlUxvQBDUo3J7695rpsnTirvV5LE847OwDCFcPH0UTvFp
	nExTUGUOThPlzDQ7el5Qf7SdEpGeUBx9VDWaQ5FkjoChMZCwNcN9iyJp4ImNRz9BvjxXh2v8EVc
	ej98Aa27tBpTTRfP3/P9EpJEGB49dzw49wOyW5CpDQ9q23fPnRTglQv6dwW6jlZye5WFeOYvBZ6
	s19PcJjA4yf5rhf4KQHodkGlTHJIdkD/S9/4Kn9HJM3W3aNNalexsyfO88tgHLxZ8oky5qxEuFW
	vVMReWaHlg5KwO793YJi5nuw2uMfZ4yS17flK9tuVQNFONp1z5DhjE+zUPMgJ2jcC+R7DsLBeVU
	tcB7ey2dU6xBLPIPlp54XkbEJIq1sEmzUjjB8W5H//relWTzXcjgU4lF3wa/9jj5Z0RelLP3NW8
	AgG1YPalaEwabYr7ZEV/femZMsTUeP2XnUo0jbMeAUYRTldIYQncV+ljYCZP7ufq26NDjkEFdN5
	lPuVhNJA+is6yciYZI2w5WYsgulPK0GKF4=
X-Received: by 2002:a05:6830:43a0:b0:7f4:2418:7ed8 with SMTP id 46e09a7af769-81780c940f4mr2966347a34.12.1790263748239;
        Thu, 24 Sep 2026 08:29:08 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-81603ad2b19sm6551506a34.4.2026.09.24.08.29.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 08:29:07 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] exportd: stop exiting from a signal handler
Date: Thu, 24 Sep 2026 11:29:03 -0400
Message-ID: <4513fefc0741f08cfa76777ae10edc6b579ad4db.1790263469.git.bcodding@hammerspace.com>
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

Same change as for mountd: use cache_block_signals() and call killer()
from the process loop once cache_stop_signal() is set.

Assisted-by: LLM
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 utils/exportd/exportd.c | 30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

diff --git a/utils/exportd/exportd.c b/utils/exportd/exportd.c
index a08aaaccbc2f..d63195c4ea28 100644
--- a/utils/exportd/exportd.c
+++ b/utils/exportd/exportd.c
@@ -61,14 +61,13 @@ cleanup_lockfiles (void)
 	unlink(etab.lockfn);
 }
 
+/*
+ * Called from main() once cache_process() has seen SIGINT or SIGTERM,
+ * never from a signal handler: see cache_block_signals().
+ */
 static void
 killer (int sig)
 {
-	if (num_threads > 1) {
-		/* play Kronos and eat our children */
-		kill(0, SIGTERM);
-		cache_wait_for_workers("exportd");
-	}
 	cleanup_lockfiles();
 	free_state_path_names(&etab);
 	xlog (L_NOTICE, "Caught signal %d, exiting.", sig);
@@ -76,14 +75,6 @@ killer (int sig)
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
 inline static void
 set_signals(void)
 {
@@ -96,12 +87,7 @@ set_signals(void)
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
 	sigaction(SIGCHLD, &sa, NULL);
 
-	sa.sa_handler = killer;
-	sigaction(SIGINT, &sa, NULL);
-	sigaction(SIGTERM, &sa, NULL);
-
-	sa.sa_handler = sig_hup;
-	sigaction(SIGHUP, &sa, NULL);
+	cache_block_signals();
 }
 
 static void
@@ -242,8 +228,10 @@ main(int argc, char **argv)
 	v4clients_init();
 
 	/* Process incoming upcalls */
-	while (cache_process(NULL) >= 0)
-		;
+	while (cache_process(NULL) >= 0) {
+		if (cache_stop_signal())
+			killer(cache_stop_signal());
+	}
 
 	xlog(L_ERROR, "%s: process loop terminated unexpectedly(%m). Exiting...\n",
 		progname);
-- 
2.53.0

