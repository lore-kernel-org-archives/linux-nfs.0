Return-Path: <SRS0=EpnZ=T5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C62A0C28CC0
	for <linux-nfs@archiver.kernel.org>; Wed, 29 May 2019 14:46:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91B9023AB8
	for <linux-nfs@archiver.kernel.org>; Wed, 29 May 2019 14:46:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oPvDNJWS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726112AbfE2OqG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 29 May 2019 10:46:06 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:36324 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726068AbfE2OqG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2019 10:46:06 -0400
Received: by mail-it1-f196.google.com with SMTP id e184so3986452ite.1
        for <linux-nfs@vger.kernel.org>; Wed, 29 May 2019 07:46:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=YmvwySkNDBTh19YZytRW2VjSprcBv6IobBlL0ZNUHcE=;
        b=oPvDNJWShxIZkJrsVHSyylSo0nZOL9pMi9BpAvD7V0wgJIxHFBbZQ9rTNzcoWdMMiX
         SGVWBQulQahSrBGMfLPcm9dsWCVG6SVOpMh/dgqbQksbV2uZlyd5vZRPOeCmocdlKHpC
         1hWdAk5FJRZGOI9S374WPBnHg0t9wBAWgFsuHXsHJyXu9s+W/NiUrQ/oF3yMHh0qpvXX
         YZ5yYasFAJaMstcDQNnBnWXTYxOWfS7wcKkF9eG0Qj4b0ZMXjsRGJzkruATBDq0RB6ZO
         fL+yTePnJjJu3zYsrj3xXuelPXCFYoUyEmzYForKJtGUyw/qMnrhCDNGHqF3XFAOCWf2
         40LA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=YmvwySkNDBTh19YZytRW2VjSprcBv6IobBlL0ZNUHcE=;
        b=XlvrKkIB9l3Zb+O3XSC5ZacJJWoEU+M2C0xdJYsLXIBaEPiS5z1pnqPqDNzqziUo67
         c/UpH5hvQFt1ydi0podoWHUo9LbpOgL+P8f9ZH801xbYMmGd5c4hL2YC+WbEgQx9Y8H0
         MR71vg9dPA7CHjz31YfTIsTA7Lfz3T4J8r+08KlpfzuNUlCQoJa/RzpOvkKTSwrRBEEZ
         rShtv69LuMopA6AlbNT2CIwIrIw5r+ZYKQ9yVb86NlApFQyNKdGeBML9qpnG7qP6Uhlu
         sG6b/fdz2FAHKUkVaZDtDb7n3EptgpBsEXfs+GLF6X5v7EpYGgB0hi1WuWFy2xlsL91T
         6jyQ==
X-Gm-Message-State: APjAAAUcC+pEk3k7kXvNVNohHNuLlGG8INKyMVWwQZqfIQjUuNCdID7F
        yfTYvRpW4T7b3+HnMIgnABI=
X-Google-Smtp-Source: APXvYqyu6wldFzU8ufC+efk1EPJEJkPaAEIo6dlpYrx6uSOoiktlqf6YOVf3s5czaeIxFJprUrSk7g==
X-Received: by 2002:a24:3643:: with SMTP id l64mr7699350itl.148.1559141160341;
        Wed, 29 May 2019 07:46:00 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q72sm1143821ita.26.2019.05.29.07.45.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 May 2019 07:45:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SUNRPC fix regression in umount of a secure mount
Date:   Wed, 29 May 2019 10:46:00 -0400
Message-Id: <20190529144600.2126-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If call_status returns ENOTCONN, we need to re-establish the connection
state after. Otherwise the client goes into an infinite loop of call_encode,
call_transmit, call_status (ENOTCONN), call_encode.

Fixes: c8485e4d63 ("SUNRPC: Handle ECONNREFUSED correctly in xprt_transmit()")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d6e57da..94a653b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2288,13 +2288,13 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ECONNABORTED:
+	case -ENOTCONN:
 		rpc_force_rebind(clnt);
 		/* fall through */
 	case -EADDRINUSE:
 		rpc_delay(task, 3*HZ);
 		/* fall through */
 	case -EPIPE:
-	case -ENOTCONN:
 	case -EAGAIN:
 		break;
 	case -EIO:
-- 
1.8.3.1

