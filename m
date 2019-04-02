Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54488C10F0C
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 263C820882
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lIg1kvUK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725842AbfDBXqX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:23 -0400
Received: from mail-pl1-f193.google.com ([209.85.214.193]:33810 "EHLO
        mail-pl1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726624AbfDBXqX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:23 -0400
Received: by mail-pl1-f193.google.com with SMTP id y6so7063204plt.1
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S8RDUuCY53QUXkY2lUphX2faWIsgxtcZI0Y2k8SAfDs=;
        b=lIg1kvUKQD4wdPYnvQQnbRt26KOfMUurMs5gXv5KU8c+j+pyO/h7od+9mqwb6ajV/Y
         7r5MFgRYC2+Z6gYcMvGxxkVsjNRRaIQ0iAwh1Aep4IZwmjKM+yUWhQatuVBpEx8AoEeY
         oeouGFfqRT0muWSyivcy0+hwqcZ0R1HUlj/r19SxbzP5DYB5+wic/7yE4T36YZatJg8V
         Q5Fv6zT3COqaCnkWjdYC5xSftnQUgdNA7i8Dz0+IsZff7SCe+hrI4DB2kXEMErQoh9YO
         odNTV0ixpNj3tyw9qJNhFI3ahEnCLEgGvH48z9pV4iLSVGhWRKn0P1OVH7XJQvFDWlm0
         vyTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S8RDUuCY53QUXkY2lUphX2faWIsgxtcZI0Y2k8SAfDs=;
        b=Gfo7myP08nRaG/sajawEBF6X+uZDaa6Yn7D9fmcB+G3NJsX+KQuBR1VRwiz+D7eS/P
         0/4lsSA4W/A1wij6rOUt1GeYC6m//TwSP00/CL9+Y5CWbPDuAPxKuTbr061oY6WyPbgR
         bwXdl71YuVlWg++V5HsJu81V9UyepCqSjS8Dsj+meVggoiclze+JqThwWcrXbk9iitOy
         2uacjDy1X9fbUAmP7Yg73yHwEBroMJQsp1HyylqJsfv4VkJkT3Wp6F6FntitbXEPvYYX
         CYBbuj7u6K/QGSyJ54GtfCdvmpD7LzzxY9Yfe+XHukLf115fp0E24a9zZgyP4TRCj5ry
         NeFA==
X-Gm-Message-State: APjAAAXotWwtPA9ACN3FF1JAb0BHXZ3EJksoKpiWPsgmz8GXiGs/OBqf
        iGm78tvGMnt5CM3nyJoL5Q==
X-Google-Smtp-Source: APXvYqwVaFCK52Lm+AXRLQGhDQaPRF2skHB8q5cvwkK0GP1H2NufHu50W3jedPyo4W7+Qb1xhETZnw==
X-Received: by 2002:a17:902:599d:: with SMTP id p29mr38395685pli.156.1554248782311;
        Tue, 02 Apr 2019 16:46:22 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:21 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] SUNRPC: rsi_parse() should use the current user namespace
Date:   Tue,  2 Apr 2019 16:44:10 -0700
Message-Id: <20190402234411.28204-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402234411.28204-4-trond.myklebust@hammerspace.com>
References: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
 <20190402234411.28204-2-trond.myklebust@hammerspace.com>
 <20190402234411.28204-3-trond.myklebust@hammerspace.com>
 <20190402234411.28204-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

rsi_parse() is part of a downcall, so we must assume that the uids
and gids are encoded using the current user namespace.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 0c5d7896d6dd..8be2f209982b 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -474,12 +474,12 @@ static int rsc_parse(struct cache_detail *cd,
 		 * treatment so are checked for validity here.)
 		 */
 		/* uid */
-		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
+		rsci.cred.cr_uid = make_kuid(current_user_ns(), id);
 
 		/* gid */
 		if (get_int(&mesg, &id))
 			goto out;
-		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
+		rsci.cred.cr_gid = make_kgid(current_user_ns(), id);
 
 		/* number of additional gid's */
 		if (get_int(&mesg, &N))
@@ -497,7 +497,7 @@ static int rsc_parse(struct cache_detail *cd,
 			kgid_t kgid;
 			if (get_int(&mesg, &id))
 				goto out;
-			kgid = make_kgid(&init_user_ns, id);
+			kgid = make_kgid(current_user_ns(), id);
 			if (!gid_valid(kgid))
 				goto out;
 			rsci.cred.cr_group_info->gid[i] = kgid;
-- 
2.20.1

