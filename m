Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76D5BC10F13
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 02:08:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 33ED0206B6
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 02:08:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TMIccGRc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726201AbfDOCIk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 14 Apr 2019 22:08:40 -0400
Received: from mail-pl1-f194.google.com ([209.85.214.194]:34854 "EHLO
        mail-pl1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbfDOCIk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Apr 2019 22:08:40 -0400
Received: by mail-pl1-f194.google.com with SMTP id w24so7772092plp.2
        for <linux-nfs@vger.kernel.org>; Sun, 14 Apr 2019 19:08:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=qHTMmpQUn70KBpHgIMtpHRkO3d4j2b7JBWh5Kw5zQTw=;
        b=TMIccGRcaJZjJJq5DvQpXN6M6sZK8bH0Y3oy7zV6PaYwPA1HLywH7gppqBxz1HRNzI
         DmmWPaaQ+pJrpAKxis2s+3VfPdsC0YPQmlt46Ev1xZJoOshkE6MaUyuECBXn5K8m4Qz/
         4rXoX7uQnrEOxMnMVFIVMes130HRUzxiHEkt3tDMOo6l5icAUO4RHV196NOxvuMsyY14
         CwxJo616IIVjPk5bMTaRtUAhs0Jvico3sHH5/BNDaY1mwbPROlMMcsDASYnuRNCK20+x
         wWTNzZS+Tp0DQs1NcvYCHq1uhDpR7LTUPEICECluAz8Klu8a6WnyG8jBOUzLJxixdOEn
         qjhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id;
        bh=qHTMmpQUn70KBpHgIMtpHRkO3d4j2b7JBWh5Kw5zQTw=;
        b=VTaVTXEe541Q0zLE4pOQxyCn5MsNhhJ6dh9ljO0CM9NT7RC8mXWtQdbv1Za3veF7t2
         VQRNAmIFt6PuWRRyJozkp3gmr1wjLj1dONLNf05kkMUvPLZqpCHdXfWZ1+REg2IlHk6i
         pnF9/PVrbmGKop8aRKf2vBD79rbrbYj4QyR9z8aaQ3WZvifAP9Yes0zfVBT75m2k6EjO
         5+5LfcVIDn/tCpoo84kXr2AHbeONH/BYEOy/iPRAZCvZ4XOd+Js5KoSFj2uxxWfemaaM
         JT5VhB3OSFwEXgyMWuCmOJpGTq56a2Hv1VNptot1T6p6qnpB6Zfs+8uSbNSH6tOdOybd
         ZTvQ==
X-Gm-Message-State: APjAAAWG7ESY8ZwBRNNkMcwCj8NATAg4eO0vdZ7G3g5qtYvBJT+uITqo
        BWP2qqN+CEyOOP6JHXot0srApDrk/BQ=
X-Google-Smtp-Source: APXvYqwUNpQgM/ruu52d8sIMP+Jgs8LJyCYOFmf/CUxamdwgn+4dNLuGXuzUjKpMbnDOBd5Hx4ctUA==
X-Received: by 2002:a17:902:201:: with SMTP id 1mr72785758plc.89.1555294119504;
        Sun, 14 Apr 2019 19:08:39 -0700 (PDT)
Received: from mangix-pc.lan (76-14-106-140.rk.wavecable.com. [76.14.106.140])
        by smtp.gmail.com with ESMTPSA id t21sm30689890pfe.22.2019.04.14.19.08.38
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 19:08:38 -0700 (PDT)
From:   Rosen Penev <rosenp@gmail.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] mount: Add missing cast to getsockname
Date:   Sun, 14 Apr 2019 19:08:38 -0700
Message-Id: <20190415020838.924-1-rosenp@gmail.com>
X-Mailer: git-send-email 2.17.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Otherwise compilation can fail with incompatible pointer type.

Signed-off-by: Rosen Penev <rosenp@gmail.com>
---
 utils/mount/network.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index fc21110..e166a82 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1062,7 +1062,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	if (caddr) {
 		/* Get the address of our end of this connection */
 		socklen_t len = sizeof(*caddr);
-		if (getsockname(sock, caddr, &len) != 0)
+		if (getsockname(sock, (struct sockaddr *) caddr, &len) != 0)
 			caddr->sin_family = 0;
 	}
 
-- 
2.17.1

