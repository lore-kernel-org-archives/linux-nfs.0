Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468AbaKROGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:45 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jSL025265
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6iwk022957
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:44 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] mount.nfs: parse options - add helper po_contains_prefix
Date: Tue, 18 Nov 2014 09:06:41 -0500
Message-Id: <3210f38d54929658120ef91c5f951e04ad63fdc7.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The version options (v2,v4,v4.2) may increase in the future, but they have
a predictable prefix.  Add a parse option helper to locate and return these
options by prefix so that a future increment of version does not require the
addition of strings to a search table.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/parse_opt.c |   24 ++++++++++++++++++++++++
 utils/mount/parse_opt.h |    2 ++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index 342e210..7ba61c4 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -410,6 +410,30 @@ po_found_t po_contains(struct mount_options *options, char *keyword)
 }
 
 /**
+ * po_contains_prefix - check for presence of an option matching a prefix
+ * @options: pointer to mount options
+ * @prefix: pointer to prefix to match against a keyword
+ * @keyword: pointer to a C string containing the option keyword if found
+ *
+ * On success, *keyword contains the pointer of the matching option's keyword.
+ */
+po_found_t po_contains_prefix(struct mount_options *options,
+								const char *prefix, char **keyword)
+{
+	struct mount_option *option;
+
+	if (options && prefix) {
+		for (option = options->head; option; option = option->next)
+			if (strncmp(option->keyword, prefix, strlen(prefix)) == 0) {
+				*keyword = option->keyword;
+				return PO_FOUND;
+			}
+	}
+
+	return PO_NOT_FOUND;
+}
+
+/**
  * po_get - return the value of the rightmost instance of an option
  * @options: pointer to mount options
  * @keyword: pointer to a C string containing option keyword for which to search
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index 5037207..0745e0f 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -45,6 +45,8 @@ po_return_t		po_join(struct mount_options *, char **);
 
 po_return_t		po_append(struct mount_options *, char *);
 po_found_t		po_contains(struct mount_options *, char *);
+po_found_t		po_contains_prefix(struct mount_options *options,
+						const char *prefix, char **keyword);
 char *			po_get(struct mount_options *, char *);
 po_found_t		po_get_numeric(struct mount_options *,
 					char *, long *);
-- 
1.7.1

