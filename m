Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893Ab3HON6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 09:58:18 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FDwHEM023533
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 09:58:17 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7FDwGGn022095
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 09:58:17 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7FDwGQj015437
	for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 09:58:16 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7FDwFJm015435
	for linux-nfs@vger.kernel.org; Thu, 15 Aug 2013 09:58:15 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mount.nfs: improve handling of bg, fg, and sloppy in nfsmount.conf
Date: Thu, 15 Aug 2013 09:58:15 -0400
Message-Id: <1376575095-15403-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch makes 2 small improvements to the parsing of the bg, fg, and
sloppy mount options in nfsmount.conf.

1. "bg" and "fg" negate should each other.  "Background=True" should
mean "bg" and "Background=False" should mean "fg".  The same applies to
"Foreground".

2. Once we see "Sloppy=False" while parsing the configuration file we
should ignore subsequent occurrences of the sloppy option.  This will
preserve the "right-most setting wins" behavior for the sloppy mount
option.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/mount/configfile.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 1f1b6e7..68b9f93 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -73,6 +73,8 @@ struct mnt_alias {
 };
 int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
 
+static int strict;
+
 /*
  * See if the option is an alias, if so return the 
  * real mount option along with the argument type.
@@ -310,7 +312,15 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		if (strcasecmp(value, "false") == 0) {
 			if (argtype != MNT_NOARG)
 				snprintf(buf, BUFSIZ, "no%s", field);
+			else if (strcasecmp(field, "bg") == 0)
+				snprintf(buf, BUFSIZ, "fg");
+			else if (strcasecmp(field, "fg") == 0)
+				snprintf(buf, BUFSIZ, "bg");
+			else if (strcasecmp(field, "sloppy") == 0)
+				strict = 1;
 		} else if (strcasecmp(value, "true") == 0) {
+			if ((strcasecmp(field, "sloppy") == 0) && strict)
+				continue;
 			snprintf(buf, BUFSIZ, "%s", field);
 		} else {
 			nvalue = strdup(value);
@@ -345,6 +355,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
 	char *ptr, *server, *config_opts;
 	int optlen = 0;
 
+	strict = 0;
 	SLIST_INIT(&head);
 	list_size = 0;
 	/*
-- 
1.7.11.7

