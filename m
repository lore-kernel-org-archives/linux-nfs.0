Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 221CCC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 02:00:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E2B43206BA
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 02:00:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DHSWLj0O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730804AbfCZCAF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 22:00:05 -0400
Received: from mail-pg1-f194.google.com ([209.85.215.194]:36093 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727043AbfCZCAF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2019 22:00:05 -0400
Received: by mail-pg1-f194.google.com with SMTP id r124so7479198pgr.3;
        Mon, 25 Mar 2019 19:00:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=t+qMmHzBR4DjmBcN69RFLD3h2J4om3ztagHlBsYe6Kk=;
        b=DHSWLj0OnWP2FrggkOf4UJYd9aUo8fBQlQvAJiuM6p4Yq1fEjursjHf0pf1lJBlEBX
         Zg8OOxe4RDOhIBEfGh4xzoOLczntBv3doDbLKtEDO/1h3GV5B4GQQrnTYmtAIYJdtjzV
         7Q4Hpq5xC7jRvc+6reNZv+Co3hgLAhldr6gsCyqye1a+wHeJVpKXRpgwNmue9mW32eTD
         FYVBdzeZ+5ffCgKnYYJv04Oq4q/sOlv9BOSG+I+iyD1YLSwTtGiS48YhG0Z7td6FYne5
         C1uX4wa+iWZAiyq4lofI/ULcqQNp3yN4ElgTEakcCIcPkXj7fwE6LaNiMwiKOdzdG4ct
         pogw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:mime-version
         :content-disposition:content-transfer-encoding:user-agent;
        bh=t+qMmHzBR4DjmBcN69RFLD3h2J4om3ztagHlBsYe6Kk=;
        b=onS+0zdU5kCsj66gzLLXgDR0RQOB4FkpciOlVaYV62gHnzDlUUw6NVezYA+Qne52x3
         2+BVWqZKVbCS8/9QMRK+zOqxof50rgZ+urJv9LAvItOhcUvdZJ7THgfhGQjBQDab9zW9
         4EUglJLTXYhJAJ5yeQid5Bnjk4T6WZ/Zic45qU43ewGECDIs86Gbb7276Y1hJsN125+l
         50+K5NYGkmmW5B6jR7krYwLO2eHB6W04i9+h/QsmEyXnPJhq4FKKmaRzN8TrFts03G5p
         shZNUuAHyiRG9spoOIkY8oTQqbduRM8jFiEBnkWwhLw/oCWye0qFRmaKPffa0vBDecEv
         FUvA==
X-Gm-Message-State: APjAAAXSf4D/wZQAI9ne7yWLBciA9Tj0cDpDIfYQmL1k2H9h3hF4oXCR
        NytmV5kghNSWLGYHuf0X5R0=
X-Google-Smtp-Source: APXvYqzn/Z+QH+uMwh1Kyw6P9zMcleSTncNNiLb9W4VtYNvZncgytQ8YZUOze6Ue3MndQY7GWQ1ikg==
X-Received: by 2002:a65:6299:: with SMTP id f25mr26843229pgv.376.1553565604263;
        Mon, 25 Mar 2019 19:00:04 -0700 (PDT)
Received: from ip-172-31-25-235.us-west-2.compute.internal (ec2-54-245-141-36.us-west-2.compute.amazonaws.com. [54.245.141.36])
        by smtp.gmail.com with ESMTPSA id 17sm23841230pgt.0.2019.03.25.19.00.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 19:00:03 -0700 (PDT)
Date:   Tue, 26 Mar 2019 02:00:01 +0000
From:   Alakesh Haloi <alakesh.haloi@gmail.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        trivial@kernel.org
Subject: [PATCH] SUNRPC: fix uninitialized variable warning
Message-ID: <20190326020001.GA29659@ip-172-31-25-235.us-west-2.compute.internal>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Avoid following compiler warning on uninitialized variable

net/sunrpc/xprtsock.c: In function ‘xs_read_stream_request.constprop’:
net/sunrpc/xprtsock.c:525:10: warning: ‘read’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   return read;
          ^~~~
net/sunrpc/xprtsock.c:529:23: warning: ‘ret’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  return ret < 0 ? ret : read;
         ~~~~~~~~~~~~~~^~~~~~

Signed-off-by: Alakesh Haloi <alakesh.haloi@gmail.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9359539907ba..732d4b57411a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -495,8 +495,8 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 		int flags, struct rpc_rqst *req)
 {
 	struct xdr_buf *buf = &req->rq_private_buf;
-	size_t want, read;
-	ssize_t ret;
+	size_t want, uninitialized_var(read);
+	ssize_t uninitialized_var(ret);
 
 	xs_read_header(transport, buf);
 
-- 
2.17.2

