Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ADB5C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:36:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5445221917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:36:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387683AbeLURgJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:36:09 -0500
Received: from relay.sw.ru ([185.231.240.75]:40952 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730364AbeLURgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:36:09 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOiU-0004vy-GA; Fri, 21 Dec 2018 20:36:06 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 7/8] sunrpc: fix debug message in svc_create_xprt()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <5ee97efb-e944-189d-e7b6-d6ca9ac31e39@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:36:05 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545412216.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

_svc_create_xprt() returns positive port number
so its non-zero return value is not an error

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/svc_xprt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 728ccd4d4490..834fedb441ef 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -301,9 +301,9 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 		request_module("svc%s", xprt_name);
 		err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
 	}
-	if (err)
+	if (err < 0)
 		dprintk("svc: transport %s not found, err %d\n",
-			xprt_name, err);
+			xprt_name, -err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(svc_create_xprt);
-- 
2.17.1

