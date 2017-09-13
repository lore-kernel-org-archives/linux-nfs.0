Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33256 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbdIMOBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 10:01:49 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8BD11C04BD2C
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 14:01:49 +0000 (UTC)
Message-ID: <1505311306.15819.23.camel@redhat.com>
Subject: [PATCH 2/7] nfs-utils: Merge conf_get_str and conf_get_section
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@redhat.com>
Date: Wed, 13 Sep 2017 15:01:46 +0100
In-Reply-To: <1505311126.15819.20.camel@redhat.com>
References: <1505311126.15819.20.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

conf_get_section() started as conf_get_str() with one extra search
parameter, subsequent patches have not maintained feature parity,
combine the code to make a single more generic function and just call
that differently where required.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 4323fbb..8239d66 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -636,28 +636,9 @@ conf_match_num(const char *section, const char *tag, int x)
 char *
 conf_get_str(const char *section, const char *tag)
 {
-	struct conf_binding *cb;
-retry:
-	cb = LIST_FIRST (&conf_bindings[conf_hash (section)]);
-	for (; cb; cb = LIST_NEXT (cb, link)) {
-		if (strcasecmp (section, cb->section) == 0
-		    && strcasecmp (tag, cb->tag) == 0) {
-			if (cb->value[0] == '$') {
-				/* expand $name from [environment] section,
-				 * or from environment
-				 */
-				char *env = getenv(cb->value+1);
-				if (env && *env)
-					return env;
-				section = "environment";
-				tag = cb->value + 1;
-				goto retry;
-			}
-			return cb->value;
-		}
-	}
-	return 0;
+	return conf_get_section(section, NULL, tag);
 }
+
 /*
  * Find a section that may or may not have an argument
  */
@@ -665,7 +646,7 @@ char *
 conf_get_section(const char *section, const char *arg, const char *tag)
 {
 	struct conf_binding *cb;
-
+retry:
 	cb = LIST_FIRST (&conf_bindings[conf_hash (section)]);
 	for (; cb; cb = LIST_NEXT (cb, link)) {
 		if (strcasecmp(section, cb->section) != 0)
@@ -674,6 +655,17 @@ conf_get_section(const char *section, const char *arg, const char *tag)
 			continue;
 		if (strcasecmp(tag, cb->tag) != 0)
 			continue;
+		if (cb->value[0] == '$') {
+			/* expand $name from [environment] section,
+			 * or from environment
+			 */
+			char *env = getenv(cb->value+1);
+			if (env && *env)
+				return env;
+			section = "environment";
+			tag = cb->value + 1;
+			goto retry;
+		}
 		return cb->value;
 	}
 	return 0;
-- 
1.8.3.1



