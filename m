Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A79E5C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7749B2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iPj9JpCW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725997AbfCAT05 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:26:57 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:41015 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725862AbfCAT04 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:56 -0500
Received: by mail-yw1-f67.google.com with SMTP id q128so14917094ywg.8
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4R/Kf8z3Xqz6UYa2j9PRwzcmqRxvTHufVmm/jGZ9C3g=;
        b=iPj9JpCWE3rnBolh/OAm+UP6wLPxXdWbT9IRIcH8yhNGVxZ7xXBbZQEIB4W9hikynG
         pb5lmoWBGX4D2AIZh9wIS8m87RhyZrKyb6ncuNezdQHcvOti/390LkQkLuWXcbQBd4QM
         UhrqRZ3b4NGCh/kH8dP2A4B9DNU+/luNtsB7P3sHS2186DT3eedvE6hd7WMJiTLI7Fss
         g7AFCdA2UmXwTIQ1OlRaXk9dLVTmtq8XexnaQueNjUZM6pqGYtEOm3ohG0QwRYtCD4aK
         I6xBbH+a+6EtASxZnV0DRZpEQ2+4eP36/fB65JgC8ZDOMHGzgGkq40KxmN06GBzRXC7y
         kItQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=4R/Kf8z3Xqz6UYa2j9PRwzcmqRxvTHufVmm/jGZ9C3g=;
        b=W7vHoBDpMCuLZNZsJUoX++sTsa3UbCLWCVoqJMEzKl2lqY6MrZZONOdZaC8XhowGw/
         IkaGkI5egA2yIDOfFKssti6+FbnzIjZVNK2PDjieYQLkGbXLw5E7E0oMZ+od8z4UEfkk
         OTVS5bQC+7IKRQqlRvXL7378fPr8Clt2PYSCcKYN8mAAfEXFXG58RTSQ4N3+10eYC0u3
         TZbDTFAUrONCp54UlLauLsWAOiPT8HEon+vhU7fWs7iU6NNGoOtKF43cblALRjcId1bB
         z4DldZEnt02+GnuPV/N4G5HsXk/aUyEIEQRK+wQmNasYaEGe//bCSlx+Pz4AZAj+YTeJ
         B2Ug==
X-Gm-Message-State: APjAAAX+5ycrNWik5BswtB/TFb547oqYjVsXAged6ujjyASzDVPdM/wR
        6LP5KnGA17skOftkcvFxJBdR6eM=
X-Google-Smtp-Source: APXvYqzJ+8jB7RpAAMGICUo61n1A7DPUIgaKk4SupneZNA3dApOhX5FOwspR1JX01Cmf92f8L5TLpw==
X-Received: by 2002:a25:8703:: with SMTP id a3mr1981962ybl.445.1551468415076;
        Fri, 01 Mar 2019 11:26:55 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:54 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 02/19] NFS/flexfiles: Fix up sparse RCU annotations
Date:   Fri,  1 Mar 2019 14:24:38 -0500
Message-Id: <20190301192455.104943-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-2-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 32701b6a9566..244a03c22b31 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -410,7 +410,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	for (i = 0; i < fls->mirror_array_cnt; i++) {
 		struct nfs4_ff_layout_mirror *mirror;
 		struct cred *kcred;
-		const struct cred *cred;
+		const struct cred __rcu *cred;
 		kuid_t uid;
 		kgid_t gid;
 		u32 ds_count, fh_count, id;
@@ -501,7 +501,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 			goto out_err_free;
 		kcred->fsuid = uid;
 		kcred->fsgid = gid;
-		cred = kcred;
+		cred = RCU_INITIALIZER(kcred);
 
 		if (lgr->range.iomode == IOMODE_READ)
 			rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
-- 
2.20.1

