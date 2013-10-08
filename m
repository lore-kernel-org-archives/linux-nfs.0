Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753581Ab3JHV34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Oct 2013 17:29:56 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r98LTuso031139
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 8 Oct 2013 17:29:56 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-53-5.rdu2.redhat.com [10.10.53.5])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r98LTtAo032123
	for <linux-nfs@vger.kernel.org>; Tue, 8 Oct 2013 17:29:56 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsmount.conf: remove duplicate 'timeo' from the parsing string
Date: Tue,  8 Oct 2013 17:30:25 -0400
Message-Id: <1381267825-27457-2-git-send-email-steved@redhat.com>
In-Reply-To: <1381267825-27457-1-git-send-email-steved@redhat.com>
References: <1381267825-27457-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the 'timeo' option is specified in multiple sections of
the nfsmount.conf file, each instance is added to the parsing
string. This patch make the first instance override any others.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/configfile.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 6985ed9..39d3741 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -186,8 +186,18 @@ char *lookup_entry(char *opt)
 {
 	struct entry *entry;
 	char *alias = is_alias(opt);
+	char *ptr;
 
 	SLIST_FOREACH(entry, &head, entries) {
+		/*
+		 * Only check the left side or options that use '='
+		 */
+		if ((ptr = strchr(entry->opt, '=')) != 0) {
+			int len = (int) (ptr - entry->opt);
+
+			if (strncasecmp(entry->opt, opt, len) == 0)
+				return opt;
+		}
 		if (strcasecmp(entry->opt, opt) == 0)
 			return opt;
 		if (alias && strcasecmp(entry->opt, alias) == 0)
-- 
1.8.3.1

