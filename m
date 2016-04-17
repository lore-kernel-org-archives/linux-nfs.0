Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:35813 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcDQJKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:10:47 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 3165420A0D
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:10:43 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:10:04 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] des_impl: Use bzero instead of __bzero
Message-ID: <20160417091004.GA2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes compilation error with musl libc:

.libs/libtirpc_la-des_impl.o: In function `_des_crypt':
src/des_impl.c:591: undefined reference to `__bzero'

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/des_impl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/des_impl.c b/src/des_impl.c
index 9dbccaf..dbcfaa1 100644
--- a/src/des_impl.c
+++ b/src/des_impl.c
@@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct desparams *desp)
     }
   tin0 = tin1 = tout0 = tout1 = xor0 = xor1 = 0;
   tbuf[0] = tbuf[1] = 0;
-  __bzero (schedule, sizeof (schedule));
+  bzero (schedule, sizeof (schedule));
 
   return (1);
 }
-- 
2.7.3

