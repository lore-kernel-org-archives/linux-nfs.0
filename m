Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:38938 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755790AbeDWPYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:24:32 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1C77081A88C8
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:24:32 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id B0990215CDC8
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:24:31 +0000 (UTC)
Message-ID: <1524497070.7418.4.camel@redhat.com>
Subject: [PATCH 1/7] nfs-utils: Fix minor memory leaks
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:24:30 +0100
In-Reply-To: <1524496788.7418.2.camel@redhat.com>
References: <1524496788.7418.2.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix some minor memory leaks, a null pointer reference and a typo.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 29f132d..a4cc236 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -186,7 +186,7 @@ conf_set_now(const char *section, const char *arg, const char *tag,
 		conf_remove_now(section, tag);
 	else if (conf_get_section(section, arg, tag)) {
 		if (!is_default) {
-			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...\n", 
+			xlog(LOG_INFO, "conf_set: duplicate tag [%s]:%s, ignoring...", 
 				section, tag);
 		}
 		return 1;
@@ -659,7 +659,7 @@ retry:
 	for (; cb; cb = LIST_NEXT (cb, link)) {
 		if (strcasecmp(section, cb->section) != 0)
 			continue;
-		if (arg && strcasecmp(arg, cb->arg) != 0)
+		if (arg && (cb->arg == NULL || strcasecmp(arg, cb->arg) != 0))
 			continue;
 		if (strcasecmp(tag, cb->tag) != 0)
 			continue;
@@ -917,6 +917,8 @@ conf_set(int transaction, const char *section, const char *arg,
 fail:
 	if (node->tag)
 		free(node->tag);
+	if (node->arg)
+		free(node->arg);
 	if (node->section)
 		free(node->section);
 	if (node)
@@ -1004,6 +1006,8 @@ conf_end(int transaction, int commit)
 			TAILQ_REMOVE (&conf_trans_queue, node, link);
 			if (node->section)
 				free(node->section);
+			if (node->arg)
+				free(node->arg);
 			if (node->tag)
 				free(node->tag);
 			if (node->value)
-- 
1.8.3.1



