Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:50772 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0TRU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jun 2016 15:17:20 -0400
Received: from zmail22.collab.prod.int.phx2.redhat.com (zmail22.collab.prod.int.phx2.redhat.com [10.5.83.26])
	by mx6-phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u5RJHJDJ043461
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jun 2016 15:17:19 -0400
Date: Mon, 27 Jun 2016 15:17:19 -0400 (EDT)
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <335417401.1580552.1467055039492.JavaMail.zimbra@redhat.com>
In-Reply-To: <598557625.1580230.1467054918817.JavaMail.zimbra@redhat.com>
Subject: [PATCH] sunrpc: Fix bit count when setting hashtable size to
 power-of-two
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Author: Frank Sorenson <sorenson@redhat.com>
Date:   2016-06-27 13:55:48 -0500

    sunrpc: Fix bit count when setting hashtable size to power-of-two
    
    The hashtable size is incorrectly calculated as the next higher
    power-of-two when being set to a power-of-two.  fls() returns the
    bit number of the most significant set bit, with the least
    significant bit being numbered '1'.  For a power-of-two, fls()
    will return a bit number which is one higher than the number of bits
    required, leading to a hashtable which is twice the requested size.
    
    In addition, the value of (1 << nbits) will always be at least num,
    so the test will never be true.
    
    Fix the hash table size calculation to correctly set hashtable
    size, and eliminate the unnecessary check.
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 040ff62..9d7056f 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -51,9 +51,7 @@ static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL)
 		goto out_inval;
-	nbits = fls(num);
-	if (num > (1U << nbits))
-		nbits++;
+	nbits = fls(num - 1);
 	if (nbits > MAX_HASHTABLE_BITS || nbits < 2)
 		goto out_inval;
 	*(unsigned int *)kp->arg = nbits;
