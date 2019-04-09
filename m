Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C905C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D031421473
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mL3IMpmD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726576AbfDIQP5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:15:57 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:54826 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726515AbfDIQP5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 12:15:57 -0400
Received: by mail-it1-f194.google.com with SMTP id a190so5848004ite.4
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 09:15:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S8RDUuCY53QUXkY2lUphX2faWIsgxtcZI0Y2k8SAfDs=;
        b=mL3IMpmDVAcfjrvSIL9WnAa3lK4Fswi2kWH7ih+N8noC5Be9oR8vuLtzkDqjfSCC4r
         UtKAr7u4EqhBkbt5ukMvN20AFXIixZ57C4fbjXeQPdc5Y3C88ysty8Hy2e4/RphgUrjp
         2vJe/aYFWMy+h6MDV7PBfyuQDCuLEyd9VaIrcNWQMTeRBkIFy/WCZwhUYj9cLcNOHGMx
         60rc7KLGics7r0uKOX+QOZTly5ub574RlBcRAog+lv3jOafIHzq0aVN2kStFHhTm59DU
         ZSHvUY48OQAOXYZCH1d6ic4vu2MWxO/FgZrXNwid81eSRUJieHSbig9prcmrr25CvSGL
         d63A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S8RDUuCY53QUXkY2lUphX2faWIsgxtcZI0Y2k8SAfDs=;
        b=MlUuyc4+A0Df8AZulzBOWnPau1EHSvxpupzZIP0mFsEJpuWXoOkCzyFjZi4YIODcEc
         yfhcQxp0UFRKeoyqlQjDJddRIiiZkBav5EduyoheSbZat1Yzk2x1CaeGGe8KMjjiYLdA
         Kxm5TdeMFj2jgSiIs7XXoeGHv3VvLHxc4pgG0bNpJwmj+lgsHjikhTQORfRgGRaKIyz2
         kABebAl1G/HCqgQdRlp8ZZeKQAIrPYhSX7djS/TMzKNQJHkpEe7HHsCH6G0XW3QaWr4r
         KoFyeKyP3othVEKeW08sTkuKd3nsUBqNdkR/f8TRNgtCcrBCSr3wUClN5Y/ihL/yZMOp
         RX/w==
X-Gm-Message-State: APjAAAWBKhnkCfCyVVuHwLVBDVJY8EUsb3dQly6DtG7hVSlFo5uQs0EX
        QEkpMJv6OFf4wnGbo7Xy+cfChH8=
X-Google-Smtp-Source: APXvYqwfKYtLYrmylAznIIv+cWCwQDe8OVchI2OgsSvbSOkSDhpQUqoY3wCwCB+Hx7sw5/mtxFe1og==
X-Received: by 2002:a24:3c51:: with SMTP id m78mr23931458ita.119.1554826556064;
        Tue, 09 Apr 2019 09:15:56 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d133sm7402425ita.5.2019.04.09.09.15.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 09:15:54 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] SUNRPC: rsi_parse() should use the current user namespace
Date:   Tue,  9 Apr 2019 12:13:41 -0400
Message-Id: <20190409161342.34338-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409161342.34338-5-trond.myklebust@hammerspace.com>
References: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
 <20190409161342.34338-2-trond.myklebust@hammerspace.com>
 <20190409161342.34338-3-trond.myklebust@hammerspace.com>
 <20190409161342.34338-4-trond.myklebust@hammerspace.com>
 <20190409161342.34338-5-trond.myklebust@hammerspace.com>
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

