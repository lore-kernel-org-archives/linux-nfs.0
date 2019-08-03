Return-Path: <SRS0=Vt5f=V7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8086C433FF
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 15:00:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC8DD214AE
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 15:00:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ravujXrt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727845AbfHCPAh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Aug 2019 11:00:37 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:37510 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727535AbfHCPAh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Aug 2019 11:00:37 -0400
Received: by mail-io1-f66.google.com with SMTP id q22so38891096iog.4
        for <linux-nfs@vger.kernel.org>; Sat, 03 Aug 2019 08:00:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0pFB+4SQh7Dkgli7Gh6pL88AFg9wW+6p1cHkhZw918E=;
        b=ravujXrtMqYxtV2qgbAOzi3Pe4ofolJ/ojfovdZ6CSF0ooSAZhrFwwnUckGNi7FbVp
         h/ffzZEb/yffXJZ46/MDjakIGSp3/HFrE5QQid3EuQKvYRlDnZCC58xKxR+fjIqvlAa0
         AvYZmAI/qyFZ6wtBkpvjC29fgnH2X//WXdMcIxtA6BUUDQuigirSWUV9pXUcNGm6pCCd
         ztPM9TEdyzqG5Kxd5EELABYCYywtTbojqFFMlO/Am6U4RJP+jbfCy7h+BiYpOoJc9gqn
         EmkcvXN470jgdcp4HrDYGu8IsjelMxn5um9TVa0Fud4w0sQ5RX6dCLYdnoMKjnQW8rhT
         4GPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0pFB+4SQh7Dkgli7Gh6pL88AFg9wW+6p1cHkhZw918E=;
        b=IdGbf6I6ehiB5uAEkK3OiwJ7NzNmoyDDs4aie3FlS09+fu5pgo8rX7qrKfp9RbEO/T
         Rk8AfWkZCbnnwwr5Eep1CK6/hJY2PN1/ijZ9klrxwuqMJZFoOA/LjlvRcmOYzUrT4I8z
         smzDpjvWdRZw6+5hc4Fgv8iETpb8v+9Xs/7Un6S3eFhjrh7SFDlrP6UgxWCGkRKXMbvU
         gd+zBOMTPEWkBRFN24N0cqC9aaIWQiixa6UH8clvihG4WGCADK5/Vw+YYiF8HIi2sLjx
         vZb8aQpaUfa8zsqmwPe/boziaBkwnITEHfDQ1nJf8cXmBqAy6xV1fdp0QjKxzvARHSiC
         UhUw==
X-Gm-Message-State: APjAAAVHVEON98T0o8zxGiJlFQ8QVgPk7vdf2STJCcbggTvnl9oHsdV1
        GYAivWF3UJCfEu2CqYSJBuG71Ro=
X-Google-Smtp-Source: APXvYqxBHDWJNmyejRqNN32DYUujsIf55l9fywOgI/vPqhDPok0u6ngvOfHETqcihxLEkrl1PPfAOw==
X-Received: by 2002:a5d:94d0:: with SMTP id y16mr90267804ior.123.1564844436022;
        Sat, 03 Aug 2019 08:00:36 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f20sm60820416ioh.17.2019.08.03.08.00.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 08:00:35 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFSv4: When recovering state fails with EAGAIN, retry the same recovery
Date:   Sat,  3 Aug 2019 10:58:22 -0400
Message-Id: <20190803145826.15504-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190803145826.15504-3-trond.myklebust@hammerspace.com>
References: <20190803145826.15504-1-trond.myklebust@hammerspace.com>
 <20190803145826.15504-2-trond.myklebust@hammerspace.com>
 <20190803145826.15504-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the server returns with EAGAIN when we're trying to recover from
a server reboot, we currently delay for 1 second, but then mark the
stateid as needing recovery after the grace period has expired.

Instead, we should just retry the same recovery process immediately
after the 1 second delay. Break out of the loop after 10 retries.

Fixes: 35a61606a612 ("NFS: Reduce indentation of the switch statement...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4state.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a71a61e5fe2c..d03b9cf42bd0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1607,6 +1607,7 @@ static int __nfs4_reclaim_open_state(struct nfs4_state_owner *sp, struct nfs4_st
 static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs4_state_recovery_ops *ops)
 {
 	struct nfs4_state *state;
+	unsigned int loop = 0;
 	int status = 0;
 
 	/* Note: we rely on the sp->so_states list being ordered 
@@ -1633,8 +1634,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 
 		switch (status) {
 		default:
-			if (status >= 0)
+			if (status >= 0) {
+				loop = 0;
 				break;
+			}
 			printk(KERN_ERR "NFS: %s: unhandled error %d\n", __func__, status);
 			/* Fall through */
 		case -ENOENT:
@@ -1648,6 +1651,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			break;
 		case -EAGAIN:
 			ssleep(1);
+			if (loop++ < 10) {
+				set_bit(ops->state_flag_bit, &state->flags);
+				break;
+			}
 			/* Fall through */
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
-- 
2.21.0

