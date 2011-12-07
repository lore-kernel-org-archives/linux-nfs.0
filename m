Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37225 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab1LGOI5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 09:08:57 -0500
Received: by faar15 with SMTP id r15so101455faa.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 06:08:55 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
Date: Wed,  7 Dec 2011 16:08:47 +0200
Message-Id: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am trying to build a pnfs client on a 32 bit system  and the
pnfs-latest  kernel fails to compile. I get the following error

 >  Building modules, stage 2.
 >  TEST    posttest
 > MODPOST 2046 modules
 >ERROR: "__udivdi3" [crypto/xor.ko] undefined!
 >make[1]: *** [__modpost] Error 1
 >make: *** [modules] Error 2
 >make: *** Waiting for unfinished jobs....
 >Succeed: decoded and checked 1244492 instructions

Reported-by: Rita Sequeira <rita.prajval@gmail.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---

untested patch yet...

 crypto/xor.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/crypto/xor.c b/crypto/xor.c
index 65433f5..2151ded 100644
--- a/crypto/xor.c
+++ b/crypto/xor.c
@@ -95,7 +95,8 @@
 
 	ns_end -= ns_begin;
 	if (ns_end > 0)
-		speed = BENCH_SIZE / 1024 * count * NSEC_PER_SEC / ns_end;
+		speed = BENCH_SIZE / 1024 * count *
+				(unsigned)(NSEC_PER_SEC / ns_end);
 	else
 		speed = 17;
 	tmpl->speed = speed;
-- 
1.7.6

