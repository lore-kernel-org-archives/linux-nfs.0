Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from resqmta-ch2-04v.sys.comcast.net ([69.252.207.36]:59298 "EHLO
        resqmta-ch2-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750808AbdGaEZd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 00:25:33 -0400
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Joshua Kinard <kumba@gentoo.org>
From: Joshua Kinard <kumba@gentoo.org>
Subject: [PATCH] Replace bzero() calls with equivalent memset() calls
Message-ID: <47646199-1784-f1ac-23ae-eedaf3a24c95@gentoo.org>
Date: Mon, 31 Jul 2017 00:25:29 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As annotated in the bzero(3) man page, bzero() was marked as LEGACY in
POSIX.1-2001 and removed in POSIX.1-2008, and should be replaced with
memset() calls to write zeros to a memory region.  The attached patch
replaces two bzero() calls and one __bzero() call in libtirpc with
equivalent memset() calls.  The latter replacement fixes a compile error
under uclibc-ng, which lacks a definition for __bzero()

Signed-off-by: Joshua Kinard <kumba@gentoo.org>
---

 src/auth_time.c    |    2 +-
 src/des_impl.c     |    2 +-
 src/svc_auth_des.c |    2 +-
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
index 2e90146..64a7682 100644
--- a/src/svc_auth_des.c
+++ b/src/svc_auth_des.c
@@ -356,7 +356,7 @@ cache_init()
 
 	authdes_cache = (struct cache_entry *)
 		mem_alloc(sizeof(struct cache_entry) * AUTHDES_CACHESZ);	
-	bzero((char *)authdes_cache, 
+	memset((char *)authdes_cache, 0,
 		sizeof(struct cache_entry) * AUTHDES_CACHESZ);
 
 	authdes_lru = (short *)mem_alloc(sizeof(short) * AUTHDES_CACHESZ);

