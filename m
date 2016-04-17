Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:51385 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbcDQRqD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 13:46:03 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id 6565820B57
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 19:46:01 +0200 (CEST)
Date: Sun, 17 Apr 2016 19:45:22 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: [PATCH v2] Replace bzero and __bzero by memset
Message-ID: <20160417174522.GB637@nyan>
References: <20160417091004.GA2737@nyan>
 <20160417161708.GF5369@vapier.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160417161708.GF5369@vapier.lan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes in particular a compilation error with musl libc:

.libs/libtirpc_la-des_impl.o: In function `_des_crypt':
src/des_impl.c:591: undefined reference to `__bzero'

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/auth_time.c    | 2 +-
 src/des_impl.c     | 2 +-
 src/svc_auth_des.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/src/auth_time.c b/src/auth_time.c
index 7f83ab4..210d251 100644
--- a/src/auth_time.c
+++ b/src/auth_time.c
@@ -317,7 +317,7 @@ __rpc_get_time_offset(td, srv, thost, uaddr, netid)
 	sprintf(ipuaddr, "%d.%d.%d.%d.0.111", a1, a2, a3, a4);
 	useua = &ipuaddr[0];
 
-	bzero((char *)&sin, sizeof(sin));
+	memset((char *)&sin, 0, sizeof(sin));
 	if (uaddr_to_sockaddr(useua, &sin)) {
 		msg("unable to translate uaddr to sockaddr.");
 		if (needfree)
diff --git a/src/des_impl.c b/src/des_impl.c
index 9dbccaf..15bec2a 100644
--- a/src/des_impl.c
+++ b/src/des_impl.c
@@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct desparams *desp)
     }
   tin0 = tin1 = tout0 = tout1 = xor0 = xor1 = 0;
   tbuf[0] = tbuf[1] = 0;
-  __bzero (schedule, sizeof (schedule));
+  memset (schedule, 0, sizeof (schedule));
 
   return (1);
 }
diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
index 73de033..9235eea 100644
--- a/src/svc_auth_des.c
+++ b/src/svc_auth_des.c
@@ -356,7 +356,7 @@ cache_init()
 
 	authdes_cache = (struct cache_entry *)
 		mem_alloc(sizeof(struct cache_entry) * AUTHDES_CACHESZ);	
-	bzero((char *)authdes_cache, 
+	memset((char *)authdes_cache, 0
 		sizeof(struct cache_entry) * AUTHDES_CACHESZ);
 
 	authdes_lru = (short *)mem_alloc(sizeof(short) * AUTHDES_CACHESZ);
-- 
2.7.3

