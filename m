Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:55824 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726761AbeGLMju (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 08:39:50 -0400
Date: Thu, 12 Jul 2018 15:30:08 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [PATCH] sunrpc: kstrtoul() can also return -ERANGE
Message-ID: <20180712123008.3aejokccq2smpctq@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Smatch complains that "num" can be uninitialized when kstrtoul() returns
-ERANGE.  It's true enough, but basically harmless in this case.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index d2623b9f23d6..7bb3f2062045 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -50,7 +50,7 @@ static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 	if (!val)
 		goto out_inval;
 	ret = kstrtoul(val, 0, &num);
-	if (ret == -EINVAL)
+	if (ret)
 		goto out_inval;
 	nbits = fls(num - 1);
 	if (nbits > MAX_HASHTABLE_BITS || nbits < 2)
