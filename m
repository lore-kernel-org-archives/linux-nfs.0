Return-Path: <SRS0=ul47=5K=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 630B6C54FD9
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Mar 2020 07:14:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F249E208C3
	for <linux-nfs@archiver.kernel.org>; Wed, 25 Mar 2020 07:05:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727302AbgCYHFJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 Mar 2020 03:05:09 -0400
Received: from smtp02.smtpout.orange.fr ([80.12.242.124]:44712 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727291AbgCYHFI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2020 03:05:08 -0400
Received: from localhost.localdomain ([93.22.148.147])
        by mwinf5d03 with ME
        id JX552200Q3B2lW503X56BU; Wed, 25 Mar 2020 08:05:07 +0100
X-ME-Helo: localhost.localdomain
X-ME-Auth: Y2hyaXN0b3BoZS5qYWlsbGV0QHdhbmFkb28uZnI=
X-ME-Date: Wed, 25 Mar 2020 08:05:07 +0100
X-ME-IP: 93.22.148.147
From:   Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, chuck.lever@oracle.com, davem@davemloft.net,
        kuba@kernel.org, gnb@sgi.com, neilb@suse.de,
        tom@opengridcomputing.com
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 2/2] SUNRPC: Optimize 'svc_print_xprts()'
Date:   Wed, 25 Mar 2020 08:04:52 +0100
Message-Id: <20200325070452.22043-1-christophe.jaillet@wanadoo.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Using 'snprintf' is safer than 'sprintf' because it can avoid a buffer
overflow.
The return value can also be used to avoid a strlen a call.

Finally, we know where we need to copy and the length to copy, so, we
can save a few cycles by rearraging the code and using a memcpy instead of
a strcat.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
This patch should have no functionnal change.
We could go further, use scnprintf and write directly in the destination
buffer. However, this could lead to a truncated last line.
---
 net/sunrpc/svc_xprt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index df39e7b8b06c..6df861650040 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -118,12 +118,12 @@ int svc_print_xprts(char *buf, int maxlen)
 	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
 		int slen;
 
-		sprintf(tmpstr, "%s %d\n", xcl->xcl_name, xcl->xcl_max_payload);
-		slen = strlen(tmpstr);
-		if (len + slen >= maxlen)
+		slen = snprintf(tmpstr, sizeof(tmpstr), "%s %d\n",
+				xcl->xcl_name, xcl->xcl_max_payload);
+		if (slen >= sizeof(tmpstr) || len + slen >= maxlen)
 			break;
+		memcpy(buf + len, tmpstr, slen + 1);
 		len += slen;
-		strcat(buf, tmpstr);
 	}
 	spin_unlock(&svc_xprt_class_lock);
 
-- 
2.20.1

