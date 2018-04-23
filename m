Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39008 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755418AbeDWP1A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 11:27:00 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7188681A8B85
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:27:00 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.46])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 142BB20BC8C7
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2018 15:26:59 +0000 (UTC)
Message-ID: <1524497218.7418.7.camel@redhat.com>
Subject: [PATCH 4/7] nfs-utils: Indicate if config file was missing
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 23 Apr 2018 16:26:58 +0100
In-Reply-To: <1524496788.7418.2.camel@redhat.com>
References: <1524496788.7418.2.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return an indication that the config file could not be loaded
for processes that want to differentiate this from empty config

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/conffile.h |  2 +-
 support/nfs/conffile.c     | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index ad20067..6baaf9a 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -60,7 +60,7 @@ extern _Bool    conf_get_bool(const char *, const char *, _Bool);
 extern char    *conf_get_str(const char *, const char *);
 extern char    *conf_get_str_with_def(const char *, const char *, char *);
 extern char    *conf_get_section(const char *, const char *, const char *);
-extern void     conf_init_file(const char *);
+extern int      conf_init_file(const char *);
 extern void     conf_cleanup(void);
 extern int      conf_match_num(const char *, const char *, int);
 extern int      conf_remove(int, const char *, const char *);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index fe41de5..7ed5646 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -522,7 +522,7 @@ static void conf_free_bindings(void)
 }
 
 /* Open the config file and map it into our address space, then parse it.  */
-static void
+static int
 conf_load_file(const char *conf_file)
 {
 	int trans;
@@ -532,7 +532,7 @@ conf_load_file(const char *conf_file)
 	conf_data = conf_readfile(conf_file);
 
 	if (conf_data == NULL)
-		return;
+		return 1;
 
 	/* Load default configuration values.  */
 	conf_load_defaults();
@@ -550,10 +550,10 @@ conf_load_file(const char *conf_file)
 
 	/* Apply the new configuration values */
 	conf_end(trans, 1);
-	return;
+	return 0;
 }
 
-void
+int
 conf_init_file(const char *conf_file)
 {
 	unsigned int i;
@@ -564,7 +564,7 @@ conf_init_file(const char *conf_file)
 	TAILQ_INIT (&conf_trans_queue);
 
 	if (conf_file == NULL) conf_file=NFS_CONFFILE;
-	conf_load_file(conf_file);
+	return conf_load_file(conf_file);
 }
 
 /* 
-- 
1.8.3.1



