Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754313AbaGOPJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:50 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/15] svcauth_des: Convert local debug() calls to LIBTIRPC_DEBUG() calls
Date: Tue, 15 Jul 2014 11:09:29 -0400
Message-Id: <1405436974-4161-11-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_auth_des.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
index e0ff6cb..08e2bee 100644
--- a/src/svc_auth_des.c
+++ b/src/svc_auth_des.c
@@ -64,9 +64,9 @@
 #include <libc_private.h>
 #endif
 
-extern int key_decryptsession_pk(const char *, netobj *, des_block *);
+#include "debug.h"
 
-#define debug(msg)	 printf("svcauth_des: %s\n", msg) 
+extern int key_decryptsession_pk(const char *, netobj *, des_block *);
 
 #define USEC_PER_SEC ((u_long) 1000000L)
 #define BEFORE(t1, t2) timercmp(t1, t2, <)
@@ -178,20 +178,20 @@ _svcauth_des(rqst, msg)
 
 		sessionkey = &cred->adc_fullname.key;
 		if (! getpublickey(cred->adc_fullname.name, pkey_data)) {
-			debug("getpublickey");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: getpublickey failed"));
 			return(AUTH_BADCRED);
 		}
 		pkey.n_bytes = pkey_data;
 		pkey.n_len = strlen(pkey_data) + 1;
 		if (key_decryptsession_pk(cred->adc_fullname.name, &pkey,
 				       sessionkey) < 0) {
-			debug("decryptsessionkey");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: key_decryptsessionkey failed"));
 			return (AUTH_BADCRED); /* key not found */
 		}
 	} else { /* ADN_NICKNAME */	
 		sid = (short)cred->adc_nickname;
 		if (sid < 0 || sid >= AUTHDES_CACHESZ) {
-			debug("bad nickname");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: bad nickname"));
 			return (AUTH_BADCRED);	/* garbled credential */
 		}
 		sessionkey = &authdes_cache[sid].key;
@@ -214,7 +214,7 @@ _svcauth_des(rqst, msg)
 			sizeof(des_block), DES_DECRYPT | DES_HW);
 	}
 	if (DES_FAILED(status)) {
-		debug("decryption failure");
+		LIBTIRPC_DEBUG(1, ("_svcauth_des: decryption failure"));
 		return (AUTH_FAILED);	/* system error */
 	}
 
@@ -240,13 +240,13 @@ _svcauth_des(rqst, msg)
 			window = IXDR_GET_U_LONG(ixdr);
 			winverf = IXDR_GET_U_LONG(ixdr);
 			if (winverf != window - 1) {
-				debug("window verifier mismatch");
+				LIBTIRPC_DEBUG(1, ("_svcauth_des: window verifier mismatch"));
 				return (AUTH_BADCRED);	/* garbled credential */
 			}
 			sid = cache_spot(sessionkey, cred->adc_fullname.name, 
 			    &timestamp);
 			if (sid < 0) {
-				debug("replayed credential");
+				LIBTIRPC_DEBUG(1, ("_svcauth_des: replayed credential"));
 				return (AUTH_REJECTEDCRED);	/* replay */
 			}
 			nick = 0;
@@ -256,19 +256,19 @@ _svcauth_des(rqst, msg)
 		}
 
 		if ((u_long)timestamp.tv_usec >= USEC_PER_SEC) {
-			debug("invalid usecs");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: invalid usecs"));
 			/* cached out (bad key), or garbled verifier */
 			return (nick ? AUTH_REJECTEDVERF : AUTH_BADVERF);
 		}
 		if (nick && BEFORE(&timestamp, 
 				   &authdes_cache[sid].laststamp)) {
-			debug("timestamp before last seen");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: timestamp before last seen"));
 			return (AUTH_REJECTEDVERF);	/* replay */
 		}
 		(void) gettimeofday(&current, (struct timezone *)NULL);
 		current.tv_sec -= window;	/* allow for expiration */
 		if (!BEFORE(&current, &timestamp)) {
-			debug("timestamp expired");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: timestamp expired"));
 			/* replay, or garbled credential */
 			return (nick ? AUTH_REJECTEDVERF : AUTH_BADCRED);
 		}
@@ -292,7 +292,7 @@ _svcauth_des(rqst, msg)
 	status = ecb_crypt((char *)sessionkey, (char *)cryptbuf,
 	    sizeof(des_block), DES_ENCRYPT | DES_HW);
 	if (DES_FAILED(status)) {
-		debug("encryption failure");
+		LIBTIRPC_DEBUG(1, ("_svcauth_des: encryption failure"));
 		return (AUTH_FAILED);	/* system error */
 	}
 	verf.adv_xtimestamp = cryptbuf[0];
@@ -328,7 +328,7 @@ _svcauth_des(rqst, msg)
 		if (entry->rname != NULL) {
 			(void) strcpy(entry->rname, cred->adc_fullname.name);
 		} else {
-			debug("out of memory");
+			LIBTIRPC_DEBUG(1, ("_svcauth_des: out of memory"));
 		}
 		entry->key = *sessionkey;
 		entry->window = window;
@@ -472,7 +472,7 @@ authdes_getucred(adc, uid, gid, grouplen, groups)
 
 	sid = adc->adc_nickname;
 	if (sid >= AUTHDES_CACHESZ) {
-		debug("invalid nickname");
+		LIBTIRPC_DEBUG(1, ("authdes_getucred: invalid nickname"));
 		return (0);
 	}
 	cred = (struct bsdcred *)authdes_cache[sid].localcred;
@@ -488,11 +488,11 @@ authdes_getucred(adc, uid, gid, grouplen, groups)
 		if (!netname2user(adc->adc_fullname.name, &i_uid, &i_gid, 
 			&i_grouplen, groups))
 		{
-			debug("unknown netname");
+			LIBTIRPC_DEBUG(1, ("authdes_getucred: unknown netname"));
 			cred->grouplen = UNKNOWN;	/* mark as lookup up, but not found */
 			return (0);
 		}
-		debug("missed ucred cache");
+		LIBTIRPC_DEBUG(1, ("authdes_getucred: missed ucred cache"));
 		*uid = cred->uid = i_uid;
 		*gid = cred->gid = i_gid;
 		*grouplen = cred->grouplen = i_grouplen;
-- 
1.9.3

