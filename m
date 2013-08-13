Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758274Ab3HMTUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 15:20:32 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKWup010158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:32 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKWOw010812
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:32 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7DJKVdH021437
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7DJKVwO021436
	for linux-nfs@vger.kernel.org; Tue, 13 Aug 2013 15:20:31 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 4/4] mount.nfs:  clean up conf_parse_mntopts()
Date: Tue, 13 Aug 2013 15:20:29 -0400
Message-Id: <1376421629-21382-5-git-send-email-smayhew@redhat.com>
In-Reply-To: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's no longer necessary for conf_parse_mntopts to explicitly check for
argtype != MNT_NOARG after calling should_add_noarg_opt().

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/mount/configfile.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 623c886..8f68a6e 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -364,15 +364,12 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 			}
 			continue;
 		}
-		if (argtype != MNT_NOARG) {
-			snprintf(buf, BUFSIZ, "no%s", field);
-			if (lookup_entry(buf) != NULL)
-				continue;
-			buf[0] = '\0';
-		}
+		snprintf(buf, BUFSIZ, "no%s", field);
+		if (lookup_entry(buf) != NULL)
+			continue;
+		buf[0] = '\0';
 		if (strcasecmp(value, "false") == 0) {
-			if (argtype != MNT_NOARG)
-				snprintf(buf, BUFSIZ, "no%s", field);
+			snprintf(buf, BUFSIZ, "no%s", field);
 		} else if (strcasecmp(value, "true") == 0) {
 			snprintf(buf, BUFSIZ, "%s", field);
 		} else {
-- 
1.7.11.7

