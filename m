Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:57475 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbaHFGZQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:25:16 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so1518535lbi.10
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 23:25:15 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH v2 01/11] conffile: use standard uint*_t and unsigned char
Date: Wed,  6 Aug 2014 08:24:56 +0200
Message-Id: <1407306306-29796-2-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the standard integer types. This fixes compiling errors with musl
libc.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 support/include/conffile.h |  2 +-
 support/nfs/conffile.c     | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 05ea5d2..94fb005 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -49,7 +49,7 @@ struct conf_list {
 extern char    *conf_path;
 
 extern int      conf_begin(void);
-extern int      conf_decode_base64(u_int8_t *, u_int32_t *, u_char *);
+extern int      conf_decode_base64(uint8_t *, uint32_t *, unsigned char *);
 extern int      conf_end(int, int);
 extern void     conf_free_list(struct conf_list *);
 extern struct sockaddr *conf_get_address(char *, char *);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index c3434d5..6b94ec0 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -72,10 +72,10 @@ TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
 /*
  * Radix-64 Encoding.
  */
-static const u_int8_t bin2asc[]
+static const uint8_t bin2asc[]
   = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
 
-static const u_int8_t asc2bin[] =
+static const uint8_t asc2bin[] =
 {
   255, 255, 255, 255, 255, 255, 255, 255,
   255, 255, 255, 255, 255, 255, 255, 255,
@@ -109,10 +109,10 @@ LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
 
 static char *conf_addr;
 
-static __inline__ u_int8_t
+static __inline__ uint8_t
 conf_hash(char *s)
 {
-	u_int8_t hash = 0;
+	uint8_t hash = 0;
 
 	while (*s) {
 		hash = ((hash << 1) | (hash >> 7)) ^ tolower (*s);
@@ -603,10 +603,10 @@ cleanup:
 
 /* Decode a PEM encoded buffer.  */
 int
-conf_decode_base64 (u_int8_t *out, u_int32_t *len, u_char *buf)
+conf_decode_base64 (uint8_t *out, uint32_t *len, unsigned char *buf)
 {
-	u_int32_t c = 0;
-	u_int8_t c1, c2, c3, c4;
+	uint32_t c = 0;
+	uint8_t c1, c2, c3, c4;
 
 	while (*buf) {
 		if (*buf > 127 || (c1 = asc2bin[*buf]) == 255)
-- 
2.0.4

