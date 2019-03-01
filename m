Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 149BDC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:13:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D429C2075B
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:13:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QyOYWthx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728610AbfCATNx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:13:53 -0500
Received: from mail-it1-f169.google.com ([209.85.166.169]:38412 "EHLO
        mail-it1-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726609AbfCATNx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:13:53 -0500
Received: by mail-it1-f169.google.com with SMTP id l66so23084358itg.3
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:13:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=2eyaZVq5xrMsZTOuy+mJ/btcM3AHETfeE1XZmveA+sQ=;
        b=QyOYWthxTlIZM107w/3I/ntafQTIDExoVMCla4+KdSej+ZnJuJDonfuCxY894J1P6D
         UyWjPpyt8rudpOPxMP7UskDCPYnDu7gv83oSbUwS1Klg0jfKudm+bxbvPrBiiGBfr/Tm
         t+L3y6HtBZqbtiF8FSYq9fGC0aLVTF0vqq8qZZU1T9co6tYfr+ASwNOQc4pZBdhsRCG4
         viZJrP/65o/BsWT5MtrPm64c1KaN1fYJotevfe4/uyFN5+7PFUaUpUXfJM6C285oxdGS
         e4JwUBaZYB1M7T4zNVhil02fAHYn+ijQWSe6bCsVObE8H1GtVimQQ5qYLFUMwS0pgzfb
         NVSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=2eyaZVq5xrMsZTOuy+mJ/btcM3AHETfeE1XZmveA+sQ=;
        b=mxMB5qB3VqQCMz1EeJypRMiNOIBPrlAtogWnbW/y18rrdwnnrbP8hA+TRaaY4kMYCW
         Crrm/tV/aRVtGy9+nuFQEbNeZFuUUYEiO661a5DL6XHS9fySiJqIiqQd9v+6PsneaIc8
         85TL8ni7P15H9GkQkTiaXX0VGr9TVF1z2/4e6FXVALSkLIrP17gmvIeX1i/1sXcO1EID
         uABTI1Q+RaMZi3RayLDmhvYGZVdN+d/ka+7ldxXVcsK910+RVmsxIfubL+VOv7lH17da
         PT2lWTdnwDzbaTzwG/5HqU2XHPeTQ5uEz8r8XaJ7yxr7NGxv+0X0oURZ4e5uXE7QdzkP
         RAXw==
X-Gm-Message-State: APjAAAUD+Phxpg0iAIxIDrvwor3sUxEpNKO9IkY9oHZTG08JZZdnYSFY
        HgpJU4oFs+reiLPXZ12YA8PZJR4=
X-Google-Smtp-Source: APXvYqzKDzEVn+wHOj3JLzPfswy1BYJ5V8a4RDSVqL2LKLoD1IwoofA6q+CUZMF+Bp7PvVSU6SZrJg==
X-Received: by 2002:a24:dd1:: with SMTP id 200mr4059828itx.65.1551467631434;
        Fri, 01 Mar 2019 11:13:51 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id n184sm719405itn.7.2019.03.01.11.13.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:13:50 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: Reinitialise sequence results before retransmitting a request
Date:   Fri,  1 Mar 2019 14:11:52 -0500
Message-Id: <20190301191153.104498-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If we have to retransmit a request, we should ensure that we reinitialise
the sequence results structure, since in the event of a signal
we need to treat the request as if it had not been sent.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 77c6e2d3f3fc..5f8517d1a0a5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -945,6 +945,13 @@ EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
 #endif	/* !CONFIG_NFS_V4_1 */
 
+static void nfs41_sequence_res_init(struct nfs4_sequence_res *res)
+{
+	res->sr_timestamp = jiffies;
+	res->sr_status_flags = 0;
+	res->sr_status = 1;
+}
+
 static
 void nfs4_sequence_attach_slot(struct nfs4_sequence_args *args,
 		struct nfs4_sequence_res *res,
@@ -956,10 +963,6 @@ void nfs4_sequence_attach_slot(struct nfs4_sequence_args *args,
 	args->sa_slot = slot;
 
 	res->sr_slot = slot;
-	res->sr_timestamp = jiffies;
-	res->sr_status_flags = 0;
-	res->sr_status = 1;
-
 }
 
 int nfs4_setup_sequence(struct nfs_client *client,
@@ -998,6 +1001,7 @@ int nfs4_setup_sequence(struct nfs_client *client,
 
 	trace_nfs4_setup_sequence(session, args);
 out_start:
+	nfs41_sequence_res_init(res);
 	rpc_call_start(task);
 	return 0;
 
-- 
2.20.1

