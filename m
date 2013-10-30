Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f41.google.com ([209.85.214.41]:44865 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab3J3FcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 01:32:17 -0400
MIME-Version: 1.0
Date: Wed, 30 Oct 2013 13:32:15 +0800
Message-ID: <CAPgLHd-12jZsZCqyeo0Bu=us_ZQHps4YzcgOfNA_Z4jkSUA4rA@mail.gmail.com>
Subject: [PATCH -next] SUNRPC: remove duplicated include from clnt.c
From: Wei Yongjun <weiyj.lk@gmail.com>
To: Trond.Myklebust@netapp.com, bfields@fieldses.org, davem@davemloft.net
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/sunrpc/clnt.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 759b78b..dab09da 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -31,7 +31,6 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/un.h>
-#include <linux/rcupdate.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/addr.h>

