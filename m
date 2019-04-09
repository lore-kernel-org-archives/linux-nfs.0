Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C25EC10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D12BD21473
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rcQY7cuT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726539AbfDIQPx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:15:53 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:43639 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726530AbfDIQPx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 12:15:53 -0400
Received: by mail-io1-f67.google.com with SMTP id x3so14771626iol.10
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 09:15:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IDkn36GQmmIg4vIlUt5+QqXnWkgyNKdUA6K/9tbYIS0=;
        b=rcQY7cuTERxEaxSTOdodvTshFjv/vsW3hQdm5f+zvhfm19nhfgwWQ2b3DyDWf10bOT
         kmsk8336oX0Ft74/u8fHKst7GQI71/x0B7b6Hi4zXgS4yHb9heBDoxgCAqnsQUcAtBF/
         eF8PgBgJG9MJ5Ltl2MAczlaLYyxR1Qjz1i98IzboGpoph4Nfs9e38ujytopoTSUZ28lm
         2xK4eeOt1lfH7SsggFKRN1viaVu7wKqzX4kCWiLFr/PM+Aw0ra91ojoSspSxiyqJg+AD
         Kr/9TBTkCcwxxjOWETBtfhmtTMhmh0TW0dcs/p6XfuKr/X6+SoG3KyxYBAR+MX/k4WLK
         mMZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=IDkn36GQmmIg4vIlUt5+QqXnWkgyNKdUA6K/9tbYIS0=;
        b=Gz9uJUi8HdIZfBeJm/mrs8TvGSJl/tq45/TJ5SLYrhKiYSPIapszOKeptxrODzR1E9
         hKjQ7SqKS2NnPesysxlo7rG/p0a1MOWo/nzTpAd9z41CJSDJcLGehD6eEXQR61qrkZQd
         8eThyJpEcZHF5IcP78S9xI0fZQKO8KPt+YM3duxZLwAy1VnlZ1IO6lbYB0QBPX/VYesx
         Rk3JgmpOeGGZGwjaBlQSfBIZZGljWfvrjZsboyWA4MGWeYiNfUHZf4HjSFXaZK7lDhXo
         3UAEiRfhWIOxzJTaqAJrBU7+Lh6cv2FR49IrAFsQfE+BzWr8T54dXrWWQMut7Oe4XnOG
         Hmbw==
X-Gm-Message-State: APjAAAX438OMbKIr+H/bRSR3aGrH/0lIug0fFn44GNaCsWdMXjXRIgSe
        8f9nt4nM+Ivtjm7sXOAQtQ==
X-Google-Smtp-Source: APXvYqzsnGkctH396/UWlEmvW3W2Gv9uvIGvLs5PtZIlezetjGUOE7RBJ0FmJLWX7E6z4wTBmtJoyQ==
X-Received: by 2002:a6b:3c0e:: with SMTP id k14mr25390788iob.162.1554826552047;
        Tue, 09 Apr 2019 09:15:52 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d133sm7402425ita.5.2019.04.09.09.15.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 09:15:51 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/6] SUNRPC: Temporary sockets should inherit the cred from their parent
Date:   Tue,  9 Apr 2019 12:13:38 -0400
Message-Id: <20190409161342.34338-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409161342.34338-2-trond.myklebust@hammerspace.com>
References: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
 <20190409161342.34338-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Temporary sockets should inherit the credential (and hence the user
namespace) from the parent listener transport.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svc_xprt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b76ee83d4d43..9429b28e9ba0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -786,9 +786,10 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		__module_get(xprt->xpt_class->xcl_owner);
 		svc_check_conn_limits(xprt->xpt_server);
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
-		if (newxpt)
+		if (newxpt) {
+			newxpt->xpt_cred = get_cred(xprt->xpt_cred);
 			svc_add_new_temp_xprt(serv, newxpt);
-		else
+		} else
 			module_put(xprt->xpt_class->xcl_owner);
 	} else if (svc_xprt_reserve_slot(rqstp, xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
-- 
2.20.1

