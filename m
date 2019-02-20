Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C910C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1566321738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cjjx0SpA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730392AbfBTDEy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:54 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:53278 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727576AbfBTDEy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:54 -0500
Received: by mail-it1-f193.google.com with SMTP id x131so11868134itc.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 19:04:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/8uHzbksAoYNOq2+elgDOAfMP1O7vHJwznRO3Zz4dBE=;
        b=cjjx0SpAU6b9V7+CeF2tYWAltC+ogwz3hFXqVsvTVQ1sRiyZUzNfLMKi/lh05W74as
         6SaaNkuWRAbxfGjXVFB2fN4f1RUSF01dn7C46hUxz6vv1weR06fE0PYb4bHhvz0gxz84
         DvL3sFrONRrbA+gb0Zvl2tE9fLt8HNBl29hY/FqRemjWVNBr15Y0sfnHGdpXif9+quVt
         F7BqlQEvq8J380mN/crl1+QQWFR1J5N/fv9Ueqfd3JZPD8P5MlhIjEBhIhKmCtobiEVN
         0ElohFm73xP/LWIQMbyXKHZgWRm2agwl8Baer8ppzhwC9CeEPkxhLTZfdOmRPPou525u
         H2ZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=/8uHzbksAoYNOq2+elgDOAfMP1O7vHJwznRO3Zz4dBE=;
        b=KA1iOj5L8L9oh8H5SM/pcawAerJOdsAErVv/RjiuaVQHcnH9JElgXDe7PZ2kmT4vHS
         n1qYtTPX89opVRsdwlsFoVzroNlRDJ9BtdJC1D7BfURY/3yqz+XwUq6Lbi6xFI+HZLDR
         +keDFXBUhsGEeDtEMvU0bsZs6HhBGK7JGRB24P9pzCO40KBgjjurWM9+AGQCHE2oGrr3
         m9ucuYSCYNaE/6R245CWrFo4wh/0sIueIyzxrj9iRUDI3FBkEGzQ0+A1Ihlv1S2zBNmf
         K8zHlXjBFzCQCaRY1NM+xvdKFDU39UOw8thTZGsW0v0OPU2r875smlmOS5IAUPHk+YJ7
         DgvQ==
X-Gm-Message-State: AHQUAuayHFXDRMtVOL5xTYhUzdIrLuRYaTqKsLHi6Eo9qP5CE+AlnzE1
        cmRpXPUEW/Ge7BVtjG8NXLs5UWw=
X-Google-Smtp-Source: AHgI3IYKijrPADFEEuOHAi2oU696d9fluXZ7772HM74kvXZgqJKSSaVWvU493wVqYQXVGk9s7IoFzA==
X-Received: by 2002:a6b:8d13:: with SMTP id p19mr2690446iod.18.1550631892490;
        Tue, 19 Feb 2019 19:04:52 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a192sm2036924ita.0.2019.02.19.19.04.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 19:04:51 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] SUNRPC: Further cleanups of xs_sendpages()
Date:   Tue, 19 Feb 2019 22:03:40 -0500
Message-Id: <20190220030341.58766-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220030341.58766-3-trond.myklebust@hammerspace.com>
References: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
 <20190220030341.58766-2-trond.myklebust@hammerspace.com>
 <20190220030341.58766-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that we send the pages using a struct msghdr, instead of
using sendpage(), we no longer need to 'prime the socket' with
an address for unconnected UDP messages.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d20b153ce19e..73586114b825 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -735,10 +735,6 @@ static int xs_sendmsg(struct socket *sock, struct msghdr *msg, size_t seek)
 
 static int xs_send_kvec(struct socket *sock, struct msghdr *msg, struct kvec *vec, size_t seek)
 {
-	if (!vec) {
-		iov_iter_kvec(&msg->msg_iter, WRITE, NULL, 0, 0);
-		return sock_sendmsg(sock, msg);
-	}
 	iov_iter_kvec(&msg->msg_iter, WRITE, vec, 1, vec->iov_len);
 	return xs_sendmsg(sock, msg, seek);
 }
@@ -781,12 +777,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (unlikely(!sock))
 		return -ENOTSOCK;
 
-	if (base != 0) {
-		addr = NULL;
-		addrlen = 0;
-	}
-
-	if (base < xdr->head[0].iov_len || addr != NULL) {
+	if (base < xdr->head[0].iov_len) {
 		unsigned int len = xdr->head[0].iov_len - base;
 		remainder -= len;
 		if (remainder == 0)
-- 
2.20.1

