Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DE16C04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 18:16:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3230B2081C
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 18:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JNBPwJFI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3230B2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725732AbeLBF3h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 00:29:37 -0500
Received: from mail-pf1-f195.google.com ([209.85.210.195]:40151 "EHLO
        mail-pf1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725726AbeLBF3h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 00:29:37 -0500
Received: by mail-pf1-f195.google.com with SMTP id i12so4372130pfo.7
        for <linux-nfs@vger.kernel.org>; Sat, 01 Dec 2018 10:16:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Uv4ynGws8NlsVVFe+PaKZzQkwudBNYnPCID2Ig21U6I=;
        b=JNBPwJFIXY4HIBkvur7vYI0aQQ6/yjzxytZpZsoJc1PfwK2beH2HyoDLpyXnFc4FiE
         fng3KpyHHkQ2jBtB3eosAShBVifAqVN3LoR7epU4wUXcm2y+9xYvzKBZzRYOc7KRos6w
         G0yisv6oSihawXnRXQrXdTBjI5VrSnsBL6SJ74kSNN1KKy4p6YQjV58I0+cGtBUswAnl
         nA0gML5LRa4+/1KcXKlLkDMo6tgqrb9A5LUjugUaszyP+kPpNTWenyTehz4yUT0zYhky
         bkH2vcKOXES6WrmFhro8B62osvPlOSCe2mm6MhRFQsHO6wx4zC95Nk8mSZttH64e2fE3
         C/wQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Uv4ynGws8NlsVVFe+PaKZzQkwudBNYnPCID2Ig21U6I=;
        b=E1Zdc5t+Ca6hSPe+yH6N7B/OgwwemBXYCqljnrSd2lLuRe6DCs+m5LpXrEbs4YFyv9
         ZwZi4HHidD+fCNQEHFNRLTsq4Rv/VYhRhVj5xj+QuYU6CVfaPPS6fhfWiuImeYLElmoq
         mwalJs1uQeBoIBGCPSXfnaJd8gs0LLO+x345l7l9TXy/Hasty/Ciu7LB3H/qDLXJAhM+
         bJWxCcSPx3yWQmzm3dcHAIbFiAIm1BpXyYbCTHcl3TMzHcxD2dLbK9NPFo22+v3yREnC
         UD8J7BgqU0BJZYqSJzcHL/0ii42T/7dNGxf1IE3CZYRmbeBxKbCO9x0e1xiJueyhTaUk
         Ps5Q==
X-Gm-Message-State: AA+aEWaqqABBXC3kHdtSwagz/TYT6Z/qLPrm3JQHZs8/As2P4RZGaA4r
        t4RkG+RHFvk1ywH9z47HT8d2GU4Wdk4=
X-Google-Smtp-Source: AFSGD/XnQZM1HTJl8J5KHcTszPAebrMAOaVnV4AeeYxvYqqObVbBU6IyemrmQux2pGc+fIGVu4qvaA==
X-Received: by 2002:a63:dc54:: with SMTP id f20mr8597957pgj.410.1543688191075;
        Sat, 01 Dec 2018 10:16:31 -0800 (PST)
Received: from localhost.localdomain ([2601:646:877f:9499::26ab])
        by smtp.gmail.com with ESMTPSA id s190sm11570042pfb.103.2018.12.01.10.16.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Dec 2018 10:16:30 -0800 (PST)
From:   Khem Raj <raj.khem@gmail.com>
To:     linux-nfs@vger.kernel.org
Cc:     Khem Raj <raj.khem@gmail.com>
Subject: [PATCH] cacheio: use intmax_t for formatted IO
Date:   Sat,  1 Dec 2018 10:16:20 -0800
Message-Id: <20181201181621.7268-1-raj.khem@gmail.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

time_t is not same size on x32 ABI (ILP32)

Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 support/nfs/cacheio.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 9dc4cf1..2086a95 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -17,6 +17,7 @@
 
 #include <nfslib.h>
 #include <stdio.h>
+#include <inttypes.h>
 #include <stdio_ext.h>
 #include <string.h>
 #include <ctype.h>
@@ -234,7 +235,7 @@ cache_flush(int force)
 	    stb.st_mtime > now)
 		stb.st_mtime = time(0);
 	
-	sprintf(stime, "%ld\n", stb.st_mtime);
+	sprintf(stime, "%jd\n", (intmax_t)stb.st_mtime);
 	for (c=0; cachelist[c]; c++) {
 		int fd;
 		sprintf(path, "/proc/net/rpc/%s/flush", cachelist[c]);
-- 
2.19.2

