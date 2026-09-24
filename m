Received: from mail-oo2-f27.google.com (mail-oo2-f27.google.com [74.125.231.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9394E4A1E04
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 15:29:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790263752; cv=none; b=AGtB9jgUw8v56HTL1/RdUWEWgX+nQ6ZSDWLKfTmyDokcLxq6/polt6Mh9pltqX9Lsbt2MQpK8rKiCEkbIBzh7T49Tg6E1vRidqRbJYo18iKtjj1s0fL66R2Enq6gFZNAx5hWaOjPG7KtNBaLFp0oIJRXRgTPYrE+joifMzuRkFQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790263752; c=relaxed/simple;
	bh=QgEaMLYhkX4ydTtSE2NwwA19Wv716GCleI+H1gmxepw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Aoy5fTI4GY9IRaEDMNnfUdzCeyeg8CqP1bgFi/dsPzySMMX/QQ+yO/NAqmUIGceNgZ3hvK0U8Ch7h75G2JiGR0a2LizOffyZivCiY8uz5kM9Qkq+9CueenJb2zmCb0eo2htHE0ymWXe94u7eT8gtRMT9KU0+bmU0uCcFppnFCoM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=d94MWxwA; arc=none smtp.client-ip=74.125.231.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="d94MWxwA"
Received: by mail-oo2-f27.google.com with SMTP id 006d021491bc7-6bc475ffcbfso257496eaf.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 08:29:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790263749; x=1790868549; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=svQzfaauVWbuOsDDyFg1hTJf0QuTPa0Fc8wazFBM7Bc=;
        b=d94MWxwAoow4ILitVhTCriClWe6vVeTg33ajlt348J317NqreWEkZxJVaFsV1ANuwU
         XL5/OyZUenBiVOE453riBcQJa9NlyeAZjG4unLpiJ3cggaZuvHiE+z4nSGyFPSiMn/ZH
         pQNRlKvlkT+vVXwE92ZsWoveTSGty5jRRUV3Tro/JICfLoRip+UPBVPYYe9hpwtsxnR+
         zTs5krI94T6mPuubdnIzT9scjj96ugQ/G9skAPkg/ZCZ89+j3SiMc+3PXUJyzBSKbE3U
         u4Zxp1fVxK3XggopEHleEecNHBTG3ZcwquUaeB7td2p5vGtIrWcdlTuGzdcaEAcBZgwR
         3/TA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790263749; x=1790868549;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=svQzfaauVWbuOsDDyFg1hTJf0QuTPa0Fc8wazFBM7Bc=;
        b=0kMp37ITZzKiVsfDw7aOPvMsOu9rv2cka3QjM9QL8fEVOjwMVsdh13mdGOok8acwxY
         HyazqEBtirkZBtd3Rw6ChxUgCwo6zOnVeUqItcgIVxokl2YfIwcvqZNSF22RN08tuplQ
         nLMs/ITGTNzhw2hK7bC7CTd8YfQFTjlWILXjzIknW2RH+xvW9/JgLqE+uodK4EzdeOLa
         m15VnOyH+nzGfSVC91R6i794Hjwt70aNHKtzs5t22Eh1PV3TK2jULRZ18oyozo8CjilQ
         ef/DlVlQjR+GpJjQuzdkQ9r06nSrGf7lDYyo/x9D2+WmD8wQjDsMZaYnZj58C2NAQm4w
         t5Lw==
X-Gm-Message-State: AFuF++mKh7O0/Zl0cciVjk8XyZ1wGnVl2QSfeSStsjST7iCB0MhNJiCj
	PS1+l3v+wWk/z1mDLuAydza2Af8/KOe3h+EHaNTq0573dsj5bdMx+Qq3MnDhz4XY8VERrHu/RM3
	ICo0c
X-Gm-Gg: AYBFou1tpWYIqkI8q1HSAcLEfYqlf2fscIabIC1thPO6iut8i/JRrQ95fBAPRp8EAcU
	jFTAcEUV4qYYUmFPAV8wvEZSnbF29M3KB2pWMdh9ZLfokOHqFzRydZztidTFlatlGvB1ZXGfpgW
	yZ97B6wc77jnzK+lxjmGVGM2YuIbcfEaALs1lDLwG+1HOqVgEhJGJLMXw8paKkJ4wEIDLRncRt8
	ZgrPmnp6/I7g4SYhhwdssrCVqBUQB+ztA/nw9/Ecm4dIDamgb9lW9nx3Ab55fFzlielu6GhlsIW
	Icq2AIjQKqfE0kb87SQK14XJCjwxqQsAwY7WejiFDyOhh0gNtlPcybqWdNCaG68yRwTjnOYH16A
	YGBa77PluFP5L0zadVPUcFB57UUNMgld0FS3iXXDEbHxONdwJkwZeBmt6ZVb4Ky0tpO2hkJtcfA
	XHTU11fMb/413yTnE05em+QxRAHs/0xPIKsEugYwn16V6N9lH4LeOn4cxbTPw9hiKJjZCMQiTio
	+lsIyCuFgKqimLUwzJJd1HtC1H3AZaq6Vtnpy1K3j8k
X-Received: by 2002:a4a:ee10:0:b0:6b1:bb82:f7a3 with SMTP id 006d021491bc7-6d43f2c790emr2875595eaf.5.1790263749050;
        Thu, 24 Sep 2026 08:29:09 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-81603ad2b19sm6551506a34.4.2026.09.24.08.29.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 08:29:08 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] mountd: hold SIGTERM during rpcbind registration instead of ignoring it
Date: Thu, 24 Sep 2026 11:29:04 -0400
Message-ID: <b9bacfa339cb927f26194f6381942462a09a0067.1790263469.git.bcodding@hammerspace.com>
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

mountd ignores HUP, INT and TERM from just before it unregisters and
re-registers with rpcbind until it installs its real handling.  A SIGTERM
in that window is simply lost, and mountd carries on as if nothing
happened.  With a local rpcbind, about half of the SIGTERMs sent in the
first 30ms of startup were dropped this way.

Call cache_block_signals() there instead of ignoring them.  A signal that
arrives during registration now stays pending until my_svc_run(), which
unregisters and exits.

Assisted-by: LLM
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 utils/mountd/mountd.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index bdbff1dda0b7..5c2d5ddf2577 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -851,13 +851,14 @@ main(int argc, char **argv)
 	sa.sa_handler = SIG_IGN;
 	sa.sa_flags = 0;
 	sigemptyset(&sa.sa_mask);
-	sigaction(SIGHUP, &sa, NULL);
-	sigaction(SIGINT, &sa, NULL);
-	sigaction(SIGTERM, &sa, NULL);
 	sigaction(SIGPIPE, &sa, NULL);
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
 	sigaction(SIGCHLD, &sa, NULL);
 
+	/* Hold HUP, INT and TERM until my_svc_run() rather than dropping
+	 * them while we register with rpcbind */
+	cache_block_signals();
+
 	unregister_services();
 	if (version2()) {
 		listeners += nfs_svc_create("mountd", MOUNTPROG,
@@ -871,8 +872,6 @@ main(int argc, char **argv)
 	if (version23() && listeners == 0)
 		xlog(L_WARNING, "mountd: No V2 or V3 listeners created!");
 
-	cache_block_signals();
-
 	if (!foreground) {
 		/* We first fork off a child. */
 		if ((c = fork()) > 0)
-- 
2.53.0

