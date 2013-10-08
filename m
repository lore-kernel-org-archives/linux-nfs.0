Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753581Ab3JHV34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Oct 2013 17:29:56 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r98LTtPi024573
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 8 Oct 2013 17:29:56 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-53-5.rdu2.redhat.com [10.10.53.5])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r98LTtAn032123
	for <linux-nfs@vger.kernel.org>; Tue, 8 Oct 2013 17:29:55 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsmount.conf: Remove duplicate 'bg' and 'fg' from parsing string.
Date: Tue,  8 Oct 2013 17:30:24 -0400
Message-Id: <1381267825-27457-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the 'Background' and/or 'Foreground' options are set
in multiple sections of the nfsmount.conf file, each instance
gets added to the parsing string. This patch makes the first
instance of either option override the any others.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/configfile.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 68b9f93..6985ed9 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -164,6 +164,20 @@ add_entry(char *opt)
 	SLIST_INSERT_HEAD(&head, entry, entries);
 }
 /*
+ * Check the alias list to see if the given 
+ * opt is a alias
+ */
+char *is_alias(char *opt)
+{
+	int i;
+
+	for (i=0; i < mnt_alias_sz; i++) {
+		if (strcasecmp(opt, mnt_alias_tab[i].alias) == 0)
+			return mnt_alias_tab[i].opt; 
+	}
+	return NULL;
+}
+/*
  * See if the given entry exists if the link list,
  * if so return that entry
  */
@@ -171,10 +185,21 @@ inline static
 char *lookup_entry(char *opt)
 {
 	struct entry *entry;
+	char *alias = is_alias(opt);
 
 	SLIST_FOREACH(entry, &head, entries) {
 		if (strcasecmp(entry->opt, opt) == 0)
 			return opt;
+		if (alias && strcasecmp(entry->opt, alias) == 0)
+			return opt;
+		if (alias && strcasecmp(alias, "fg") == 0) {
+			if (strcasecmp(entry->opt, "bg") == 0)
+				return opt;
+		}
+		if (alias && strcasecmp(alias, "bg") == 0) {
+			if (strcasecmp(entry->opt, "fg") == 0)
+				return opt;
+		}
 	}
 	return NULL;
 }
-- 
1.8.3.1

