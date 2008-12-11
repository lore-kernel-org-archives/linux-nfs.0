From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] text-based mount command: add function to parse numeric
	mount options
Date: Thu, 11 Dec 2008 13:33:48 -0500
Message-ID: <20081211183348.6882.44805.stgit@ingres.1015granger.net>
References: <20081211182820.6882.20716.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:37417 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061AbYLKSe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 13:34:27 -0500
In-Reply-To: <20081211182820.6882.20716.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a function that is especially for parsing keyword mount options
that take a numeric value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/parse_opt.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/parse_opt.h |    3 +++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index cb398bd..f61d0dd 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -36,6 +36,10 @@
  */
 
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <ctype.h>
 #include <unistd.h>
 #include <stdio.h>
@@ -366,6 +370,57 @@ char *po_get(struct mount_options *options, char *keyword)
 }
 
 /**
+ * po_get_numeric - return numeric value of rightmost instance of keyword option
+ * @options: pointer to mount options
+ * @keyword: pointer to a C string containing option keyword for which to search
+ * @value: OUT: set to the value of the keyword
+ *
+ * This is specifically for parsing keyword options that take only a numeric
+ * value.  If multiple instances of the same option are present in a mount
+ * option list, the rightmost instance is always the effective one.
+ *
+ * Returns:
+ *	* PO_FOUND if the keyword was found and the value is numeric; @value is
+ *	  set to the keyword's value
+ *	* PO_NOT_FOUND if the keyword was not found
+ *	* PO_BAD_VALUE if the keyword was found, but the value is not numeric
+ *
+ * These last two are separate in case the caller wants to warn about bad mount
+ * options instead of silently using a default.
+ */
+#ifdef HAVE_STRTOL
+po_found_t po_get_numeric(struct mount_options *options, char *keyword, long *value)
+{
+	char *option, *endptr;
+	long tmp;
+
+	option = po_get(options, keyword);
+	if (option == NULL)
+		return PO_NOT_FOUND;
+
+	errno = 0;
+	tmp = strtol(option, &endptr, 10);
+	if (errno == 0 && endptr != option) {
+		*value = tmp;
+		return PO_FOUND;
+	}
+	return PO_BAD_VALUE;
+}
+#else	/* HAVE_STRTOL */
+po_found_t po_get_numeric(struct mount_options *options, char *keyword, long *value)
+{
+	char *option;
+
+	option = po_get(options, keyword);
+	if (option == NULL)
+		return PO_NOT_FOUND;
+
+	*value = atoi(option);
+	return PO_FOUND;
+}
+#endif	/* HAVE_STRTOL */
+
+/**
  * po_rightmost - determine the relative position of two options
  * @options: pointer to mount options
  * @key1: pointer to a C string containing an option keyword
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index fb003c3..199630f 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -32,6 +32,7 @@ typedef enum {
 typedef enum {
 	PO_NOT_FOUND = 0,
 	PO_FOUND = 1,
+	PO_BAD_VALUE = 2,
 } po_found_t;
 
 typedef enum {
@@ -50,6 +51,8 @@ po_return_t		po_join(struct mount_options *, char **);
 po_return_t		po_append(struct mount_options *, char *);
 po_found_t		po_contains(struct mount_options *, char *);
 char *			po_get(struct mount_options *, char *);
+po_found_t		po_get_numeric(struct mount_options *,
+					char *, long *);
 po_rightmost_t		po_rightmost(struct mount_options *, char *, char *);
 po_found_t		po_remove_all(struct mount_options *, char *);
 void			po_destroy(struct mount_options *);

