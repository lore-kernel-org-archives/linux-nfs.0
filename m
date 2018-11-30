Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12246C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C910B20660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZzTYc7f7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C910B20660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726571AbeLAIae (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:30:34 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:53864 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAIae (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:30:34 -0500
Received: by mail-it1-f195.google.com with SMTP id g85so618212ita.3
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:19:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=ZzTYc7f7+BmSqMQS0wQU7pPh4Gi/4qecvkbc8I7O7xmmT3cMlknmZL2xtsTHQdpCwv
         PeqQO/jNy1e+vHSpcsSJIob+uzYZDcTVB58NATPf3IkSvZKuKtTyIdH2rUCQf3QZNMc7
         JrolU+cwq5Hm+YvgDwnfZZU9Zia4LgDS4kaxVGwfUFwwfgVH25CmeltSrmys7e89pBhV
         k0QeyzwVB2y3EirMpHLF6O9UxstqQr7Myh8FOH/QE70NkI1ADP9W8+ykvb8lFuyJQhmV
         atfZ4slFvBJi07JfPF3il9kvDK+6J3Rbyxj72nHHTh9pQ/BVrS/AwupqdeBh/MCsJByE
         1CVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=01dPSorkMzYoAkW8cLBYQTAhpw9QBeR18qNhoOAgQ3Y=;
        b=ox0/bvfnpqyBv4rXHVcJ178RyXHbWZ+6mvn/Yl1tu8cgmrj3gtZvq2UXr5GZvCnen2
         hh1nrNpH/XdA82eDAWuAVnOW7WOltR0cE6JrUxmJqzjD+LXreidyjdSN2ON/lND0sRxE
         WmAHh4EPGt+bpms+yJNHTk4TUDYEzMtREXeL2qsUaxpWoc9sbnCjfgld01E7I+XSlVYh
         u5b6gZWbPdxugAKtr4KCSQBr0Vjp3TOpP82LpZ7iEMuK6+iAdFrpkYO3Z9wcViFf0F3q
         LzgJvsghjpvpElR0WvzW7tm/vylGGTqaNHIKaV2TDM4TKp/3xLXOXdqAOSgVKGVfmJre
         cyzw==
X-Gm-Message-State: AA+aEWaoiSKSMhFIQTlr4EoflybjR9aQwiUYIyh6ME4kJ09kYUGoDA5c
        iGSJi/bslaP+dKOH0n1xw+7W4vc=
X-Google-Smtp-Source: AFSGD/W8r0r8h9vKG2RZ4ogByGn4b60FEdS3eSUu0TptprqQevo7NyDvPRVAxAA3nil6GRGPzDAGkQ==
X-Received: by 2002:a24:ce45:: with SMTP id v66-v6mr377906itg.26.1543612796585;
        Fri, 30 Nov 2018 13:19:56 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id y1sm141393itb.29.2018.11.30.13.19.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:19:56 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] SUNRPC: Fix leak of krb5p encode pages
Date:   Fri, 30 Nov 2018 16:18:45 -0500
Message-Id: <20181130211846.89000-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

call_encode can be invoked more than once per RPC call. Ensure that
each call to gss_wrap_req_priv does not overwrite pointers to
previously allocated memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5d3f252659f1..ba765473d1f0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1791,6 +1791,7 @@ priv_release_snd_buf(struct rpc_rqst *rqstp)
 	for (i=0; i < rqstp->rq_enc_pages_num; i++)
 		__free_page(rqstp->rq_enc_pages[i]);
 	kfree(rqstp->rq_enc_pages);
+	rqstp->rq_release_snd_buf = NULL;
 }
 
 static int
@@ -1799,6 +1800,9 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 	struct xdr_buf *snd_buf = &rqstp->rq_snd_buf;
 	int first, last, i;
 
+	if (rqstp->rq_release_snd_buf)
+		rqstp->rq_release_snd_buf(rqstp);
+
 	if (snd_buf->page_len == 0) {
 		rqstp->rq_enc_pages_num = 0;
 		return 0;
-- 
2.19.2

