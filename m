Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30088 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750727AbdBRVfY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2017 16:35:24 -0500
Date: Sun, 19 Feb 2017 00:34:59 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] sunrpc: silence uninitialized variable warning
Message-ID: <20170218213459.GA32320@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kstrtouint() can return a couple different error codes so the check for
"ret == -EINVAL" is wrong and static analysis tools correctly complain
that we can use "num" without initializing it.  It's not super harmful
because we check the bounds.  But it's also easy enough to fix.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 956c7bce80d1..311ce92384b7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3209,7 +3209,9 @@ static int param_set_uint_minmax(const char *val,
 	if (!val)
 		return -EINVAL;
 	ret = kstrtouint(val, 0, &num);
-	if (ret == -EINVAL || num < min || num > max)
+	if (ret)
+		return ret;
+	if (num < min || num > max)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
 	return 0;
