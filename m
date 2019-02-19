Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB65CC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:02:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D8122146E
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fsYp7gnO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726289AbfBSOCG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 09:02:06 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39330 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725845AbfBSOCF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 09:02:05 -0500
Received: by mail-it1-f196.google.com with SMTP id l15so6320921iti.4
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 06:02:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=6o/7kZQSrXBwkL6P67bIzyW8cId9Ath7266RW1BGDAQ=;
        b=fsYp7gnOgynrKq/jjrHP8+kEJdn5O0IJ82tdbAgP73g4sHSz4G+r3id0kFgOhslD/z
         HeFvA0H79Qur8MrMYyu67qyIzyq6MiPaWVWweZY9KMkrTODG3m/SXpkzayA3/QyOy+7s
         KDyEeHdRWZtXcnArQLSxcyC/163jpNnw9Iq/v3rT26jVBUKQkIwEyuf08CuWHdzDPKyF
         TBJ2ZOMeBLcTnWzDuaL/Ft1XlJCqQ0atwXJ5Etm3wmO9id0lyyUlMEBI6979tVe8Rya+
         Lyn3i7kXKWugSQo22aGdwz6c6XiZ4EEdEn+f0nUj+J7QHHO56JIehATSyFHN31898Aol
         71DQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=6o/7kZQSrXBwkL6P67bIzyW8cId9Ath7266RW1BGDAQ=;
        b=kj26+FCOaMWt3cjYC+ZDYiWE86uZ0huRls8MB3sbHaMbEYy0XWhiPtKl93OrS3J7OV
         hv+83Q8lKWeWwIY+mUS7RtyyRpnYkpCD2uiq+LjwXtiUFSXgNI4oP3zYNrAhpv1krOE+
         odp/TsKKWhlZ4ruaEidmMiDEqOt9crkasQYFnxW4D4yO7dH1FaDtnySUkoyj5k6rPTMQ
         PqUPnhclSicMHU9n3L5oAWY3W8DDgDmqAIOCFnId5VhnCXSUzWY4l5ngVfX7D7c+kK5q
         LCoGyP6pP50e6FFskihfNsd+dz1STVN27rTEbTXgkuuOWIhFjpqThnNnIdyCnRzHTBAC
         +VKA==
X-Gm-Message-State: AHQUAuZvm25sZndyFkdOmgUtgNMvAJskKQgzWkcX1abX/AKCo2rq3Yb0
        1EGxq2lTrm4kAX/swSTfEed6odc=
X-Google-Smtp-Source: AHgI3IbU/lUMalWObuzyOWYMq2pk5kQ7wWrPu3AATaR0wH+DZa9rFqOyMo26kecxEAfojCvKHQo5Qg==
X-Received: by 2002:a24:b8c6:: with SMTP id m189mr2048276ite.72.1550584924743;
        Tue, 19 Feb 2019 06:02:04 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o9sm694759itb.23.2019.02.19.06.02.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 06:02:04 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix sparse annotations for nfs_set_open_stateid_locked()
Date:   Tue, 19 Feb 2019 09:00:18 -0500
Message-Id: <20190219140018.119996-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e8e12faa8604..1dbdc85e6885 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1555,6 +1555,10 @@ static void nfs_clear_open_stateid(struct nfs4_state *state,
 
 static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 		const nfs4_stateid *stateid, nfs4_stateid *freeme)
+	__must_hold(&state->owner->so_lock)
+	__must_hold(&state->seqlock)
+	__must_hold(RCU)
+
 {
 	DEFINE_WAIT(wait);
 	int status = 0;
-- 
2.20.1

