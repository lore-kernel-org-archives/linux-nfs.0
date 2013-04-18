Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:58540 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab3DRBHd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Apr 2013 21:07:33 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq17so3558188wib.17
        for <linux-nfs@vger.kernel.org>; Wed, 17 Apr 2013 18:07:32 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 18 Apr 2013 09:07:32 +0800
Message-ID: <CAPgLHd9dZK_t+hfMX1as67wGxWmaRh4-sSY-rRrTVHpRDve0YQ@mail.gmail.com>
Subject: [PATCH] svcauth_gss: fix error return code in rsc_parse()
From: Wei Yongjun <weiyj.lk@gmail.com>
To: bfields@fieldses.org, Trond.Myklebust@netapp.com, ebiederm@xmission.com,
        skinsbursky@parallels.com, jlayton@redhat.com, simo@redhat.com
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 5ead605..c2156fb 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -505,8 +505,10 @@ static int rsc_parse(struct cache_detail *cd,
 		len = qword_get(&mesg, buf, mlen);
 		if (len > 0) {
 			rsci.cred.cr_principal = kstrdup(buf, GFP_KERNEL);
-			if (!rsci.cred.cr_principal)
+			if (!rsci.cred.cr_principal) {
+				status = -ENOMEM;
 				goto out;
+			}
 		}
 
 	}

