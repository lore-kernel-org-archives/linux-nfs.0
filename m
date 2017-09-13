Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52832 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751019AbdIMOAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 10:00:39 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 98FE4356F0
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 14:00:39 +0000 (UTC)
Message-ID: <1505311230.15819.21.camel@redhat.com>
Subject: [PATCH 1/7] nfs-utils: const-ify the config handling functions
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@redhat.com>
Date: Wed, 13 Sep 2017 15:00:30 +0100
In-Reply-To: <1505311126.15819.20.camel@redhat.com>
References: <1505311126.15819.20.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tighten up the conffile interface by switching to const
arguments where appropriate.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/conffile.h | 22 +++++++++++-----------
 support/nfs/conffile.c     | 38 +++++++++++++++++++-------------------
 2 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 2d11a52..0e7fa8b 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -49,21 +49,21 @@ struct conf_list {
 };
 
 extern int      conf_begin(void);
-extern int      conf_decode_base64(uint8_t *, uint32_t *, unsigned char *);
+extern int      conf_decode_base64(uint8_t *, uint32_t *, const unsigned char *);
 extern int      conf_end(int, int);
 extern void     conf_free_list(struct conf_list *);
-extern struct sockaddr *conf_get_address(char *, char *);
-extern struct conf_list *conf_get_list(char *, char *);
-extern struct conf_list *conf_get_tag_list(char *, char *);
-extern int      conf_get_num(char *, char *, int);
-extern _Bool    conf_get_bool(char *, char *, _Bool);
-extern char    *conf_get_str(char *, char *);
-extern char    *conf_get_section(char *, char *, char *);
+extern struct sockaddr *conf_get_address(const char *, const char *);
+extern struct conf_list *conf_get_list(const char *, const char *);
+extern struct conf_list *conf_get_tag_list(const char *, const char *);
+extern int      conf_get_num(const char *, const char *, int);
+extern _Bool    conf_get_bool(const char *, const char *, _Bool);
+extern char    *conf_get_str(const char *, const char *);
+extern char    *conf_get_section(const char *, const char *, const char *);
 extern void     conf_init(const char *);
 extern void     conf_cleanup(void);
-extern int      conf_match_num(char *, char *, int);
-extern int      conf_remove(int, char *, char *);
-extern int      conf_remove_section(int, char *);
+extern int      conf_match_num(const char *, const char *, int);
+extern int      conf_remove(int, const char *, const char *);
+extern int      conf_remove_section(int, const char *);
 extern void     conf_report(void);
 
 /*
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 8690218..4323fbb 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -57,8 +57,8 @@
 
 static void conf_load_defaults(void);
 static char * conf_load(const char *path);
-static int conf_set(int , char *, char *, char *, 
-	char *, int , int );
+static int conf_set(int , const char *, const char *, const char *, 
+	const char *, int , int );
 static void conf_parse(int trans, char *buf, 
 	char **section, char **subsection);
 
@@ -116,7 +116,7 @@ struct conf_binding {
 LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
 
 static __inline__ uint8_t
-conf_hash(char *s)
+conf_hash(const char *s)
 {
 	uint8_t hash = 0;
 
@@ -131,7 +131,7 @@ conf_hash(char *s)
  * Insert a tag-value combination from LINE (the equal sign is at POS)
  */
 static int
-conf_remove_now(char *section, char *tag)
+conf_remove_now(const char *section, const char *tag)
 {
 	struct conf_binding *cb, *next;
 
@@ -154,7 +154,7 @@ conf_remove_now(char *section, char *tag)
 }
 
 static int
-conf_remove_section_now(char *section)
+conf_remove_section_now(const char *section)
 {
   struct conf_binding *cb, *next;
   int unseen = 1;
@@ -181,8 +181,8 @@ conf_remove_section_now(char *section)
  * into SECTION of our configuration database.
  */
 static int
-conf_set_now(char *section, char *arg, char *tag, 
-	char *value, int override, int is_default)
+conf_set_now(const char *section, const char *arg, const char *tag, 
+	const char *value, int override, int is_default)
 {
 	struct conf_binding *node = 0;
 
@@ -565,7 +565,7 @@ conf_cleanup(void)
  * if that tag does not exist.
  */
 int
-conf_get_num(char *section, char *tag, int def)
+conf_get_num(const char *section, const char *tag, int def)
 {
 	char *value = conf_get_str(section, tag);
 
@@ -583,7 +583,7 @@ conf_get_num(char *section, char *tag, int def)
  * A failure to match one of these results in DEF
  */
 _Bool
-conf_get_bool(char *section, char *tag, _Bool def)
+conf_get_bool(const char *section, const char *tag, _Bool def)
 {
 	char *value = conf_get_str(section, tag);
 
@@ -609,7 +609,7 @@ conf_get_bool(char *section, char *tag, _Bool def)
 
 /* Validate X according to the range denoted by TAG in section SECTION.  */
 int
-conf_match_num(char *section, char *tag, int x)
+conf_match_num(const char *section, const char *tag, int x)
 {
 	char *value = conf_get_str (section, tag);
 	int val, min, max, n;
@@ -634,7 +634,7 @@ conf_match_num(char *section, char *tag, int x)
 
 /* Return the string value denoted by TAG in section SECTION.  */
 char *
-conf_get_str(char *section, char *tag)
+conf_get_str(const char *section, const char *tag)
 {
 	struct conf_binding *cb;
 retry:
@@ -662,7 +662,7 @@ retry:
  * Find a section that may or may not have an argument
  */
 char *
-conf_get_section(char *section, char *arg, char *tag)
+conf_get_section(const char *section, const char *arg, const char *tag)
 {
 	struct conf_binding *cb;
 
@@ -684,7 +684,7 @@ conf_get_section(char *section, char *arg, char *tag)
  * TAG in SECTION.
  */
 struct conf_list *
-conf_get_list(char *section, char *tag)
+conf_get_list(const char *section, const char *tag)
 {
 	char *liststr = 0, *p, *field, *t;
 	struct conf_list *list = 0;
@@ -738,7 +738,7 @@ cleanup:
 }
 
 struct conf_list *
-conf_get_tag_list(char *section, char *arg)
+conf_get_tag_list(const char *section, const char *arg)
 {
 	struct conf_list *list = 0;
 	struct conf_list_node *node;
@@ -776,7 +776,7 @@ cleanup:
 
 /* Decode a PEM encoded buffer.  */
 int
-conf_decode_base64 (uint8_t *out, uint32_t *len, unsigned char *buf)
+conf_decode_base64 (uint8_t *out, uint32_t *len, const unsigned char *buf)
 {
 	uint32_t c = 0;
 	uint8_t c1, c2, c3, c4;
@@ -873,8 +873,8 @@ conf_trans_node(int transaction, enum conf_op op)
 
 /* Queue a set operation.  */
 static int
-conf_set(int transaction, char *section, char *arg,
-	char *tag, char *value, int override, int is_default)
+conf_set(int transaction, const char *section, const char *arg,
+	const char *tag, const char *value, int override, int is_default)
 {
 	struct conf_trans *node;
 
@@ -926,7 +926,7 @@ fail:
 
 /* Queue a remove operation.  */
 int
-conf_remove(int transaction, char *section, char *tag)
+conf_remove(int transaction, const char *section, const char *tag)
 {
 	struct conf_trans *node;
 
@@ -955,7 +955,7 @@ fail:
 
 /* Queue a remove section operation.  */
 int
-conf_remove_section(int transaction, char *section)
+conf_remove_section(int transaction, const char *section)
 {
 	struct conf_trans *node;
 
-- 
1.8.3.1



