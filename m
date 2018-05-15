Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751153AbeEOPxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 11:53:25 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6DF6B4201AE1
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 15:53:25 +0000 (UTC)
Message-ID: <1526399603.7441.8.camel@redhat.com>
Subject: [PATCH v3 4/8] nfs-utils: Indicate if config file was missing
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 15 May 2018 16:53:23 +0100
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
References: <1526399410.7441.4.camel@redhat.com>
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
index 5fb58ea..e65caaf 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -547,7 +547,7 @@ static void conf_free_bindings(void)
 }
 
 /* Open the config file and map it into our address space, then parse it.  */
-static void
+static int
 conf_load_file(const char *conf_file)
 {
 	int trans;
@@ -557,7 +557,7 @@ conf_load_file(const char *conf_file)
 	conf_data = conf_readfile(conf_file);
 
 	if (conf_data == NULL)
-		return;
+		return 1;
 
 	/* Load default configuration values.  */
 	conf_load_defaults();
@@ -575,10 +575,10 @@ conf_load_file(const char *conf_file)
 
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
@@ -589,7 +589,7 @@ conf_init_file(const char *conf_file)
 	TAILQ_INIT (&conf_trans_queue);
 
 	if (conf_file == NULL) conf_file=NFS_CONFFILE;
-	conf_load_file(conf_file);
+	return conf_load_file(conf_file);
 }
 
 /*
-- 
1.8.3.1



