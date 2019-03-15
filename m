Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BB42C10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1818218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XS8U8gVi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726527AbfCORw4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:56 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:40437 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726496AbfCORw4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:56 -0400
Received: by mail-it1-f195.google.com with SMTP id l139so12192653ita.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wFrrKbKR8ieezLBHPq2aOkY3Zb4IiPdPima20uTaGUw=;
        b=XS8U8gVi2l2xiNS1fm01sTDG19aCExlmzHURirxg77dhP9Ys9ZfrPaTAOXaVWYZCxQ
         fBhZIDLhjO1ZJjq4qPtezHm5wq5WATDVJ1xo5asZleKyh35ElCWsQHkqrAMgPuwmspNi
         FGwoO4BmkeQfMQ2k8R2KJc9CWvzuR+NKdJndaIDIVPdlzRBLqzXYS4Ea77WaOLxok4UC
         zCU5ZlStRbAdGbh/FlWez/1z+uP5tmMQBfVocpJbKOduRLocfkKqSHbdzX+zRlZqSNpm
         ry1oyHB4tGGB7BdlnMzGZnFOtQEmMU4yBij6egQzPRrFwN6AbtjzrInYHzqfWYj/+xKx
         mEBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wFrrKbKR8ieezLBHPq2aOkY3Zb4IiPdPima20uTaGUw=;
        b=TgXDgnDt5kuyRL0u3Ee9dLWLDWnZG+gGOajpaW5P1f+d354hUdLYpXvUi9HNnOBgB7
         1FddxKNs3J5xm6tiEIi7XbRqNdcQ/EgLyFZGHiixJRX2iAA0UPw+uNmdBNItT1HSJ1Pa
         AYR9Gl3U7Hr3UCEf3ILap2Y0ejrPxZJoFMY/07N1a9J4fd+jjH/o3Vpt7T4Ry63sj61t
         7Y/VUvp7pwxTY7OHNKsWVjLXcyxig/Kl9myMTknqi4Z1erxughBi+/I3H+9CZ84Vmgy5
         JrE0i8bl/meLAyke/zE1YKYxIq4OB33qaASjjN7SuzFPcVoPSlA0tWGVnMDv8R0ncwdf
         /HpQ==
X-Gm-Message-State: APjAAAXBgBa/S1L9+dW3izarNyupicDYI81MX31LWiuK953ZU0mBaylz
        wbTd8bUGCkOdgfRJWqhViplpgm4=
X-Google-Smtp-Source: APXvYqw1VlusZ27wBireo3hZp4z5lDalqy/0y6Fy5sR+8oCyQF5xChwEEALlUs+58Cic2BZj0sZ+Zw==
X-Received: by 2002:a24:4643:: with SMTP id j64mr2676213itb.74.1552672374845;
        Fri, 15 Mar 2019 10:52:54 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:54 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] SUNRPC: Handle the SYSTEM_ERR rpc error
Date:   Fri, 15 Mar 2019 13:51:40 -0400
Message-Id: <20190315175141.68792-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190315175141.68792-4-trond.myklebust@hammerspace.com>
References: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
 <20190315175141.68792-2-trond.myklebust@hammerspace.com>
 <20190315175141.68792-3-trond.myklebust@hammerspace.com>
 <20190315175141.68792-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Handle the SYSTEM_ERR rpc error by retrying the RPC call as if it
were a garbage argument.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1f47801e0002..cb73d6c25857 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2497,6 +2497,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 		error = -EOPNOTSUPP;
 		goto out_err;
 	case rpc_garbage_args:
+	case rpc_system_err:
 		trace_rpc__garbage_args(task);
 		error = -EIO;
 		break;
-- 
2.20.1

