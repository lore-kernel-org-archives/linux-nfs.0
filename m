Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E80DC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CD182147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gt+E61sD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725794AbfBSNzR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:17 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36426 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBSNzR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:17 -0500
Received: by mail-it1-f193.google.com with SMTP id h6so6316830itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wXjLTa00JtUj+bxtm/gQ5O9DQfSATWfqpQWj8DpjYoI=;
        b=gt+E61sDZv1olrmsclTkqYbE3/2MJTzCKttvSPkCLFyH0RanHX8tSt2NdVGCvWLi5Y
         Gw6TFgWt4VF+7fp449a4iClPX8C8aY9mxQjmGRCci+78uYB7w3liDhjGqqgRVigxEUjB
         NI0TUWA5hMLl3SILGEdYLJz6OZFmKCu9R468BDJx6oG3pUl9OkFHbaA3HGSB8TgM3C9t
         YfyKMTmmBu7lSQ08wH25Oru/MQ889xUw74xqV5L9H77h/+k90hc2JKunPP3Sfa+7Jxwj
         sLHU6vZaYE5EUkjptvxvx+lcK7SY0udrMn7YzVnlYPCYeo5QedUVbsq9hWA9BQnhWD8v
         NeCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wXjLTa00JtUj+bxtm/gQ5O9DQfSATWfqpQWj8DpjYoI=;
        b=cjYmDu+Po6RCiLVOC7fxJwx6xoLp1DhHyQ/ZnMHv8y9Cm7NJkydAGEgJOfkv5veMJL
         XnbmrGLadRP2Bp/U3ukvuR+U6WjdoDrolmJVFLmTpCQbO3FTLFvHRNpFwzxhv0TpKYIA
         xu1js7hFktyKfZIZ+X585XlfE5hbIZrCqQ3et1v4AjYSI62eCNojf63tgmmXQDc4j7hI
         hvjo2uGqVM5vuVKlN0NkiTwZ+QzrE8uJEdqDRIirM1igxqe20djMlC4I3ikZ4L615914
         EnfmepzlJ6WKpVFfri3Y5KSVXKJtLL0cDRdDMBpAiuC5ldniMc254j7IrzfCLxrNwyPO
         cm3Q==
X-Gm-Message-State: AHQUAuaHNh6azpCGhJTPUUWbx8JHEcKXRHriVJQUDIR8f6wdckw2jx7z
        EsyJqCKs3v2AcuEIIi0LmS+8/ws=
X-Google-Smtp-Source: AHgI3IbA3qSM3uviqm5eUU8ktv/Brmub9A59HzecXrGoC+dPuZVyM5sBAkEEA//8iTQgAwe8Qz98lw==
X-Received: by 2002:a5d:9b0d:: with SMTP id y13mr20277556ion.112.1550584516463;
        Tue, 19 Feb 2019 05:55:16 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:15 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/8] NFS: Don't recoalesce on error in nfs_pageio_complete_mirror()
Date:   Tue, 19 Feb 2019 08:53:06 -0500
Message-Id: <20190219135311.119300-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-3-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the I/O completion failed with a fatal error, then we should just
exit nfs_pageio_complete_mirror() rather than try to recoalesce.

Fixes: a7d42ddb3099 ("nfs: add mirroring support to pgio layer")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.0+
---
 fs/nfs/pagelist.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 03bde9a41451..a8951f1f7b4e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1209,7 +1209,7 @@ static void nfs_pageio_complete_mirror(struct nfs_pageio_descriptor *desc,
 		desc->pg_mirror_idx = mirror_idx;
 	for (;;) {
 		nfs_pageio_doio(desc);
-		if (!mirror->pg_recoalesce)
+		if (desc->pg_error < 0 || !mirror->pg_recoalesce)
 			break;
 		if (!nfs_do_recoalesce(desc))
 			break;
-- 
2.20.1

