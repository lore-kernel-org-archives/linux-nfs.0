Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36374 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbcLBD7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:02 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:28 +1100
Subject: [PATCH 02/15] conffile: add bool support
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110812.28046.17685846656088587454.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

conf_get_bool() interprets various strings as 'true' or 'false'.
If no suitable value is found, the default is returned.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/include/conffile.h |    2 ++
 support/nfs/conffile.c     |   32 ++++++++++++++++++++++++++++++++
 systemd/nfs.conf.man       |   16 ++++++++++++++++
 3 files changed, 50 insertions(+)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index a6d5846f6720..3fe3a78230f6 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -36,6 +36,7 @@
 #include <sys/queue.h>
 #include <ctype.h>
 #include <stdint.h>
+#include <stdbool.h>
 
 struct conf_list_node {
 	TAILQ_ENTRY(conf_list_node) link;
@@ -57,6 +58,7 @@ extern struct sockaddr *conf_get_address(char *, char *);
 extern struct conf_list *conf_get_list(char *, char *);
 extern struct conf_list *conf_get_tag_list(char *, char *);
 extern int      conf_get_num(char *, char *, int);
+extern _Bool    conf_get_bool(char *, char *, _Bool);
 extern char    *conf_get_str(char *, char *);
 extern char    *conf_get_section(char *, char *, char *);
 extern void     conf_init(void);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 6b94ec0b5b53..609d78294f35 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -446,6 +446,38 @@ conf_get_num(char *section, char *tag, int def)
 	return def;
 }
 
+/*
+ * Return the Boolean value denoted by TAG in section SECTION, or DEF
+ * if that tags does not exist.
+ * FALSE is returned for case-insensitve comparisons with 0, f, false, n, no, off
+ * TRUE is returned for 1, t, true, y, yes, on
+ * A failure to match one of these results in DEF
+ */
+_Bool
+conf_get_bool(char *section, char *tag, _Bool def)
+{
+	char *value = conf_get_str(section, tag);
+
+	if (!value)
+		return def;
+	if (strcasecmp(value, "1") == 0 ||
+	    strcasecmp(value, "t") == 0 ||
+	    strcasecmp(value, "true") == 0 ||
+	    strcasecmp(value, "y") == 0 ||
+	    strcasecmp(value, "yes") == 0 ||
+	    strcasecmp(value, "on") == 0)
+		return true;
+
+	if (strcasecmp(value, "0") == 0 ||
+	    strcasecmp(value, "f") == 0 ||
+	    strcasecmp(value, "false") == 0 ||
+	    strcasecmp(value, "n") == 0 ||
+	    strcasecmp(value, "no") == 0 ||
+	    strcasecmp(value, "off") == 0)
+		return false;
+	return def;
+}
+
 /* Validate X according to the range denoted by TAG in section SECTION.  */
 int
 conf_match_num(char *section, char *tag, int x)
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 3dd56f735de2..1f524d8fe74e 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -44,6 +44,22 @@ is ignored, as is any blank line.
 .PP
 Lookup of section and value names is case-insensitive.
 
+Where a Boolean value is expected, any of
+.BR true ,
+.BR t ,
+.BR yes ,
+.BR y ,
+.BR on ", or"
+.B 1
+can be used for "true", while
+.BR false ,
+.BR f ,
+.BR no ,
+.BR n ,
+.BR off ", or"
+.B 0
+can be used for "false".  Comparisons are case-insensitive.
+
 .SH SECTIONS
 The following sections are known to various programs, and can contain
 the given named values.


