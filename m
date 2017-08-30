Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45486 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751337AbdH3L4c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:56:32 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 83ACC7EA93
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:56:32 +0000 (UTC)
Message-ID: <1504094190.10850.8.camel@redhat.com>
Subject: [PATCH 4/7] nfs-utils: Add get_str with default value
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:56:30 +0100
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
References: <1504093866.10850.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The similar config code in libnfsidmap had one additional feature of
a get_str function with a default value option, include an equivalent
function here to maintain compatibility.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/conffile.h |  1 +
 support/nfs/conffile.c     | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 0e7fa8b..d4cb6b4 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -58,6 +58,7 @@ extern struct conf_list *conf_get_tag_list(const char *, const char *);
 extern int      conf_get_num(const char *, const char *, int);
 extern _Bool    conf_get_bool(const char *, const char *, _Bool);
 extern char    *conf_get_str(const char *, const char *);
+extern char    *conf_get_str_with_def(const char *, const char *, char *);
 extern char    *conf_get_section(const char *, const char *, const char *);
 extern void     conf_init(const char *);
 extern void     conf_cleanup(void);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 9c0fad9..c97f82a 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -635,6 +635,17 @@ conf_get_str(const char *section, const char *tag)
 	return conf_get_section(section, NULL, tag);
 }
 
+/* Return the string value denoted by TAG in section SECTION,
+ * unless it is not set, in which case return def
+ */
+char *
+conf_get_str_with_def(const char *section, const char *tag, char *def)
+{
+	char * result = conf_get_section(section, NULL, tag);
+	if (!result) return def;
+	return result;
+}
+
 /*
  * Find a section that may or may not have an argument
  */
-- 
1.8.3.1



